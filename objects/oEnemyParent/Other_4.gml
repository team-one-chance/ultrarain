var wall_padding = 12;

// All objects the drone must navigate around.
var wall_objects = [
    o_Block,
	o_Door_UNB
];

for (var i = 0; i < array_length(wall_objects); i++)
{
    with (wall_objects[i])
    {
        mp_grid_add_rectangle(
            other.nav_grid,
            bbox_left - wall_padding,
            bbox_top - wall_padding,
            bbox_right + wall_padding,
            bbox_bottom + wall_padding
        );
    }
}