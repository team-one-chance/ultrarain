var player = instance_nearest(x, y, o_Player);

if (player != noone)
{
    var move_speed = 2;

    // Target position
    var target_x = player.x;
    var target_y = player.y - 40;


    // =====================================
    // CHECK IF WALL BLOCKS PATH
    // =====================================

    var wall_in_way = collision_line(
        x,
        y,
        target_x,
        target_y,
        o_Block,
        false,
        true
    );


    // =====================================
    // START AVOIDING WALL
    // =====================================

    if (wall_in_way != noone)
    {
        avoiding_wall = true;
    }


    // =====================================
    // WALL AVOIDANCE
    // =====================================

    if (avoiding_wall)
    {
        // Move upward
        if (!place_meeting(x, y - move_speed, o_Block))
        {
            y -= move_speed;
        }

        // Also move slightly toward player horizontally
        if (target_x > x)
        {
            if (!place_meeting(x + move_speed, y, o_Block))
            {
                x += move_speed;
            }
        }
        else if (target_x < x)
        {
            if (!place_meeting(x - move_speed, y, o_Block))
            {
                x -= move_speed;
            }
        }


        // Check again if we now have a clear path to player
        wall_in_way = collision_line(
            x,
            y,
            target_x,
            target_y,
            o_Block,
            false,
            true
        );

        var wall_clearance = 15;

if (wall_in_way == noone
&& !place_meeting(x, y + wall_clearance, o_Block))
{
    avoiding_wall = false;
}
    }


    // =====================================
    // NORMAL PLAYER FOLLOWING
    // =====================================

    else
    {
        var dir = point_direction(
            x,
            y,
            target_x,
            target_y
        );

        var move_x = lengthdir_x(move_speed, dir);
        var move_y = lengthdir_y(move_speed, dir);

        if (!place_meeting(x + move_x, y + move_y, o_Block))
        {
            x += move_x;
            y += move_y;
        }
        else
        {
            avoiding_wall = true;
        }
    }
}


if place_meeting(x, y, o_HitscanVisual)
{
ehp -= 50;
	if (ehp <= 0){
	instance_destroy();
	show_debug_log("scheisse");
}
}

// =====================================
// HIT SPRITE
// =====================================

if (hit_timer > 0)
{
    hit_timer -= delta_time / 1000000;

    sprite_index = hit_sprite;
}
else
{
    sprite_index = normal_sprite;
}