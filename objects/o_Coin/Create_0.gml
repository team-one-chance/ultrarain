depth = o_Player.depth -1;
split_threshold = 0.75;

// Play once whenever a coin is thrown.
audio_play_sound(sfxCoin, 1, false);
// Draw in front of every molten-lava instance.
for (var _i = 0; _i < instance_number(oMoltenLava); _i++)
{
    var _lava = instance_find(oMoltenLava, _i);
    depth = min(depth, _lava.depth - 1);
}

// =====================================
// APEX ANIMATION
// =====================================

apex_anim_frame = 0;
apex_anim_speed = 27; // frames per second


is_pinned = false;
pin_owner = noone;

pin_x = x;
pin_y = y;
pin_sink_speed = 48;
pin_duration = 9;
pin_time_left = 0;

pin_was_supporting = false;
pin_drop_remaining = 0;
pin_jump_drop_distance = 200;
pin_jump_drop_speed = 400; // 200 pixels in 0.5 seconds.

// An 8 × 8 solid area, matching the normal coin sprite.
pin_half_width = 4;
pin_half_height = 4;

pin_here = function(_owner)
{
    if (is_pinned) return;

    pin_owner = _owner;
    pin_x = phy_position_x;
    pin_y = phy_position_y;

    phy_speed_x = 0;
    phy_speed_y = 0;
    phy_angular_velocity = 0;

    // Gravity and physics contacts can no longer move this coin.
	phy_active = false;
	is_pinned = true;

	pin_time_left = pin_duration;
	pin_was_supporting = false;
	pin_drop_remaining = 0;
};


pin_player_on_top = function(_player)
{
    if (!instance_exists(_player)) return false;
    if (_player.pHP <= 0 || _player.phy_speed_y < 0)
        return false;

    var _feet_x = _player.phy_position_x + 0.5;
    var _feet_y = _player.phy_position_y;
    var _top = pin_y - pin_half_height;

    return abs(_feet_x - pin_x)
        < _player.player_collider_half_width + pin_half_width
        && abs(_feet_y - _top) <= 2;
};


// Sweep the player's body against the pinned coin.
// This catches fast movement as well as ordinary overlap.
pin_resolve_player = function(_player, _start_x, _start_y)
{
    if (!is_pinned) return;

    var _half = _player.player_collider_half_width;
    var _height = _player.player_collider_height;

    // Expand the coin by the player's body dimensions.
    // The moving point represents the player's feet/origin.
    var _minimum = [
        pin_x - pin_half_width - _half - 0.5,
        pin_y - pin_half_height
    ];

    var _maximum = [
        pin_x + pin_half_width + _half - 0.5,
        pin_y + pin_half_height + _height
    ];

    var _start = [_start_x, _start_y];

    var _travel = [
        _player.phy_position_x - _start_x,
        _player.phy_position_y - _start_y
    ];

	var _enter = -infinity;
	var _leave = infinity;
    var _hit_axis = -1;
    var _normal = 0;

    for (var _axis = 0; _axis < 2; _axis++)
    {
        if (abs(_travel[_axis]) < 0.000001)
        {
            if (_start[_axis] < _minimum[_axis]
            || _start[_axis] > _maximum[_axis])
            {
                return;
            }
        }
        else
        {
            var _a =
                (_minimum[_axis] - _start[_axis])
                / _travel[_axis];

            var _b =
                (_maximum[_axis] - _start[_axis])
                / _travel[_axis];

            var _near = min(_a, _b);
            var _far = max(_a, _b);

            if (_near > _enter)
            {
                _enter = _near;
                _hit_axis = _axis;
                _normal = -sign(_travel[_axis]);
            }

            _leave = min(_leave, _far);
        }
    }

    if (_enter > _leave || _leave < 0 || _enter > 1)
        return;

    // If pinned inside the player, use the nearest exit side.
    if (_enter < 0)
    {
        var _inside =
            _start[0] > _minimum[0]
            && _start[0] < _maximum[0]
            && _start[1] > _minimum[1]
            && _start[1] < _maximum[1];

        if (!_inside) return;

        var _distances = [
            _start[0] - _minimum[0],
            _maximum[0] - _start[0],
            _start[1] - _minimum[1],
            _maximum[1] - _start[1]
        ];

        var _closest = 0;

        for (var _i = 1; _i < 4; _i++)
        {
            if (_distances[_i] < _distances[_closest])
                _closest = _i;
        }

        _hit_axis = floor(_closest / 2);
        _normal = (_closest mod 2 == 0) ? -1 : 1;
    }

    if (_hit_axis == -1) return;

    var _boundary = _normal < 0
        ? _minimum[_hit_axis]
        : _maximum[_hit_axis];

    if (_hit_axis == 0)
    {
        _player.phy_position_x = _boundary + _normal * 0.01;

        if (_player.phy_speed_x * _normal < 0)
            _player.phy_speed_x = 0;
    }
    else
    {
        _player.phy_position_y = _boundary + _normal * 0.01;

        if (_player.phy_speed_y * _normal < 0)
            _player.phy_speed_y = 0;
    }
};