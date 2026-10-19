other.wire_contact_effect(id, false);
var _effect = instance_create_depth(
    x,
    y,
    -10000,
    o_ShotImpact,
    {
        impact_direction: 270,
        impact_enemy: false
    }
);

// Small yellow spark burst and brief flash.
_effect.spark_color_start = c_yellow;
_effect.spark_color_end = make_color_rgb(255, 110, 20);
_effect.spark_tail_length = 4;
_effect.flash_radius = 4;
_effect.flash_duration = 0.06;
_effect.flash_life = 0.06;

instance_destroy();