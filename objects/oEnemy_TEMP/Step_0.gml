

var player = instance_nearest(x, y, o_Player); //determines the position of player for the enemy

if (player != noone)//if the enemy isn't already at the player's pos
{
    var distance = point_distance(x, y, player.x, player.y-40);
//we have two paramete sets, xy pos of enemy and xy pos of player. they have to be the same
    if (distance > 30) //specifies the distance between enemy and player
    {
        var dir = point_direction(x, y, player.x, player.y-40);
		

        x += lengthdir_x(2, dir);  //xsp
        y += lengthdir_y(2, dir); //ysp
		//we have two parameters again, 2 is the speed and dir is the directin it needs to move in
    }
}