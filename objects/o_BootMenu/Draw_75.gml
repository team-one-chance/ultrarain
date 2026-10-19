var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Preserve drawing settings for other objects.
var _old_font = draw_get_font();
var _old_color = draw_get_color();
var _old_alpha = draw_get_alpha();
var _old_halign = draw_get_halign();
var _old_valign = draw_get_valign();

draw_set_font(f_Console);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

// Stop drawing the console once the tutorial is entered.
if (boot_state != 8)
{
    draw_set_color(make_color_rgb(5, 8, 7));
    draw_rectangle(0, 0, _gw, _gh, false);

    // Shake the console during the crash.
    var _shake_x = 0;
    var _shake_y = 0;

    if (boot_state == 2)
    {
        var _strength =
            12 * (1 - clamp(state_elapsed / 0.65, 0, 1));

        _shake_x = random_range(-_strength, _strength);
        _shake_y = random_range(-_strength, _strength);
    }

    var _text_x = 32 + _shake_x;

    draw_set_color(console_dim);
    draw_text(
        _text_x,
        24 + _shake_y,
        "ULTRARAIN SYSTEM CONSOLE [SESSION 07103026]"	
    );

    draw_line(
        32 + _shake_x,
        58 + _shake_y,
        _gw - 32 + _shake_x,
        58 + _shake_y
    );

    // Display the newest lines; older output scrolls away.
    var _line_height = 34;
    var _max_lines =
        max(1, floor((_gh - 160) / _line_height));

    var _count = array_length(console_lines);
    var _first = max(0, _count - _max_lines);

    for (var _i = _first; _i < _count; _i++)
    {
        var _entry = console_lines[_i];

        draw_set_color(_entry.tint);

        if (_entry.message == "> rules.exe overwriting..."
        && transition_sound != -1 && audio_is_playing(transition_sound))
        {
            var _sample = clamp(
                floor(audio_sound_get_track_position(transition_sound) / 0.05),
                0, array_length(transition_envelope) - 1
            );
            draw_set_alpha(0.15 + 0.85 * transition_envelope[_sample]);
        }

var _text_scale =
    (_entry.message == "> rules.exe overwriting...")
    ? 1.3 : 1;

draw_text_transformed(
    _text_x,
    82 + (_i - _first) * _line_height + _shake_y,
    _entry.message,
    _text_scale,
    _text_scale,
    0
);
        draw_set_alpha(1);
    }

    // Enter prompt and blinking block cursor.
if (boot_state == 0 || boot_state == 4)
{
    var _prompt = "Press ENTER to exit sleep.exe";

    if (boot_state == 4)
    {
        _prompt = "Press ENTER to rename rules.exe into freewill.exe";
    }
        var _prompt_y = _gh - 58;

        draw_set_color(console_white);
        draw_text(_text_x, _prompt_y, _prompt);

        if (floor(boot_elapsed / 0.5) mod 2 == 0)
        {
            var _cursor_x =
                _text_x + string_width(_prompt) + 12;

            draw_set_color(console_green);

            draw_rectangle(
                _cursor_x,
                _prompt_y + 3,
                _cursor_x + 10,
                _prompt_y + 22,
                false
            );
        }
    }

    // Red flash over the console during the crash.
    if (boot_state == 2)
    {
        var _crash_alpha =
            0.3 * (1 - clamp(state_elapsed / 0.65, 0, 1));

        draw_set_color(console_red);
        draw_set_alpha(_crash_alpha);
        draw_rectangle(0, 0, _gw, _gh, false);
        draw_set_alpha(1);
    }
}

// White blinks, white fade, then tutorial reveal.
var _white_alpha = 0;

if (boot_state == 6)
{
    if (floor(state_elapsed / 0.12) mod 2 == 0)
    {
        _white_alpha = 0.85;
    }
}
else if (boot_state == 7)
{
    _white_alpha = clamp(state_elapsed / 0.65, 0, 1);
}
else if (boot_state == 8)
{
    _white_alpha = 1 - clamp(state_elapsed / 0.85, 0, 1);
}

if (_white_alpha > 0)
{
    draw_set_color(c_white);
    draw_set_alpha(_white_alpha);
    draw_rectangle(0, 0, _gw, _gh, false);
}

// Restore drawing settings.
draw_set_font(_old_font);
draw_set_color(_old_color);
draw_set_alpha(_old_alpha);
draw_set_halign(_old_halign);
draw_set_valign(_old_valign);
