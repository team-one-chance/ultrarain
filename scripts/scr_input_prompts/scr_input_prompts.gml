// Kenney Input Prompts 1.5A, CC0; frame order matches s_InputPrompts.
// Add or change action text and icon frames here. Each room trigger selects an ID.
function input_prompt_definition(_id)
{
    switch (string_lower(_id))
    {
        case "move": return { text: "MOVE", icons: [0, 1] };
        case "jump": return { text: "JUMP", icons: [2] };
        case "slide": return { text: "HOLD TO SLIDE", icons: [3] };
        case "dash": return { text: "DASH", icons: [4] };
        case "heal": return { text: "HEAL", icons: [5] };
        case "interact": return { text: "INTERACT", icons: [6] };
        case "shoot": return { text: "FIRE / SWORD ATTACK", icons: [7] };
        case "coin": return { text: "THROW COIN", icons: [8] };
        case "weapons": return { text: "SWITCH WEAPON", icons: [9, 10] };
        case "slam": return { text: "SLAM WHILE AIRBORNE", icons: [11] };
        case "mantle": return { text: "MANTLE", icons: [12] };
        case "pin": return { text: "PIN A COIN", icons: [13] };
    }
    return { text: "", icons: [] };
}

// Draw one definition in GUI coordinates. Callers may reuse this for interactions.
function input_prompt_draw(_definition, _text, _x, _y)
{
    var _font = draw_get_font();
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    var _size = 32; // GUI pixels per icon; increase for larger button images.
    var _gap = 4; // GUI pixels between icons.
    var _icons_width = array_length(_definition.icons) * (_size + _gap);
    var _width = _icons_width + string_width(_text) + 24;
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_rectangle(_x - _width / 2, _y - 24, _x + _width / 2, _y + 24, false);
    draw_set_alpha(1);
    var _left = _x - _width / 2 + 8;
    for (var _i = 0; _i < array_length(_definition.icons); _i++)
    {
        draw_sprite_ext(s_InputPrompts, _definition.icons[_i], _left + _i * (_size + _gap),
            _y - _size / 2, _size / 64, _size / 64, 0, c_white, 1);
    }
    draw_set_color(c_white);
    draw_text(_left + _icons_width + 4, _y, _text);
    draw_set_font(_font);
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_set_halign(_halign);
    draw_set_valign(_valign);
}
