var total_seconds = elapsed_time;

var minutes =
    floor(total_seconds / 60);

var seconds =
    floor(total_seconds) mod 60;

var milliseconds =
    floor(frac(total_seconds) * 1000);


var timer_text =
    string(minutes)
    + ":"
    + string_format(seconds, 2, 0)
    + "."
    + string_format(milliseconds, 3, 0);


draw_text(
    220,
    64,
    timer_text
);