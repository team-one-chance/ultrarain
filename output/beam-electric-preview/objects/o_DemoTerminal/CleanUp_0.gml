stop_command_result_sfx();
if (instance_exists(reader))
{
    if (reader.hacking_controller == id)
    {
        reader.hacking_controller = noone;
    }
}
