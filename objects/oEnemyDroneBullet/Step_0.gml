// =====================================
// CALCULATE NEXT POSITION
// =====================================

var next_x = x + lengthdir_x(bullet_speed, direction);
var next_y = y + lengthdir_y(bullet_speed, direction);


// =====================================
// CHECK PLAYER
// =====================================

var player_hit = collision_line(
    x,
    y,
    next_x,
    next_y,
    o_Player,
    false,
    true
);

if (player_hit != noone)
{
    player_hit.pHP -= bullet_damage;

    show_debug_message(
        "PLAYER HIT! HP: " + string(player_hit.pHP)
    );

    instance_destroy();
    exit;
}


// =====================================
// CHECK WALL
// =====================================

if (collision_line(
    x,
    y,
    next_x,
    next_y,
    o_Block,
    false,
    true
) != noone)
{
    instance_destroy();
    exit;
}


// =====================================
// MOVE BULLET
// =====================================

x = next_x;
y = next_y;