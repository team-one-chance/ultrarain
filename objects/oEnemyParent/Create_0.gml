// =====================================
// NAVIGATION GLOBAL
// =====================================

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

take_damage = function(
    _damage,
    _knockback_dir = 0,
    _knockback_force = 0,
    _is_sword = false
)
{
    var final_damage = _damage;

    // STUN PROPERTIES, MUST ALSO SOMEHOW BE APPLIED TO MINIBOSS
	// UNIQUE TO ENEMYTEMP BUT YOU COULD REUSE IT FOR THE MINIBOSS
    if (_is_sword && attack_state == 3)
    {
        final_damage *= parry_damage_multiplier;

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
