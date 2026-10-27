if (!variable_instance_exists(id, "item_key"))
    item_key = "coin_rounding";

if (!variable_instance_exists(id, "item_amount"))
    item_amount = 1;

if (!variable_instance_exists(id, "item_max_level"))
    item_max_level = 3;

item_controller_init(id);	