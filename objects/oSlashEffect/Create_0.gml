duration = 0.15;
slash_damage = 10;
knockback_force = 100;

// Each enemy takes damage once per slash.
hit_enemies = ds_list_create();

// Each slash can release only one coin-powered beam.
coin_beam_released = false;
