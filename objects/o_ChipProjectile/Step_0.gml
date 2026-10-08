if (variable_global_exists("dev_freeze_enemies") && global.dev_freeze_enemies) exit;
var _dt = chip_dt();
life -= _dt;
if (life <= 0) { instance_destroy(); exit; }
var _dx = lengthdir_x(travel_speed * _dt, travel_angle);
var _dy = lengthdir_y(travel_speed * _dt, travel_angle);
var _steps = max(1, ceil(max(abs(_dx), abs(_dy))));
repeat (_steps)
{
    x += _dx / _steps;
    y += _dy / _steps;
    if (chip_wall_at(x, y)) { instance_destroy(); exit; }
    if (is_healing)
    {
        if (!instance_exists(target)) { instance_destroy(); exit; }
        if (place_meeting(x, y, target))
        {
            chip_attach_heal(target, heal_amount);
            instance_destroy();
            exit;
        }
    }
    else
    {
        var _player = instance_place(x, y, o_Player);
        if (_player != noone)
        {
            var _source_x = instance_exists(owner) ? owner.x : x;
            var _result = _player.chip_receive_hit(_source_x, true);
            if (_result == 2 && instance_exists(owner))
                owner.chip_request_boosted_heal();
            instance_destroy();
            exit;
        }
    }
}
