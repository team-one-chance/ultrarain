// =====================================
// NAVIGATION
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
// HP
// =====================================

ehp_max = 100;
ehp = ehp_max;


// =====================================
// HIT EFFECT
// =====================================

hit_duration = 0.15;
hit_timer = 0;

normal_sprite = sprite_index;
hit_sprite = sEnemy_hit;


// =====================================
// KNOCKBACK
// =====================================

knockback_duration = 0.2;
knockback_move_multiplier = 0.2;
knockback_decay = 0.8;

knockback_timer = 0;
knockback_x = 0;
knockback_y = 0;


// =====================================
// WALL CLIMBING
// =====================================

climb_speed = 150;
climb_wall_check_distance = 2;
climb_mantle_distance = 12;
ground_check_distance = 1;

// Prevents an attack from taking control during or immediately
// after climbing. This gives the enemy time to settle on the floor.
post_climb_attack_delay = 0.1;
post_climb_attack_timer = 0;

is_climbing = false;
climb_direction = 0;
climb_sprite = sEnemyClimb;


// =====================================
// DAMAGE FUNCTION
// =====================================

take_damage = function(
    _damage,
    _knockback_dir = 0,
    _knockback_force = 0,
    _is_sword = false
)
{
    var final_damage = _damage;

    // Sword hit during the enemy's dash
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
// GENERAL ATTACK DISTANCES
// =====================================

// Maximum feet-level Y difference for attacks.
attack_vertical_tolerance = 30;

// Charge can begin inside this X distance.
attack_trigger_x_distance = 90;


// =====================================
// CLOSE-RANGE ROCKING
// =====================================

// Enter rocking when almost directly aligned with the player.
attack_rock_enter_x_distance = 1;

// Leave rocking when the player moves this far away.
attack_rock_exit_x_distance = 90;

attack_rock_distance_min = 16;
attack_rock_distance_max = 36;

attack_rock_speed_min = 89;
attack_rock_speed_max = 125;

attack_rock_start_delay_min = 0;
attack_rock_start_delay_max = 0.25;

attack_rock_turn_delay_min = 0.05;
attack_rock_turn_delay_max = 0.25;

attack_rock_blocked_delay_min = 0.05;
attack_rock_blocked_delay_max = 0.2;

attack_rock_offset_min = -10;
attack_rock_offset_max = 10;

attack_rocking = false;
attack_rock_side = choose(-1, 1);

attack_rock_distance = random_range(
    attack_rock_distance_min,
    attack_rock_distance_max
);

attack_rock_speed = random_range(
    attack_rock_speed_min,
    attack_rock_speed_max
);

attack_rock_delay = random_range(
    attack_rock_start_delay_min,
    attack_rock_start_delay_max
);

attack_rock_offset = random_range(
    attack_rock_offset_min,
    attack_rock_offset_max
);

attack_sprite = sEnemyAttack;
bite_sprite = sEnemyBite;


// =====================================
// CHARGE ATTACK
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
// PARRY / STUN
// =====================================

parry_damage_multiplier = 2;
parry_stun_duration = 1.5;

stun_timer = 0;
stun_sprite = sEnemyStunned;
