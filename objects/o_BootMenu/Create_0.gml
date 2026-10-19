// Carry the final white overlay into the tutorial.
persistent = true;
depth = 100;

boot_state = 0;
state_elapsed = 0;
boot_elapsed = 0;

console_lines = [];
line_sound = -1;
transition_sound = -1;
overwrite_started = false;
// Normalized trans1 loudness in 50 ms windows, used to flash with its pulses.
transition_envelope = [
    1, 0.951, 0.958, 0.807, 0.234, 0.197, 0.15, 0.03, 0.477,
    0.998, 0.928, 0.968, 0.64, 0.221, 0.189, 0.12, 0.009, 0.717,
    0.968, 0.947, 0.984, 0.351, 0.211, 0.179, 0.087, 0.001,
    0.891, 0.954, 0.945, 0.892, 0.239, 0.201, 0.164, 0.052, 0.001
];
scroll_timer = 0;
scroll_interval = 0.1;

console_green = make_color_rgb(90, 235, 130);
console_red = make_color_rgb(255, 55, 65);
console_white = make_color_rgb(215, 225, 220);
console_dim = make_color_rgb(90, 110, 100);

boot_add_line = function(_text, _color, _play_sfx = true)
{
    // Restart the terminal cue for each new line without overlapping it.
    if (line_sound != -1 && audio_is_playing(line_sound))
    {
        audio_stop_sound(line_sound);
    }
    line_sound = -1;
    if (_play_sfx && !audio_is_playing(sfxInitOpen)
    && !audio_is_playing(sfxInitEnter1)
    && !audio_is_playing(sfxInitEnter2))
    {
        if (transition_sound != -1 && audio_is_playing(transition_sound))
        {
            audio_stop_sound(transition_sound);
        }
        line_sound = audio_play_sound(sfxInitBG, 1, false);
    }

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

audio_play_sound(sfxInitOpen, 1, false);

boot_add_line(
    "PS C:\\SYSTEM> .\\sleep.exe",
    console_white
);

boot_add_line(
    "[OK] sleep.exe initiated",
    console_green
);
