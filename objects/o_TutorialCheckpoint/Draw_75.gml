var _old_alpha = draw_get_alpha();
var _old_color = draw_get_color();
var _old_halign = draw_get_halign();
if (vent_skip_alpha > 0)
{
    draw_set_alpha(vent_skip_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
}
else
{
    var _player = instance_find(o_Player, 0);
    if (instance_exists(_player) && _player.pHP > 0 && !_player.grinder_dying
        && _player.is_sliding && _player.x >= 1450 && _player.x <= 2000
        && _player.y >= 2592 && _player.y <= 2632 && _player.hacking_controller == noone)
    {
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width() * 0.5, display_get_gui_height() * 0.8,
            controls_key_name(controls_key("interact")) + " - SKIP VENT");
    }
}
draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
draw_set_halign(_old_halign);
