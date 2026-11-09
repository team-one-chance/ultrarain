// =====================================
// LIFETIME
// =====================================
var _dt = (variable_global_exists("dev_delta_time") ? (variable_global_exists("dev_delta_time") ? global.dev_delta_time : delta_time) : delta_time) / 1000000;
beam_age += _dt;
life -= _dt;

if (life <= 0)
{
    instance_destroy();
    exit;
}

// Keep your original movement speed in pixels per Step.
var move_x = lengthdir_x(move_speed, move_dir);
var move_y = lengthdir_y(move_speed, move_dir);

// =====================================
// ENEMY AOE: ENLARGED SPRITE BOUNDS
// =====================================
var old_left = bbox_left;
var old_top = bbox_top;
var old_right = bbox_right;
var old_bottom = bbox_bottom;

var sweep_left = min(old_left, old_left + move_x);
var sweep_top = min(old_top, old_top + move_y);
var sweep_right = max(old_right, old_right + move_x);
var sweep_bottom = max(old_bottom, old_bottom + move_y);



var _blocks = ds_list_create();

collision_rectangle_list(
    sweep_left,
    sweep_top,
    sweep_right,
    sweep_bottom,
    o_Block_Breakable,
    false,
    true,
    _blocks,
    false
);

var _hit_block = false;

for (var b = 0; b < ds_list_size(_blocks); b++)
{
    var _block = _blocks[| b];

    if (instance_exists(_block) && beam_damage > 0)
    {
        _hit_block = true;
        _block.take_damage(beam_damage);
    }
}

ds_list_destroy(_blocks);

if (_hit_block)
{
    instance_destroy();
    exit;
}

// =====================================
// WALLS: KEEP THE ORIGINAL CORE SIZE
// =====================================
// Undo only the coin growth when checking walls. An enlarged damage area
// can brush the floor without destroying the beam immediately.
var _core_left = x + (old_left - x) / beam_aoe_scale;
var _core_top = y + (old_top - y) / beam_aoe_scale;
var _core_right = x + (old_right - x) / beam_aoe_scale;
var _core_bottom = y + (old_bottom - y) / beam_aoe_scale;

if (collision_rectangle(
    min(_core_left, _core_left + move_x),
    min(_core_top, _core_top + move_y),
    max(_core_right, _core_right + move_x),
    max(_core_bottom, _core_bottom + move_y),
    o_Block,
    false,
    true
) != noone)
{
    instance_destroy();
    exit;
}

x += move_x;
y += move_y;

// =====================================
// DAMAGE EACH ENEMY ONCE
// =====================================
var hits = ds_list_create();

collision_rectangle_list(
    sweep_left, sweep_top, sweep_right, sweep_bottom,
    oEnemyParent, false, true, hits, false
);

for (var i = 0; i < ds_list_size(hits); i++)
{
    var enemy = hits[| i];

    if (
        instance_exists(enemy)
        && ds_list_find_index(hit_enemies, enemy) == -1
    )
    {
        ds_list_add(hit_enemies, enemy);

        apply_beam_hit(enemy);
    }
}

ds_list_destroy(hits);
