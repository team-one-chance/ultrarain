other.wire_contact_effect(id, false);

instance_create_depth(
    x,
    y,
    -10000,
    o_ShotImpact,
    {
        impact_direction: point_direction(other.x, other.y, x, y) + 180,
        impact_enemy: false
    }
);

instance_destroy();