draw_self();

if (player_near && !reading)
{
    var _tx = (bbox_left + bbox_right) * 0.5;
    var _ty = bbox_top - 24;
    var _prompt = "[" + controls_key_name(controls_key("interact")) + "] READ TERMINAL";

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_color(c_black);

    for (var _ox = -1; _ox <= 1; _ox++)
    {
        for (var _oy = -1; _oy <= 1; _oy++)
        {
            if (_ox == 0 && _oy == 0) continue;

            draw_text(_tx + _ox, _ty + _oy, _prompt);
        }
    }

    draw_set_color(c_white);
    draw_text(_tx, _ty, _prompt);
    draw_set_halign(fa_left);
}
