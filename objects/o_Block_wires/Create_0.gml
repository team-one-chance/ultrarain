player = noone;

// Electrical bursts. Distances are in room pixels; times are in seconds.
wire_arc_reach = 27;
wire_arc_count = random_range(3, 10); // Simultaneous arcs per burst; 0 disables arcs.
wire_burst_interval_min = 0.15;
wire_burst_interval_max = 0.5;
wire_burst_timer = random_range(wire_burst_interval_min, wire_burst_interval_max);
wire_arcs = [];


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
    1
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
