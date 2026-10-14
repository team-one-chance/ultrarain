// One leader updates the clock for all gears before their normal Step events.
var _leader = instance_find(o_GrinderLeft, 0);
if (_leader == noone) _leader = instance_find(o_GrinderRight, 0);
if (id == _leader) {
    var _dt = (variable_global_exists("dev_delta_time")
        ? global.dev_delta_time : delta_time) / 1000000;
    global.grinder_animation_time = (global.grinder_animation_time + _dt) mod 3;
}
