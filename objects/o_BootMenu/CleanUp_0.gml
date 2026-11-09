if (line_sound != -1 && audio_is_playing(line_sound))
{
    audio_stop_sound(line_sound);
}
if (transition_sound != -1 && audio_is_playing(transition_sound))
{
    audio_stop_sound(transition_sound);
}
