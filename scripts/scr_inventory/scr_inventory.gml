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

    _pickup.item_collected = false;
    _pickup.item_owner = noone;

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
                quality: 1
            };

        case "coin_anchor":
            return {
                name: "Pin House",
                icon: object_get_sprite(o_pinhouse),
                quality: 4
            };
    }

    return {
        name: _key,
        icon: -1,
        quality: 1
    };
}


// Draw the player's inventory at the bottom centre of the GUI.
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

    draw_set_color(_old_color);
    draw_set_alpha(_old_alpha);
    draw_set_font(_old_font);
    draw_set_halign(_old_halign);
    draw_set_valign(_old_valign);
}