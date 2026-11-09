var _player = instance_find(o_Player, 0);
if (!instance_exists(_player) || _player.pHP <= 0 || _player.grinder_dying
    || _player.hacking_controller != noone || !layer_get_visible(layer)) exit;
if (variable_global_exists("dev_freecam") && global.dev_freecam) exit;
if (!input_prompt_available(id, _player)) exit;

// Show only the highest-priority matching prompt; nearest wins ties.
var _distance = point_distance(x, y, _player.x, _player.y);
var _winner = id;
for (var _i = 0; _i < instance_number(o_InputPrompt); _i++)
{
    var _candidate = instance_find(o_InputPrompt, _i);
    if (_candidate == id || !input_prompt_available(_candidate, _player)) continue;
    var _candidate_distance = point_distance(_candidate.x, _candidate.y, _player.x, _player.y);
    if (_candidate.priority > priority || (_candidate.priority == priority
        && (_candidate_distance < _distance || (_candidate_distance == _distance && _candidate.id < id))))
    {
        _winner = _candidate;
        break;
    }
}
if (_winner != id) exit;
var _text = prompt_text == "" ? prompt_definition.text : prompt_text;
input_prompt_draw(prompt_definition, _text, display_get_gui_width() * 0.5, display_get_gui_height() * 0.2, prompt_id, prompt_scale);
