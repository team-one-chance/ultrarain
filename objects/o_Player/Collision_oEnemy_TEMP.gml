show_debug_message("Collision is happening");

pHP -= 20;


if (pHP <= 0)
{
    instance_destroy();
}



if (dmg_cooldowng <= 0)
{
    pHP -= 10;
    dmg_cooldown = 30;
}

if (pHP <= 0)
{
    instance_destroy();
}
if (place_meeting(x, y, oEnemy_TEMP))
{
    show_debug_message("Collision is happening");
}