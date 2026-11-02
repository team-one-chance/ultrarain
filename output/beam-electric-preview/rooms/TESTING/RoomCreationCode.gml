global.GLslash_damage = 10;
global.GLknockback_force = 100;
global.dev_delta_time = 1000000 / 60;
global.dev_freeze_enemies = false;
view_enabled = false;

var _check = function(_condition, _message)
{
    if (!_condition) show_error("BEAM TEST FAILED: " + _message, true);
    show_debug_message("BEAM TEST PASS: " + _message);
};
var _electric = instance_create_depth(700, 300, 0, oSwordBeam);
_electric.configure_coin_beam(4, 180);
var _fire = instance_create_depth(700, 300, 0, oSwordBeam);
_fire.configure_coin_beam(3, 180);
_check(_electric.beam_damage == 50 && _fire.beam_damage == 40, "existing damage scaling");

var _drone = instance_create_depth(200, 200, 0, oDrone);
_drone.ehp = 1000000000;
_electric.apply_beam_hit(_drone);
_check(!instance_exists(_drone), "electricity kills a billion-HP drone through normal death handling");
_drone = instance_create_depth(200, 200, 0, oDrone);
_drone.ehp = 1000000000;
_fire.apply_beam_hit(_drone);
_check(instance_exists(_drone) && _drone.ehp == 999999960, "fire does ordinary drone damage");

var _scout = instance_create_depth(250, 300, 0, oEnemy_Scout);
_scout.ehp = 10000;
_scout.attack_state = 3;
_scout.is_climbing = true;
_electric.apply_beam_hit(_scout);
_check(_scout.ehp == 9950 && _scout.attack_state == 5 && _scout.stun_timer == 2
    && !_scout.is_climbing, "Scout takes damage and interrupts into a two-second stun");
repeat (60) with (_scout) event_perform(ev_step, ev_step_normal);
_check(_scout.attack_state == 5 && abs(_scout.stun_timer - 1) < 0.001, "Scout remains stunned after one second");
repeat (65) with (_scout) event_perform(ev_step, ev_step_normal);
_check(_scout.attack_state != 5 && _scout.stun_timer == 0, "Scout recovers after two seconds");
_fire.apply_beam_hit(_scout);
_check(_scout.attack_state != 5 && _scout.stun_timer == 0, "fire does not apply Scout electrical stun");

var _boss = instance_create_depth(250, 300, 0, oEnemy_Breaker);
_boss.ehp = 10000;
_boss.shield_hp = 1000;
_boss.facing_direction = 1;
_electric.apply_beam_hit(_boss);
_check(_boss.shield_hp == 940 && _boss.ehp == 10000
    && _boss.breaker_state != BreakerState.STUN, "50-damage electric shield hit deals 60 without body stun");
_fire.apply_beam_hit(_boss);
_check(_boss.shield_hp == 900, "fire has no shield bonus");
_boss.facing_direction = -1;
_electric.apply_beam_hit(_boss);
_check(_boss.shield_hp == 890 && _boss.ehp == 9950,
    "rear electrical hit adds ten shield damage while retaining normal body damage");
_boss.facing_direction = 1;
_boss.shield_hp = 10;
_electric.apply_beam_hit(_boss);
_check(_boss.shield_hp == 0 && _boss.breaker_state == BreakerState.SHIELD_BREAK,
    "shield-breaking electric hit preserves the phase transition");
_electric.apply_beam_hit(_boss);
_check(_boss.ehp == 9950 && _boss.breaker_state == BreakerState.SHIELD_BREAK,
    "shield-break transition remains invulnerable");

_boss = instance_create_depth(250, 300, 0, oEnemy_Breaker);
_boss.ehp = 10000;
_boss.shield_hp = 0;
_boss.breaker_unshielded = true;
_boss.breaker_state = BreakerState.BASH;
_boss.breaker_control_grace = 10;
_electric.apply_beam_hit(_boss);
_check(_boss.ehp == 9950 && _boss.breaker_state == BreakerState.STUN
    && _boss.stun_timer == 1.5 && _boss.breaker_stun_budget == 1.5,
    "unshielded boss takes damage and stuns despite an attack and control grace");
repeat (60) with (_boss) event_perform(ev_step, ev_step_normal);
_check(_boss.breaker_state == BreakerState.STUN && abs(_boss.stun_timer - 0.5) < 0.001,
    "boss remains stunned after one second");
repeat (35) with (_boss) event_perform(ev_step, ev_step_normal);
_check(_boss.breaker_state != BreakerState.STUN && _boss.stun_timer == 0,
    "boss recovers after 1.5 seconds");
_fire.apply_beam_hit(_boss);
_check(_boss.breaker_state != BreakerState.STUN, "fire does not apply boss electrical stun");

var _held = instance_create_depth(400, 300, 0, o_HitscanVisual);
_held.breaker_grab_owner = _boss;
_boss.breaker_grab_target = _held;
_boss.breaker_state = BreakerState.GRAB;
_electric.apply_beam_hit(_boss);
_check(_held.breaker_grab_owner == noone && _boss.breaker_grab_target == noone
    && _boss.breaker_state == BreakerState.STUN, "electrical interruption releases a grabbed player");
_boss.stun_timer = 3;
_boss.breaker_stun_budget = 3;
_electric.apply_beam_hit(_boss);
_check(_boss.stun_timer == 3, "electricity does not shorten a longer boss stun");
_boss.ehp = 10;
_electric.apply_beam_hit(_boss);
_check(!instance_exists(_boss), "lethal boss hit does not access a destroyed enemy");

var _overlap = instance_create_depth(550, 480, 0, oEnemy_Scout);
_overlap.ehp = 10000;
var _sweep = instance_create_depth(600, 500, 0, oSwordBeam);
_sweep.configure_coin_beam(4, 0);
_sweep.move_speed = 1;
_sweep.knockback_force = 0;
with (_sweep) event_perform(ev_step, ev_step_normal);
_check(_overlap.ehp == 9950 && _overlap.stun_timer == 2,
    "collision sweep applies electrical damage and stun");
with (_sweep) event_perform(ev_step, ev_step_normal);
_check(_overlap.ehp == 9950 && ds_list_size(_sweep.hit_enemies) == 1,
    "an overlapping beam only hits each enemy once");

show_debug_message("ALL ELECTRIC BEAM TESTS PASSED");
game_end();
