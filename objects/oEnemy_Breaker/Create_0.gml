event_inherited();

// Keep the placed miniboss body and room references; Breaker owns its movement.
enum BreakerState { CHASE, APPROACH, BASH, COOLDOWN, JUMP_CHARGE, RISE,
    SLAM_TURN, DIVE, LAND, LAND_RECOVERY, SHIELD_BREAK, STUN, GRAB, THROW }
mask_index = sMiniBoss;
image_speed = 0;
// Compare standing bodies; the shield extends above Breaker's head.
var _old_centre = (bbox_left + bbox_right) * 0.5;
var _old_feet = bbox_bottom;
breaker_scale = (sprite_get_height(s_Player) + 1) * 1.5
    / sprite_get_height(s_Breaker_idle_unshielded);
image_xscale = breaker_scale;
image_yscale = breaker_scale;
x += _old_centre - (bbox_left + bbox_right) * 0.5;
y += _old_feet - bbox_bottom;
breaker_state = BreakerState.CHASE;
breaker_time = 0;
breaker_animation_time = 0;
breaker_footstep_index = -1;
breaker_unshielded = false;
breaker_eyes_awake = false;
breaker_eye_light = undefined;
breaker_eye_color = breaker_attack_settings().eye_idle_color; // Current glow color, shared with deferred lighting.
breaker_eye_halo_radius = breaker_attack_settings().eye_halo_radius; // Sprite pixels; shared outer halo and room-light radius.
breaker_eye_core_halo_radius = breaker_attack_settings().eye_core_halo_radius; // Sprite pixels; shared inner halo radius.
breaker_eye_glow_scale = 1; // Current halo-radius multiplier; boosted during either melee parry window.
breaker_eye_glow_gain = 1; // Current halo-brightness multiplier; shared by eye drawing and room lighting.
breaker_eye_light_strength = 0.85;
breaker_eye_blink_start = 0.37;
breaker_eye_blink_slow_interval = 0.24;
breaker_eye_blink_fast_interval = 0.055;
breaker_break_pending = false;
breaker_hit_time = 0;
breaker_hit_elapsed = 0;
breaker_shield_flash_time = 0;
breaker_body_flash_time = 0;
breaker_shield_flash_duration = 0.12;
breaker_shield_flash_axis_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_shield_axis");
breaker_shield_flash_radius_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_shield_radius");
breaker_shield_flash_amount_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_flash");
breaker_body_flash_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_whole_body");
breaker_eye_axis_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_eye_axis");
breaker_eye_color_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_eye_color");
breaker_eye_radius_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_eye_radius");
breaker_eye_active_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_eye_active");
breaker_eye_only_uniform = shader_get_uniform(sh_BreakerShieldFlash, "u_eye_only");
breaker_beam_knockback_distance = 0;
breaker_beam_knockback_time = 0;
breaker_control_grace = 0;
breaker_control_grace_duration = 0.75;
breaker_stun_budget = 0;
breaker_stun_elapsed = 0;
breaker_bash_hit = false;
breaker_bash_serial = 0; // Attack counter; a parry press can only apply to the shield bash visible when pressed.
breaker_slide_turn_lock = 0; // Seconds remaining before turning after a slide under the body.
breaker_slide_turn_lock_duration = 0.8; // Seconds; longer gives the sliding player more time behind him.
breaker_slide_bash_lock = false; // Keep a committed melee facing fixed until it ends.
breaker_grab_target = noone;
breaker_grab_stabbed = false;
breaker_throw_flipped = false;
breaker_grab_hand = [[64,25], [65,17], [65,17], [65,17], [65,17], [52,26], [58,22], [64,20], [64,22], [64,22], [64,22], [64,22]]; // Cropped sprite pixels, grab frames 2-13.
breaker_throw_hand = [[68,25], [63,20], [44,6], [44,6], [63,9], [79,27]]; // Cropped sprite pixels, throw frames 2-7.
breaker_throw_speed = 10; // Physics speed in pixels per game frame; higher throws farther.
breaker_throw_lift = 5; // Upward physics speed in pixels per game frame.
breaker_leap_hit = false;
breaker_intercept = false;
breaker_landed = false;
breaker_shield_debris_spawned = false;
breaker_shield_break_sound = -1;
breaker_bash_sound = -1; // Playback handle for this Breaker's current bash; stop it if that bash is parried.
breaker_stop_bash_sound = function() {
    if (breaker_bash_sound == -1) return;
    audio_stop_sound(breaker_bash_sound);
    breaker_bash_sound = -1;
};
breaker_hit_sounds = [];
breaker_play_hit_sound = function(_asset = sfxBreakerHit) {
    if (breaker_shield_break_sound != -1 && audio_is_playing(breaker_shield_break_sound)) return;
    for (var _i = array_length(breaker_hit_sounds) - 1; _i >= 0; _i--) {
        if (!audio_is_playing(breaker_hit_sounds[_i])) array_delete(breaker_hit_sounds, _i, 1);
    }
    var _gain = _asset == sfxBreakerHitNoShield ? 2 : 1.25;
    // Impacts are combat feedback: remain audible across the pistol's range.
    var _sound = world_sfx_play(_asset, x, y, _gain, 1, 2560);
    if (_sound != -1) array_push(breaker_hit_sounds, _sound);
};
facing_direction = 1;
breaker_source_direction = 1;
// Registration in the original 128x216 export canvas, before cropping.
breaker_anchor_x = 64;
breaker_anchor_y = 208;
breaker_crop_offsets = {};
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbash), [11, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_block), [41, 116]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_bashcooldown), [27, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_idle), [42, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jump), [39, 86]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jumpcharge), [42, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_land), [2, 83]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_landrecovery), [41, 120]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam), [2, 83]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_trans), [3, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk_block), [31, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk), [31, 118]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbreak), [36, 126]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_shieldbash_unshielded), [6, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_block_unshielded), [40, 126]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_bashcooldown_unshielded), [27, 130]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_idle_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_grab_unshielded), [34, 126]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_throw_unshielded), [30, 123]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jump_unshielded), [45, 104]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_jumpcharge_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_land_unshielded), [5, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_landrecovery_unshielded), [19, 82]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_unshielded), [29, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_slam_trans_unshielded), [1, 74]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_unshielded), [50, 135]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_enter_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_stun_exit_unshielded), [42, 128]);
variable_struct_set(breaker_crop_offsets, sprite_get_name(s_Breaker_walk_unshielded), [32, 128]);

breaker_foot_offsets = {};
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_trans), [109, 108, 106, 107, 108, 108, 108]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_trans_unshielded), [101, 96, 96, 94, 94, 104, 115]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam), [99]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_slam_unshielded), [115, 115, 115]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_land), [99, 96, 90, 90, 94, 90]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_land_unshielded), [115, 105, 95, 95, 95, 95, 95, 82, 82, 82, 82]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_landrecovery), [88, 88, 88, 88, 88]);
variable_struct_set(breaker_foot_offsets, sprite_get_name(s_Breaker_landrecovery_unshielded), [79, 80, 81, 76, 76]);

// Eye axes sampled from the visible visor pixels of each cropped frame.
breaker_eye_axes = {};
// Shielded attack visor positions in cropped sprite pixels; sampled from each frame.
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_jumpcharge), [[35.5, 20.5, 38.5, 20.5], [38.5, 25.5, 41.5, 25.5], [39.5, 28.5, 42.5, 28.5], [40.5, 31.5, 43.5, 31.5], [41.5, 34.5, 44.5, 34.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [42.5, 36.5, 45.5, 36.5], [44.5, 40.5, 46.5, 40.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_jump), [[47.5, 72.5, 49.5, 72.5], [44.5, 54.5, 47.5, 54.5], [43.5, 36.5, 43.5, 39.5], [43.5, 36.5, 43.5, 39.5], [43.5, 36.5, 43.5, 39.5], [42.5, 38.5, 45.5, 38.5], [43.5, 38.5, 46.5, 38.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_slam_trans), [[43.5, 38.5, 46.5, 38.5], [45.5, 39.5, 48.5, 39.5], [48.5, 42.5, 51.5, 42.5], [50.5, 43.5, 53.5, 43.5], [52.5, 45.5, 55.5, 45.5], [55.5, 46.5, 55.5, 49.5], [55.5, 49.5, 58.5, 50.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_slam), [[56.5, 40.5, 59.5, 41.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_land), [[56.5, 40.5, 59.5, 41.5], [56.5, 40.5, 59.5, 41.5], [56.5, 40.5, 59.5, 41.5], [56.5, 40.5, 59.5, 41.5], [56.5, 49.5, 58.5, 49.5], [56.5, 40.5, 59.5, 41.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_shieldbash), [[36.5, 20.5, 39.5, 20.5], [36.5, 24.5, 39.5, 24.5], [36.5, 24.5, 39.5, 24.5], [36.5, 24.5, 39.5, 24.5], [36.5, 24.5, 39.5, 24.5], [36.5, 24.5, 39.5, 24.5], [50.5, 24.5, 53.5, 24.5], [64.5, 24.5, 67.5, 24.5], [65.5, 25.5, 68.5, 25.5], [66.5, 26.5, 68.5, 26.5], [65.5, 25.5, 68.5, 25.5], [64.5, 24.5, 67.5, 24.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_shieldbreak), [[28.5, 8.5, 31.5, 7.5], [35.5, 8.5, 38.5, 8.5], [36.5, 9.5, 39.5, 9.5], [36.5, 9.5, 39.5, 9.5], [38.5, 11.5, 41.5, 11.5], [39.5, 11.5, 42.5, 11.5], [39.5, 11.5, 42.5, 11.5], [39.5, 11.5, 42.5, 11.5], [39.5, 11.5, 42.5, 11.5], [40.5, 11.5, 43.5, 12.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [41.5, 13.5, 43.5, 14.5], [40.5, 11.5, 43.5, 12.5], [39.5, 11.5, 42.5, 11.5], [38.5, 10.5, 41.5, 10.5], [39.5, 11.5, 42.5, 12.5], [41.5, 12.5, 44.5, 12.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_idle_unshielded), [[35.5, 10.5, 38.5, 10.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_walk_unshielded), [[45.5, 11.5, 48.5, 11.5], [45.5, 12.5, 48.5, 12.5], [45.5, 13.5, 48.5, 13.5], [45.5, 12.5, 48.5, 12.5], [45.5, 11.5, 48.5, 11.5], [45.5, 11.5, 48.5, 11.5], [45.5, 10.5, 48.5, 10.5], [45.5, 10.5, 48.5, 10.5], [45.5, 11.5, 48.5, 11.5], [45.5, 11.5, 48.5, 11.5], [45.5, 11.5, 48.5, 11.5], [45.5, 10.5, 48.5, 10.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_block_unshielded), [[35.5, 11.5, 38.5, 11.5], [33.5, 9.5, 36.5, 9.5], [37.5, 12.5, 40.5, 12.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_shieldbash_unshielded), [[41.5, 10.5, 44.5, 10.5], [41.5, 14.5, 44.5, 14.5], [41.5, 14.5, 44.5, 14.5], [41.5, 14.5, 44.5, 14.5], [41.5, 14.5, 44.5, 14.5], [41.5, 14.5, 44.5, 14.5], [55.5, 14.5, 58.5, 14.5], [69.5, 14.5, 72.5, 14.5], [70.5, 14.5, 73.5, 15.5], [71.5, 16.5, 73.5, 17.5], [70.5, 14.5, 73.5, 15.5], [69.5, 14.5, 72.5, 14.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_bashcooldown_unshielded), [[48.5, 12.5, 51.5, 12.5], [48.5, 12.5, 51.5, 12.5], [48.5, 12.5, 51.5, 12.5], [48.5, 12.5, 51.5, 12.5], [48.5, 12.5, 51.5, 12.5], [48.5, 12.5, 51.5, 12.5], [48.5, 11.5, 51.5, 11.5], [48.5, 11.5, 51.5, 11.5], [48.5, 10.5, 51.5, 10.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_jumpcharge_unshielded), [[35.5, 10.5, 38.5, 10.5], [38.5, 15.5, 41.5, 15.5], [39.5, 18.5, 42.5, 18.5], [40.5, 21.5, 43.5, 21.5], [41.5, 24.5, 44.5, 24.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [42.5, 26.5, 45.5, 26.5], [43.5, 27.5, 46.5, 28.5], [44.5, 30.5, 46.5, 31.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_jump_unshielded), [[41.5, 54.5, 43.5, 55.5], [38.5, 36.5, 41.5, 36.5], [38.5, 19.5, 35.5, 20.5], [38.5, 19.5, 35.5, 20.5], [38.5, 19.5, 35.5, 20.5], [36.5, 20.5, 38.5, 20.5], [37.5, 21.5, 40.5, 20.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_slam_trans_unshielded), [[45.5, 39.5, 48.5, 38.5], [58.5, 48.5, 60.5, 48.5], [68.5, 60.5, 69.5, 61.5], undefined, undefined, [73.5, 80.5, 73.5, 83.5], [70.5, 85.5, 70.5, 88.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_slam_unshielded), [[42.5, 85.5, 42.5, 88.5], [42.5, 85.5, 42.5, 88.5], [42.5, 85.5, 42.5, 88.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_land_unshielded), [[66.5, 85.5, 66.5, 88.5], [73.5, 76.5, 73.5, 77.5], [79.5, 62.5, 80.5, 65.5], [79.5, 62.5, 80.5, 65.5], [79.5, 62.5, 80.5, 65.5], [79.5, 62.5, 80.5, 65.5], [79.5, 62.5, 80.5, 65.5], [79.5, 62.5, 80.5, 65.5], [80.5, 65.5, 79.5, 62.5], [80.5, 65.5, 79.5, 62.5], [80.5, 65.5, 79.5, 62.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_landrecovery_unshielded), [[71.5, 42.5, 69.5, 39.5], [64.5, 32.5, 67.5, 34.5], [62.5, 24.5, 64.5, 27.5], [57.5, 18.5, 60.5, 20.5], [52.5, 10.5, 55.5, 10.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_stun_enter_unshielded), [[35.5, 10.5, 38.5, 10.5], [39.5, 13.5, 41.5, 14.5], [41.5, 15.5, 44.5, 17.5], [42.5, 18.5, 44.5, 20.5], [45.5, 22.5, 46.5, 24.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_stun_unshielded), [[37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 13.5, 39.5, 16.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5], [37.5, 15.5, 38.5, 17.5]]);
variable_struct_set(breaker_eye_axes, sprite_get_name(s_Breaker_stun_exit_unshielded), [[45.5, 22.5, 46.5, 24.5], [42.5, 18.5, 44.5, 20.5], [41.5, 15.5, 44.5, 17.5], [39.5, 13.5, 41.5, 14.5], [35.5, 10.5, 38.5, 10.5]]);

// Shield stripe axes in cropped sprite pixels, indexed by animation frame.
breaker_shield_axes = {};
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_idle), [[60.00, 3.50, 60.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_block), [[55.00, 5.50, 55.00, 89.50], [50.18, 3.67, 60.22, 86.28], [57.50, 6.50, 58.60, 90.51], [62.00, 7.50, 62.00, 91.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_walk), [[71.00, 4.50, 71.00, 88.50], [71.00, 4.50, 71.00, 88.50], [71.00, 6.50, 71.00, 90.50], [71.00, 5.50, 71.00, 89.50], [71.00, 4.50, 71.00, 88.50], [71.00, 3.50, 71.00, 87.50], [71.00, 3.50, 71.00, 87.50], [71.00, 4.50, 71.00, 88.50], [71.00, 6.50, 71.00, 90.50], [71.00, 4.50, 71.00, 88.50], [71.00, 3.50, 71.00, 87.50], [71.00, 3.50, 71.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_walk_block), [[65.00, 3.50, 65.00, 87.50], [63.00, 3.50, 63.00, 87.50], [64.00, 5.50, 64.00, 89.50], [64.00, 5.50, 64.00, 89.50], [65.00, 4.50, 65.00, 88.50], [64.00, 3.50, 64.00, 87.50], [63.00, 3.50, 63.00, 87.50], [65.00, 4.50, 65.00, 88.50], [64.00, 6.50, 64.00, 90.50], [63.00, 4.50, 63.00, 88.50], [62.00, 5.50, 62.00, 89.50], [64.00, 4.50, 64.00, 88.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_shieldbash), [[61.00, 3.50, 61.00, 87.50], [56.48, 5.64, 65.93, 89.20], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [61.00, 6.50, 61.00, 90.50], [75.00, 5.50, 75.00, 89.50], [89.00, 4.50, 89.00, 88.50], [89.00, 5.50, 89.00, 89.50], [92.00, 5.50, 92.00, 89.50], [92.00, 5.50, 92.00, 89.50], [92.00, 5.50, 92.00, 89.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_bashcooldown), [[76.00, 5.50, 76.00, 89.50], [75.00, 4.50, 75.00, 88.50], [75.00, 3.50, 75.00, 87.50], [75.00, 3.50, 75.00, 87.50], [75.00, 3.50, 75.00, 87.50], [70.00, 4.50, 70.00, 88.50], [63.86, 88.52, 65.95, 4.50], [63.00, 4.50, 63.00, 88.50], [62.00, 3.50, 62.00, 87.50]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_jumpcharge), [[60.00, 3.50, 60.00, 87.50], [56.47, 5.64, 65.90, 89.32], [54.88, 4.99, 67.64, 88.24], [53.68, 6.23, 70.90, 88.85], [51.89, 6.42, 72.89, 88.64], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 7.92, 75.60, 88.18], [51.07, 9.92, 75.60, 90.18]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_jump), [[54.07, 41.92, 78.60, 122.18], [28.78, 15.45, 97.47, 64.20], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00], [3.50, 6.00, 87.50, 6.00]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_slam_trans), [[3.50, 6.00, 87.50, 6.00], [9.53, 7.79, 93.44, 14.54], [16.94, 7.20, 99.90, 21.71], [23.69, 6.86, 105.20, 30.54], [31.67, 7.91, 109.88, 40.19], [40.07, 9.81, 114.39, 49.22], [47.51, 9.83, 116.82, 57.70]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_slam), [[48.51, 0.83, 117.82, 48.70]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_land), [[48.51, 0.83, 117.82, 48.70], [48.51, 0.83, 117.82, 48.70], [48.51, 0.83, 117.82, 48.70], [81.29, 90.43, 88.33, 6.54], [81.29, 94.43, 88.33, 10.54], [81.29, 90.43, 88.33, 6.54]]);
variable_struct_set(breaker_shield_axes, sprite_get_name(s_Breaker_landrecovery), [[70.29, 88.43, 77.33, 4.54], [69.86, 88.52, 71.95, 4.50], [68.00, 4.50, 68.00, 88.50], [66.00, 3.50, 66.00, 87.50], [62.50, 3.50, 63.60, 87.51]]);

// Existing combat tuning is retained; animation timing now controls each action.
// A deliberate chase pace; the player base run is 264 px/s.
ground_move_speed = 180;
// Approximate authored stride, scaled into room pixels.
breaker_walk_cycle_distance = 144 * breaker_scale;
normal_attack_approach_speed = ground_move_speed;
// Hard mode makes the shield-break phase a sharper escalation.
breaker_unshielded_move_multiplier = enemy_difficulty >= 2 ? 1.45 : 1.2;
breaker_unshielded_damage_multiplier = enemy_difficulty >= 2 ? 1.5 : 1.25;
breaker_unshielded_cooldown_multiplier = enemy_difficulty >= 2 ? 0.45 : 0.6;
// The narrow core allows overlap with the outside of the visible silhouette.
breaker_body_core_fraction = 0.36;
breaker_body_height_fraction = 0.8; // Keep the feet fixed; lower the blocking top.
breaker_body_soft_margin = 12;
gravity_force = 900;
maximum_fall_speed = 500;
vertical_speed = 0;
ground_check_distance = 1;
is_grounded = false;
ehp_max = 1000;
ehp = ehp_max;
shield_hp_max = ehp_max * (enemy_difficulty == 3 ? 0.5 : 0.25); // Shield health as a fraction of boss health; Futile retains its tuning.
shield_hp = shield_hp_max;
breaker_parry_shield_fraction = 0.05; // Fraction of maximum shield HP lost per full parry; ignores weapon damage multipliers.
breaker_parry_stun_seconds = 1; // Full-parry stun duration in seconds; does not grant player healing.
breaker_half_parry_push_speed = 3.25; // Player movement speed units; larger values push the player farther on a half parry.
breaker_half_parry_push_seconds = 0.12; // Seconds of horizontal push; larger values lengthen the knockback.
shield_bar_width = 28;
shield_bar_height = 3;
shield_bar_y_offset = 12;
shield_front_bullet_multiplier = 0.10;
shield_front_sword_multiplier = 5;
shield_front_beam_multiplier = 1;
// One through four coins: very little, little, moderate, relatively large.
shield_beam_knockback_distances = [4, 12, 28, 56];
shield_beam_knockback_duration = 0.12;
phase2_bullet_damage_multiplier = 2;
phase2_sword_damage_multiplier = 1;
phase2_beam_damage_multiplier = 1;
back_damage_multiplier = 1;
hit_duration = 0.5;
hit_timer = 0;
normal_attack_damage = 12;
normal_attack_range = 36;
normal_attack_vertical_tolerance = 30;
var _breaker_wait = enemy_difficulty == 0 ? 1.75 : (enemy_difficulty == 3 ? 0.6 : (enemy_difficulty == 2 ? 0.85 : 1.4)); // Longer attack intervals on Easy and Normal.
normal_attack_cooldown_min = 0.6 * _breaker_wait;
normal_attack_cooldown_max = 0.9 * _breaker_wait;
normal_attack_cooldown = random_range(normal_attack_cooldown_min, normal_attack_cooldown_max);
stand_range = 85;
// Human frame numbers: both melee lunges use frames 7-9; contact follows the configured frame boundary.
breaker_bash_first_frame = 7;
breaker_bash_last_frame = 9;
breaker_bash_distance = 24;
breaker_attack_speed = 1.0; // Unitless melee attack-speed multiplier: 1 = current speed, 2 = twice as fast, 0.5 = half speed; minimum 0.01.
leap_damage = 20;
leap_trigger_min_distance = 260;
leap_trigger_max_distance = 720;
leap_vertical_tolerance = 90;
leap_jump_speed = -560;
leap_launch_speed = leap_jump_speed;
// Higher difficulties cover more ground and accelerate into the slam faster.
var _leap_travel_scale = enemy_difficulty == 3 ? 1.55 : (enemy_difficulty == 2 ? 1.3 : 1);
var _slam_speed_scale = enemy_difficulty == 3 ? 1.4 : (enemy_difficulty == 2 ? 1.2 : 1);
leap_max_horizontal_speed = 520 * _leap_travel_scale;
leap_fall_gravity_multiplier = 4 * _slam_speed_scale;
leap_max_fall_speed = 1200 * _slam_speed_scale;
leap_landing_range = 48;
leap_landing_height = 20;
leap_cooldown_min = 5 * _breaker_wait;
leap_cooldown_max = 7 * _breaker_wait;
leap_cooldown = 0; // Ready to punish a distant player immediately.
leap_target_x = x;
breaker_jump_charge_duration = 0.625;
breaker_intercept_range = 300;
breaker_intercept_min_height = 30;
breaker_intercept_max_height = 420;
breaker_intercept_max_jump_speed = 900;
breaker_intercept_prediction_time = 0.20;
breaker_intercept_max_lead = 80;
// Close-range aerial intercepts are occasional on Futile; distant slams
// retain their own shorter cooldown to punish players who stay away.
breaker_intercept_cooldown_duration = enemy_difficulty == 3 ? 9 : 2 * _breaker_wait;
breaker_intercept_cooldown = 0;
// Fit the entire turn to the apex instead of hovering for the authored duration.
breaker_turn_duration = 0.18;
breaker_land_lead = 0.08;
// Shared impact-to-chase timing; both phases play every frame within this budget.
breaker_land_duration = 0.30;
breaker_land_recovery_duration = 0.25;
slam_knockback_multiplier = 0.35;
slam_knockback_duration = 0.16;
slam_stun_duration = 0.2;
slam_shield_damage_multiplier = 1;
phase2_slam_damage_multiplier = 1;

breaker_bash_windup_seconds = function() {
    return breaker_attack_settings().melee_base_windup_seconds
        / max(0.01, breaker_attack_speed); // Scale anticipation with the same multiplier as the swing and follow-through.
};
breaker_bash_animation_duration = function() {
    var _bash = breaker_sprite(s_Breaker_shieldbash, s_Breaker_shieldbash_unshielded);
    var _authored_windup = (breaker_bash_first_frame - 1) / breaker_fps(_bash); // Seconds occupied by the original anticipation frames.
    return breaker_bash_windup_seconds() + breaker_duration(_bash) - _authored_windup; // Actual playback seconds; every part follows breaker_attack_speed.
};
breaker_melee_parry_timing = function() {
    var _settings = breaker_attack_settings();
    var _warning_start = 0; // Both phases begin their blinking warning on the first animation frame.
    var _animation_end = breaker_bash_animation_duration(); // Full playback duration in seconds, including follow-through.
    var _bash = breaker_sprite(s_Breaker_shieldbash, s_Breaker_shieldbash_unshielded);
    var _contact_frame = clamp(breaker_unshielded
        ? _settings.unshielded_contact_frame : _settings.shielded_contact_frame,
        breaker_bash_first_frame, sprite_get_number(_bash)); // Human frame number; contact happens when this frame begins.
    var _followthrough_frames = sprite_get_number(_bash) - (_contact_frame - 1); // Frames from contact onward remain visual follow-through.
    var _window_end = _animation_end - _followthrough_frames / breaker_fps(_bash); // Seconds from attack entry until impact.
    return {
        warning_start_seconds: _warning_start, // Seconds from attack entry when the blinking warning begins.
        start_seconds: lerp(_warning_start, _window_end, _settings.melee_warning_fraction), // Seconds from attack entry halfway through the shortened window: active parrying opens.
        end_seconds: _window_end // Seconds from attack entry when the parry window closes and an unblocked attack lands.
    };
};
breaker_melee_parry_open = function() {
    if (breaker_state != BreakerState.BASH || breaker_bash_hit) return false;
    var _window = breaker_melee_parry_timing();
    return breaker_time >= _window.start_seconds && breaker_time < _window.end_seconds;
};
breaker_can_melee_parry = function(_player, _parry_state) {
    if (breaker_state != BreakerState.BASH || breaker_bash_hit
        || !instance_exists(_player)) return false;
    var _phase_parry = breaker_unshielded ? ParryState.HALF : ParryState.FULL;
    if (_parry_state != _phase_parry) return false;
    // Use the window the player saw when pressing, independent of player/enemy Step order.
    for (var _i = 0; _i < array_length(_player.parry_breaker_windows); ++_i) {
        var _record = _player.parry_breaker_windows[_i];
        if (_record.boss == id && _record.bash_serial == breaker_bash_serial)
            return _record.parry_state == _parry_state;
    }
    return false;
};
breaker_evade_cue_active = function() {
    var _warning_start = max(0, breaker_jump_charge_duration - breaker_attack_settings().warning_seconds);
    return (breaker_state == BreakerState.JUMP_CHARGE && breaker_time >= _warning_start)
        || breaker_contact_active();
};
breaker_eye_warning_blink = function(_warning_time) {
    var _settings = breaker_attack_settings();
    return (_warning_time mod _settings.warning_blink_period)
        < _settings.warning_blink_period * _settings.warning_blink_duty;
};
// Reuse the exact cropped-frame registration used to draw the body.
breaker_update_eye_glow = function(_draw_x, _draw_y, _scale_x) {
    breaker_eye_light = undefined;
    var _settings = breaker_attack_settings();
    breaker_eye_color = _settings.eye_idle_color;
    breaker_eye_glow_scale = 1;
    breaker_eye_glow_gain = 1;
    var _evade_warning = breaker_evade_cue_active(); // Slam warning applies with or without the shield.
    var _bash_warning = breaker_state == BreakerState.BASH && !breaker_bash_hit;
    var _melee_window = breaker_melee_parry_timing();
    var _melee_warning_start = _melee_window.warning_start_seconds;
    _bash_warning = _bash_warning && breaker_time >= _melee_warning_start
        && breaker_time < _melee_window.end_seconds;
    if (_evade_warning) {
        var _warning_brightness = 1; // Steady red once the slam launches.
        if (breaker_state == BreakerState.JUMP_CHARGE) {
            var _warning_time = breaker_time - max(0, breaker_jump_charge_duration - _settings.warning_seconds);
            _warning_brightness = breaker_eye_warning_blink(_warning_time) ? 1 : _settings.warning_glow_minimum;
        }
        breaker_eye_color = merge_color(c_black, _settings.evade_color, _warning_brightness);
    }
    else if (_bash_warning) {
        var _color = breaker_unshielded ? _settings.block_color : _settings.full_color;
        var _pulse = 1; // Hold the attack color steady throughout its parry window.
        if (breaker_time < _melee_window.start_seconds) {
            var _blink_time = breaker_time - _melee_warning_start; // Seconds since the green/yellow blinking half began.
            var _blink_period = _settings.melee_blink_period / max(0.01, breaker_attack_speed); // Seconds per blink at the current attack speed.
            var _blink_on = (_blink_time mod _blink_period)
                < _blink_period * _settings.melee_blink_duty;
            if (breaker_unshielded) {
                // Replace the red idle glow with full yellow, then switch back to red between blinks.
                _color = _blink_on ? _settings.block_color : _settings.eye_idle_color;
            }
            else {
                _pulse = _blink_on ? 1 : _settings.warning_glow_minimum;
            }
        }
        else {
            breaker_eye_glow_scale = _settings.melee_glow_scale;
            breaker_eye_glow_gain = _settings.melee_glow_gain;
        }
        breaker_eye_color = _pulse == 1 ? _color : merge_color(c_black, _color, _pulse);
    }
    // Shielded attacks must show their cues too; phase two also glows between attacks.
    breaker_eyes_awake = breaker_unshielded || _evade_warning || _bash_warning;
    if (breaker_state == BreakerState.SHIELD_BREAK) {
        var _transition_duration = breaker_duration(s_Breaker_shieldbreak);
        var _blink_time = breaker_time - _transition_duration * breaker_eye_blink_start;
        var _blink_span = max(0.001, _transition_duration * (1 - breaker_eye_blink_start));
        var _progress = clamp(_blink_time / _blink_span, 0, 1);
        var _slow_rate = 1 / breaker_eye_blink_slow_interval;
        var _fast_rate = 1 / breaker_eye_blink_fast_interval;
        // Integrate a rising rate so the blink phase advances smoothly.
        var _blink_phase = _blink_time * (_slow_rate
            + (_fast_rate - _slow_rate) * _progress * _progress / 3);
        breaker_eyes_awake = _blink_time >= 0
            && (floor(_blink_phase) mod 2) == 0;
    }
    if (!breaker_eyes_awake || !visible || image_alpha <= 0) return;
    var _name = sprite_get_name(sprite_index);
    if (!variable_struct_exists(breaker_eye_axes, _name)) return;
    var _axes = variable_struct_get(breaker_eye_axes, _name);
    var _axis = _axes[clamp(floor(image_index), 0, array_length(_axes) - 1)];
    if (is_undefined(_axis)) return; // The visor is hidden during the turn.
    var _cos = dcos(image_angle);
    var _sin = dsin(image_angle);
    var _x1 = (_axis[0] - sprite_get_xoffset(sprite_index)) * _scale_x;
    var _y1 = (_axis[1] - sprite_get_yoffset(sprite_index)) * image_yscale;
    var _x2 = (_axis[2] - sprite_get_xoffset(sprite_index)) * _scale_x;
    var _y2 = (_axis[3] - sprite_get_yoffset(sprite_index)) * image_yscale;
    var _wx1 = _draw_x + _x1 * _cos + _y1 * _sin;
    var _wy1 = _draw_y - _x1 * _sin + _y1 * _cos;
    var _wx2 = _draw_x + _x2 * _cos + _y2 * _sin;
    var _wy2 = _draw_y - _x2 * _sin + _y2 * _cos;
    breaker_eye_light = { x: (_wx1 + _wx2) * 0.5, y: (_wy1 + _wy2) * 0.5,
        x1: _wx1, y1: _wy1, x2: _wx2, y2: _wy2, scale: abs(image_yscale),
        draw_x: _draw_x, draw_y: _draw_y, scale_x: _scale_x };
};
breaker_set_eye_uniforms = function(_eye_only) {
    shader_set_uniform_f(breaker_eye_only_uniform, _eye_only);
    var _active = breaker_eyes_awake && !is_undefined(breaker_eye_light);
    shader_set_uniform_f(breaker_eye_active_uniform, _active ? 1 : 0);
    if (!_active) return;
    var _eye = breaker_eye_light;
    shader_set_uniform_f(breaker_eye_axis_uniform, _eye.x1, _eye.y1, _eye.x2, _eye.y2);
    shader_set_uniform_f(breaker_eye_radius_uniform, breaker_attack_settings().eye_core_radius * _eye.scale);
    shader_set_uniform_f(breaker_eye_color_uniform, color_get_red(breaker_eye_color) / 255,
        color_get_green(breaker_eye_color) / 255, color_get_blue(breaker_eye_color) / 255);
};
breaker_draw_eye_halo = function(_x, _y, _radius, _color, _alpha) {
    var _segments = breaker_attack_settings().eye_halo_segments; // Shared circle subdivisions; controls halo smoothness.
    draw_primitive_begin(pr_trianglelist);
    for (var _i = 0; _i < _segments; ++_i) {
        var _angle1 = _i * 360 / _segments; // Degrees to the first rim vertex.
        var _angle2 = (_i + 1) * 360 / _segments; // Degrees to the next rim vertex.
        draw_vertex_colour(_x, _y, _color, _alpha);
        draw_vertex_colour(_x + lengthdir_x(_radius, _angle1), _y + lengthdir_y(_radius, _angle1), _color, 0);
        draw_vertex_colour(_x + lengthdir_x(_radius, _angle2), _y + lengthdir_y(_radius, _angle2), _color, 0);
    }
    draw_primitive_end();
};
breaker_draw_eye_glow = function() {
    if (!breaker_eyes_awake || is_undefined(breaker_eye_light)
        || !visible || image_alpha <= 0 || !layer_get_visible(layer)) return;
    var _eye = breaker_eye_light;
    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();
    // Alpha-composite one selected color instead of adding it over white/red sprite pixels.
    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);
    breaker_draw_eye_halo(_eye.x, _eye.y, breaker_eye_halo_radius * _eye.scale * breaker_eye_glow_scale,
        breaker_eye_color, min(1, 0.22 * breaker_eye_glow_gain) * image_alpha);
    breaker_draw_eye_halo(_eye.x, _eye.y, breaker_eye_core_halo_radius * _eye.scale * breaker_eye_glow_scale,
        breaker_eye_color, min(1, 0.65 * breaker_eye_glow_gain) * image_alpha);
    if (shader_is_compiled(sh_BreakerShieldFlash)) {
        shader_set(sh_BreakerShieldFlash);
        breaker_set_eye_uniforms(1);
        draw_sprite_ext(sprite_index, image_index, _eye.draw_x, _eye.draw_y,
            _eye.scale_x, image_yscale, image_angle, c_white, image_alpha);
        shader_reset();
    }
    else {
        draw_set_alpha(image_alpha);
        draw_set_color(breaker_eye_color);
        draw_line_width(_eye.x1, _eye.y1, _eye.x2, _eye.y2, 2 * _eye.scale);
    }
    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
};

breaker_sprite = function(_shielded, _unshielded) {
    return breaker_unshielded ? _unshielded : _shielded;
};
breaker_fps = function(_sprite) {
    // FPS means frames per second; active melee sprites share the Create attack-speed multiplier.
    if (_sprite == s_Breaker_jumpcharge || _sprite == s_Breaker_jumpcharge_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_jump_charge_duration;
    if (_sprite == s_Breaker_land || _sprite == s_Breaker_land_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_land_duration;
    if (_sprite == s_Breaker_landrecovery || _sprite == s_Breaker_landrecovery_unshielded)
        return max(1, sprite_get_number(_sprite)) / breaker_land_recovery_duration;
    var _fps = sprite_get_speed(_sprite);
    if (sprite_get_speed_type(_sprite) == spritespeed_framespergameframe)
        _fps *= game_get_speed(gamespeed_fps);
    if (_sprite == s_Breaker_shieldbash || _sprite == s_Breaker_shieldbash_unshielded)
        _fps *= max(0.01, breaker_attack_speed);
    if (_sprite == s_Breaker_bashcooldown_unshielded)
        _fps /= breaker_unshielded_cooldown_multiplier;
    return max(0.001, _fps);
};
breaker_duration = function(_sprite) {
    return max(1, sprite_get_number(_sprite)) / breaker_fps(_sprite);
};
breaker_spawn_wreckage = function(_shield) {
    if (_shield && breaker_shield_debris_spawned) return;
    if (_shield) breaker_shield_debris_spawned = true;
    instance_create_depth((bbox_left + bbox_right) * 0.5, bbox_bottom + 1,
        clamp(depth + 1, -15999, 15999), oBreakerWreckage, {
            wreck_shield: _shield,
            wreck_scale_x: abs(image_xscale) * facing_direction * breaker_source_direction,
            wreck_scale_y: image_yscale
        });
};
breaker_set_state = function(_state) {
    breaker_state = _state;
    breaker_time = 0;
    breaker_animation_time = 0;
    breaker_hit_time = 0;
    breaker_hit_elapsed = 0;
    path_end();
    if (_state == BreakerState.BASH) {
        breaker_bash_hit = false;
        breaker_bash_serial += 1;
        breaker_slide_bash_lock = breaker_slide_turn_lock > 0;
    }
    else breaker_slide_bash_lock = false;
    if (_state == BreakerState.JUMP_CHARGE) {
        breaker_leap_hit = false;
    }
    if (_state == BreakerState.RISE) world_sfx_play(sfxBreakerJump, x, y);
    if (_state == BreakerState.SHIELD_BREAK) {
        breaker_eyes_awake = false;
        for (var _i = 0; _i < array_length(breaker_hit_sounds); _i++) {
            audio_stop_sound(breaker_hit_sounds[_i]);
        }
        breaker_hit_sounds = [];
        breaker_shield_break_sound = world_sfx_play(sfxBreakerShieldBreak, x, y);
        world_sfx_play(sfxBreakerTransition, x, y, 1, 1, 1280);
        breaker_spawn_wreckage(true);
        var _sx = abs(image_xscale) * facing_direction * breaker_source_direction;
        instance_create_depth((bbox_left + bbox_right) * 0.5 + (42 - 64 + 60) * _sx,
            bbox_bottom + 1 + (118 - 208 + 45) * image_yscale,
            clamp(depth - 1, -15999, 15999), oEnemyExplosion,
            { fx_miniboss: true, fx_scale: 0.45 });
    }
    if (_state == BreakerState.LAND) breaker_landed = false;
};
// Spawn-marker entrance: launch once, bypassing chase range and charge gates.
breaker_start_entrance_slam = function() {
    var _target = instance_nearest(x, y, o_Player);
    if (!instance_exists(_target)) return;
    breaker_clear_control();
    breaker_intercept = false;
    breaker_leap_hit = false;
    leap_target_x = _target.x;
    var _direction = sign(leap_target_x - (bbox_left + bbox_right) * 0.5);
    if (_direction != 0) facing_direction = _direction;
    leap_launch_speed = leap_jump_speed;
    vertical_speed = leap_launch_speed;
    breaker_set_state(BreakerState.RISE);
    sprite_index = breaker_sprite(s_Breaker_jump, s_Breaker_jump_unshielded);
    image_index = 0;
};
breaker_attacking = function() {
    return breaker_state == BreakerState.GRAB || breaker_state == BreakerState.THROW
        || breaker_state == BreakerState.BASH || breaker_state == BreakerState.JUMP_CHARGE
        || breaker_airborne_attack() || breaker_state == BreakerState.LAND
        || breaker_state == BreakerState.LAND_RECOVERY;
};
// Catch a dash crossing the unshielded core, including during the close stab.
breaker_try_grab = function(_target, _side) {
    if (!breaker_unshielded || !instance_exists(_target) || _target.pHP <= 0
        || _target.grinder_dying || instance_exists(_target.breaker_grab_owner)
        || breaker_hit_time > 0 || breaker_state == BreakerState.STUN
        || breaker_state == BreakerState.SHIELD_BREAK
        || (breaker_attacking() && breaker_state != BreakerState.BASH)) return false;
    breaker_grab_target = _target;
    breaker_grab_stabbed = false;
    breaker_throw_flipped = false;
    if (_side != 0) facing_direction = _side;
    _target.breaker_grab_owner = id;
    // Stop the dash/run animation immediately when the player is caught.
    _target.sprite_index = s_Player;
    _target.image_index = 0;
    _target.image_speed = 0;
    // The throw crosses the core; discard the previous collision exit side.
    var _contact_key = string(id);
    if (variable_struct_exists(_target.breaker_body_sides, _contact_key))
        variable_struct_remove(_target.breaker_body_sides, _contact_key);
    _target.dash_active = false;
    _target.dash_iframe_timer = 0;
    _target.is_slamming = false;
    _target.is_sliding = false;
    _target.is_ledge_climbing = false;
    _target.is_mantle_lunging = false;
    _target.damage_knockback_timer = 0;
    _target.damage_knockback_pending = false;
    _target.phy_speed_x = 0;
    _target.phy_speed_y = 0;
    breaker_set_state(BreakerState.GRAB);
    return true;
};
breaker_airborne_attack = function() {
    return breaker_state == BreakerState.RISE || breaker_state == BreakerState.SLAM_TURN
        || breaker_state == BreakerState.DIVE;
};
breaker_contact_active = function() {
    return breaker_airborne_attack()
        || (breaker_state == BreakerState.LAND && !breaker_landed);
};
breaker_leap_damage_player = function(_target) {
    if (breaker_leap_hit || !instance_exists(_target)) return;
    breaker_leap_hit = true;
    miniboss_damage_player(_target, leap_damage, ParryState.UNPARRYABLE);
};
breaker_clear_control = function() {
    knockback_timer = 0;
    slam_stun_timer = 0;
    slam_knockback_timer = 0;
    slam_velocity_x = 0;
    slam_velocity_y = 0;
    attack_state = 0;
    stun_timer = 0;
};
breaker_request_break = function() {
    if (breaker_unshielded || breaker_state == BreakerState.SHIELD_BREAK) return;
    breaker_break_pending = true;
    // The shield stays visually intact through the entire airborne slam and land.
    if (breaker_airborne_attack() || breaker_state == BreakerState.LAND) return;
    breaker_clear_control();
    breaker_set_state(BreakerState.SHIELD_BREAK);
};
// Shared parry visual effects (VFX) for both shield phases, using the room-independent boss settings.
breaker_parry_contact_effect = function(_player, _contact, _direction) {
    var _settings = breaker_slam_visual_settings().half_parry_sparks;
    var _effect = instance_create_depth(_contact.px, _contact.py, -10000, o_ShotImpact,
        { impact_parry: true, impact_block: true,
          impact_strength: _player.parry_block_config.impact_strength,
          impact_visual: _player.parry_block_config.impact, impact_direction: _direction });
    _effect.spark_color_start = _settings.bright_color;
    _effect.spark_color_end = _settings.fade_color;
};
breaker_receive_full_parry = function() {
    breaker_stop_bash_sound();
    breaker_clear_control();
    breaker_set_state(BreakerState.STUN);
    breaker_stun_elapsed = 0;
    stun_timer = breaker_parry_stun_seconds;
    breaker_stun_budget = breaker_parry_stun_seconds;

    // Shield damage is based on its maximum, never the remaining shield or body HP.
    shield_hp = max(0, shield_hp - shield_hp_max * breaker_parry_shield_fraction);
    breaker_shield_flash_time = breaker_shield_flash_duration;
    if (shield_hp <= 0) breaker_request_break();
    else breaker_play_hit_sound();
};
breaker_react_to_hit = function() {
    if (breaker_unshielded && (breaker_hit_time > 0 || breaker_control_grace > 0)) return;
    if (breaker_attacking() || breaker_state == BreakerState.SHIELD_BREAK
        || breaker_state == BreakerState.STUN) return;
    var _reaction = breaker_sprite(s_Breaker_block, s_Breaker_block_unshielded);
    breaker_hit_time = breaker_duration(_reaction);
    breaker_hit_elapsed = 0;
};
breaker_move_x = function(_distance, _needs_floor) {
    var _steps = ceil(abs(_distance));
    if (_steps <= 0) return;
    var _dx = _distance / _steps;
    repeat (_steps) {
        if (place_meeting(x + _dx, y, o_Block)) break;
        if (_needs_floor && !place_meeting(x + _dx, y + ground_check_distance, o_Block)) break;
        x += _dx;
    }
};
miniboss_damage_player = function(_target, _damage, _parry_state = ParryState.UNPARRYABLE) {
    if (instance_exists(_target))
        _target.take_damage(_damage, x, _parry_state);
};

// Share front/back classification with bullet impact visuals, including coin shots.
breaker_hit_from_back = function(_attacker_x = undefined) {
    if (is_undefined(_attacker_x)) {
        var _player = instance_nearest(x, y, o_Player);
        if (_player != noone) _attacker_x = _player.x;
    }
    return !is_undefined(_attacker_x)
        && sign(_attacker_x - (bbox_left + bbox_right) * 0.5) == -facing_direction;
};
miniboss_parent_take_damage = take_damage;
// The phase transition cannot be damaged by weapons, slams, or direct crashes.
is_invulnerable = function() {
    return breaker_state == BreakerState.SHIELD_BREAK;
};
take_damage = function(_damage, _knockback_dir = 0, _knockback_force = 0,
    _is_sword = false, _hit_x = undefined, _is_beam = false, _beam_coins = 1,
    _electric_shield_bonus = 0, _electric_stun_seconds = 0) {
    if (is_invulnerable() || _damage <= 0) return;
    var _back = breaker_hit_from_back(_hit_x);
    var _electric_shield_damage = _is_beam ? _damage * max(0, _electric_shield_bonus) : 0;
    // Shield impacts and phase-two body hits share the same coin-scaled push.
    if (_is_beam && (breaker_unshielded || (shield_hp > 0 && !_back))
        && !breaker_attacking()
        && breaker_state != BreakerState.SHIELD_BREAK
        && breaker_state != BreakerState.STUN
        && place_meeting(x, y + ground_check_distance, o_Block)) {
        var _tier = clamp(floor(_beam_coins), 1, array_length(shield_beam_knockback_distances)) - 1;
        breaker_beam_knockback_distance = lengthdir_x(
            shield_beam_knockback_distances[_tier], _knockback_dir);
        breaker_beam_knockback_time = shield_beam_knockback_duration;
    }
    if (shield_hp > 0 && !_back) {
        var _mult = _is_beam ? shield_front_beam_multiplier
            : (_is_sword ? shield_front_sword_multiplier : shield_front_bullet_multiplier);
        var _shield_damage = _damage * _mult;
        _shield_damage += _electric_shield_damage;
        shield_hp = max(0, shield_hp - _shield_damage);
        if (shield_hp > 0 && (_is_sword || _is_beam)) breaker_play_hit_sound(); // Bullet impacts play their ricochet cue at the bounce.
        breaker_shield_flash_time = breaker_shield_flash_duration;
        if (shield_hp <= 0) breaker_request_break();
        else breaker_react_to_hit();
        return;
    }
    if (shield_hp <= 0) _damage *= _is_beam ? phase2_beam_damage_multiplier
        : (_is_sword ? phase2_sword_damage_multiplier : phase2_bullet_damage_multiplier);
    if (_back) _damage *= back_damage_multiplier;
    if (_damage > 0) {
        if (breaker_unshielded) breaker_body_flash_time = breaker_shield_flash_duration;
        breaker_play_hit_sound(sfxBreakerHitNoShield);
    }
    breaker_react_to_hit();
    // Block reactions handle stagger; beam pushback is handled separately above.
    // Avoid invoking the parent's Scout-specific dash parry or knockback.
    miniboss_parent_take_damage(_damage, _knockback_dir, 0, false);
    // Rear hits retain their normal body damage and also discharge into an intact shield.
    if (instance_exists(id) && ehp > 0 && _back && shield_hp > 0 && _electric_shield_damage > 0) {
        shield_hp = max(0, shield_hp - _electric_shield_damage);
        breaker_shield_flash_time = breaker_shield_flash_duration;
        if (shield_hp <= 0) breaker_request_break();
    }
    if (_is_beam && instance_exists(id) && ehp > 0 && breaker_unshielded
        && shield_hp <= 0 && _electric_stun_seconds > 0)
        breaker_receive_electric_stun(_electric_stun_seconds);
};
// Electricity interrupts phase-two attacks, bypassing ordinary slam immunity.
breaker_receive_electric_stun = function(_seconds) {
    if (!breaker_unshielded || shield_hp > 0 || is_invulnerable() || ehp <= 0) return;
    var _remaining = max(stun_timer, max(slam_stun_timer, slam_knockback_timer));
    var _was_stunned = breaker_state == BreakerState.STUN;
    if (instance_exists(breaker_grab_target))
        breaker_grab_target.breaker_grab_owner = noone;
    breaker_grab_target = noone;
    breaker_stop_bash_sound();
    breaker_clear_control();
    breaker_beam_knockback_time = 0;
    breaker_beam_knockback_distance = 0;
    breaker_intercept = false;
    breaker_leap_hit = true;
    vertical_speed = max(0, vertical_speed); // Stop a rising attack; normal gravity still brings him down.
    breaker_set_state(BreakerState.STUN);
    if (!_was_stunned) breaker_stun_elapsed = 0;
    stun_timer = max(_remaining, _seconds); // Seconds; a new hit never shortens an existing stun.
    breaker_stun_budget = stun_timer; // Preserve the full electrical duration through the normal stun tick.
};
slam_interrupt = function() {
    if (breaker_state == BreakerState.STUN) {
        // Preserve a shield-bash parry stun; external control cannot extend it.
        slam_stun_timer = min(slam_stun_timer, breaker_stun_budget);
        slam_knockback_timer = min(slam_knockback_timer, breaker_stun_budget);
        stun_timer = min(stun_timer, breaker_stun_budget);
        return;
    }
    if (!breaker_unshielded || breaker_attacking() || breaker_control_grace > 0
        || breaker_state == BreakerState.SHIELD_BREAK) {
        breaker_clear_control();
        return;
    }
    if (breaker_state != BreakerState.STUN) {
        breaker_set_state(BreakerState.STUN);
        breaker_stun_elapsed = 0;
        var _minimum = breaker_duration(s_Breaker_stun_enter_unshielded)
            + breaker_duration(s_Breaker_stun_exit_unshielded);
        slam_stun_timer = max(slam_stun_timer, _minimum);
        breaker_stun_budget = max(slam_stun_timer, max(slam_knockback_timer, stun_timer));
    }
};
slam_damage = function(_damage, _impact_x, _source) {
    if (is_invulnerable() || _damage <= 0) return;
    var _back = sign(_impact_x - (bbox_left + bbox_right) * 0.5) == -facing_direction;
    if (shield_hp > 0 && !_back) {
        shield_hp = max(0, shield_hp - _damage * slam_shield_damage_multiplier);
        if (shield_hp > 0) breaker_play_hit_sound();
        breaker_shield_flash_time = breaker_shield_flash_duration;
        if (shield_hp <= 0) breaker_request_break();
        else breaker_react_to_hit();
        return;
    }
    if (shield_hp <= 0) _damage *= phase2_slam_damage_multiplier;
    if (_back) _damage *= back_damage_multiplier;
    if (_damage > 0) {
        if (breaker_unshielded) breaker_body_flash_time = breaker_shield_flash_duration;
        breaker_play_hit_sound(sfxBreakerHitNoShield);
    }
    breaker_react_to_hit();
    miniboss_parent_take_damage(_damage, 0, 0, false);
};
// Shielded Breaker and active attacks take damage but resist crowd control.
take_slam = function(_damage, _speed, _impact_x, _impact_y, _source) {
    if (is_invulnerable()) return;
    if (!breaker_unshielded || breaker_attacking() || breaker_control_grace > 0
        || breaker_state == BreakerState.STUN || breaker_state == BreakerState.SHIELD_BREAK) {
        slam_damage(max(0, _damage * slam_damage_multiplier), _impact_x, _source);
        return;
    }
    enemy_receive_slam(_damage, _speed, _impact_x, _impact_y, _source);
};
sprite_index = s_Breaker_idle;
normal_sprite = s_Breaker_idle;
stun_sprite = s_Breaker_stun_unshielded;
