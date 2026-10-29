freecam_restore_layers();
if (!enabled || menu_exhibition_active() || world_frozen || !global.dev_collisions) exit;
var _color = draw_get_color();
var _alpha = draw_get_alpha();
draw_set_alpha(1);
// Native Box2D shapes show the actual bound fixtures, including slide changes.
physics_world_draw_debug(phy_debug_render_shapes);
with (all)
{
    if (sprite_index == -1 && mask_index == -1) continue;
    var _name = object_get_name(object_index);
    var _tint = c_gray;
    if (object_index == o_Player) _tint = c_aqua;
    else if (object_index == oEnemyParent || object_is_ancestor(object_index, oEnemyParent)) _tint = c_red;
    else if (string_pos("Block", _name) > 0 || string_pos("Door", _name) > 0 || string_pos("Chute", _name) > 0) _tint = c_lime;
    else if (string_pos("Bullet", _name) > 0 || string_pos("Slash", _name) > 0 || string_pos("Beam", _name) > 0 || string_pos("Trap", _name) > 0) _tint = c_yellow;
    draw_set_color(_tint);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
}
draw_set_color(_color);
draw_set_alpha(_alpha);
