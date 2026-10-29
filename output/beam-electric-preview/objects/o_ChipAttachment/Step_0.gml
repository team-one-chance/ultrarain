var _dt = chip_dt();
if (detached)
{
    fall_timer += _dt;
    fall_speed += 600 * _dt;
    y += fall_speed * _dt;
    if (fall_timer >= 0.6) instance_destroy();
    exit;
}
if (!instance_exists(target))
{
    detached = true;
    exit;
}
var _dead = is_healing ? target.ehp <= 0 : target.pHP <= 0;
if (_dead)
{
    detached = true;
    exit;
}
x = (target.bbox_left + target.bbox_right) * 0.5;
y = (target.bbox_top + target.bbox_bottom) * 0.5;
if (!is_healing)
{
    var _slot = 0;
    for (var _i = 0; _i < instance_number(o_ChipAttachment); _i++)
    {
        var _other_chip = instance_find(o_ChipAttachment, _i);
        if (_other_chip == id || _other_chip.is_healing || _other_chip.detached) continue;
        if (_other_chip.target == target && _other_chip.effect < effect) _slot++;
    }
    x += (_slot == 0) ? -6 : 6;
}
var _heal_dt = min(_dt, max(0, duration - elapsed));
if (is_healing)
    target.ehp = min(target.ehp_max, target.ehp + heal_total / duration * _heal_dt);
elapsed += _dt;
if (elapsed >= duration) detached = true;
