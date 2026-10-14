var _dt = (variable_global_exists("dev_delta_time")
    ? global.dev_delta_time : delta_time) / 1000000;
drop_timer -= _dt;
if (drop_timer <= 0) {
    drop_timer = drop_interval + random_range(-0.04, 0.04);
    var _batch = choose(1, 1, 2);
    repeat (_batch) {
        // Include in-flight hatch releases when reserving room for the next body.
        if (instance_number(o_FallingRobotScrap) + instance_number(o_RobotDropHatch)
            >= max_falling_bodies) break;
        var _hatch = instance_create_depth(random_range(drop_min_x, drop_max_x),
            random_range(drop_min_y, drop_max_y), depth - 2, o_RobotDropHatch);
        _hatch.drop_emitter = id;
    }
}
