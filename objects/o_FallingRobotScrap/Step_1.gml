scrap_before_x = x;
scrap_before_y = y;

scrap_fall_speed_before = 0;

if (scrap_fixture != -1
&& (scrap_state == 0 || scrap_state == 2))
{
    scrap_fall_speed_before = phy_linear_velocity_y;
}