function demo_save_player(_player)
{
    global.demo_travel_state = {
        hp: _player.pHP,
        hp_max: _player.pHP_max,

        medkit_owned: _player.medkit_owned,
        syringe_count: _player.syringe_count,
        syringe_max: _player.syringe_max,

        coin_count: _player.coin_count,
        coin_max: _player.coin_max,

        weapon_type: _player.weapon_type,
        item_coin_anchor: _player.item_coin_anchor
    };
}