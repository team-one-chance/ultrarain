game_over_age = 0;
game_over_delay = 1.1;
button_hover = false;

// Draw and mouse hit testing share the same responsive GUI coordinates.
update_layout = function()
{
    gui_w = display_get_gui_width();
    gui_h = display_get_gui_height();
    ui_scale = min(1, gui_w / 520, gui_h / 320);
    centre_x = gui_w * 0.5;
    centre_y = gui_h * 0.5;
    panel_left = centre_x - 230 * ui_scale;
    panel_right = centre_x + 230 * ui_scale;
    panel_top = centre_y - 125 * ui_scale;
    panel_bottom = centre_y + 125 * ui_scale;
    button_left = centre_x - 110 * ui_scale;
    button_right = centre_x + 110 * ui_scale;
    button_top = centre_y + 47 * ui_scale;
    button_bottom = centre_y + 91 * ui_scale;
};
update_layout();
