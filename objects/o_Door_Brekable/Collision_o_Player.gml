if (!broken
&& (other.is_sliding || other.is_slamming))
{
    door_break();
}

door_take_damage = function(_amount)
{
    if (broken || break_requested) return;

    door_hp = max(0, door_hp - max(0, _amount));

    if (door_hp <= 0)
    {
        door_break();
    }
};