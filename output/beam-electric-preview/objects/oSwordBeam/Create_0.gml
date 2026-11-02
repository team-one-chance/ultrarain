// =====================================
// BASE BEAM — ONE COIN
// =====================================
// Start with the growth frames; Animation End loops only frames 10-16.
image_index = 0;
move_speed = 16;
move_dir = 0;
life = 1.5;

beam_base_damage = 2* global.GLslash_damage;
beam_base_knockback = global.GLknockback_force;

// =====================================
// POWER ADDED BY EACH EXTRA FIELD COIN
// =====================================
beam_damage_per_extra_coin = beam_base_damage / 2;
beam_knockback_per_extra_coin = beam_base_knockback/1.5;
beam_size_per_extra_coin = 0.6;

// Electrical hit effects; only beams reaching the coin threshold apply these bonuses.
beam_electric_scout_stun = 2; // Seconds Scouts cannot attack after an electrical hit.
beam_electric_boss_stun = 1.5; // Seconds unshielded Breaker is stunned, including during attacks.
beam_electric_shield_bonus = 0.20; // Fraction of current beam damage added to the boss's shield, including rear hits.

// Electrical visual settings.
beam_lightning = false;
beam_lightning_coin_threshold = 4; // Consumed coins needed to replace the fire with electricity.
beam_lightning_refresh = 24; // Shape changes per second; higher values make the arcs flicker faster.
beam_lightning_segments = 12; // Segments per arc; higher values add finer zigzags.
beam_lightning_jitter = 2.5; // Unscaled room pixels of sideways arc movement.
beam_lightning_width = 1.5; // Unscaled room pixels for each arc's icy body.
beam_lightning_fork_length = 6; // Unscaled room pixels for the short branching sparks.
beam_lightning_blue = make_color_rgb(45, 125, 255); // Outer glow matches Bulletflash's lightning.
beam_lightning_ice = make_color_rgb(135, 220, 255); // Bright blue body around the white core.
beam_coins_used = 1;
beam_damage = beam_base_damage;
knockback_force = beam_base_knockback;
beam_aoe_scale = 1;

beam_base_xscale = max(0.001, abs(image_xscale));
beam_base_yscale = max(0.001, abs(image_yscale));
beam_age = 0;
hit_enemies = ds_list_create();

// Step calls this once per enemy; ordinary fire beams keep the normal damage response.
apply_beam_hit = function(_enemy)
{
    if (!instance_exists(_enemy)) return;
    var _damage = beam_damage;
    if (beam_lightning && (_enemy.object_index == oDrone
        || object_is_ancestor(_enemy.object_index, oDrone)))
    {
        // Remaining HP guarantees a kill through the drone's normal death effects.
        _damage = max(_damage, _enemy.ehp);
    }

    _enemy.take_damage(_damage, move_dir, knockback_force, false, x, true, beam_coins_used,
        beam_lightning ? beam_electric_shield_bonus : 0,
        beam_lightning ? beam_electric_boss_stun : 0);

    if (beam_lightning && instance_exists(_enemy) && _enemy.ehp > 0
        && (_enemy.object_index == oEnemy_Scout
            || object_is_ancestor(_enemy.object_index, oEnemy_Scout)))
    {
        _enemy.scout_receive_electric_stun(beam_electric_scout_stun);
    }
};

// =====================================
// COIN POWER CONFIGURATION
// =====================================
configure_coin_beam = function(_count, _direction)
{
    beam_coins_used = max(1, floor(_count));
    beam_lightning = beam_coins_used >= beam_lightning_coin_threshold;
    var _extra = beam_coins_used - 1;

    move_dir = _direction;
    beam_damage = beam_base_damage
        + beam_damage_per_extra_coin * _extra;
    knockback_force = beam_base_knockback
        + beam_knockback_per_extra_coin * _extra;
    beam_aoe_scale = max(
        0.001,
        1 + beam_size_per_extra_coin * _extra
    );

    var _facing = sign(lengthdir_x(1, move_dir));
    if (_facing == 0) _facing = 1;

    // Scale both the sprite and its actual enemy hit area.
    image_xscale = _facing * beam_base_xscale * beam_aoe_scale;
    image_yscale = beam_base_yscale * beam_aoe_scale;

    // Select the release cue after the consumed coin count is known.
    audio_play_sound(beam_lightning ? sfxSwordBeamMax : sfxSwordBeam, 1, false);
};

// Also used by the lighting renderer so the electrical core stays bright in dark rooms.
draw_electrical_beam = function()
{
    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();
    var _growth = clamp((image_index + 1) / 10, 0.1, 1); // First ten frames grow the original beam.
    var _left = bbox_left;
    var _top = bbox_top;
    var _width = max(1, bbox_right - bbox_left);
    var _height = max(1, bbox_bottom - bbox_top);
    var _center_x = (_left + bbox_right) * 0.5;
    var _center_y = (_top + bbox_bottom) * 0.5;
    var _facing = image_xscale >= 0 ? 1 : -1;
    var _scale = max(0.001, abs(image_yscale)) * _growth;
    var _tick = floor(beam_age * beam_lightning_refresh);
    var _segments = max(2, floor(beam_lightning_segments));

    // Three branching arcs form a crescent inside the existing damage area.
    for (var _arc = 0; _arc < 3; _arc++)
    {
        var _points = [];
        for (var _i = 0; _i <= _segments; _i++)
        {
            var _t = _i / _segments;
            var _envelope = sin(pi * _t); // Pin all arcs together at the upper and lower tips.
            var _noise = sin(_i * 12.9898 + _arc * 78.233 + _tick * 4.17 + x * 0.031 + y * 0.017);
            var _offset_x = _facing * _width
                * (-0.4 + _envelope * (0.65 + _arc * 0.12));
            _offset_x += _noise * beam_lightning_jitter * abs(image_xscale) * _envelope;
            array_push(_points, [
                _center_x + _offset_x * _growth,
                _center_y + (_t - 0.5) * _height * _growth
            ]);
        }

        // The same blue halo, icy body and white core as a Bulletflash bolt.
        for (var _layer = 0; _layer < 3; _layer++)
        {
            var _line_width = beam_lightning_width * _scale
                * (_layer == 0 ? 3 : (_layer == 1 ? 1 : 0.45));
            draw_set_color(_layer == 0 ? beam_lightning_blue
                : (_layer == 1 ? beam_lightning_ice : c_white));
            draw_set_alpha(image_alpha * (_layer == 0 ? 0.3 : 1));
            for (var _point = 1; _point < array_length(_points); _point++)
            {
                var _a = _points[_point - 1];
                var _b = _points[_point];
                draw_line_width(_a[0], _a[1], _b[0], _b[1], _line_width);
            }
        }

        draw_set_color(beam_lightning_ice);
        draw_set_alpha(image_alpha * 0.7);
        for (var _fork = 3; _fork < _segments; _fork += 4)
        {
            var _anchor = _points[_fork];
            var _side = ((_fork + _arc) mod 2) == 0 ? 1 : -1;
            var _fork_x = _anchor[0] - _facing * beam_lightning_fork_length * _scale;
            var _fork_y = _anchor[1] + _side * beam_lightning_fork_length * _scale;
            draw_line_width(_anchor[0], _anchor[1], _fork_x, _fork_y,
                beam_lightning_width * _scale * 0.4);
            draw_line_width(_fork_x, _fork_y,
                _fork_x + _facing * beam_lightning_fork_length * _scale * 0.3,
                _fork_y + _side * beam_lightning_fork_length * _scale * 0.5,
                beam_lightning_width * _scale * 0.2);
        }
    }

    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
};
