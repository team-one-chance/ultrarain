// =====================================
// BASE BEAM — ONE COIN
// =====================================
// Start with the growth frames; Animation End loops only frames 10-16.
image_index = 0;
move_speed = 16;
move_dir = 0;
life = 1.5;

beam_base_damage = 40;
beam_base_knockback = 30;

// =====================================
// POWER ADDED BY EACH EXTRA FIELD COIN
// =====================================
beam_damage_per_extra_coin = 30;
beam_knockback_per_extra_coin = 60;
beam_size_per_extra_coin = 0.7;

// One coin: 40 damage, 30 knockback, normal size.

// Five coins: 120 damage, 270 knockback, 2.4x width AND height.
beam_coins_used = 1;
beam_damage = beam_base_damage;
knockback_force = beam_base_knockback;
beam_aoe_scale = 1;

beam_base_xscale = max(0.001, abs(image_xscale));
beam_base_yscale = max(0.001, abs(image_yscale));
beam_age = 0;
hit_enemies = ds_list_create();

// =====================================
// COIN POWER CONFIGURATION
// =====================================
configure_coin_beam = function(_count, _direction)
{
    beam_coins_used = max(1, floor(_count));
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
};
