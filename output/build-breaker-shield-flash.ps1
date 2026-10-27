$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.Drawing;
public static class BreakerShieldAxis {
    public static bool Red(Color c) {
        return c.A > 0 && c.R > 45 && c.R > c.G * 1.4 && c.R > c.B * 1.4;
    }
    public static double[] Find(Bitmap b) {
        bool[,] seen = new bool[b.Width, b.Height];
        List<Point> best = null;
        double bestSpan = 0;
        for (int y = 0; y < b.Height; y++) for (int x = 0; x < b.Width; x++) {
            if (seen[x,y] || !Red(b.GetPixel(x,y))) continue;
            var group = new List<Point>();
            var queue = new Queue<Point>();
            queue.Enqueue(new Point(x,y)); seen[x,y] = true;
            int minx=x, maxx=x, miny=y, maxy=y;
            while (queue.Count > 0) {
                Point p = queue.Dequeue(); group.Add(p);
                minx=Math.Min(minx,p.X); maxx=Math.Max(maxx,p.X);
                miny=Math.Min(miny,p.Y); maxy=Math.Max(maxy,p.Y);
                for(int dy=-1;dy<=1;dy++) for(int dx=-1;dx<=1;dx++) {
                    int nx=p.X+dx, ny=p.Y+dy;
                    if(nx<0 || ny<0 || nx>=b.Width || ny>=b.Height || seen[nx,ny]) continue;
                    if(!Red(b.GetPixel(nx,ny))) continue;
                    seen[nx,ny]=true; queue.Enqueue(new Point(nx,ny));
                }
            }
            double span=(maxx-minx)*(maxx-minx)+(maxy-miny)*(maxy-miny);
            if(span>bestSpan) { best=group; bestSpan=span; }
        }
        // Some bash frames already have a white shield stripe in the source art.
        if(best == null || bestSpan < 225) return null;
        double cx=0, cy=0, xx=0, xy=0, yy=0;
        foreach(Point p in best) { cx+=p.X+0.5; cy+=p.Y+0.5; }
        cx/=best.Count; cy/=best.Count;
        foreach(Point p in best) {
            double dx=p.X+0.5-cx, dy=p.Y+0.5-cy;
            xx+=dx*dx; xy+=dx*dy; yy+=dy*dy;
        }
        double angle=0.5*Math.Atan2(2*xy,xx-yy), ax=Math.Cos(angle), ay=Math.Sin(angle);
        double lo=0, hi=0;
        foreach(Point p in best) {
            double t=(p.X+0.5-cx)*ax+(p.Y+0.5-cy)*ay;
            lo=Math.Min(lo,t); hi=Math.Max(hi,t);
        }
        // Include the separated red caps at either end of the shield.
        lo-=32; hi+=32;
        return new double[] {cx+lo*ax,cy+lo*ay,cx+hi*ax,cy+hi*ay};
    }
    public static bool InShield(int x, int y, double[] a) {
        double dx=a[2]-a[0], dy=a[3]-a[1];
        double t=Math.Max(0,Math.Min(1,((x+0.5-a[0])*dx+(y+0.5-a[1])*dy)/(dx*dx+dy*dy)));
        double ex=x+0.5-a[0]-t*dx, ey=y+0.5-a[1]-t*dy;
        return ex*ex+ey*ey <= 25;
    }
}
'@
$names = @('idle','block','walk','walk_block','shieldbash','bashcooldown','jumpcharge','jump','slam_trans','slam','land','landrecovery')
$lines = @('// Shield stripe axes in cropped sprite pixels, indexed by animation frame.', 'breaker_shield_axes = {};')
$sheet = New-Object System.Drawing.Bitmap 1920,560
$g = [System.Drawing.Graphics]::FromImage($sheet)
$g.Clear([System.Drawing.Color]::FromArgb(35,35,40))
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
for ($i=0; $i -lt $names.Count; $i++) {
    $name = 's_Breaker_' + $names[$i]
    $raw = Get-Content ('sprites/' + $name + '/' + $name + '.yy') -Raw
    $meta = ($raw -replace ',\s*([}\]])', '$1') | ConvertFrom-Json
    $axes = @()
    for ($frame=0; $frame -lt $meta.frames.Count; $frame++) {
        $path = Join-Path (Get-Location) ('sprites/' + $name + '/' + $meta.frames[$frame].name + '.png')
        $bmp = [System.Drawing.Bitmap]::FromFile($path)
        $axis = [BreakerShieldAxis]::Find($bmp)
        if ($null -eq $axis) { $axis = $previousAxis }
        if ($null -eq $axis) { throw ('No shield axis for ' + $name) }
        $previousAxis = $axis
        $axes += '[' + (($axis | ForEach-Object { $_.ToString('F2', [Globalization.CultureInfo]::InvariantCulture) }) -join ', ') + ']'
        if ($frame -eq 0) {
            $cx = ($i % 6)*320; $cy = [Math]::Floor($i / 6)*280
            $g.DrawString($names[$i], [System.Drawing.SystemFonts]::DefaultFont, [System.Drawing.Brushes]::White, $cx, $cy)
            $g.DrawImage($bmp, $cx, ($cy+22), ($bmp.Width*2), ($bmp.Height*2))
        }
        for ($py=0; $py -lt $bmp.Height; $py++) { for ($px=0; $px -lt $bmp.Width; $px++) {
            if ([BreakerShieldAxis]::Red($bmp.GetPixel($px,$py)) -and [BreakerShieldAxis]::InShield($px,$py,$axis)) {
                $bmp.SetPixel($px,$py,[System.Drawing.Color]::White)
            }
        } }
        if ($frame -eq 0) { $g.DrawImage($bmp, ($cx+150), ($cy+22), ($bmp.Width*2), ($bmp.Height*2)) }
        $bmp.Dispose()
    }
    $lines += 'variable_struct_set(breaker_shield_axes, sprite_get_name(' + $name + '), [' + ($axes -join ', ') + ']);'
}
$g.Dispose()
$sheet.Save((Join-Path (Get-Location) 'output/breaker-shield-flash-preview.png'))
$sheet.Dispose()
$lines | Set-Content output/breaker-shield-axes.gml
