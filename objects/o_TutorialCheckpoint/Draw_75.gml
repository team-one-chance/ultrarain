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
    if (vent_skip_available(_player))
    {
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_text(display_get_gui_width() * 0.5, display_get_gui_height() * 0.8,
            controls_key_name(controls_key("interact")) + " - SKIP VENT");
    }
}
// Preserve the encounter's three warning flashes, now timed from room entry.
if (big_room_ambush_elapsed >= 0 && !big_room_ambush_spawned
    && floor(big_room_ambush_elapsed / 0.15) mod 2 == 0)
{
    draw_set_color(c_red);
    draw_set_alpha(0.22);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_set_alpha(_old_alpha);
draw_set_color(_old_color);
draw_set_halign(_old_halign);
