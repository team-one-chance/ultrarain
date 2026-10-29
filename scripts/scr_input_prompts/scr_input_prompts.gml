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
        case "vent_break": return { text: "JUMP, THEN SLAM TO BREAK THE VENT", icons: [2, 11] };
        case "breaker_shield": return { text: "SWORD BREAKS SHIELD; DASH THROUGH WHILE SHIELDED", icons: [10, 7, 4] };
    }
    return { text: "", icons: [] };
}

// Contextual hints disappear once their obstacle or target is gone.
function input_prompt_available(_prompt, _player)
{
    if (!instance_exists(_prompt) || !instance_exists(_player)) return false;
    if (!layer_get_visible(_prompt.layer) || _prompt.prompt_definition.text == "") return false;
    if (abs(_player.x - _prompt.x) > max(1, _prompt.trigger_width) * 0.5
        || abs(_player.y - _prompt.y) > max(1, _prompt.trigger_height) * 0.5) return false;
    switch (string_lower(_prompt.prompt_id))
    {
        case "vent_break":
            var _block = instance_nearest(1040, 2528, o_Block_Breakable);
            return instance_exists(_block) && point_distance(_block.x, _block.y, 1040, 2528) < 48;
        case "breaker_shield":
            var _boss = instance_nearest(_player.x, _player.y, oEnemy_Breaker);
            return instance_exists(_boss) && _boss.shield_hp > 0 && !_boss.breaker_unshielded
                && point_distance(_player.x, _player.y, _boss.x, _boss.y) < 900;
    }
    return true;
}

// Draw one definition in GUI coordinates. Callers may reuse this for interactions.
function input_prompt_actions(_id)
{
    switch (string_lower(_id))
    {
        case "move": return ["left", "right"];
        case "jump": return ["jump"];
        case "slide": return ["slide"];
        case "dash": return ["dash"];
        case "heal": return ["heal"];
        case "interact": return ["interact"];
        case "shoot": return ["fire"];
        case "coin": return ["coin"];
        case "weapons": return ["pistol", "sword"];
        case "slam": return ["slam"];
        case "mantle": return ["up"];
        case "pin": return ["pin"];
        case "vent_break": return ["jump", "slam"];
        case "breaker_shield": return ["sword", "fire", "dash"];
    }
    return [];
}

function input_prompt_draw(_definition, _text, _x, _y, _id = "")
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
    var _actions = input_prompt_actions(_id);
    var _defaults = controls_defaults();
    for (var _i = 0; _i < array_length(_definition.icons); _i++)
    {
        var _icon_x = _left + _i * (_size + _gap);
        if (_i < array_length(_actions)
            && controls_key(_actions[_i]) != variable_struct_get(_defaults, _actions[_i]))
        {
            // Unavailable icon frames fall back to the current binding's label.
            var _key_text = controls_key_name(controls_key(_actions[_i]));
            var _text_scale = min(1, (_size - 4) / max(1, string_width(_key_text)));
            draw_set_color(c_white);
            draw_rectangle(_icon_x, _y - _size / 2, _icon_x + _size, _y + _size / 2, true);
            draw_set_halign(fa_center);
            draw_text_transformed(_icon_x + _size / 2, _y, _key_text, _text_scale, _text_scale, 0);
            draw_set_halign(fa_left);
        }
        else draw_sprite_ext(s_InputPrompts, _definition.icons[_i], _icon_x,
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
