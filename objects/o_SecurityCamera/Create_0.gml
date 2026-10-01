broken = false;
broken_sprite = -1; // replace -1 with your broken camera sprite

image_index = 0;
image_speed = 0;

spark_timer = 0;

camera_break = function()
{
    if (broken) return;

    broken = true;

    if (broken_sprite != -1)
    {
        sprite_index = broken_sprite;
        image_index = 0;
    }

    spark_timer = 0;
};