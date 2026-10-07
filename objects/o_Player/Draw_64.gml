// =====================================
// PERFECT APEX WHITE FLASH
// =====================================

if (perfect_apex_flash_timer > 0)
{
    var _flash_alpha =
        perfect_apex_flash_timer
        / perfect_apex_flash_duration;

    draw_set_color(c_white);
    draw_set_alpha(0.45);

    draw_rectangle(
        0,
        0,
        display_get_gui_width(),
        display_get_gui_height(),
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
}

// =====================================
// PLAYER HP BAR
// =====================================

var bar_x = 20;
var bar_y = 20;

var bar_width = 200;
var bar_height = 20;

var hp_percent = pHP / pHP_max;

// Keep value between 0 and 1
hp_percent = clamp(hp_percent, 0, 1);
// White outline
var bar_outline = 2;

draw_set_color(c_white);

draw_rectangle(
    bar_x - bar_outline,
    bar_y - bar_outline,
    bar_x + bar_width + bar_outline,
    bar_y + bar_height + bar_outline,
    false
);
// Background
draw_set_color(c_black);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + bar_width,
    bar_y + bar_height,
    false
);

// HP colour
var hp_colour = c_lime;

if (hp_percent < 0.25)
{
    hp_colour = c_red;
}
else if (hp_percent < 0.50)
{
    hp_colour = make_colour_rgb(255, 100, 0);
}
else if (hp_percent < 0.75)
{
    hp_colour = c_yellow;
}

draw_set_color(hp_colour);

draw_rectangle(
    bar_x,
    bar_y,
    bar_x + (bar_width * hp_percent),
    bar_y + bar_height,
    false
);

// HP text
draw_set_color(c_white);

draw_text(
    bar_x,
    bar_y + bar_height + 5,
    string(pHP) + " / " + string(pHP_max)
);

// Reset
draw_set_color(c_white);

if (medkit_owned)
{
    draw_set_alpha(1);

    for (var i = 0; i < syringe_max; i++)
    {
        var _sx = bar_x + 8 + i * 24;
        var _sy = bar_y + bar_height + 36;

        draw_set_color(i < syringe_count ? c_lime : c_dkgray);

        // Plunger, body and needle.
        draw_rectangle(_sx - 4, _sy, _sx + 4, _sy + 2, false);
        draw_line(_sx, _sy + 2, _sx, _sy + 5);
        draw_rectangle(_sx - 3, _sy + 5, _sx + 3, _sy + 17, false);
        draw_line(_sx, _sy + 18, _sx, _sy + 24);
    }

    draw_set_color(c_white);
}
// =====================================
// COIN ICON AND COUNTER
// =====================================

var coin_gui_x = 20;
var coin_gui_y = 75;

var coin_icon_scale = 2.5;
var coin_icon_gap = 6;

var coin_text = string(coin_count) + "/" + string(coin_max);

var old_colour = draw_get_color();
var old_alpha = draw_get_alpha();
var old_halign = draw_get_halign();
var old_valign = draw_get_valign();

draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Centre the icon vertically beside the text.
var icon_width = sprite_get_width(s_Coin) * coin_icon_scale;
var icon_height = sprite_get_height(s_Coin) * coin_icon_scale;

var icon_top = coin_gui_y
    + floor((string_height(coin_text) - icon_height) * 0.5);

// Account for the sprite's origin.
draw_sprite_ext(
    s_Coin,
    0,
    coin_gui_x + sprite_get_xoffset(s_Coin) * coin_icon_scale,
    icon_top + sprite_get_yoffset(s_Coin) * coin_icon_scale,
    coin_icon_scale,
    coin_icon_scale,
    0,
    c_white,
    1
);

draw_text(
    coin_gui_x + icon_width + coin_icon_gap,
    coin_gui_y,
    coin_text
);

draw_set_color(old_colour);
draw_set_alpha(old_alpha);
draw_set_halign(old_halign);
draw_set_valign(old_valign);

// =====================================
// WEAPON LOADOUT GUI
// =====================================

// Position and sizing
var weapons_gui_x = 20;
var weapons_gui_y = 110;
var weapon_slot_size = 44;
var weapon_slot_gap = 8;
// Pistol size, sword size
var weapon_icon_sizes = [28, 40];

var weapon_icons = [s_Pistol, sDarkRepulsor];
var weapon_names = ["pistol", "sword"];

// Preserve drawing settings
var weapons_old_colour = draw_get_color();
var weapons_old_alpha = draw_get_alpha();
var weapons_old_halign = draw_get_halign();
var weapons_old_valign = draw_get_valign();

draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);

for (var i = 0; i < 2; i++)
{
    var slot_x = weapons_gui_x
        + i * (weapon_slot_size + weapon_slot_gap);

    var slot_y = weapons_gui_y;
    var equipped = weapon_type == weapon_names[i];

    // Slot background
    draw_set_color(
        equipped
        ? make_color_rgb(25, 65, 85)
        : make_color_rgb(84, 84, 84)
    );

    draw_rectangle(
        slot_x,
        slot_y,
        slot_x + weapon_slot_size,
        slot_y + weapon_slot_size,
        false
    );

    // Highlight the equipped slot
    var border_colour = equipped
        ? make_color_rgb(90, 220, 255)
        : make_color_rgb(80, 80, 90);

    draw_set_color(border_colour);

    draw_rectangle(
        slot_x,
        slot_y,
        slot_x + weapon_slot_size,
        slot_y + weapon_slot_size,
        true
    );

    // Fit the sprite inside its slot
    var icon_sprite = weapon_icons[i];
    var icon_w = sprite_get_width(icon_sprite);
    var icon_h = sprite_get_height(icon_sprite);

    var icon_scale = weapon_icon_sizes[i]
    / max(1, max(icon_w, icon_h));

    var centre_x = slot_x + weapon_slot_size * 0.5;
    var centre_y = slot_y + weapon_slot_size * 0.5;

    // Centre correctly regardless of sprite origin
    var icon_x = centre_x
        + (sprite_get_xoffset(icon_sprite) - icon_w * 0.5)
        * icon_scale;

    var icon_y = centre_y
        + (sprite_get_yoffset(icon_sprite) - icon_h * 0.5)
        * icon_scale;

    draw_sprite_ext(
        icon_sprite,
        0,
        icon_x,
        icon_y,
        icon_scale,
        icon_scale,
        0,
        c_white,
        equipped ? 1 : 0.6
    );

    // Keyboard shortcut beneath the slot
    draw_set_color(equipped ? border_colour : c_white);

    draw_text(
        centre_x,
        slot_y + weapon_slot_size + 4,
        string(i + 1)
    );
}

draw_set_color(weapons_old_colour);
draw_set_alpha(weapons_old_alpha);
draw_set_halign(weapons_old_halign);
draw_set_valign(weapons_old_valign);
