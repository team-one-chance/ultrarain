draw_sprite_ext(s_RobotDropHatch, 0, x, y, 1, 1, 0, c_white, hatch_alpha);
// Crop the moving shutters at the mouth so they retract into its housing.
var _shown = ceil(40 * (1 - hatch_open));
if (_shown > 0) {
    draw_sprite_part_ext(s_RobotDropHatch, 1, 8 + 40 - _shown, 8, _shown, 16,
        x - 40, y - 8, 1, 1, c_white, hatch_alpha);
    draw_sprite_part_ext(s_RobotDropHatch, 1, 48, 8, _shown, 16,
        x + 40 - _shown, y - 8, 1, 1, c_white, hatch_alpha);
}
