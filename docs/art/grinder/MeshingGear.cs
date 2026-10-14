using System;
using System.Drawing;
using System.Drawing.Imaging;

// Eight equal involute teeth; 20-degree pressure angle, small backlash.
public static class MeshingGear {
    public const double Pitch = 224.0 / 3.0;
    public const double PitchRadius = Pitch / 2.0;
    public const double Module = Pitch / 8.0;
    public const double TipRadius = PitchRadius + Module;
    public const double RootRadius = PitchRadius - Module * 1.25;
    private static readonly double Pressure = 20 * Math.PI / 180;
    private static readonly double BaseRadius = PitchRadius * Math.Cos(Pressure);
    private static readonly double HalfWidth = Math.PI / 16 - 0.012;
    private static double Involute(double a) { return Math.Tan(a) - a; }
    public static bool Inside(double x, double y) {
        double r = Math.Sqrt(x*x + y*y);
        if (r <= RootRadius) return true;
        if (r > TipRadius) return false;
        double angle = Math.Atan2(y,x), tooth = Math.PI / 4;
        double offset = angle - Math.Round(angle/tooth)*tooth;
        double half = HalfWidth + Involute(Pressure);
        if (r > BaseRadius) half -= Involute(Math.Acos(BaseRadius/r));
        return Math.Abs(offset) <= half;
    }
    public static Bitmap Frame(double degrees, Bitmap material) {
        Bitmap result = new Bitmap(96,96,PixelFormat.Format32bppArgb);
        double a = degrees*Math.PI/180, c = Math.Cos(a), s = Math.Sin(a);
        for (int y=0; y<96; y++) for (int x=0; x<96; x++) {
            double dx=x-47.5, dy=y-47.5;
            double u=dx*c+dy*s, v=-dx*s+dy*c;
            if (!Inside(u,v)) continue;
            // Reuse the approved gear's steel wear and yellow hub texture.
            int sx=(int)Math.Round((material.Width-1)/2.0 + u*12.4);
            int sy=(int)Math.Round((material.Height-1)/2.0 + v*12.4);
            Color col=Color.FromArgb(64,66,70);
            if(sx>=0 && sy>=0 && sx<material.Width && sy<material.Height) {
                Color sample=material.GetPixel(sx,sy);
                if(sample.A>127) col=Color.FromArgb(sample.R,sample.G,sample.B);
            }
            if(!Inside(u+0.8,v)||!Inside(u-0.8,v)||!Inside(u,v+0.8)||!Inside(u,v-0.8))
                col=Color.FromArgb(28,29,31);
            else if(!Inside(u+1.8,v)||!Inside(u-1.8,v)||!Inside(u,v+1.8)||!Inside(u,v-1.8))
                col=Color.FromArgb(151,148,138);
            result.SetPixel(x,y,col);
        }
        return result;
    }
    public static int Overlap(double angle) {
        double a=angle*Math.PI/180, b=(22.5-angle)*Math.PI/180;
        int count=0;
        for(double y=-TipRadius;y<=TipRadius;y+=0.5)
            for(double x=Pitch-TipRadius;x<=TipRadius;x+=0.5)
                if(Inside(x*Math.Cos(a)+y*Math.Sin(a),-x*Math.Sin(a)+y*Math.Cos(a)) &&
                   Inside((x-Pitch)*Math.Cos(b)+y*Math.Sin(b),-(x-Pitch)*Math.Sin(b)+y*Math.Cos(b))) count++;
        return count;
    }
}
