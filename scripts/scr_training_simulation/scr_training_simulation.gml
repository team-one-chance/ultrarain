/// Shared shield material response; changing these values affects every shield user.
function shield_material_settings()
{
    return { bullet: 0.10, sword: 5 }; // Damage multipliers: bullets chip, swords rapidly strip shielding.
}

function training_active()
{
    return room == r_preTutorial && instance_exists(o_TrainingSimulation);
}

// Input bindings remain shared; only simulation availability is filtered here.
function training_action_allowed(_action)
{
    if (!training_active()) return true;
    var _controller = instance_find(o_TrainingSimulation, 0);
    if (_controller.reset_pending || _controller.ending_time >= 0) return false;
    var _section = _controller.section;
    switch (_action)
    {
        case "left": case "right": case "jump": case "up":
            return _section != 0 && _section != 8;
        case "slide": case "dash": return _section >= 2 && _section != 8;
        case "wall": case "slam": return _section >= 3 && _section != 8;
        case "coin":
            if (instance_exists(o_Player) && o_Player.weapon_type == "sword") return _section >= 5;
            return _section >= 7 && (_section != 7 || _controller.stage >= 1);
        case "throw_coin": return _section >= 7 && (_section != 7 || _controller.stage >= 1);
        case "pin": return false; // Coin pinning is not part of this program.
        case "heal": return _section >= 9;
    }
    return true;
}

function training_action(_action)
{
    if (!training_active()) return;
    var _controller = instance_find(o_TrainingSimulation, 0);
    if (_controller.reset_pending || _controller.ending_time >= 0) return;
    if (_action == "direct_coin")
    {
        if (_controller.section == 7 && _controller.stage >= 1) _controller.coin_hits = min(3, _controller.coin_hits + 1);
        return;
    }
    if (_action == "wall") return; // A single contact is insufficient; training_update measures a sustained hold.
    variable_struct_set(_controller.actions, _action, true);
}

function training_dissolve(_x, _y)
{
    if (!training_active()) return;
    instance_create_depth(_x, _y, -9000, o_TrainingDigitalFX);
}

// Kills, rather than vanished instance references, drive encounter progression.
function training_defeated(_target)
{
    if (!training_active() || !variable_instance_exists(_target, "training_generation")) return;
    var _controller = instance_find(o_TrainingSimulation, 0);
    if (_target.training_generation != _controller.generation) return;
    for (var _i = 0; _i < array_length(_controller.targets); ++_i)
    {
        if (_controller.targets[_i].actor == _target)
            _controller.targets[_i].defeated = true;
    }
}

function training_initialize()
{
    section = -1; // Ordered section index; printed with a one-based number in diagnostics.
    generation = 0; // Reset token invalidates callbacks belonging to a previous encounter.
    reset_pending = false;
    resetting = false;
    targets = [];
    floor_blocks = [];
    section_geometry = []; // Runtime colliders/barriers owned by this section; never saved in the room.
    wall_gate = noone;
    wall_hold_time = 0; // Seconds continuously holding a wall at near-zero vertical speed.
    wall_hold_required = 0.35; // Seconds required; longer values make a passing wall brush less likely to qualify.
    materials_camera_top = 16800; // Room Y: hides courses above materials while leaving player headroom below the enlarged HUD.
    ui_text_scale = 1.75; // Multiplier on the tutorial font before adapting to GUI resolution.
    ui_prompt_scale = 1.5; // Multiplier on icons and binding text before adapting to GUI resolution.
    actions = {};
    notes = [];
    stage = 0;
    coin_hits = 0;
    elapsed = 0;
    text_age = 0;
    transition_time = 0;
    ending_time = -1;
    debug_visible = false;
    objective = "";
    prompt = "";
    terminal_ready = false;
    // Read every authored note at runtime, preserving the editor resource and overrides.
    with (o_Notes)
        array_push(other.notes, { title: note_name, description: notes, x: x, y: y,
            right: bbox_right, bottom: bbox_bottom });
    layer_set_visible("notes", false);
    note = function(_title, _index = 0)
    {
        for (var _i = 0; _i < array_length(notes); ++_i)
        {
            if (notes[_i].title != _title) continue;
            if (_index-- == 0) return notes[_i];
        }
        show_error("Training note missing: " + _title, true);
    };
    say = function(_text, _prompt = "")
    {
        objective = _text;
        prompt = _prompt;
        text_age = 0;
        audio_play_sound(sfxInitOpen, 1, false, 0.35);
    };
    demonstrated = function(_action)
    {
        return variable_struct_exists(actions, _action) && variable_struct_get(actions, _action);
    };
    snap_camera = function()
    {
        if (!instance_exists(o_Player)) return;
        var _camera = view_camera[0];
        if (_camera == -1) return;
        // Physics coordinates update immediately; x/y can still describe the source until the physics tick.
        camera_set_view_pos(_camera, o_Player.phy_position_x - camera_get_view_width(_camera) / 2,
            training_camera_y(o_Player.phy_position_y - camera_get_view_height(_camera) / 1.4));
        if (instance_exists(o_CAMERA))
        {
            o_CAMERA.shake_offset_x = 0;
            o_CAMERA.shake_offset_y = 0;
            o_CAMERA.shake_remaining_seconds = 0;
        }
    };
    teleport = function(_title)
    {
        var _spawn = note(_title);
        with (o_Player)
        {
            stop_movement_sfx();
            phy_position_x = _spawn.x + 16;
            phy_position_y = _spawn.y + 32;
            // Synchronize draw/collision queries before another event can inspect the destination.
            x = phy_position_x;
            y = phy_position_y;
            phy_speed_x = 0;
            phy_speed_y = 0;
            damage_knockback_timer = 0;
            damage_knockback_pending = false;
            trap_knockback_timer = 0;
            trap_bounce_pending = false;
            sword_swing_timer = 0;
            sword_swing_pending_hit = false;
            parry_timer = 0;
            chip_wall_release_timer = 0;
            chip_waiting_for_landing = false;
            is_slamming = false;
            is_sliding = false;
            dash_active = false;
            is_ledge_climbing = false;
            is_mantle_lunging = false;
            // Clear the sliding footprint even if the old position was under a low ceiling.
            player_set_collider(false, true);
            dash_current_speed = 0;
            dash_burst_timer = 0;
            dash_chain = 0;
            dash_iframe_timer = 0;
            ground_dash_cooldown_timer = 0;
            air_dash_cooldown_timer = 0;
            slide_boost_timer = 0;
            slide_double_boost_stage = 0;
            wall_jump_lock_time = 0;
            wall_slide_active = false;
            sprite_index = s_Player;
            image_index = 0;
            footstep_last_x = phy_position_x;
        }
        snap_camera();
        transition_time = 0.13; // Seconds of visual loading flicker; the simulation thread never blocks.
    };
    add_geometry = function(_x, _y, _width, _height, _player_only = true)
    {
        // Dimensions in room pixels. Player-only barriers never block bullets or grant wall holds.
        var _actor = instance_create_layer(_x, _y, "Instances",
            _player_only ? o_PlayerBarrier : o_Block,
            { image_xscale: _width / 32, image_yscale: _height / 32, visible: false });
        array_push(section_geometry, _actor);
        return _actor;
    };
    setup_geometry = function()
    {
        switch (section)
        {
            case 1:
                var _ledge = note("dead end");
                var _abyss = note("abyss tp");
                add_geometry(_ledge.right - 31, _ledge.y + 64, 32, _abyss.y + 256 - (_ledge.y + 64));
                break;
            case 2:
                var _exit = note("end of slide and dash");
                add_geometry(_exit.x + 64, _exit.y - 608, 32, 1120);
                break;
            case 3:
                // Close the missing right face of the painted pillar, without changing its tiles.
                add_geometry(24224, 12992, 32, 3264, false);
                add_geometry(24000, 12992, 224, 32, false); // Close the painted top as well as the missing right face.
                // A temporary solid gate catches bypass attempts; jumping from it still permits a real wall hold.
                wall_gate = add_geometry(23744, 14080, 224, 16, false);
                break;
            case 4:
                var _spawn = note("get pistol");
                add_geometry(_spawn.x - 96, _spawn.y - 288, 32, 320);
                add_geometry(_spawn.x + 96, _spawn.y - 288, 32, 320);
                break;
            case 5:
                add_geometry(17792, 15328, 32, 512);
                add_geometry(18848, 15328, 32, 512);
                add_geometry(17792, 15328, 1088, 32);
                break;
            case 6:
                // Cap the side walls before the player can climb into another section.
                add_geometry(19872, 16960, 1376, 32);
                break;
        }
    };
    teleport_marker = function()
    {
        var _title = "";
        switch (section)
        {
            case 1:
                var _abyss = note("abyss tp");
                return { x: (note("dead end").right + _abyss.right) / 2,
                    y: _abyss.y, width: _abyss.right - note("dead end").right, height: 28, ready: demonstrated("jump") };
            case 2:
                var _exit = note("end of slide and dash");
                return { x: _exit.x, y: _exit.y - 24, width: 64, height: 112,
                    ready: demonstrated("slide") && demonstrated("air_dash") && demonstrated("ground_dash") };
            case 4: _title = "up next sword"; break;
            case 5: _title = "up next materials"; break;
            case 6: _title = "up next coins"; break;
            case 7: _title = "up next coins2"; break;
            case 8: _title = "up next combat"; break;
            default: return undefined;
        }
        var _marker = note(_title);
        return { x: _marker.x + 16, y: _marker.y + 16, width: 48, height: 64, ready: false };
    };
    spawn_target = function(_title, _index = 0, _kind = 0, _object = o_TrainingTarget)
    {
        var _marker = note(_title, _index);
        var _actor = instance_create_layer(_marker.x, _marker.y, "Enemies", _object,
            { training_generation: generation, training_kind: _kind, training_spawn_age: 0 });
        if (_object != o_TrainingTarget)
        {
            _actor.image_blend = make_color_rgb(70, 225, 255);
            _actor.ehp = min(_actor.ehp, 60); // HP cap keeps the practical exam forgiving.
            training_dissolve(_actor.x, _actor.y - 24);
        }
        array_push(targets, { actor: _actor, defeated: false });
        return _actor;
    };
    all_defeated = function()
    {
        if (array_length(targets) == 0) return false;
        for (var _i = 0; _i < array_length(targets); ++_i)
            if (!targets[_i].defeated) return false;
        return true;
    };
    clear_encounter = function()
    {
        // Invalidate old death callbacks before removing anything.
        generation++;
        with (oEnemyParent) instance_destroy();
        with (o_Coin) instance_destroy();
        with (oSwordSlash) instance_destroy();
        with (oSwordBeam) instance_destroy();
        with (oEnemyDroneBullet) instance_destroy();
        with (o_HitscanVisual) instance_destroy();
        with (o_TrainingDigitalFX) instance_destroy();
        with (oSlamVFX) instance_destroy();
        for (var _i = 0; _i < array_length(floor_blocks); ++_i)
            if (instance_exists(floor_blocks[_i])) with (floor_blocks[_i]) instance_destroy();
        floor_blocks = [];
        for (var _i = 0; _i < array_length(section_geometry); ++_i)
            if (instance_exists(section_geometry[_i])) with (section_geometry[_i]) instance_destroy();
        section_geometry = [];
        wall_gate = noone;
        targets = [];
    };
    enter = function(_section, _physical = false)
    {
        clear_encounter();
        section = _section;
        // Pistol training begins the blue combat background; retries and replay restore the appropriate color.
        layer_set_visible("BG_Far_Blue", section >= 4);
        layer_set_visible("BG_Far_Green", section < 4);
        stage = 0;
        elapsed = 0;
        actions = {};
        coin_hits = 0;
        ending_time = -1;
        terminal_ready = false;
        wall_hold_time = 0;
        reset_pending = false;
        if (!instance_exists(o_Player)) instance_create_layer(0, 0, "Player", o_Player);
        with (o_Player)
        {
            pHP_max = 150; // Fixed simulation HP, independent of the menu difficulty.
            pHP = 150;
            owns_pistol = other.section >= 4;
            owns_sword = other.section >= 5;
            weapon_validate();
            coin_count = 4;
            coin_max = 4;
        }
        setup_geometry();
        switch (section)
        {
            case 0:
                teleport("spawn look");
                say("AIM AT EACH NODE");
                for (var _i = 0; _i < array_length(notes); ++_i)
                {
                    if (notes[_i].title != "looktarget" && notes[_i].title != "target") continue;
                    var _actor = instance_create_layer(notes[_i].x, notes[_i].y, "Enemies",
                        o_TrainingTarget, { training_generation: generation, training_kind: 4 });
                    array_push(targets, { actor: _actor, defeated: false });
                }
                break;
            case 1: teleport("spawn jump"); say("JUMP ACROSS. DROP INTO THE HOLE.", "jump"); break;
            case 2:
                if (!_physical) teleport("spawn slide");
                say("SLIDE UNDER THE CEILING", "slide");
                break;
            case 3:
                teleport("spawn wallhold");
                say("JUMP AGAINST A WALL. HOLD TOWARD IT TO STOP.", "move");
                var _floor = note("breakablefloor");
                for (var _i = 0; _i < 5; ++_i)
                {
                    var _block = instance_create_layer(_floor.x - 64 + 32 * _i,
                        _floor.y, "Instances", o_Block_Breakable);
                    _block.block_hp = 1; // Any successful slam breaks each 32-pixel segment.
                    _block.image_blend = c_aqua;
                    array_push(floor_blocks, _block);
                }
                break;
            case 4:
                if (!_physical) teleport("get pistol");
                say("PISTOL ONLINE. DESTROY ALL FOUR TARGETS.", "shoot");
                for (var _i = 0; _i < 3; ++_i) spawn_target("enemy spawn 1", _i);
                spawn_target("enemy spawn 2", 0, 1);
                break;
            case 5:
                teleport("spawn sword");
                // Keep pistol selected: the authored first wave requires actually switching.
                o_Player.weapon_type = "pistol";
                say("SWORD ONLINE. SWITCH WEAPON.", "weapons");
                break;
            case 6:
                teleport("spawn materials");
                say("DESTROY THE MATERIAL TARGETS", "shoot");
                spawn_target("enemy spawn 6");
                break;
            case 7:
                teleport("spawn coins");
                say("EQUIP YOUR PISTOL TO THROW COINS.", "pistol");
                break;
            case 8:
                teleport("spawn coins2");
                o_Player.weapon_type = "pistol";
                say("THROW A COIN ABOVE THE WALL. SHOOT IT TO REACH THE TARGET.", "coin");
                spawn_target("enemy spawn 5");
                break;
            case 9:
                teleport("spawn combat");
                say("PRACTICAL: DEFEAT THE SCOUT, THEN THE DRONE.", "weapons");
                break;
        }
    };
    enter(0);
}

function training_update()
{
    if (variable_global_exists("dev_menu_open") && global.dev_menu_open) return;
    var _dt = min(0.05, max(0, (variable_global_exists("dev_delta_time")
        ? global.dev_delta_time : delta_time) / 1000000)); // Seconds, bounded after a window stall.
    if (_dt <= 0) return;
    if (!menu_exhibition_active() && keyboard_check_pressed(vk_f4)) debug_visible = !debug_visible;
    elapsed += _dt;
    text_age += _dt;
    transition_time = max(0, transition_time - _dt);
    if (reset_pending || !instance_exists(o_Player))
    {
        resetting = true;
        var _section = section;
        // Recreate the player to clear every movement, trap, attack and damage timer.
        if (instance_exists(o_Player))
        {
            o_Player.pHP = 150;
            with (o_Player) instance_destroy();
        }
        enter(_section);
        resetting = false;
        return;
    }
    var _player = instance_find(o_Player, 0);
    // Bounds follow authored playable clusters, including both physical descent shafts.
    var _bounds = [ [10700,13700,12100,14850], [13100,13800,15650,15700],
        [16600,12300,20900,14500], [23100,12800,25450,17850],
        [23900,16900,25550,17850], [17400,15100,19250,16100],
        [19700,16300,21400,17600], [19700,16000,21000,16900],
        [17800,15900,19000,16900], [14500,16000,17000,17400] ];
    var _area = _bounds[section];
    if (_player.pHP <= 0 || _player.grinder_dying || _player.x < _area[0]
        || _player.y < _area[1] || _player.x > _area[2] || _player.y > _area[3])
    {
        reset_pending = true;
        return;
    }
    for (var _i = 0; _i < array_length(targets); ++_i)
    {
        if (!targets[_i].defeated && instance_exists(targets[_i].actor))
        {
            var _actor = targets[_i].actor;
            if (variable_instance_exists(_actor, "training_spawn_age"))
            {
                _actor.training_spawn_age += _dt;
                _actor.image_alpha = clamp(_actor.training_spawn_age / 0.18, 0, 1);
            }
        }
        if (!targets[_i].defeated && !instance_exists(targets[_i].actor))
        {
            reset_pending = true; // Unexpected removal cannot silently complete an objective.
            return;
        }
    }
    if (section == 0 || section == 8)
    {
        _player.phy_speed_x = 0;
    }
    if (section == 7 || section == 8) _player.coin_count = _player.coin_max;
    if (ending_time >= 0)
    {
        ending_time += _dt;
        if (ending_time >= 2.2) training_exit(); // Fresh menu and persistent rooms, with no training state.
        return;
    }
    switch (section)
    {
        case 0:
            if (all_defeated()) enter(1);
            break;
        case 1:
            var _abyss = note("abyss tp");
            if (demonstrated("jump") && _player.y >= _abyss.y
                && _player.x >= note("dead end").right && _player.x <= _abyss.right)
            {
                // The player must physically jump/fall down the authored hole first.
                enter(2);
            }
            break;
        case 2:
            // Use the stable physics footprint, entering the visible portal's 64-pixel-wide volume.
            var _exit_front = _player.phy_position_x + 0.5 + _player.player_collider_half_width;
            if (_exit_front >= note("end of slide and dash").x - 32)
            {
                if (demonstrated("slide") && demonstrated("air_dash") && demonstrated("ground_dash")) enter(3);
                else
                {
                    var _missing = !demonstrated("slide") ? "SLIDE TO COMPLETE THIS SECTION"
                        : (!demonstrated("air_dash") ? "JUMP AND DASH MIDAIR" : "DASH ON THE GROUND");
                    if (objective != _missing) say(_missing, !demonstrated("slide") ? "slide"
                        : (!demonstrated("air_dash") ? "air_dash" : "dash_jump"));
                }
            }
            else if (_player.x >= note("bp dash").x)
            {
                if (objective != "DASH ON THE GROUND, THEN JUMP") say("DASH ON THE GROUND, THEN JUMP", "dash_jump");
            }
            else if (_player.x >= note("bp jumpdash").x)
            {
                if (objective != "JUMP, THEN DASH MIDAIR") say("JUMP, THEN DASH MIDAIR", "air_dash");
            }
            break;
        case 3:
            var _holding = _player.chip_wall_holding_now && abs(_player.phy_speed_y) <= 0.5
                && (controls_down("left") || controls_down("right"));
            if (!demonstrated("wall"))
            {
                wall_hold_time = _holding ? wall_hold_time + _dt : 0;
                if (wall_hold_time >= wall_hold_required)
                {
                    actions.wall = true;
                    if (instance_exists(wall_gate)) with (wall_gate) instance_destroy();
                    wall_gate = noone;
                    say("WALL HOLD CONFIRMED. DESCEND BETWEEN THE RED WALLS.", "move");
                }
            }
            if (demonstrated("wall") && abs(_player.x - note("bp slam").x) <= 224
                && _player.y >= note("bp slam").y - 224 && _player.y <= note("breakablefloor").y + 64)
            {
                if (prompt != "slam") say("JUMP, THEN SLAM THROUGH THE GLOWING FLOOR.", "slam");
            }
            if (_player.is_slamming && abs(_player.x - note("breakablefloor").x) < 120
                && _player.y >= note("breakablefloor").y - 80) stage = 1;
            if (_player.y >= note("get pistol").y + 16
                && abs(_player.x - note("get pistol").x) < 112)
            {
                if (demonstrated("wall") && stage == 1) enter(4, true);
                else reset_pending = true;
            }
            break;
        case 4: if (all_defeated()) enter(5); break;
        case 5:
            if (stage == 0 && _player.weapon_type == "sword")
            {
                stage = 1;
                spawn_target("enemy spawn 3");
                say("STRIKE THE DUMMY", "shoot");
            }
            else if (stage == 1 && all_defeated())
            {
                stage = 2;
                targets = [];
                spawn_target("enemy spawn 4", 0);
                spawn_target("enemy spawn 4", 1);
                say("DESTROY BOTH TARGETS", "shoot");
            }
            else if (stage == 2 && all_defeated()) enter(6);
            break;
        case 6:
            if (all_defeated())
            {
                stage++;
                if (stage >= 3) { enter(7); break; }
                targets = [];
                spawn_target("enemy spawn 6", 0, stage + 1);
                say(stage == 1 ? "ARMORED MATERIAL. TRY YOUR SWORD." : "A DIRECTIONAL SHIELD PROTECTS THE TARGET.", "weapons");
            }
            break;
        case 7:
            if (stage == 0 && demonstrated("equip_pistol") && _player.weapon_type == "pistol")
            {
                stage = 1;
                say("THROW A COIN. SHOOT IT MIDAIR. HIT THREE COINS.", "coin_shoot");
            }
            else if (stage == 1)
            {
                if (_player.weapon_type != "pistol" && prompt != "pistol")
                    say("COINS REQUIRE YOUR PISTOL.", "pistol");
                else if (_player.weapon_type == "pistol" && prompt != "coin_shoot")
                    say("THROW A COIN. SHOOT IT MIDAIR. HIT THREE COINS.", "coin_shoot");
                if (coin_hits >= 3) enter(8);
            }
            break;
        case 8: if (all_defeated()) enter(9); break;
        case 9:
            if (stage == 0 && elapsed >= 1)
            {
                stage = 1;
                spawn_target("enemy spawn 7", 0, 0, oEnemy_Scout);
            }
            else if (stage == 1 && all_defeated())
            {
                stage = 2;
                targets = [];
                spawn_target("enemy spawn 8", 0, 0, oDrone);
            }
            else if (stage == 2 && all_defeated())
            {
                stage = 3;
                terminal_ready = true;
                say("TRAINING COMPLETE. INTERACT WITH THE TERMINAL.", "interact");
            }
            if (terminal_ready)
            {
                var _terminal = note("terminal lucidity");
                if (point_distance(_player.x, _player.y - 32, _terminal.x, _terminal.y) < 100
                    && controls_pressed("interact"))
                {
                    ending_time = 0;
                    // Keep a last-moment dash or fall from interrupting the authored disconnect.
                    _player.stop_movement_sfx();
                    _player.phy_speed_x = 0;
                    _player.phy_speed_y = 0;
                    _player.phy_active = false;
                    say("CONNECTION LOST");
                }
            }
            break;
    }
}

// Match pause-menu cleanup: GameMaker globals survive game_restart().
function training_exit()
{
    global.demo_travel_state = undefined;
    global.demo_took_damage = false;
    global.demo_used_healing = false;
    global.demo_finish_time = 0;
    global.menu_checkpoint = undefined;
    global.tutorial_checkpoint_retry = undefined;
    global.menu_launch_room = undefined;
    global.menu_saved_fullscreen = window_get_fullscreen();
    game_restart();
}

// Keep the materials arena framed below its roof so climbing cannot reveal nearby courses.
function training_camera_y(_y)
{
    return training_active() && o_TrainingSimulation.section == 6
        ? max(_y, o_TrainingSimulation.materials_camera_top) : _y;
}
