if (broken && flash_elapsed < flash_duration)
{
    // 0.15 seconds red, then 0.15 seconds clear.
    if (floor(flash_elapsed / 0.15) mod 2 == 0)
    {
        draw_set_color(c_red);
        draw_set_alpha(0.22);

        draw_rectangle(
            0, 0,
            display_get_gui_width(),
            display_get_gui_height(),
            false
        );

        draw_set_alpha(1);
        draw_set_color(c_white);
    }
}