player = noone;


// =====================================
// GET STRETCHED SIZE
// =====================================

var wall_width  = sprite_get_width(sprite_index)  * abs(image_xscale);
var wall_height = sprite_get_height(sprite_index) * abs(image_yscale);


// =====================================
// CREATE PHYSICS FIXTURE
// =====================================

var fix =
    physics_fixture_create();


// Fixture dimensions
physics_fixture_set_box_shape(
    fix,
    wall_width / 2,
    wall_height / 2
);


// =====================================
// PHYSICS PROPERTIES
// =====================================

// 0 density = static / immovable
physics_fixture_set_density(
    fix,
    0
);

physics_fixture_set_friction(
    fix,
    0.5
);

physics_fixture_set_restitution(
    fix,
    0
);


// IMPORTANT:
// Makes it actually collide with the
// player and other group-1 physics objects.
physics_fixture_set_collision_group(
    fix,
    0
);


// =====================================
// ALIGN FIXTURE WITH STRETCHED SPRITE
// =====================================

physics_fixture_bind_ext(
    fix,
    id,
    wall_width / 2,
    wall_height / 2
);


// Fixture definition no longer needed
physics_fixture_delete(fix);