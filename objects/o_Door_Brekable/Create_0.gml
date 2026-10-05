broken = false;
break_requested = false;
door_hp = 50;



door_take_damage = function(_amount)
{
    if (broken || break_requested) return;

    door_hp = max(0, door_hp - max(0, _amount));

    show_debug_message(
        "Door hit: damage=" + string(_amount)
        + ", HP remaining=" + string(door_hp)
    );

    if (door_hp <= 0)
    {
        show_debug_message("Door break requested");
        door_break();
    }
};



image_index = 0;
image_speed = 0;

flash_elapsed = 0;
flash_duration = 0.9;

// Static collider covering the sprite.
// Keep the door unrotated in the room.
var _width = sprite_get_width(sprite_index) * abs(image_xscale);
var _height = sprite_get_height(sprite_index) * abs(image_yscale);

var _fix = physics_fixture_create();

physics_fixture_set_box_shape(_fix, _width / 2, _height / 2);

// Density 0 makes this a stationary obstacle.
physics_fixture_set_density(_fix, 0);
physics_fixture_set_friction(_fix, 0.5);
physics_fixture_set_restitution(_fix, 0);
physics_fixture_set_collision_group(_fix, 1);

door_fixture = physics_fixture_bind_ext(
    _fix,
    id,
    (sprite_get_width(sprite_index) / 2
        - sprite_get_xoffset(sprite_index)) * image_xscale,
    (sprite_get_height(sprite_index) / 2
        - sprite_get_yoffset(sprite_index)) * image_yscale
);

physics_fixture_delete(_fix);

// Request a break. The Step event handles it safely.
door_break = function()
{
    if (!broken)
    {
        break_requested = true;
    }
};