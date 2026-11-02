if (instance_exists(shield_actor)) with (shield_actor) instance_destroy();
if (ehp <= 0)
{
    training_defeated(id);
    training_dissolve(x + 16, y + 24);
}
