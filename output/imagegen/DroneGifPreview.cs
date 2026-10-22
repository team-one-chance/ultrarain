using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;

public static class DroneGifPreview
{
    // A small GIF packager. Input frame pixels are sampled with integer scaling.
    // Frequent clear codes keep the LZW stream at a fixed, valid six-bit width.
    private sealed class Codes
    {
        public readonly List<byte> Bytes = new List<byte>();
        private int bits;
        private int count;
        public void Push(int value)
        {
            bits |= value << count;
            count += 6;
            while (count >= 8)
            {
                Bytes.Add((byte)(bits & 255));
                bits >>= 8;
                count -= 8;
            }
        }
        public void Finish() { if (count > 0) Bytes.Add((byte)(bits & 255)); }
    }

    public static void Write(string[] paths, string output, int scale, double fps)
    {
        var colors = new List<int>();
        var lookup = new Dictionary<int, int>();
        int background = Color.FromArgb(65,65,70).ToArgb();
        colors.Add(background);
        lookup.Add(background, 0);
        foreach (string path in paths)
            using (var image = new Bitmap(path))
                for (int y=0; y<image.Height; y++)
                    for (int x=0; x<image.Width; x++)
                    {
                        Color pixel = image.GetPixel(x,y);
                        if (pixel.A == 0) continue;
                        int argb = pixel.ToArgb();
                        if (!lookup.ContainsKey(argb))
                        {
                            lookup.Add(argb,colors.Count);
                            colors.Add(argb);
                        }
                    }
        if (colors.Count > 32) throw new InvalidOperationException("Palette exceeds 32 colors.");
        using (var writer = new BinaryWriter(File.Create(output)))
        {
            writer.Write(Encoding.ASCII.GetBytes("GIF89a"));
            writer.Write((ushort)(48*scale));
            writer.Write((ushort)(32*scale));
            writer.Write((byte)0xF4);
            writer.Write((byte)0);
            writer.Write((byte)0);
            for (int i=0; i<32; i++)
            {
                Color c = Color.FromArgb(i<colors.Count ? colors[i] : background);
                writer.Write(c.R); writer.Write(c.G); writer.Write(c.B);
            }
            writer.Write(new byte[] {0x21,0xFF,0x0B});
            writer.Write(Encoding.ASCII.GetBytes("NETSCAPE2.0"));
            writer.Write(new byte[] {0x03,0x01,0x00,0x00,0x00});
            foreach (string path in paths)
                using (var image = new Bitmap(path))
                {
                    writer.Write(new byte[] {0x21,0xF9,0x04,0x04});
                    writer.Write((ushort)Math.Max(1,(int)Math.Round(100.0/fps)));
                    writer.Write(new byte[] {0x00,0x00,0x2C});
                    writer.Write((ushort)0); writer.Write((ushort)0);
                    writer.Write((ushort)(48*scale)); writer.Write((ushort)(32*scale));
                    writer.Write((byte)0);
                    writer.Write((byte)5);
                    var codes = new Codes();
                    int index = 0;
                    for (int y=0; y<32*scale; y++)
                        for (int x=0; x<48*scale; x++)
                        {
                            if (index++ % 28 == 0) codes.Push(32);
                            Color pixel = image.GetPixel(x/scale,y/scale);
                            codes.Push(pixel.A == 0 ? 0 : lookup[pixel.ToArgb()]);
                        }
                    codes.Push(33);
                    codes.Finish();
                    for (int i=0; i<codes.Bytes.Count; i+=255)
                    {
                        int count = Math.Min(255,codes.Bytes.Count-i);
                        writer.Write((byte)count);
                        writer.Write(codes.Bytes.GetRange(i,count).ToArray());
                    }
                    writer.Write((byte)0);
                }
            writer.Write((byte)0x3B);
        }
    }
}
