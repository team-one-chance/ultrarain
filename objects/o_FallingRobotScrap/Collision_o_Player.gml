var _reason = "";

if (scrap_state != 0 && scrap_state != 2)
{
    _reason = "wrong state: " + string(scrap_state);
}
else if (!scrap_emerged)
{
    _reason = "not emerged";
}
else if (!scrap_can_damage)
{
    _reason = "scrap_can_damage is false";
}
else if (scrap_hit_player)
{
    _reason = "already damaged player";
}
else if (scrap_fall_speed_before <= 60)
{
    _reason = "fall speed too low: "
        + string(scrap_fall_speed_before);
}
else if (other.pHP <= 0)
{
    _reason = "player already dead";
}
else if (other.dmg_cooldown > 0)
{
    _reason = "player damage cooldown: "
        + string(other.dmg_cooldown);
}
else
{
    if (other.take_damage(scrap_damage, x))
    {
        other.dmg_cooldown = 1;
        scrap_hit_player = true;
        _reason = "damage applied: " + string(scrap_damage);
    }
    else
    {
        _reason = "take_damage rejected hit; damage="
            + string(scrap_damage)
            + ". Check grinder_dying / damage_blocks_damage().";
    }
}

if (!scrap_contact_debugged)
{
    show_debug_message("SCRAP CONTACT: " + _reason);
    scrap_contact_debugged = true;
}