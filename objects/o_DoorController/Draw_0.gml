draw_self();

if (player_near && controller_state < 2)
{
    var _prompt = "E - USE";

    if (controller_state == 1)
    {
        _prompt = "E - HIJACK WIRES";
    }

draw_set_color(c_black);

for (var _ox = -1; _ox <= 1; _ox++)
{
    for (var _oy = -1; _oy <= 1; _oy++)
    {
        if (_ox == 0 && _oy == 0) continue;

        draw_text(x - 45 + _ox, y - 28 + _oy, _prompt);
    }
}

draw_set_color(c_white);
draw_text(x - 45, y - 28, _prompt);
}