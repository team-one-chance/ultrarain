// Place in a room: choose prompt_id from scr_input_prompts and optionally set
// prompt_text to override its label. Empty text uses the shared definition.
// Position is the trigger centre; width and height are room pixels. A larger
// priority wins when areas overlap; equal priorities select the closest centre.
prompt_definition = input_prompt_definition(prompt_id);
prompt_scale = room == LE_TUTORIAL_WIP ? 2 : 1; // GUI size multiplier; doubles tutorial icons, text, and backing panel.
