if (!reading) exit;

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _pw = min(900, _gw - 40);
var _ph = min(420, _gh - 40);
var _px = (_gw - _pw) * 0.5;
var _py = (_gh - _ph) * 0.5;

draw_set_color(c_black);
draw_set_alpha(0.75);
draw_rectangle(0, 0, _gw, _gh, false);

draw_set_alpha(1);
draw_set_color(make_color_rgb(18, 22, 28));
draw_rectangle(
    _px, _py,
    _px + _pw, _py + _ph,
    false
);

draw_set_color(c_white);
draw_rectangle(
    _px, _py,
    _px + _pw, _py + _ph,
    true
);

draw_set_halign(fa_center);
draw_text(_gw * 0.5, _py + 24, terminal_title);

draw_set_halign(fa_left);
draw_text_ext(
    _px + 32,
    _py + 70,
    terminal_display_text,
    24,
    _pw - 64
);

// Command hint.
draw_set_halign(fa_left);
draw_set_color(make_color_rgb(130, 145, 140));

draw_text(
    _px + 32,
    _py + _ph - 118,
    "To restart: VRAIN initiate restart.exe"
);

// Command input, using the menu's console font.
var _previous_font = draw_get_font();
draw_set_font(f_Console);
draw_set_color(make_color_rgb(90, 235, 130));

var _input_x = _px + 32;
var _input_y = _py + _ph - 90;
var _input_text = "> " + command_input;

draw_text(_input_x, _input_y, _input_text);

// Blinking block cursor.
if (floor(command_cursor_timer / 0.5) mod 2 == 0)
{
    var _cursor_x =
        _input_x + string_width(_input_text) + 4;

    draw_rectangle(
        _cursor_x,
        _input_y + 3,
        _cursor_x + 9,
        _input_y + 21,
        false
    );
}

draw_set_font(_previous_font);

// Feedback for an invalid command.
draw_set_color(command_restart_pending ? c_lime : make_color_rgb(255, 70, 70));
draw_text(
    _px + 32,
    _py + _ph - 62,
    command_feedback
);

draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(
    _gw * 0.5,
    _py + _ph - 36,
    "ENTER — EXECUTE    |    ESC — CLOSE"
);

draw_set_halign(fa_left);
draw_set_alpha(1);
draw_set_color(c_white);
