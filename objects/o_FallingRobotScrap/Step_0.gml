	var _dt = max(0, (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000);
scrap_age += _dt;

// Out-of-room removal is spatial. Old debris is cleaned only out of sight.
// Losing the emitter does not delete an otherwise valid falling body.
if (x < -256 || x > room_width + 256 || y > room_height + 256
|| (scrap_age > scrap_offscreen_cleanup_age && scrap_is_offscreen()))
{
    instance_destroy();
    exit;
}

for (var _i = array_length(scrap_sparks) - 1; _i >= 0; _i--)
{
    var _spark = scrap_sparks[_i];
    _spark.life -= _dt;
    if (_spark.life <= 0)
    {
        array_delete(scrap_sparks, _i, 1);
        continue;
    }
    _spark.x += _spark.vx * _dt;
    _spark.y += _spark.vy * _dt;
    _spark.vy += 360 * _dt;
}

switch (scrap_state)
{
    case 0:
    {
        if (!scrap_emerged)
        {
            // Only the reveal through the hatch is scripted movement.
            y += scrap_vy * _dt + 0.5 * scrap_gravity * _dt * _dt;
            scrap_vy += scrap_gravity * _dt;
            if (y - 24 * scrap_size >= scrap_release_y)
            {
                scrap_emerged = true;
                scrap_draw_angle = scrap_release_angle;
                scrap_bind_physics();
            }
        }
        else
        {
            if (scrap_fixture == -1) scrap_bind_physics();
            phy_linear_velocity_y = min(phy_linear_velocity_y, scrap_max_fall_speed);
            scrap_draw_angle += scrap_spin * _dt;
        }
        break;
    }

    case 1:
    {
        scrap_stage_time += _dt;
        var _grind = clamp(scrap_stage_time / scrap_grind_duration, 0, 1);
        scrap_set_position(lerp(scrap_entry_x, scrap_grind_target_x, _grind),
            lerp(scrap_entry_y, scrap_grinder_center, _grind));
        scrap_draw_angle += 260 * _dt;
        image_xscale = scrap_flip * scrap_size * (1 - 0.6 * _grind);
        image_yscale = scrap_size * (1 - 0.85 * _grind);

        if (_grind >= 1)
        {
            scrap_draw_sprite = s_CrumpledRobot;
            sprite_index = s_CrumpledRobot;
            mask_index = s_CrumpledRobot;
            image_index = scrap_variant;
            image_xscale = scrap_flip * scrap_size;
            image_yscale = scrap_size;
            scrap_draw_angle = random(360);
            scrap_radius = 21 * scrap_size;
            scrap_set_position(x, scrap_grinder_bottom + scrap_visual_extent + 4);
            scrap_vx = random_range(-24, 24);
            scrap_vy = random_range(170, 230);
            scrap_spin = random_range(-160, 160);
            scrap_stage_time = 0;
            scrap_state = 2;
scrap_state = 2;
depth = scrap_normal_depth;

// Check whether there is actual lava beneath this robot.
var _lava_below = false;

for (var _j = 0; _j < instance_number(oMoltenLava); _j++)
{
    var _lava = instance_find(oMoltenLava, _j);

    if (x >= _lava.bbox_left
    && x <= _lava.bbox_right
    && _lava.bbox_bottom >= y)
    {
        _lava_below = true;
        break;
    }
}

// Robots over lava remain physical.
// Of those missing the lava, 10% remain physical.
var _physical = _lava_below || random(1) < 0.01;

if (_physical)
{
    // Bridge debris can damage the player on its first impact.
    scrap_can_damage = !_lava_below;
    scrap_hit_player = false;

    scrap_bind_physics();
}
else
{
    // State 4: background debris, without physical collision.
    scrap_state = 4;
    scrap_can_damage = false;
    scrap_stop_physics();

    var _player = instance_find(o_Player, 0);

    if (instance_exists(_player))
    {
        depth = _player.depth + 1;
    }
}

scrap_before_x = x;
scrap_before_y = y;
        }
        break;
    }

    case 2:
    {
        if (scrap_fixture == -1) scrap_bind_physics();
        phy_linear_velocity_y = min(phy_linear_velocity_y, scrap_max_fall_speed);
        scrap_draw_angle += scrap_spin * _dt;
        break;
    }
	
	case 4:
{
    scrap_vy = min(
        scrap_vy + scrap_gravity * _dt,
        scrap_max_fall_speed
    );

    scrap_set_position(
        x + scrap_vx * _dt,
        y + scrap_vy * _dt
    );

    scrap_draw_angle += scrap_spin * _dt;

    // Delete only once the whole sprite is below every visible camera.
    var _has_camera = false;
    var _below_all_cameras = true;

    for (var _view = 0; _view < 8; _view++)
    {
        if (!view_visible[_view]) continue;

        var _camera = view_camera[_view];
        if (_camera == -1) continue;

        _has_camera = true;

        var _camera_bottom =
            camera_get_view_y(_camera)
            + camera_get_view_height(_camera);

        if (y - scrap_visual_extent <= _camera_bottom + 32)
        {
            _below_all_cameras = false;
        }
    }

    if (_has_camera && _below_all_cameras)
    {
        instance_destroy();
        exit;
    }

    break;
}


    case 3:
    {
        scrap_stage_time += _dt;
        var _sink = clamp(scrap_stage_time / scrap_sink_duration, 0, 1);
        scrap_set_position(scrap_entry_x, scrap_entry_y + scrap_sink_depth * _sink);
        // Draw crops at the real lava surface. No fading into thin air.
        image_alpha = 1;
        if (_sink >= 1)
        {
            instance_destroy();
            exit;
        }
        break;
    }
}
