// =====================================
// NAVIGATION GLOBAL
// =====================================

// Direct room launches default to Normal. Children tune their own idle delays.
enemy_difficulty = variable_global_exists("game_difficulty") ? global.game_difficulty : 1;

var cell_size = 16;

nav_grid = mp_grid_create(
    0,
    0,
    ceil(room_width / cell_size),
    ceil(room_height / cell_size),
    cell_size,
    cell_size
);

enemy_path = path_add();
repath_timer = 0;

nav_grid_dirty = true;
nav_refresh = function()
{
    if (!nav_grid_dirty) return;
    mp_grid_clear_all(nav_grid);
    var _wall_padding = 12;
    var _wall_objects = [o_Block, o_Door_UNB, o_Door_Breakable, o_Chute_Breakable];
    for (var _i = 0; _i < array_length(_wall_objects); _i++)
    {
        with (_wall_objects[_i])
        {
            if (variable_instance_exists(id, "broken") && broken) continue;
            if (object_index == o_Door_UNB && door_state == 2) continue;
            mp_grid_add_rectangle(other.nav_grid,
                bbox_left - _wall_padding, bbox_top - _wall_padding,
                bbox_right + _wall_padding, bbox_bottom + _wall_padding);
        }
    }
    nav_grid_dirty = false;
};



// =====================================
// KNOCKBACK/ GLOBAL OR UNIQUE DPENDING ON YOUR NEEDS
// =====================================

knockback_duration = 0.2;
knockback_move_multiplier = 0.2;
knockback_decay = 0.8;

knockback_timer = 0;
knockback_x = 0;
knockback_y = 0;




// =====================================
// DAMAGE FUNCTION / GLOBAL
// =====================================

// Children can extend eligibility without changing the shared damage response.
can_parry = function() { return attack_state == 3; };

take_damage = function(
    _damage,
    _knockback_dir = 0,
    _knockback_force = 0,
    _is_sword = false
)
{
    var final_damage = _damage;

    if (_is_sword && can_parry())
    {
        final_damage *= parry_damage_multiplier;

        // Emit at the player-facing contact point, before a lethal hit removes us.
        var _parry_x = (bbox_left + bbox_right) * 0.5;
        var _parry_y = (bbox_top + bbox_bottom) * 0.5;
        var _player = instance_nearest(x, y, o_Player);
        if (_player != noone)
        {
            _parry_x = clamp((_player.bbox_left + _player.bbox_right) * 0.5, bbox_left, bbox_right);
            _parry_y = clamp((_player.bbox_top + _player.bbox_bottom) * 0.5, bbox_top, bbox_bottom);
        }
        instance_create_depth(_parry_x, _parry_y, depth - 1, o_ShotImpact,
            { impact_enemy: true, impact_parry: true, impact_direction: _knockback_dir });

        attack_state = 5;
        stun_timer = parry_stun_duration;

        attack_shake_x = 0;
        attack_shake_y = 0;

        is_climbing = false;
        path_end();
    }

    ehp -= final_damage;

    show_debug_message(
        "Enemy damaged: " + string(final_damage)
        + " | HP: " + string(ehp)
    );

    hit_timer = hit_duration;

    if (_knockback_force > 0)
    {
        path_end();

        knockback_timer = knockback_duration;

        knockback_x = lengthdir_x(
            _knockback_force,
            _knockback_dir
        );

        knockback_y = lengthdir_y(
            _knockback_force,
            _knockback_dir
        );
    }

    if (ehp <= 0)
    {
        instance_destroy();
    }
};


// =====================================
// GENERAL ATTACK DISTANCES / SHARED
// =====================================

// Maximum feet-level Y difference for attacks.
attack_vertical_tolerance = 30;

// Charge can begin inside this X distance.
attack_trigger_x_distance = 90;





// =====================================
// PARRY / STUN / SHARED
// =====================================

parry_damage_multiplier = 2;
parry_stun_duration = 1.5;

stun_timer = 0;
stun_sprite = sEnemyStunned;

// =====================================
// CHARGE ATTACK
// GLOBAL PROPERTIES SHARED WITH ALL ENEMIES, DO NOT TOUCH!!!
// =====================================

// 0 = chase
// 1 = move to attack distance
// 2 = charge
// 3 = dash
// 4 = return
// 5 = stunned after parry

attack_state = 0;

attack_cooldown_min = 5;
attack_cooldown_max = 8;

attack_cooldown = random_range(
    attack_cooldown_min,
    attack_cooldown_max
);

attack_stop_distance_min = 55;
attack_stop_distance_max = 90;

attack_stop_distance = random_range(
    attack_stop_distance_min,
    attack_stop_distance_max
);

attack_position_tolerance = 6;

attack_charge_duration = 0.55;
attack_dash_speed = 360;
attack_dash_overshoot = 16;
attack_return_speed = 720;

attack_shake_x_amount = 2;
attack_shake_y_amount = 1;

attack_side = choose(-1, 1);
attack_charge_timer = 0;

attack_origin_x = x;
attack_origin_y = y;
attack_target_x = x;

attack_shake_x = 0;
attack_shake_y = 0;

// =====================================
// SLAM RESPONSE: CHILDREN MAY OVERRIDE THESE DEFAULTS
// =====================================
slam_enabled = true;
slam_damage_multiplier = 1;
slam_knockback_multiplier = 1;
slam_knockback_duration = 0.22;
slam_knockback_drag = 8;
slam_stun_duration = 0.5;

slam_knockback_timer = 0;
slam_stun_timer = 0;
slam_velocity_x = 0;
slam_velocity_y = 0;

slam_interrupt = function()
{
    path_end();
};

slam_damage = function(_damage, _impact_x, _source)
{
    if (_damage > 0) take_damage(_damage, 0, 0, false);
};

take_slam = function(_damage, _speed, _impact_x, _impact_y, _source)
{
    enemy_receive_slam(_damage, _speed, _impact_x, _impact_y, _source);
};
