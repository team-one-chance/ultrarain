var _before = item_get_level(other, item_key);

var _collected = item_add_level(
    other,
    item_key,
    item_amount,
    item_max_level
);

var _after = item_get_level(other, item_key);

show_debug_message(
    "ITEM PICKUP"
    + " | player=" + string(other.id)
    + " | item=" + item_key
    + " | before=" + string(_before)
    + " | after=" + string(_after)
    + " | collected=" + string(_collected)
);

if (_collected)
{
    instance_destroy();
}