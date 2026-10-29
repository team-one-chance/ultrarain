event_inherited()

// =====================================
// COMBAT MOVEMENT
// =====================================
drone_engaged = false;
orbit_angle = irandom(359);
orbit_direction = choose(-1, 1);
orbit_speed = 140;
orbit_radius_x = 110;
orbit_radius_y = 45;
orbit_height = 110;
orbit_change_timer = random_range(1.2, 2.4);

// =====================================
// CHASE MOVEMENT
// =====================================
chase_angle = irandom(359);
chase_direction = choose(-1, 1);
chase_pattern_speed = 150;
chase_radius_x = 80;
chase_radius_y = 35;
chase_change_timer = random_range(0.8, 1.8);

// =====================================
// HIT EFFECT IS UNIQUE
// =====================================
hit_timer = 0;
hit_duration = 0.5;
normal_sprite = sprite_index;
hit_sprite = sDrone_hit;
// 0 = waiting, 1 = charging, 2 = firing burst
drone_fire_state = 0;
drone_ready = false;

drone_charge_duration = 0.8;
drone_charge_timer = 0;

// Aim stops tracking this long before each shot.
drone_aim_lock_duration = 0.2;
drone_shot_angle = 0;

// Maximum aiming rotation in degrees per second.
drone_aim_turn_speed = 110;

drone_burst_count = 2;
drone_shots_left = 0;
drone_shot_interval = 0.45;
drone_shot_timer = 0;
// One short oval blink per actual shot, including the last shot of the burst.
drone_shot_flash_duration = 0.07;
drone_shot_flash_timer = 0;

drone_shot_damage = 10;
drone_shot_range = 900;
drone_attack_distance = 420;

// Personal recovery and spacing between drones' turns.
var _drone_wait = enemy_difficulty == 0 ? 1.3 : (enemy_difficulty == 3 ? 0.55 : (enemy_difficulty == 2 ? 0.8 : 1));
drone_recovery_min = 1.2 * _drone_wait;
drone_recovery_max = 2.0 * _drone_wait;
drone_attack_cooldown = random_range(0.3, 1.0);

drone_turn_gap = 0.25;
drone_turn_wait = 0;
drone_attack_slots = 1; // Maximum drones charging or firing together in this room.
drone_launch_gap = 0; // Seconds between new windups; zero preserves normal turn-taking.

if (enemy_difficulty == 3)
{
    drone_attack_slots = 2; // Overlap two volleys to pressure dodges from different angles.
    drone_launch_gap = 0.16; // Seconds; stagger the two aiming warnings.
    drone_charge_duration = 0.55; // Seconds of visible warning before the first shot.
    drone_aim_lock_duration = 0.14; // Seconds of frozen aim before each shot; dodge window.
    drone_aim_turn_speed = 220; // Degrees/second; keep up with fast lateral movement.
    drone_burst_count = 4; // Shots per volley; each later shot tracks then locks again.
    drone_shot_interval = 0.28; // Seconds between shots, longer than the aim-lock window.
    drone_recovery_min = 0.35; // Seconds before this drone can begin another volley.
    drone_recovery_max = 0.65;
    drone_turn_gap = 0.10; // Seconds before another ready drone can take a vacant slot.
}

drone_separation_radius = 64;
drone_separation_speed = 120;

drone_fire_shot = function()
{
    drone_shot_flash_timer = drone_shot_flash_duration;
    var _sx = (bbox_left + bbox_right) * 0.5;
    var _sy = (bbox_top + bbox_bottom) * 0.5;

    world_sfx_play(sfxDroneShoot, _sx, _sy);

    var _trace = drone_trace(
        _sx, _sy,
        drone_shot_angle,
        drone_shot_range,
        true
    );

    if (instance_exists(_trace.hit))
    {
        if (_trace.hit.object_index == o_Player)
        {
            var _player = _trace.hit;

            _player.take_damage(drone_shot_damage, _sx, "red");
        }
    }

    var _visual = instance_create_depth(
        0, 0, depth - 1, o_HitscanVisual
    );

    _visual.line_x1 = _sx;
    _visual.line_y1 = _sy;
    _visual.line_x2 = _trace.end_x;
    _visual.line_y2 = _trace.end_y;
    _visual.line_color = c_red;
    _visual.life = 0.025;
};

// =====================================
// HP
// =====================================
ehp_max = 100;
ehp = ehp_max;

// =====================================
// KNOCKBACK/ GLOBAL OR UNIQUE DPENDING ON YOUR NEEDS
// =====================================
//knockback_duration = 0.2;
//knockback_move_multiplier = 0.2;
//knockback_decay = 0.8;
//knockback_timer = 0;
//knockback_x = 0;
//knockback_y = 0;
// SLAM TUNING
slam_knockback_multiplier = 0.75;
slam_knockback_duration = 0.18;
slam_stun_duration = 0.4;

slam_interrupt = function()
{
    path_end();
    repath_timer = 0;
};

drone_shot_pause_timer = 0;
drone_shot_pause_duration = 0.05;

// Preserve the inherited damage behavior.
drone_original_take_damage = take_damage;

take_damage = function(
    _damage,
    _knockback_dir = 0,
    _knockback_force = 0,
    _is_sword = false
)
{
    var _hp_before = ehp;

    if (_damage > 0)
    {
        drone_shot_pause_timer = max(
            drone_shot_pause_timer,
            drone_shot_pause_duration
        );
    }

    drone_original_take_damage(
        _damage,
        _knockback_dir,
        _knockback_force,
        _is_sword
    );

    if (instance_exists(id) && ehp > 0 && ehp < _hp_before)
    {
        world_sfx_play(sfxDroneHit, x, y);
    }
};

drone_frame_start_x = x;
drone_frame_start_y = y;

drone_bump_timer = 0;
drone_bump_duration = 0.4;
drone_bump_speed = 150;
drone_bump_velocity_x = 0;
drone_bump_velocity_y = 0;

// Keep the collision mask stable during hit animations.
mask_index = normal_sprite;
