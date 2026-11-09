if (instance_exists(door_owner) && door_owner.visible
&& layer_get_visible(door_owner.layer))
{
    with (door_owner) door_draw_frame(true);
}
