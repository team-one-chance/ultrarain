// =====================================
// DURATION
// =====================================
if (slash_owner != noone)
{
    if (!sync_sword_swing() || !slash_can_damage) exit;
}
else
{
// Standalone effects retain time-based playback.
if (slash_animation_finished)
{
    instance_destroy();
    exit;
}

slash_age += delta_time / 1000000;
var slash_progress = clamp(slash_age / max(0.001, duration), 0, 1);
image_index = min(image_number - 1, floor(slash_progress * image_number));
slash_animation_finished = slash_progress >= 1;
}

// =====================================
// DAMAGE ENEMIES TOUCHING THE SLASH
// =====================================
var hits = ds_list_create();

collision_rectangle_list(
    bbox_left, bbox_top, bbox_right, bbox_bottom,
    oEnemyParent, false, true, hits, false
);

var _facing = sign(image_xscale);
if (_facing == 0) _facing = 1;

var _beam_dir = (_facing > 0) ? 0 : 180;

for (var i = 0; i < ds_list_size(hits); i++)
{
    var enemy = hits[| i];

    if (
        instance_exists(enemy)
        && ds_list_find_index(hit_enemies, enemy) == -1
    )
    {
        ds_list_add(hit_enemies, enemy);
        enemy.take_damage(
            slash_damage,
            _beam_dir,
            knockback_force,
            true
        );
    }
}

ds_list_destroy(hits);

var _blocks = ds_list_create();

collision_rectangle_list(
    bbox_left,
    bbox_top,
    bbox_right,
    bbox_bottom,
    o_Block_Breakable,
    false,
    true,
    _blocks,
    false
);

for (var b = 0; b < ds_list_size(_blocks); b++)
{
    var _block = _blocks[| b];

    if (instance_exists(_block))
    {
        _block.take_damage(slash_damage);
    }
}

ds_list_destroy(_blocks);

// =====================================
// ONE COIN CONTACT CONSUMES ALL FIELD COINS
// =====================================
if (!coin_beam_released)
{
    var coins = ds_list_create();

    collision_rectangle_list(
        bbox_left, bbox_top, bbox_right, bbox_bottom,
        o_Coin, false, true, coins, false
    );

    var _hit_coin = noone;

    for (var c = 0; c < ds_list_size(coins); c++)
    {
        var _candidate = coins[| c];
        if (instance_exists(_candidate))
        {
            _hit_coin = _candidate;
            break;
        }
    }

    if (_hit_coin != noone)
    {
        // Snapshot live room coins before destroying any of them.
        // This includes pinned coins and coins outside the slash.
        var _field_coins = ds_list_create();

        with (o_Coin)
        {
            ds_list_add(_field_coins, id);
        }

        var _coins_used = ds_list_size(_field_coins);
        var _beam_x = _hit_coin.x;

        // Lock this slash before releasing the beam.
        coin_beam_released = true;

        // Keep your original single-coin beam spawn height.
        var beam = instance_create_layer(
            _beam_x,
            y,
            "Instances",
            oSwordBeam
        );

        beam.configure_coin_beam(_coins_used, _beam_dir);

        for (var k = 0; k < _coins_used; k++)
        {
            var _consumed_coin = _field_coins[| k];

            if (instance_exists(_consumed_coin))
            {
                instance_destroy(_consumed_coin);
            }
        }

        ds_list_destroy(_field_coins);
    }

    ds_list_destroy(coins);
}
