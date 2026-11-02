// Resolve either melee phase after both player input and the attack clock have advanced.
if (breaker_state != BreakerState.BASH || breaker_bash_hit) exit;
if (variable_instance_exists(id, "train_departing") && train_departing) exit;
if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;

var _window = breaker_melee_parry_timing(); // Shared split interval drives both eye cues and damage timing.
if (breaker_time < _window.start_seconds) exit;

var _left = facing_direction > 0 ? bbox_left : bbox_left - normal_attack_range;
var _right = facing_direction > 0 ? bbox_right + normal_attack_range : bbox_right;
var _target = collision_rectangle(_left, bbox_top, _right, bbox_bottom, o_Player, false, true);
if (_target == noone) {
    if (breaker_time >= _window.end_seconds) breaker_bash_hit = true; // A missed impact cannot hit someone later in recovery.
    exit;
}

// A press during the displayed steady half works even on its final rendered frame.
if (!breaker_unshielded) {
    if (_target.parry_melee(id, ParryState.FULL)) exit;
}
else if (_target.parry_is_active() && breaker_can_melee_parry(_target, ParryState.HALF)) {
    breaker_bash_hit = true;
    breaker_stop_bash_sound(); // Cut this bash's attack cue before the parry cue starts.
    var _block_contact = _target.parry_visual_block_success(); // Visual guard/recoil only after the existing HALF check succeeds.
    _target.parry_cooldown = 0; // The half parry blocks damage without healing or stunning Breaker.
    var _push_side = sign((_target.bbox_left + _target.bbox_right) - (bbox_left + bbox_right));
    if (_push_side == 0) _push_side = facing_direction;
    _target.damage_knockback_speed_x = _push_side * breaker_half_parry_push_speed;
    _target.damage_knockback_timer = breaker_half_parry_push_seconds;
    _target.phy_speed_x = _target.damage_knockback_speed_x;

    // Visual effects (VFX): place the burst between the facing edges of both bodies.
    var _player_centre = (_target.bbox_left + _target.bbox_right) * 0.5;
    var _breaker_centre = (bbox_left + bbox_right) * 0.5;
    var _breaker_edge = _push_side > 0 ? bbox_right : bbox_left;
    var _player_edge = _push_side > 0 ? _target.bbox_left : _target.bbox_right;
    var _spark_x = clamp((_breaker_edge + _player_edge) * 0.5,
        min(_breaker_centre, _player_centre), max(_breaker_centre, _player_centre));
    _spark_x = _block_contact.px; // World-space contact on the recoiling procedural blade.
    var _spark_y = _block_contact.py;
    var _spark_settings = breaker_slam_visual_settings().half_parry_sparks;
    var _spark_effect = instance_create_depth(_spark_x, _spark_y, -10000, o_ShotImpact,
        { impact_parry: true, impact_block: true,
          impact_strength: _target.parry_block_config.impact_strength,
          impact_visual: _target.parry_block_config.impact, impact_direction: _push_side > 0 ? 0 : 180 });
    _spark_effect.spark_color_start = _spark_settings.bright_color;
    _spark_effect.spark_color_end = _spark_settings.fade_color;
    world_sfx_play(sfxNoShieldBashParried, _spark_x, _spark_y, 1, 1, 1280); // Unshielded bash parry cue, audible near the clash.
    exit;
}
if (breaker_time >= _window.end_seconds) {
    // Damage and the eye/parry cutoff share the configured contact-frame boundary.
    breaker_bash_hit = true;
    miniboss_damage_player(_target, normal_attack_damage);
}
