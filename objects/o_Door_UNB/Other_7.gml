if (door_state == 1)
{
    door_state = 2;
    image_index = image_number - 1;
    image_speed = 0;

    if (door_fixture != -1)
    {
        physics_remove_fixture(id, door_fixture);
        door_fixture = -1;
    }
}
else if (door_state == 3)
{
    door_state = 0;
    image_index = 0;
    image_speed = 0;

    // Keep the restored collision while closed.
}