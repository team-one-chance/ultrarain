draw_self();

if (player_near && controller_state < 2)
{
    var _prompt = "E - USE";

    if (controller_state == 1)
    {
        _prompt = "E - HIJACK WIRES";
    }

    draw_set_color(c_white);
    draw_text(x - 45, y - 28, _prompt);
}