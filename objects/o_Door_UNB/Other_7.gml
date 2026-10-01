if (door_state == 1)
{
    door_state = 2;
    image_index = image_number - 1; // hold on fully open frame
    image_speed = 0;

    physics_remove_fixture(id, door_fixture);
    door_fixture = -1;
}