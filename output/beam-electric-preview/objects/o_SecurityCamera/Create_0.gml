broken = false;
broken_sprite = s_SecurityCamera_ouch;

image_index = 0;
image_speed = 0;

spark_timer = 0;

camera_break = function()
{
    if (broken) return;

    broken = true;
    image_blend = make_color_rgb(110, 115, 120);

    if (broken_sprite != -1)
    {
        sprite_index = broken_sprite;
        image_index = 0;
    }

    spark_timer = 0;
};