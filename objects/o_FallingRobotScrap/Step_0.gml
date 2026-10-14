var _dt = (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000;
scrap_age += _dt;
if (!instance_exists(scrap_emitter) || scrap_age > 12) {
    instance_destroy();
    exit;
}
for (var _i = 0; _i < array_length(scrap_sparks); _i++) {
    var _spark = scrap_sparks[_i];
    _spark.life -= _dt;
    _spark.x += _spark.vx * _dt;
    _spark.y += _spark.vy * _dt;
    _spark.vy += 360 * _dt;
}
var _radius = 21 * scrap_size;
switch (scrap_state) {
    case 0:
        var _next_x = x + scrap_vx * _dt;
        var _contact_y = scrap_grinder_top + 6 - _radius;
        var _next_y = min(_contact_y,
            y + scrap_vy * _dt + 0.5 * scrap_gravity * _dt * _dt);
        // Sweep the actual incoming sprite mask, so a slow frame cannot skip a hit.
        if (scrap_can_damage && !scrap_hit_player) {
            var _samples = max(1, ceil(max(abs(_next_x - x), abs(_next_y - y)) / 8));
            for (var _sample = 0; _sample <= _samples; _sample++) {
                var _sample_x = lerp(x, _next_x, _sample / _samples);
                var _sample_y = lerp(y, _next_y, _sample / _samples);
                var _player = instance_place(_sample_x, _sample_y, o_Player);
                if (_player != noone && (scrap_emerged || _player.bbox_bottom > scrap_release_y)
                    && _player.dmg_cooldown <= 0
                    && _player.take_damage(scrap_damage, _sample_x)) {
                    // Match the normal enemy bite/contact cooldown and hit effects.
                    _player.dmg_cooldown = 1;
                    scrap_hit_player = true;
                    break;
                }
            }
        }
        x = _next_x;
        y = _next_y;
        scrap_vy += scrap_gravity * _dt;
        if (y - 24 * scrap_size >= scrap_release_y) {
            if (!scrap_emerged) {
                image_angle = scrap_release_angle;
                scrap_emerged = true;
            }
            image_angle += scrap_spin * _dt;
        }
        if (y + _radius >= scrap_grinder_top + 6) {
            y = scrap_grinder_top + 6 - _radius;
            scrap_can_damage = false;
            // Visuals draw separately. With no sprite or mask, collision is gone.
            sprite_index = -1;
            mask_index = -1;
            scrap_entry_y = y;
            scrap_stage_time = 0;
            scrap_state = 1;
            // Small steel flecks at the point of contact.
            for (var _i = 0; _i < 9; _i++) {
                array_push(scrap_sparks, {
                    x: x + random_range(-6, 6),
                    y: scrap_grinder_top + 6,
                    vx: random_range(-125, 125),
                    vy: random_range(-150, -30),
                    life: random_range(0.18, 0.34),
                    color: choose(make_color_rgb(191, 210, 222),
                        make_color_rgb(109, 141, 163), make_color_rgb(157, 61, 77))
                });
            }
        }
        break;
    case 1:
        scrap_stage_time += _dt;
        var _grind = clamp(scrap_stage_time / scrap_grind_duration, 0, 1);
        y = lerp(scrap_entry_y, scrap_grinder_center, _grind);
        image_angle += 260 * _dt;
        image_xscale = scrap_flip * scrap_size * (1 - 0.6 * _grind);
        image_yscale = scrap_size * (1 - 0.85 * _grind);
        image_alpha = 1 - _grind;
        if (_grind >= 1) {
            // The matching crushed variant emerges beneath the gears.
            scrap_draw_sprite = s_CrumpledRobot;
            image_index = scrap_variant;
            image_xscale = scrap_flip * scrap_size;
            image_yscale = scrap_size;
            image_alpha = 1;
            image_angle = random(360);
            y = scrap_grinder_bottom + _radius + 4;
            scrap_vy = random_range(170, 230);
            scrap_spin = random_range(-160, 160);
            // Preserve horizontal velocity; scrap continues its original falling path.
            scrap_stage_time = 0;
            scrap_state = 2;
        }
        break;
    case 2:
        x += scrap_vx * _dt;
        y += scrap_vy * _dt + 0.5 * scrap_gravity * _dt * _dt;
        scrap_vy += scrap_gravity * _dt;
        image_angle += scrap_spin * _dt;
        if (y + _radius >= scrap_emitter.ground_y) {
            y = scrap_emitter.ground_y - _radius;
            scrap_entry_y = y;
            scrap_stage_time = 0;
            scrap_state = 3;
        }
        break;
    case 3:
        scrap_stage_time += _dt;
        var _sink = clamp(scrap_stage_time / scrap_sink_duration, 0, 1);
        y = scrap_entry_y + scrap_sink_depth * _sink;
        // Fade only after the body has started sinking into the ground.
        image_alpha = 1 - clamp((_sink - 0.35) / 0.65, 0, 1);
        if (_sink >= 1) instance_destroy();
        break;
}
