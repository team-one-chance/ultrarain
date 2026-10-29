function ray_bbox_fraction(_x1, _y1, _x2, _y2, _inst)
{
    var dx = _x2 - _x1;
    var dy = _y2 - _y1;

    var tmin = 0;
    var tmax = 1;

    // X axis
    if (abs(dx) < 0.000001)
    {
        if (_x1 < _inst.bbox_left || _x1 > _inst.bbox_right)
        {
            return -1;
        }
    }
    else
    {
        var tx1 = (_inst.bbox_left  - _x1) / dx;
        var tx2 = (_inst.bbox_right - _x1) / dx;

        var tx_min = min(tx1, tx2);
        var tx_max = max(tx1, tx2);

        tmin = max(tmin, tx_min);
        tmax = min(tmax, tx_max);

        if (tmin > tmax)
        {
            return -1;
        }
    }

    // Y axis
    if (abs(dy) < 0.000001)
    {
        if (_y1 < _inst.bbox_top || _y1 > _inst.bbox_bottom)
        {
            return -1;
        }
    }
    else
    {
        var ty1 = (_inst.bbox_top    - _y1) / dy;
        var ty2 = (_inst.bbox_bottom - _y1) / dy;

        var ty_min = min(ty1, ty2);
        var ty_max = max(ty1, ty2);

        tmin = max(tmin, ty_min);
        tmax = min(tmax, ty_max);

        if (tmin > tmax)
        {
            return -1;
        }
    }

    return clamp(tmin, 0, 1);
}