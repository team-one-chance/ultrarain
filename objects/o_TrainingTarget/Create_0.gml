// Combat adapter: inherits target classification, not production AI/navigation allocation.
if (!variable_instance_exists(id, "training_kind")) training_kind = 0;
ehp = 30; // HP; three standard pistol hits or sword strikes destroy an unprotected dummy.
shield_hp = (training_kind == 2 || training_kind == 5) ? 100 : 0; // Shared material multipliers strip this pool first.
shield_hp_max = shield_hp;
shield_actor = noone;
base_y = y;
age = 0;
hit_flash = 0;
image_xscale = training_kind == 4 ? 0.75 : 1;
image_yscale = training_kind == 4 ? 0.75 : 2;
y -= training_kind == 4 ? 0 : 32;
base_y = y;
image_speed = 0;
can_parry = function() { return false; };
is_invulnerable = function() { return false; };
take_damage = function(_damage, _direction = 0, _force = 0, _sword = false)
{
    if (training_kind == 4 || age < 0.18 || _damage <= 0) return;
    // The first dummy teaches a real sword strike. The follow-up wave permits either owned weapon.
    if (training_active() && o_TrainingSimulation.section == 5 && o_TrainingSimulation.stage == 1 && !_sword)
    {
        hit_flash = 0.14;
        if (o_TrainingSimulation.objective != "STRIKE THIS FIRST DUMMY WITH YOUR SWORD.")
            o_TrainingSimulation.say("STRIKE THIS FIRST DUMMY WITH YOUR SWORD.", "weapons");
        return;
    }
    hit_flash = 0.14; // Seconds of white/gold impact feedback.
    if (shield_hp > 0)
    {
        var _material = shield_material_settings();
        var _blocked = training_kind == 2 || training_kind == 5;
        if (_blocked)
        {
            shield_hp = max(0, shield_hp - _damage * (_sword ? _material.sword : _material.bullet));
            audio_play_sound(_sword ? sfxSwordSlash1 : sfxBreakerBulletRicochet1, 1, false, 0.35);
            if (!_sword && instance_exists(o_Player))
            {
                var _angle = point_direction(x, y, o_Player.x, o_Player.y - 32) + 35;
                var _streak = instance_create_layer(0, 0, "Instances", o_HitscanVisual);
                _streak.line_x1 = x + 8;
                _streak.line_y1 = y + 24;
                _streak.line_x2 = _streak.line_x1 + lengthdir_x(64, _angle);
                _streak.line_y2 = _streak.line_y1 + lengthdir_y(64, _angle);
                _streak.line_color = c_yellow;
            }
            if (training_kind == 5 && shield_hp <= 0) { ehp = 0; instance_destroy(); }
            return;
        }
    }
    ehp -= _damage;
    if (ehp <= 0) instance_destroy();
};
take_slam = function(_damage, _speed, _impact_x, _impact_y, _source)
{
    if (training_active() && o_TrainingSimulation.section == 4) return; // Pistol targets survive the arrival slam.
    take_damage(_damage);
};

if (training_kind == 3)
{
    shield_actor = instance_create_layer(x, y, "Enemies", o_TrainingTarget,
        { training_kind: 5, shield_owner: id, training_generation: training_generation });
}
if (training_kind == 5)
{
    image_xscale = 0.25; // Eight-pixel-wide floating plate; its collision mask blocks the actual shot trace.
    image_yscale = 2.5;
}
