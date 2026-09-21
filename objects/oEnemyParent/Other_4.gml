var wall_padding = 12;

with (o_Block)
{
    mp_grid_add_rectangle(
        other.nav_grid,
        bbox_left - wall_padding,
        bbox_top - wall_padding,
        bbox_right + wall_padding,
        bbox_bottom + wall_padding
    );
}