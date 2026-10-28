// Mark this particular chute as the secret-area entrance.
secret_hard_only = true;

// Replace this instance's break function.
door_break = function()
{
    // Only Hard difficulty can break this latch.
    if (!variable_global_exists("game_difficulty")
    || global.game_difficulty != 2)
    {
        return;
    }

    if (!broken)
    {
        break_requested = true;
    }
};