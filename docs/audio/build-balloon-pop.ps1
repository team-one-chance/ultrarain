$ErrorActionPreference = 'Stop'

# Remix two existing effects into a short, soft balloon crack; originals stay intact.
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Text;
public static class BalloonPopBuilder
{
    const int Rate = 44100;
    static double[] Load(string path)
    {
        byte[] b = File.ReadAllBytes(path);
        int data = 0, size = 0, channels = 0;
        for (int p = 12; p + 8 <= b.Length; )
        {
            int n = BitConverter.ToInt32(b, p + 4);
            string tag = Encoding.ASCII.GetString(b, p, 4);
            if (tag == "fmt ")
            {
                if (BitConverter.ToInt16(b, p + 8) != 1 || BitConverter.ToInt16(b, p + 22) != 16
                    || BitConverter.ToInt32(b, p + 12) != Rate) throw new Exception("Expected 44.1 kHz 16-bit PCM.");
                channels = BitConverter.ToInt16(b, p + 10);
            }
            if (tag == "data") { data = p + 8; size = n; }
            p += n + 8 + (n & 1);
        }
        if (data == 0 || channels < 1) throw new Exception("Invalid source WAV.");
        double[] samples = new double[size / (channels * 2)];
        for (int i = 0; i < samples.Length; ++i)
        for (int c = 0; c < channels; ++c)
            samples[i] += BitConverter.ToInt16(b, data + (i * channels + c) * 2) / (32768.0 * channels);
        // Use the loudest 40 ms of texture, avoiding any leading silence in the source.
        int span = (int)(Rate * 0.04), best = 0;
        double energy = 0, bestEnergy = 0;
        for (int i = 0; i < samples.Length; ++i)
        {
            energy += samples[i] * samples[i];
            if (i >= span) energy -= samples[i - span] * samples[i - span];
            if (i >= span - 1 && energy > bestEnergy) { bestEnergy = energy; best = i - span + 1; }
        }
        double[] grain = new double[span];
        double level = 0.2 / Math.Max(0.00001, Math.Sqrt(bestEnergy / span));
        for (int i = 0; i < span; ++i) grain[i] = samples[best + i] * level;
        return grain;
    }
    static double Sample(double[] source, double p)
    {
        p %= source.Length;
        int i = (int)p;
        return source[i] + (source[(i + 1) % source.Length] - source[i]) * (p - i);
    }
    static void Write(string path, double[] samples)
    {
        using (var w = new BinaryWriter(File.Create(path)))
        {
            w.Write(Encoding.ASCII.GetBytes("RIFF")); w.Write(36 + samples.Length * 2);
            w.Write(Encoding.ASCII.GetBytes("WAVEfmt ")); w.Write(16); w.Write((short)1); w.Write((short)1);
            w.Write(Rate); w.Write(Rate * 2); w.Write((short)2); w.Write((short)16);
            w.Write(Encoding.ASCII.GetBytes("data")); w.Write(samples.Length * 2);
            foreach (double s in samples) w.Write((short)Math.Round(Math.Max(-1, Math.Min(1, s)) * 32767));
        }
    }
    public static void Build(string root)
    {
        double[] crack = Load(Path.Combine(root, "sounds/sfxInitError/sfxInitError.wav"));
        double[] body = Load(Path.Combine(root, "sounds/sfxJump/sfxJump.wav"));
        double[] pop = new double[(int)Math.Round(Rate * 0.095)]; // Seconds; short enough for rapid successive balloons.
        double low = 0, smooth = 0, phase = 0, peak = 0, energy = 0;
        for (int i = 0; i < pop.Length; ++i)
        {
            double t = (double)i / Rate;
            double raw = Sample(crack, i * 1.65);
            low += 0.09 * (raw - low); // Remove low rumble from the borrowed crack texture.
            smooth += 0.40 * ((raw - low) - smooth); // Soften the top end to avoid a piercing click.
            phase += 2 * Math.PI * (95 + 290 * Math.Exp(-t / 0.012)) / Rate;
            double attack = Math.Min(1, t / 0.0015); // 1.5 ms fade-in prevents a digital edge.
            double tail = Math.Min(1, (0.095 - t) / 0.012);
            pop[i] = attack * tail * (smooth * 1.7 * Math.Exp(-t / 0.015)
                + Sample(body, i * 0.78) * 0.45 * Math.Exp(-t / 0.022)
                + Math.Sin(phase) * 0.10 * Math.Exp(-t / 0.013));
            peak = Math.Max(peak, Math.Abs(pop[i])); energy += pop[i] * pop[i];
        }
        double gain = Math.Min(0.14 / Math.Sqrt(energy / pop.Length), 0.75 / peak);
        for (int i = 0; i < pop.Length; ++i) pop[i] *= gain;
        Write(Path.Combine(root, "sounds/sfxBalloonPop/sfxBalloonPop.wav"), pop);
        double[] preview = new double[Rate * 3];
        for (int n = 0; n < 4; ++n)
        for (int i = 0; i < pop.Length; ++i)
            preview[(int)(Rate * (0.25 + n * 0.6)) + i] = pop[i] * 0.65;
        Write(Path.Combine(root, "docs/audio/sfxBalloonPop-preview.wav"), preview);
        Console.WriteLine("Balloon pop: 0.095s, mono 44100 Hz, peak {0:F3}, RMS {1:F3}", peak * gain, Math.Sqrt(energy / pop.Length) * gain);
    }
}
'@
$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
[BalloonPopBuilder]::Build($projectRoot)
