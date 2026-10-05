// Temporary test: press K to break the cameras.
// Remove this block once attacks can break them.
/*if (keyboard_check_pressed(ord("K")))
{
    camera_break();
}*/


// Same falling sparks as the terminal.
if (broken)
{
    spark_timer -= delta_time / 1000000;

    if (spark_timer <= 0)
    {
        repeat (3)
        {
            var _spark_x =
                x + (
                    irandom(sprite_get_width(sprite_index) - 1)
                    - sprite_get_xoffset(sprite_index)
                ) * image_xscale;

            var _spark_y =
                y + (
                    irandom(sprite_get_height(sprite_index) - 1)
                    - sprite_get_yoffset(sprite_index)
                ) * image_yscale;

            instance_create_depth(
                _spark_x,
                _spark_y,
                depth - 1,
                o_TerminalSpark
            );
        }

        spark_timer = random_range(0.35, 1.1);
    }
}