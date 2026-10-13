if (instance_number(o_SeamlessTravel) > 1)
{
    instance_destroy();
    exit;
}
persistent = true;
visible = false;
pending = undefined;
transition_cooldown = 0;
