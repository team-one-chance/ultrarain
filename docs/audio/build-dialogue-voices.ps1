$ErrorActionPreference = 'Stop'

# Remix existing interface/electronic effects into brief RPG-style voice syllables.
# Originals are read only; rerunning this script reproduces both placeholder assets.
Add-Type -TypeDefinition @'
using System;
using System.IO;
using System.Text;
public static class DialogueVoiceBuilder
{
    const int Rate = 44100;
    static double[] Load(string path)
    {
        byte[] b = File.ReadAllBytes(path);
        int channels = 0, rate = 0, bits = 0, format = 0, start = 0, length = 0;
        for (int p = 12; p + 8 <= b.Length; )
        {
            int n = BitConverter.ToInt32(b, p + 4);
            string tag = Encoding.ASCII.GetString(b, p, 4);
            if (tag == "fmt ")
            {
                format = BitConverter.ToInt16(b, p + 8);
                channels = BitConverter.ToInt16(b, p + 10);
                rate = BitConverter.ToInt32(b, p + 12);
                bits = BitConverter.ToInt16(b, p + 22);
            }
            if (tag == "data") { start = p + 8; length = n; }
            p += 8 + n + (n & 1);
        }
        if (format != 1 || bits != 16 || channels < 1 || rate != Rate || start == 0)
            throw new Exception("Expected 44.1 kHz, 16-bit PCM source: " + path);
        double[] samples = new double[length / (channels * 2)];
        for (int i = 0; i < samples.Length; ++i)
        for (int c = 0; c < channels; ++c)
            samples[i] += BitConverter.ToInt16(b, start + (i * channels + c) * 2) / (32768.0 * channels);
        return samples;
    }
    static double[] Grain(double[] source)
    {
        int count = (int)(Rate * 0.12); // Seconds: enough texture for a syllable without a recognizable UI chime.
        int best = 0;
        double bestEnergy = -1;
        for (int p = 0; p + count <= source.Length; p += 441)
        {
            double energy = 0;
            for (int i = 0; i < count; ++i) energy += source[p + i] * source[p + i];
            if (energy > bestEnergy) { best = p; bestEnergy = energy; }
        }
        double[] grain = new double[count];
        double rms = Math.Sqrt(bestEnergy / count);
        if (rms < 0.00001) throw new Exception("Voice source is silent or too short.");
        for (int i = 0; i < count; ++i) grain[i] = source[best + i] * 0.15 / rms;
        return grain;
    }
    static double Sample(double[] source, double p)
    {
        p %= source.Length;
        int i = (int)p;
        return source[i] + (source[(i + 1) % source.Length] - source[i]) * (p - i);
    }
    static double[] Band(double[] source, double hz, double q)
    {
        // Resonant band-pass filters give the borrowed texture vowel-like formants.
        double w = 2 * Math.PI * hz / Rate, a = Math.Sin(w) / (2 * q);
        double b0 = a / (1 + a), a1 = -2 * Math.Cos(w) / (1 + a), a2 = (1 - a) / (1 + a);
        double[] result = new double[source.Length];
        for (int i = 0; i < source.Length; ++i)
            result[i] = b0 * source[i] - (i > 1 ? b0 * source[i - 2] : 0)
                - (i > 0 ? a1 * result[i - 1] : 0) - (i > 1 ? a2 * result[i - 2] : 0);
        return result;
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
    public static void Build(string root, string name, string sourceA, string sourceB, bool low)
    {
        double[] a = Grain(Load(Path.Combine(root, "sounds", sourceA, sourceA + ".wav")));
        double[] b = Grain(Load(Path.Combine(root, "sounds", sourceB, sourceB + ".wav")));
        double seconds = low ? 0.105 : 0.080; // Seconds per syllable; Sam speaks with a heavier, longer texture.
        double[] voice = new double[(int)Math.Round(Rate * seconds)];
        for (int i = 0; i < voice.Length; ++i)
        {
            double t = (double)i / Rate;
            double speed = low ? 0.68 : 1.24; // Playback ratio: lower gives Sam a darker grain.
            double shift = i * speed + Rate * 0.002 * Math.Sin(t * 2 * Math.PI * 28);
            voice[i] = 0.7 * Sample(a, shift) + 0.3 * Sample(b, i * (low ? 0.83 : 1.05));
        }
        double[] vowelA = Band(voice, low ? 430 : 760, 2.4);
        double[] vowelB = Band(voice, low ? 1050 : 1750, 3.2);
        double peak = 0, energy = 0;
        for (int i = 0; i < voice.Length; ++i)
        {
            double t = (double)i / Rate;
            double envelope = Math.Min(1, t / 0.006) * Math.Min(1, (seconds - t) / 0.018);
            // A soft tremolo adds a voiced flutter; all audible texture comes from the existing effects.
            double flutter = 0.72 + 0.28 * Math.Cos(2 * Math.PI * (low ? 115 : 185) * t);
            voice[i] = (0.12 * voice[i] + 1.4 * vowelA[i] + 0.8 * vowelB[i]) * envelope * flutter;
            peak = Math.Max(peak, Math.Abs(voice[i])); energy += voice[i] * voice[i];
        }
        double gain = Math.Min(0.14 / Math.Sqrt(energy / voice.Length), 0.70 / peak);
        for (int i = 0; i < voice.Length; ++i) voice[i] *= gain;
        Write(Path.Combine(root, "sounds", name, name + ".wav"), voice);

        // Three short phrases at the in-game cadence, including gaps between words and sentences.
        double[] preview = new double[Rate * 5];
        double step = low ? 0.095 : 0.075;
        for (int phrase = 0; phrase < 3; ++phrase)
        for (int syllable = 0; syllable < 10; ++syllable)
        {
            double pitch = (low ? 0.90 : 1.0) + Math.Sin(syllable * 1.7 + phrase) * (low ? 0.07 : 0.10);
            int offset = (int)(Rate * (0.25 + phrase * 1.55 + syllable * step + (syllable >= 5 ? 0.12 : 0)));
            for (int j = 0; j * pitch < voice.Length - 1 && offset + j < preview.Length; ++j)
                preview[offset + j] += Sample(voice, j * pitch) * (low ? 0.50 : 0.55);
        }
        Write(Path.Combine(root, "docs", "audio", name + "-preview.wav"), preview);
        Console.WriteLine("{0}: {1:F3}s, mono PCM 44100 Hz, peak {2:F3}, RMS {3:F3}",
            name, seconds, peak * gain, Math.Sqrt(energy / voice.Length) * gain);
    }
}
'@

$projectRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
[DialogueVoiceBuilder]::Build($projectRoot, 'sfxAriTalk', 'sfxInitOpen', 'sfxInitEnter2', $false)
[DialogueVoiceBuilder]::Build($projectRoot, 'sfxSamTalk', 'sfxInitEnter1', 'sfxScoutStunMini', $true)
