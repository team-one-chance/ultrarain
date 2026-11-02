player = noone;
broken = false;
block_hp = 30;
vent_cover_layer = "fade2blackvent";
vent_cover_names = [];

image_speed = 0;

var _width = sprite_get_width(sprite_index);
var _height = sprite_get_height(sprite_index);

var _fix = physics_fixture_create();

physics_fixture_set_box_shape(
    _fix,
    _width * abs(image_xscale) / 2,
    _height * abs(image_yscale) / 2
);

physics_fixture_set_density(_fix, 0);
physics_fixture_set_friction(_fix, 0.5);
physics_fixture_set_restitution(_fix, 0);
physics_fixture_set_collision_group(_fix, 1);

physics_fixture_bind_ext(
    _fix,
    id,
    (_width / 2 - sprite_get_xoffset(sprite_index)) * image_xscale,
    (_height / 2 - sprite_get_yoffset(sprite_index)) * image_yscale
);

physics_fixture_delete(_fix);

take_damage = function(_damage)
{
    if (broken || _damage <= 0) return;

    block_hp = max(0, block_hp - _damage);

    if (block_hp > 0) return;

    broken = true;
    with (oDrone) nav_grid_dirty = true;

    var _layer = layer_get_id(vent_cover_layer);

    if (_layer != -1)
    {
        for (var _i = 0; _i < array_length(vent_cover_names); _i++)
        {
            var _cover = layer_sprite_get_id(_layer, vent_cover_names[_i]);

            if (_cover != -1)
            {
                layer_sprite_destroy(_cover);
            }
        }
    }

    repeat (16)
    {
        instance_create_depth(
            random_range(bbox_left, bbox_right),
            random_range(bbox_top, bbox_bottom),
            depth - 1,
            o_DoorDebris
        );
    }

    // Destroying the instance also removes its physics collider.
    instance_destroy();
};