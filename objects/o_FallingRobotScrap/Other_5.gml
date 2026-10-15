scrap_needs_rebind = scrap_emerged && (scrap_state == 0 || scrap_state == 2);
if (scrap_fixture != -1 && scrap_needs_rebind)
{
    scrap_vx = phy_linear_velocity_x;
    scrap_vy = phy_linear_velocity_y;
}
// A persistent room does not preserve this world's runtime fixture handle.
scrap_fixture = -1;
scrap_release_draw_resources();
