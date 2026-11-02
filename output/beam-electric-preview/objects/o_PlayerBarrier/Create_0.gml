// Group zero uses the collision-event filter: only o_Player can contact this.
// This is deliberately independent of o_Block, so it offers no wall jumps,
// ledge grabs, or enemy footholds.
barrier_bind_physics = function()
{
    var _width = sprite_get_width(sprite_index) * abs(image_xscale);
    var _height = sprite_get_height(sprite_index) * abs(image_yscale);
    var _fix = physics_fixture_create();
    physics_fixture_set_box_shape(_fix, _width / 2, _height / 2);
    physics_fixture_set_density(_fix, 0);
    physics_fixture_set_friction(_fix, 0);
    physics_fixture_set_restitution(_fix, 0);
    physics_fixture_set_collision_group(_fix, 0);
    physics_fixture_bind_ext(_fix, id, _width / 2, _height / 2);
    physics_fixture_delete(_fix);
};
barrier_bind_physics();
