// Carry the final white overlay into the tutorial.
persistent = true;
depth = 100;

boot_state = 0;
state_elapsed = 0;
boot_elapsed = 0;

console_lines = [];
scroll_timer = 0;
scroll_interval = 0.1;

console_green = make_color_rgb(90, 235, 130);
console_red = make_color_rgb(255, 55, 65);
console_white = make_color_rgb(215, 225, 220);
console_dim = make_color_rgb(90, 110, 100);

boot_add_line = function(_text, _color)
{
    array_push(console_lines, {
        message: _text,
        tint: _color
    });

    // Keep a bounded history.
    if (array_length(console_lines) > 80)
    {
        array_delete(console_lines, 0, 1);
    }
};

boot_set_state = function(_state)
{
    boot_state = _state;
    state_elapsed = 0;
};

boot_add_line(
    "PS C:\\SYSTEM> .\\sleep.exe",
    console_white
);

boot_add_line(
    "[OK] sleep.exe initiated",
    console_green
);