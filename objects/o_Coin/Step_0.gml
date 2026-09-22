// =====================================
// COIN
// =====================================

// Destroy when touching a wall
if (place_meeting(x, y, o_Block))
{
    instance_destroy();
}
/*
// Destroy when touching an enemy
if (place_meeting(x, y, oEnemy_TEMP))
{
    instance_destroy();
}