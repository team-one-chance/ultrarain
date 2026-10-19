image_speed = 0;
scrap_variant = irandom(min(sprite_get_number(s_DamagedRobot),
    sprite_get_number(s_CrumpledRobot)) - 1);
sprite_index = s_DamagedRobot;
mask_index = s_DamagedRobot;
scrap_draw_sprite = s_DamagedRobot;
image_index = scrap_variant;
image_angle = 0;
scrap_draw_angle = random_range(-25, 25);
scrap_size = random_range(1.15, 1.25);
scrap_flip = choose(-1, 1);
image_xscale = scrap_flip * scrap_size;
image_yscale = scrap_size;
scrap_radius = 21 * scrap_size;
scrap_visual_extent = ceil(24 * scrap_size * sqrt(2)) + 2;
scrap_normal_depth = depth;

scrap_emitter = noone;
scrap_release_y = -100000;
scrap_release_angle = scrap_draw_angle;
scrap_emerged = true;
scrap_can_damage = true;
scrap_hit_player = false;
scrap_contact_debugged = false;
scrap_damage = 50;
scrap_fall_speed_before = 0;
scrap_impact_played = false;

scrap_play_impact_sfx = function()
{
    // Settling piles and resting contacts must stay quiet.
    if (scrap_impact_played || !scrap_emerged || scrap_state != 0
        || abs(scrap_fall_speed_before) < 100) return;
    scrap_impact_played = true;
    var _player = instance_find(o_Player, 0);
    if (!instance_exists(_player)) return;
    if (_player.scrap_impact_sound != -1
        && audio_is_playing(_player.scrap_impact_sound)) return;
    _player.scrap_impact_sound = world_sfx_play(sfxLandingNoSlam, x, y,
        clamp(abs(scrap_fall_speed_before) / 600, 0.2, 0.55), 0.8, 480);
};

// 0 incoming, 1 grinding, 2 physical crushed scrap, 3 lava sinking.
scrap_state = 0;
scrap_vx = random_range(-18, 18);
scrap_vy = random_range(90, 150);
scrap_spin = random_range(-65, 65);
scrap_gravity = 780; // Only the short hatch-release animation uses manual gravity.
scrap_max_fall_speed = 1000;
scrap_age = 0;
scrap_stage_time = 0;
scrap_grind_duration = 0.3;
scrap_sink_duration = 0.85;
scrap_sink_depth = scrap_radius + scrap_visual_extent + 4;
scrap_entry_x = x;
scrap_entry_y = y;
scrap_grind_target_x = x;
scrap_grinder_top = 0;
scrap_grinder_bottom = 0;
scrap_grinder_center = 0;
scrap_lava_y = 0;
scrap_before_x = x;
scrap_before_y = y;
scrap_sparks = [];
scrap_fixture = -1;
scrap_needs_rebind = false;
scrap_surface = -1;
scrap_draw_camera = -1;
scrap_offscreen_cleanup_age = 45;

scrap_set_position = function(_x, _y)
{
    if (scrap_fixture != -1)
    {
        phy_position_x = _x;
        phy_position_y = _y;
    }
    else
    {
        x = _x;
        y = _y;
    }
};

scrap_bind_physics = function()
{
    var _x = x;
    var _y = y;
    if (scrap_fixture != -1)
    {
        physics_remove_fixture(id, scrap_fixture);
        scrap_fixture = -1;
    }
    var _fix = physics_fixture_create();
    physics_fixture_set_circle_shape(_fix, scrap_radius);
    physics_fixture_set_density(_fix, 1.5);
    physics_fixture_set_friction(_fix, 0.35);
    physics_fixture_set_restitution(_fix, 0.05);
    physics_fixture_set_linear_damping(_fix, 0.05);
    physics_fixture_set_angular_damping(_fix, 0.1);
    // Explicit collision events select player, ordinary blocks and other scrap.
    // Do not force collision with every group-1 hazard below the grinder.
    physics_fixture_set_collision_group(_fix, 0);
    scrap_fixture = physics_fixture_bind(_fix, id);
    physics_fixture_delete(_fix);
    phy_active = true;
    phy_fixed_rotation = true;
    phy_bullet = true;
    phy_position_x = _x;
    phy_position_y = _y;
    phy_linear_velocity_x = scrap_vx;
    phy_linear_velocity_y = scrap_vy;
};

scrap_stop_physics = function()
{
    if (scrap_fixture == -1) return;
    phy_linear_velocity_x = 0;
    phy_linear_velocity_y = 0;
    phy_active = false;
};

// Find a real surface crossed by the body's centre column. No global ground Y.
// Also detect an existing overlap, for a body pushed sideways into lava.
scrap_find_surface = function(_types, _surface_offset = 0)
{
    var _best = undefined;
    var _best_t = 2;
    var _dy = y - scrap_before_y;
    for (var _type_i = 0; _type_i < array_length(_types); _type_i++)
    {
        var _type = _types[_type_i];
        for (var _i = 0; _i < instance_number(_type); _i++)
        {
            var _surface = instance_find(_type, _i);
            var _top = _surface.bbox_top + _surface_offset;
			var _bottom = _surface.bbox_bottom + _surface_offset;
            var _t = -1;

            if (_dy > 0 && scrap_before_y + scrap_radius <= _top
            && y + scrap_radius >= _top)
            {
                _t = (_top - scrap_radius - scrap_before_y) / _dy;
            }
            else if (y + scrap_radius >= _top && y - scrap_radius <= _bottom)
            {
                _t = 1;
            }

            if (_t < 0 || _t > 1 || _t >= _best_t) continue;
            var _hit_x = lerp(scrap_before_x, x, _t);
            if (_hit_x < _surface.bbox_left || _hit_x > _surface.bbox_right) continue;

            _best_t = _t;
            _best = { object: _surface, hit_x: _hit_x, top_y: _top,
                bottom_y: _bottom, left_x: _surface.bbox_left,
                right_x: _surface.bbox_right };
        }
    }
    return _best;
};

scrap_start_grind = function(_hit)
{
    var _player = instance_find(o_Player, 0);
    if (instance_exists(_player) && (_player.scrap_crush_sound == -1
        || !audio_is_playing(_player.scrap_crush_sound)))
    {
        _player.scrap_crush_sound = world_sfx_play(sfxDoorBreaking,
            _hit.hit_x, _hit.top_y, 0.35, 0.85, 480);
    }
    scrap_stop_physics();
    scrap_can_damage = false;
    scrap_state = 1;
    scrap_stage_time = 0;
    scrap_grinder_top = _hit.top_y;
    scrap_grinder_bottom = _hit.bottom_y;
    scrap_grinder_center = (_hit.top_y + _hit.bottom_y) * 0.5;
    scrap_entry_x = _hit.hit_x;
    scrap_entry_y = _hit.top_y - scrap_radius;
    var _side = _hit.object.object_index == o_GrinderLeft ? -1 : 1;
    var _gear_center_x = (_hit.left_x + _hit.right_x) * 0.5;

scrap_grind_target_x = clamp(
    _gear_center_x + _side * 32,
    _hit.left_x + 8,
    _hit.right_x - 8
);
    depth = _hit.object.depth + 1;
    scrap_set_position(scrap_entry_x, scrap_entry_y);

    repeat (9)
    {
        array_push(scrap_sparks, { x: x + random_range(-6, 6),
            y: _hit.top_y + 6, vx: random_range(-125, 125),
            vy: random_range(-150, -30), life: random_range(0.18, 0.34),
            color: choose(make_color_rgb(191, 210, 222),
                make_color_rgb(109, 141, 163), make_color_rgb(157, 61, 77)) });
    }
};

scrap_start_sink = function(_hit)
{
    scrap_stop_physics();
    scrap_can_damage = false;
    scrap_state = 3;
    scrap_stage_time = 0;
    scrap_lava_y = _hit.top_y;
    scrap_entry_x = _hit.hit_x;
    scrap_entry_y = scrap_lava_y - scrap_radius;
    scrap_sink_depth = scrap_radius + scrap_visual_extent + 4;
    image_alpha = 1;
    depth = min(depth, _hit.object.depth - 1);
    scrap_set_position(scrap_entry_x, scrap_entry_y);
};

scrap_is_offscreen = function()
{
    var _has_view = false;
    var _margin = scrap_visual_extent + 160;
    for (var _i = 0; _i < 8; _i++)
    {
        if (!view_visible[_i] || view_camera[_i] == -1) continue;
        _has_view = true;
        var _cam = view_camera[_i];
        var _left = camera_get_view_x(_cam) - _margin;
        var _top = camera_get_view_y(_cam) - _margin;
        var _right = _left + camera_get_view_width(_cam) + _margin * 2;
        var _bottom = _top + camera_get_view_height(_cam) + _margin * 2;
        if (x >= _left && x <= _right && y >= _top && y <= _bottom) return false;
    }
    return _has_view;
};

scrap_release_draw_resources = function()
{
    if (surface_exists(scrap_surface)) surface_free(scrap_surface);
    scrap_surface = -1;
    if (scrap_draw_camera != -1) camera_destroy(scrap_draw_camera);
    scrap_draw_camera = -1;
};
