// Resolve after physics so held movement and dash speed cannot tunnel through
// Breaker. His jumping attack also damages on contact before body correction.
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;
if (grinder_dying || pHP <= 0) exit;
var _old_centre = (breaker_body_start_left + breaker_body_start_right) * 0.5;
var _contact_sides = {};
var _player_left = phy_position_x + 0.5 - player_collider_half_width;
var _player_right = phy_position_x + 0.5 + player_collider_half_width;
var _player_top = phy_position_y - player_collider_height;
var _player_bottom = phy_position_y;
for (var _i = 0; _i < array_length(breaker_body_snapshot); _i++) {
    var _record = breaker_body_snapshot[_i];
    var _boss = _record.boss;
    if (!instance_exists(_boss)) continue;
    if (variable_instance_exists(_boss, "train_departing") && _boss.train_departing) continue;

    var _centre = (_player_left + _player_right) * 0.5;
    var _boss_centre = (_boss.bbox_left + _boss.bbox_right) * 0.5;
    var _previous_separation = _old_centre - _record.centre;
    var _separation = _centre - _boss_centre;
    var _side = sign(_previous_separation);
    var _key = string(_boss.id);
    if (variable_struct_exists(breaker_body_sides, _key))
        _side = variable_struct_get(breaker_body_sides, _key);
    if (_side == 0) _side = sign(_separation);
    if (_side == 0) _side = -_boss.facing_direction;
    var _half_core = (_boss.bbox_right - _boss.bbox_left + 1)
        * _boss.breaker_body_core_fraction * 0.5;
    var _limit = _half_core + player_collider_half_width + 1;
    var _boss_top = _boss.bbox_bottom + 1
        - (_boss.bbox_bottom - _boss.bbox_top + 1) * _boss.breaker_body_height_fraction;
    var _jump_contact = _record.airborne_attack || _boss.breaker_contact_active();
    // Sweep the relative bodies on both axes before horizontal separation.
    // This also catches a fast rise/dive or a player crossing between Steps.
    if (!(variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies)
        && !_boss.breaker_leap_hit
        && _jump_contact) {
        var _relative_start_y = (breaker_body_start_top + breaker_body_start_bottom
            - _record.top - _record.bottom) * 0.5;
        var _relative_end_y = (_player_top + _player_bottom - _boss_top - _boss.bbox_bottom) * 0.5;
        var _half_height = (_player_bottom - _player_top + 1
            + _boss.bbox_bottom - _boss_top + 1) * 0.5;
        var _starts = [_previous_separation, _relative_start_y];
        var _ends = [_separation, _relative_end_y];
        var _limits = [_limit, _half_height];
        var _enter = 0;
        var _leave = 1;
        for (var _axis = 0; _axis < 2; _axis++) {
            var _travel = _ends[_axis] - _starts[_axis];
            if (abs(_travel) < 0.0001) {
                if (abs(_starts[_axis]) > _limits[_axis]) _leave = -1;
            }
            else {
                var _first = (-_limits[_axis] - _starts[_axis]) / _travel;
                var _last = (_limits[_axis] - _starts[_axis]) / _travel;
                _enter = max(_enter, min(_first, _last));
                _leave = min(_leave, max(_first, _last));
            }
        }
        if (_enter <= _leave) _boss.breaker_leap_damage_player(id);
    }
    if (_boss.breaker_unshielded && is_sliding) continue;
    var _overlap_now = _player_bottom >= _boss_top && _player_top <= _boss.bbox_bottom;
    var _signed_distance = _separation * _side;
    // Find the horizontal point of entry and test height there, so a dash is
    // blocked even if the final positions are already on opposite sides.
    var _relative_move = _previous_separation - _separation;
    var _entry = abs(_relative_move) > 0.001
        ? clamp((_previous_separation - _side * _limit) / _relative_move, 0, 1) : 1;
    var _overlap_at_entry = lerp(breaker_body_start_bottom, _player_bottom, _entry)
        >= lerp(_record.top, _boss_top, _entry)
        && lerp(breaker_body_start_top, _player_top, _entry)
        <= lerp(_record.bottom, _boss.bbox_bottom, _entry);
    var _crossed = _previous_separation * _side >= _limit && _signed_distance < _limit;
    if (!_overlap_now && !(_crossed && _overlap_at_entry)) continue;
    // A clear jump over the boss may cross his X without meeting his body.
    if (_crossed && !_overlap_at_entry) continue;

    // Keep one exit side until the bodies separate. A landing or facing change
    // must not alternate the player between opposite sides of the core.
    if (_signed_distance <= _limit + _boss.breaker_body_soft_margin)
        variable_struct_set(_contact_sides, _key, _side);

    if (_signed_distance < _limit) {
        var _correction = _boss_centre + _side * _limit - _centre;
        var _steps = max(1, ceil(abs(_correction)));
        var _dx = _correction / _steps;
        var _moved = 0;
        repeat (_steps) {
            // Probe accumulated travel explicitly; physics position writes need
            // not refresh sprite bounds during this event.
            var _probe_x = _moved + _dx;
            if (collision_rectangle(_player_left + _probe_x, _player_top + 1,
                _player_right + _probe_x, _player_bottom - 1, o_Block, false, true) != noone) break;
            _moved += _dx;
        }
        phy_position_x += _moved;
        _player_left += _moved;
        _player_right += _moved;
        // When the player is pinned against terrain, yield the boss's motion
        // instead of putting the player through the terrain or through his core.
        var _remaining = _correction - _moved;
        if (abs(_remaining) > 0.001) _boss.breaker_move_x(-_remaining, false);
        if (phy_speed_x * _side < 0) phy_speed_x = 0;
    }
    // Airborne attacks must allow contact with the damaging core rather than
    // slowing the player just outside it. Keep the grounded approach soft.
    else if (!_jump_contact && _overlap_now && _signed_distance < _limit + _boss.breaker_body_soft_margin
        && phy_speed_x * _side < 0) {
        var _softness = clamp((_signed_distance - _limit) / _boss.breaker_body_soft_margin, 0, 1);
        phy_speed_x *= lerp(0.2, 1, _softness);
    }
}

// Begin Step already records these body coordinates
// for the Breaker collision checks.
var _coin_start_x =
    (breaker_body_start_left + breaker_body_start_right) * 0.5
    - 0.5;

var _coin_start_y = breaker_body_start_bottom;

for (var _coin_i = 0; _coin_i < instance_number(o_Coin); _coin_i++)
{
    var _pinned = instance_find(o_Coin, _coin_i);

    if (!_pinned.is_pinned) continue;

    _pinned.pin_resolve_player(
        id,
        _coin_start_x,
        _coin_start_y
    );
}

breaker_body_sides = _contact_sides;
