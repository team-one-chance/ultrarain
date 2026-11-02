// Draw a gently pulsing outline around a world pickup, then its normal sprite.
function item_draw_pickup_outline()
{
    var _outline_width = 1; // Room pixels; larger values widen the outline around the sprite.
    var _pulse_seconds = 3; // Seconds per pulse; smaller values make the outline pulse faster.
    var _minimum_alpha = 0.25; // Opacity from 0 to 1 between pulses; lower values increase contrast.
    var _outline_alpha = lerp(_minimum_alpha, 1,
        0.5 + 0.5 * cos(2 * pi * (current_time / 1000) / _pulse_seconds)) * image_alpha;
    if (shader_is_compiled(sh_ItemOutline))
    {
        shader_set(sh_ItemOutline);
        shader_set_uniform_f(shader_get_uniform(sh_ItemOutline, "u_rainbow"), 0);
        shader_set_uniform_f(shader_get_uniform(sh_ItemOutline, "u_q4"), 0);
        for (var _ox = -1; _ox <= 1; _ox++)
        {
            for (var _oy = -1; _oy <= 1; _oy++)
            {
                if (_ox == 0 && _oy == 0) continue;
                draw_sprite_ext(sprite_index, image_index, x + _ox * _outline_width,
                    y + _oy * _outline_width, image_xscale, image_yscale, image_angle,
                    make_colour_rgb(214,214,214), _outline_alpha);
            }
        }
        shader_reset();
    }
    draw_self();
}

// Inventory and collected controllers belonging to the current run.
function item_run_inventory()
{
    if (!variable_global_exists("run_inventory"))
        global.run_inventory = {};

    if (!variable_global_exists("item_controllers"))
        global.item_controllers = [];

    return global.run_inventory;
}


// Called once by each pickup's Create event.
function item_controller_init(_pickup)
{
    item_run_inventory();

    // A retry rebuilds room pickups, while collected controllers persist.
    // Suppress the rebuilt copy of a pickup already owned in this run.
    for (var _i = 0; _i < array_length(global.item_controllers); _i++)
    {
        var _owned = global.item_controllers[_i];
        if (instance_exists(_owned) && _owned.object_index == _pickup.object_index
        && _owned.item_source_room == room && _owned.item_source_x == _pickup.x
        && _owned.item_source_y == _pickup.y)
        {
            instance_destroy(_pickup);
            return;
        }
    }

    _pickup.item_collected = false;
    _pickup.item_owner = noone;
    _pickup.item_source_room = room;
    _pickup.item_source_x = _pickup.x;
    _pickup.item_source_y = _pickup.y;

    // Uncollected pickups remain in their original room.
    _pickup.persistent = false;
}


// Collect a pickup and keep it alive as its own controller.
function item_controller_collect(_pickup, _player)
{
    if (!instance_exists(_pickup)
    || !instance_exists(_player))
        return false;

    if (_pickup.item_collected) return false;

    _player.inventory = item_run_inventory();

    if (!item_add_level(
        _player,
        _pickup.item_key,
        _pickup.item_amount,
        _pickup.item_max_level
    ))
    {
        return false;
    }

    _pickup.item_collected = true;
    _pickup.item_owner = _player;
    _pickup.persistent = true;
    _pickup.visible = false;

    // Both current inventory pickups use physics.
    // Collected controllers must no longer collide or fall.
    _pickup.phy_active = false;

    array_push(global.item_controllers, _pickup);

    _player.item_notice_key = _pickup.item_key;
    _player.item_notice_time = 5; // Seconds the full pickup description remains visible.
    if (_pickup.item_key == "coin_anchor" && instance_exists(o_PauseMenu))
    {
        o_PauseMenu.pickup_notice_pending = _pickup.item_key; // Open at the next Begin Step, after the pickup collision finishes.
        _player.item_notice_time = 0; // The centered modal replaces Pinhouse's timed bottom notice.
    }

    return true;
}


// Reconnect controllers to the current room's player.
function item_controllers_update(_player)
{
    if (!instance_exists(_player)) return;

    _player.inventory = item_run_inventory();

    // Preserve compatibility with the existing Pinhouse code.
    _player.item_coin_anchor =
        item_get_level(_player, "coin_anchor") > 0;

    for (
        var _i = array_length(global.item_controllers) - 1;
        _i >= 0;
        _i--
    )
    {
        var _controller = global.item_controllers[_i];

        if (!instance_exists(_controller))
        {
            array_delete(global.item_controllers, _i, 1);
            continue;
        }

        _controller.item_owner = _player;

        // Keep the invisible controller near its owner.
        _controller.x = _player.x;
        _controller.y = _player.y;
    }
}


// A fresh room restart discards the current inventory.
function item_controllers_reset()
{
    item_run_inventory();

    var _controllers = global.item_controllers;

    global.item_controllers = [];
    global.run_inventory = {};

    for (var _i = 0; _i < array_length(_controllers); _i++)
    {
        var _controller = _controllers[_i];

        if (instance_exists(_controller))
        {
            instance_destroy(_controller);
        }
    }
}

// Return an item's level. Unowned items return 0.
function item_get_level(_player, _item)
{
    if (!instance_exists(_player)) return 0;

    if (!variable_instance_exists(_player, "inventory"))
        return 0;

    if (!variable_struct_exists(_player.inventory, _item))
        return 0;

    return variable_struct_get(_player.inventory, _item);
}


// Add levels to an item.
// Returns false if the pickup cannot increase its level.
function item_add_level(_player, _item, _amount = 1, _max_level = 1)
{
    if (!instance_exists(_player)) return false;

    if (!variable_instance_exists(_player, "inventory"))
        _player.inventory = {};

    var _old_level = item_get_level(_player, _item);
    var _new_level = clamp(
        _old_level + _amount,
        0,
        _max_level
    );

    if (_new_level == _old_level) return false;

    variable_struct_set(
        _player.inventory,
        _item,
        _new_level
    );

    return true;
}

function coin_round_damage(_damage, _level)
{
    switch (_level)
    {
        case 1: return floor(_damage) + 1;
        case 2: return floor(_damage) + 2;
        case 3: return floor(_damage) + 4;
    }

    return _damage;
}

// Appearance data for each item.
function item_get_definition(_key)
{
    switch (_key)
    {
        case "coin_rounding":
            return {
                name: "PI-tastic",
                icon: object_get_sprite(o_PI_tastic),
                description: "Coin ricochets round their damage down, then add 1, 2 or 4 damage at levels 1, 2 or 3.",
                short_description: "Coin ricochets gain damage.",
                quality: 1
            };

        case "coin_anchor":
            return {
                name: "Pinhouse",
                icon: object_get_sprite(o_pinhouse),
                description: "Press " + controls_key_name(controls_key("pin")) + " to pin your oldest thrown coin in place. Recharges in 8 seconds.",
                short_description: controls_key_name(controls_key("pin")) + " pins a coin.",
                quality: 4
            };
    }

    return {
        name: _key,
        icon: -1,
        description: "",
        short_description: "",
        quality: 1
    };
}


// Draw an uncollected item hovering above its pickup body.
function item_draw_pickup(_pickup)
{
    var _definition = item_get_definition(_pickup.item_key);
    var _border = make_color_rgb(192, 192, 192);
    switch (_definition.quality)
    {
        case 2: _border = make_color_rgb(70, 220, 90); break;
        case 3: _border = make_color_rgb(235, 65, 65); break;
        case 4: _border = make_color_rgb(255, 200, 45); break;
    }

    var _float_y = _pickup.y - 6 + sin(current_time / 500) * 3;
    if (shader_is_compiled(sh_ItemOutline))
    {
        shader_set(sh_ItemOutline);
        shader_set_uniform_f(shader_get_uniform(sh_ItemOutline, "u_time"), (current_time mod 60000) / 1000);
        shader_set_uniform_f(shader_get_uniform(sh_ItemOutline, "u_rainbow"), _definition.quality == 5 ? 1 : 0);
        shader_set_uniform_f(shader_get_uniform(sh_ItemOutline, "u_q4"), _definition.quality == 4 ? 1 : 0);
        for (var _ox = -1; _ox <= 1; _ox++)
        {
            for (var _oy = -1; _oy <= 1; _oy++)
            {
                if (_ox == 0 && _oy == 0) continue;
                draw_sprite_ext(_pickup.sprite_index, _pickup.image_index,
                    _pickup.x + _ox * 2, _float_y + _oy * 2,
                    _pickup.image_xscale, _pickup.image_yscale, _pickup.image_angle,
                    _border, _pickup.image_alpha);
            }
        }
        shader_reset();
    }
    draw_sprite_ext(_pickup.sprite_index, _pickup.image_index, _pickup.x, _float_y,
        _pickup.image_xscale, _pickup.image_yscale, _pickup.image_angle,
        _pickup.image_blend, _pickup.image_alpha);
}


// Draw the player's inventory at the bottom centre of the GUI.
// Explicitly dismissed pickup instructions; the pause controller owns the frozen world.
function item_draw_pickup_modal(_key, _layout)
{
    var _item = item_get_definition(_key);
    var _font = draw_get_font();
    var _color = draw_get_color();
    var _alpha = draw_get_alpha();
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    var _scale = _layout.scale;
    var _accent = make_color_rgb(80, 220, 245);
    draw_set_font(f_Console);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_set_alpha(0.7);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(9, 15, 22));
    draw_rectangle(_layout.left, _layout.top, _layout.right, _layout.top + _layout.height, false);
    draw_set_color(_accent);
    draw_rectangle(_layout.left, _layout.top, _layout.right, _layout.top + _layout.height, true);
    draw_rectangle(_layout.left, _layout.top, _layout.right, _layout.top + 3 * _scale, false);
    draw_text_transformed(_layout.x, _layout.top + 22 * _scale, "ITEM ACQUIRED", 0.8 * _scale, 0.8 * _scale, 0);
    draw_set_color(c_white);
    draw_text_transformed(_layout.x, _layout.top + 56 * _scale, _item.name, 1.65 * _scale, 1.65 * _scale, 0);
    draw_text_transformed(_layout.right - 24 * _scale, _layout.top + 12 * _scale, "X", _scale, _scale, 0);
    if (_item.icon >= 0)
    {
        var _icon_w = sprite_get_width(_item.icon);
        var _icon_h = sprite_get_height(_item.icon);
        var _icon_scale = 80 * _scale / max(1, max(_icon_w, _icon_h)); // GUI pixels across the larger icon's longest side.
        draw_sprite_ext(_item.icon, 0,
            _layout.x + (sprite_get_xoffset(_item.icon) - _icon_w * 0.5) * _icon_scale,
            _layout.top + 150 * _scale + (sprite_get_yoffset(_item.icon) - _icon_h * 0.5) * _icon_scale,
            _icon_scale, _icon_scale, 0, c_white, 1);
    }
    draw_text_ext_transformed(_layout.x, _layout.top + 208 * _scale,
        _item.description, -1, (_layout.width - 64 * _scale) / _scale, _scale, _scale, 0);
    var _hover = point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
        _layout.button_left, _layout.button_top, _layout.button_right, _layout.button_bottom);
    draw_set_color(_hover ? make_color_rgb(28, 78, 95) : make_color_rgb(18, 42, 54));
    draw_rectangle(_layout.button_left, _layout.button_top, _layout.button_right, _layout.button_bottom, false);
    draw_set_color(_accent);
    draw_rectangle(_layout.button_left, _layout.button_top, _layout.button_right, _layout.button_bottom, true);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text_transformed(_layout.x, (_layout.button_top + _layout.button_bottom) * 0.5,
        controls_key_name(controls_key("interact")) + " - CONTINUE", 0.9 * _scale, 0.9 * _scale, 0);
    draw_set_font(_font);
    draw_set_color(_color);
    draw_set_alpha(_alpha);
    draw_set_halign(_halign);
    draw_set_valign(_valign);
}

function item_draw_hud(_player)
{
    if (!instance_exists(_player)) return;
    if (!variable_instance_exists(_player, "inventory")) return;

    var _keys = variable_struct_get_names(_player.inventory);
    var _owned = [];

    for (var _i = 0; _i < array_length(_keys); _i++)
    {
        if (item_get_level(_player, _keys[_i]) > 0)
        {
            array_push(_owned, _keys[_i]);
        }
    }

    var _count = array_length(_owned);
    if (_count == 0) return;

    // Layout: invisible slots used only for positioning.
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();
    var _size = 44;
    var _gap = 8;
    var _bottom_margin = 18;
    var _outline_width = 2;

    var _columns = max(
        1,
        floor((_gw - 32) / (_size + _gap))
    );

    var _rows = ceil(_count / _columns);

    var _old_color = draw_get_color();
    var _old_alpha = draw_get_alpha();
    var _old_font = draw_get_font();
    var _old_halign = draw_get_halign();
    var _old_valign = draw_get_valign();

    draw_set_alpha(1);
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _outline_available = shader_is_compiled(sh_ItemOutline);
    var _hovered = undefined;

    for (var _i = 0; _i < _count; _i++)
    {
        var _key = _owned[_i];
        var _amount = item_get_level(_player, _key);
        var _definition = item_get_definition(_key);

        var _row = floor(_i / _columns);
        var _column = _i mod _columns;

        var _row_count = min(
            _columns,
            _count - _row * _columns
        );

        var _row_width = _row_count * _size
            + (_row_count - 1) * _gap;

        var _left = (_gw - _row_width) * 0.5
            + _column * (_size + _gap);

        var _top = _gh - _bottom_margin
            - _rows * _size
            - (_rows - 1) * _gap
            + _row * (_size + _gap);

        var _right = _left + _size;
        var _bottom = _top + _size;
        var _cx = (_left + _right) * 0.5;
        var _cy = (_top + _bottom) * 0.5;
        if (point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0),
            _left, _top, _right, _bottom)) _hovered = _definition;

        var _border = make_color_rgb(192, 192, 192);

        switch (_definition.quality)
        {
            case 2:
                _border = make_color_rgb(70, 220, 90);
                break;

            case 3:
                _border = make_color_rgb(235, 65, 65);
                break;

            case 4:
                _border = make_color_rgb(255, 200, 45);
                break;
        }

        var _sprite = _definition.icon;

        if (sprite_exists(_sprite))
        {
            var _width = sprite_get_width(_sprite);
            var _height = sprite_get_height(_sprite);

            var _scale = (_size - 12)
                / max(1, max(_width, _height));

            var _draw_x = _cx
                + (sprite_get_xoffset(_sprite) - _width * 0.5)
                * _scale;

            var _draw_y = _cy
                + (sprite_get_yoffset(_sprite) - _height * 0.5)
                * _scale;

            if (_outline_available)
            {
                shader_set(sh_ItemOutline);

                shader_set_uniform_f(
                    shader_get_uniform(sh_ItemOutline, "u_time"),
                    (current_time mod 60000) / 1000
                );

                shader_set_uniform_f(
                    shader_get_uniform(sh_ItemOutline, "u_rainbow"),
                    _definition.quality == 5 ? 1 : 0
                );
				shader_set_uniform_f(
				shader_get_uniform(sh_ItemOutline, "u_q4"),
				_definition.quality == 4 ? 1 : 0
				);

                // Offset silhouettes create the sprite-shaped outline.
                for (var _ox = -1; _ox <= 1; _ox++)
                {
                    for (var _oy = -1; _oy <= 1; _oy++)
                    {
                        if (_ox == 0 && _oy == 0) continue;

                        draw_sprite_ext(
                            _sprite,
                            0,
                            _draw_x + _ox * _outline_width,
                            _draw_y + _oy * _outline_width,
                            _scale,
                            _scale,
                            0,
                            _border,
                            1
                        );
                    }
                }

                shader_reset();
            }

            // Original item colours over the outline.
            draw_sprite_ext(
                _sprite,
                0,
                _draw_x,
                _draw_y,
                _scale,
                _scale,
                0,
                c_white,
                1
            );
        }
        else
        {
            draw_set_color(_border);
            draw_text(_cx, _cy, "?");
        }

        // Amount, including single copies.
        var _text = string(_amount);
        var _text_x = _right - 8;
        var _text_y = _bottom - 8;

        draw_set_color(c_black);

        for (var _ox = -1; _ox <= 1; _ox++)
        {
            for (var _oy = -1; _oy <= 1; _oy++)
            {
                draw_text(
                    _text_x + _ox,
                    _text_y + _oy,
                    _text
                );
            }
        }

        draw_set_color(c_white);
        draw_text(_text_x, _text_y, _text);
    }

    // Show the full description on pickup and a compact reminder on hover.
    var _notice = undefined;
    var _notice_text = "";
    if (is_struct(_hovered))
    {
        _notice = _hovered;
        _notice_text = _notice.short_description;
    }
    else if (_player.item_notice_time > 0)
    {
        _notice = item_get_definition(_player.item_notice_key);
        _notice_text = _notice.description;
    }
    if (is_struct(_notice))
    {
        var _box_width = min(440, _gw - 32);
        var _box_bottom = _gh - _bottom_margin - _rows * _size - (_rows - 1) * _gap - 8;
        var _box_height = 68;
        draw_set_color(c_black);
        draw_set_alpha(0.85);
        draw_rectangle((_gw - _box_width) * 0.5, _box_bottom - _box_height,
            (_gw + _box_width) * 0.5, _box_bottom, false);
        draw_set_alpha(1);
        draw_set_color(c_white);
        draw_set_valign(fa_top);
        draw_text(_gw * 0.5, _box_bottom - _box_height + 6, _notice.name);
        draw_text_ext(_gw * 0.5, _box_bottom - _box_height + 24, _notice_text, 16, _box_width - 16);
    }

    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
    draw_set_font(_old_font);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
}
