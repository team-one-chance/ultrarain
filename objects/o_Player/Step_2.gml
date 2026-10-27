// Resolve after physics so held movement and dash speed cannot tunnel through
// Breaker. This is horizontal body blocking, with no contact damage or floor.
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;
if (grinder_dying || pHP <= 0) exit;
var _old_centre = (breaker_body_start_left + breaker_body_start_right) * 0.5;
for (var _i = 0; _i < array_length(breaker_body_snapshot); _i++) {
    var _record = breaker_body_snapshot[_i];
    var _boss = _record.boss;
    if (!instance_exists(_boss)) continue;
    if (_boss.breaker_unshielded && is_sliding) continue;
    if (variable_instance_exists(_boss, "train_departing") && _boss.train_departing) continue;

    var _centre = (bbox_left + bbox_right) * 0.5;
    var _boss_centre = (_boss.bbox_left + _boss.bbox_right) * 0.5;
    var _previous_separation = _old_centre - _record.centre;
    var _separation = _centre - _boss_centre;
    var _side = sign(_previous_separation);
    if (_side == 0) _side = sign(_separation);
    if (_side == 0) _side = -_boss.facing_direction;
    var _half_core = (_boss.bbox_right - _boss.bbox_left + 1)
        * _boss.breaker_body_core_fraction * 0.5;
    var _half_player = (bbox_right - bbox_left + 1) * 0.5;
    var _limit = _half_core + _half_player;
    var _boss_top = _boss.bbox_bottom + 1
        - (_boss.bbox_bottom - _boss.bbox_top + 1) * _boss.breaker_body_height_fraction;
    var _overlap_now = bbox_bottom >= _boss_top && bbox_top <= _boss.bbox_bottom;
    var _signed_distance = _separation * _side;
    // Find the horizontal point of entry and test height there, so a dash is
    // blocked even if the final positions are already on opposite sides.
    var _relative_move = _previous_separation - _separation;
    var _entry = abs(_relative_move) > 0.001
        ? clamp((_previous_separation - _side * _limit) / _relative_move, 0, 1) : 1;
    var _overlap_at_entry = lerp(breaker_body_start_bottom, bbox_bottom, _entry)
        >= lerp(_record.top, _boss_top, _entry)
        && lerp(breaker_body_start_top, bbox_top, _entry)
        <= lerp(_record.bottom, _boss.bbox_bottom, _entry);
    var _crossed = _previous_separation * _side >= _limit && _signed_distance < _limit;
    if (!_overlap_now && !(_crossed && _overlap_at_entry)) continue;
    // A clear jump over the boss may cross his X without meeting his body.
    if (_crossed && !_overlap_at_entry) continue;

    if (_signed_distance < _limit) {
        var _correction = _boss_centre + _side * _limit - _centre;
        var _steps = max(1, ceil(abs(_correction)));
        var _dx = _correction / _steps;
        var _moved = 0;
        repeat (_steps) {
            if (place_meeting(x + _dx, y, o_Block)) break;
            phy_position_x += _dx;
            _moved += _dx;
        }
        // When the player is pinned against terrain, yield the boss's motion
        // instead of putting the player through the terrain or through his core.
        var _remaining = _correction - _moved;
        if (abs(_remaining) > 0.001) _boss.breaker_move_x(-_remaining, true);
        if (phy_speed_x * _side < 0) phy_speed_x = 0;
    }
    else if (_overlap_now && _signed_distance < _limit + _boss.breaker_body_soft_margin
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
