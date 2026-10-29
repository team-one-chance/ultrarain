$ErrorActionPreference = 'Stop'

# Rebuild the continuous ground-slide texture from the preserved imported sound.
Add-Type -TypeDefinition @'
using System;
using System.IO;
public static class SlideLoopBuilder
{
    public static void Build(string source, string destination, string preview)
    {
        byte[] bytes = File.ReadAllBytes(source);
        int offset = 12, data = -1, size = 0;
        while (offset + 8 <= bytes.Length)
        {
            int length = BitConverter.ToInt32(bytes, offset + 4);
            if (System.Text.Encoding.ASCII.GetString(bytes, offset, 4) == "data")
            { data = offset + 8; size = length; break; }
            offset += 8 + length + (length & 1);
        }
        if (data < 0 || BitConverter.ToInt16(bytes, 20) != 1
            || BitConverter.ToInt16(bytes, 22) != 2
            || BitConverter.ToInt16(bytes, 34) != 16)
            throw new Exception("Expected the original stereo 16-bit PCM WAV (pulse-code modulation).");

        int rate = BitConverter.ToInt32(bytes, 24); // Samples/second; preserve the source pitch and bandwidth.
        int frames = size / 4;
        double[,] input = new double[frames, 2];
        double[] energy = new double[frames + 1];
        for (int i = 0; i < frames; i++)
        {
            for (int c = 0; c < 2; c++) input[i, c] = BitConverter.ToInt16(bytes, data + i * 4 + c * 2) / 32768.0;
            energy[i + 1] = energy[i] + (input[i, 0] * input[i, 0] + input[i, 1] * input[i, 1]) * 0.5;
        }
        int radius = (int)(rate * 0.015); // 15 ms each side: smooth the swell without erasing the scrape detail.
        for (int i = 0; i < frames; i++)
        {
            int lo = Math.Max(0, i - radius), hi = Math.Min(frames, i + radius + 1);
            double rms = Math.Sqrt((energy[hi] - energy[lo]) / (hi - lo)); // RMS means root mean square amplitude.
            double gain = Math.Min(4.0, 0.065 / Math.Max(0.001, rms)); // Limit boost to avoid raising the quiet tail's noise.
            for (int c = 0; c < 2; c++) input[i, c] *= gain;
        }

        int total = (int)(rate * 4.8); // Seconds per full cycle; no repeated source slices inside the cycle.
        double[,] output = BuildContinuousTexture(input, rate, total);
        FilterLoop(output, rate, 120, true); // Hz: remove sub-bass rumble; higher values thin the sliding texture.
        FilterLoop(output, rate, 2400, false); // Hz: soften sharp scraping highs; lower values make the slide darker.
        double sum = 0, peak = 0;
        for (int i = 0; i < total; i++)
        for (int c = 0; c < 2; c++)
        {
            sum += output[i, c] * output[i, c];
            peak = Math.Max(peak, Math.Abs(output[i, c]));
        }
        double level = Math.Min(0.040 / Math.Sqrt(sum / (total * 2)), 0.85 / peak); // RMS amplitude: quieter friction bed with headroom for other sounds.
        Write(destination, output, rate, level, 1);
        Write(preview, output, rate, level, 3); // 14.4-second preview includes three full cycles to judge the joins.
        Console.WriteLine("Loop: {0:F2}s, {1} Hz stereo; peak {2:F4}, RMS {3:F4}", (double)total / rate, rate, peak * level, Math.Sqrt(sum / (total * 2)) * level);
        Console.WriteLine("Boundary step L/R: {0:F6} / {1:F6}", Math.Abs(output[0, 0] - output[total - 1, 0]) * level, Math.Abs(output[0, 1] - output[total - 1, 1]) * level);
    }
    static double[,] BuildContinuousTexture(double[,] input, int rate, int total)
    {
        int analysisSize = 4096; // Samples per spectral measurement; captures the scrape's tone without its repeated attacks.
        double[] spectrum = new double[analysisSize / 2 + 1];
        int start = (int)(rate * 0.080), end = (int)(rate * 0.380); // Source seconds: measure only the active friction texture.
        for (int offset = start; offset + analysisSize <= end; offset += analysisSize / 2)
        {
            double[] real = new double[analysisSize], imaginary = new double[analysisSize];
            for (int i = 0; i < analysisSize; i++)
                real[i] = (input[offset + i, 0] + input[offset + i, 1]) * 0.5
                    * (0.5 - 0.5 * Math.Cos(2 * Math.PI * i / (analysisSize - 1)));
            Transform(real, imaginary, false);
            for (int k = 0; k < spectrum.Length; k++)
                spectrum[k] += real[k] * real[k] + imaginary[k] * imaginary[k];
        }
        double[] smooth = new double[spectrum.Length];
        int radius = 8; // Frequency bins (about 94 Hz each side): smooth narrow ringing into a softer friction spectrum.
        for (int k = 0; k < spectrum.Length; k++)
        {
            int lo = Math.Max(0, k - radius), hi = Math.Min(spectrum.Length - 1, k + radius);
            for (int j = lo; j <= hi; j++) smooth[k] += spectrum[j];
            smooth[k] /= hi - lo + 1;
        }
        int synthesisSize = 1;
        while (synthesisSize < total) synthesisSize <<= 1; // Power-of-two workspace for the fast Fourier transform (FFT).
        double[] re = new double[synthesisSize], im = new double[synthesisSize];
        Random random = new Random(7301); // Fixed seed preserves reproducible edits without repeating short waveforms.
        for (int k = 1; k < synthesisSize / 2; k++)
        {
            double sourceBin = (double)k * analysisSize / total; // Map to the final duration so resampling preserves the measured tone.
            int bin = (int)sourceBin;
            if (bin + 1 >= smooth.Length) break;
            double fraction = sourceBin - bin;
            double power = smooth[bin] * (1 - fraction) + smooth[bin + 1] * fraction;
            double magnitude = Math.Sqrt(power * -Math.Log(Math.Max(1e-12, random.NextDouble())));
            double phase = random.NextDouble() * 2 * Math.PI;
            re[k] = magnitude * Math.Cos(phase); im[k] = magnitude * Math.Sin(phase);
            re[synthesisSize - k] = re[k]; im[synthesisSize - k] = -im[k];
        }
        Transform(re, im, true); // One continuous periodic noise texture; no grains, splice rhythm, or recycled attack.
        double[,] result = new double[total, 2];
        for (int i = 0; i < total; i++)
        {
            double position = (double)i * synthesisSize / total;
            int index = (int)position;
            double fraction = position - index;
            double value = re[index] * (1 - fraction) + re[(index + 1) % synthesisSize] * fraction;
            result[i, 0] = result[i, 1] = value; // Centered friction matches the original sound's identical left/right channels.
        }
        return result;
    }
    static void Transform(double[] real, double[] imaginary, bool inverse)
    {
        int n = real.Length;
        for (int i = 1, j = 0; i < n; i++)
        {
            int bit = n >> 1;
            for (; (j & bit) != 0; bit >>= 1) j ^= bit;
            j ^= bit;
            if (i < j)
            {
                double t = real[i]; real[i] = real[j]; real[j] = t;
                t = imaginary[i]; imaginary[i] = imaginary[j]; imaginary[j] = t;
            }
        }
        for (int length = 2; length <= n; length <<= 1)
        {
            double angle = (inverse ? 2 : -2) * Math.PI / length;
            double stepR = Math.Cos(angle), stepI = Math.Sin(angle);
            for (int offset = 0; offset < n; offset += length)
            {
                double wr = 1, wi = 0;
                for (int j = 0; j < length / 2; j++)
                {
                    int a = offset + j, b = a + length / 2;
                    double vr = real[b] * wr - imaginary[b] * wi, vi = real[b] * wi + imaginary[b] * wr;
                    real[b] = real[a] - vr; imaginary[b] = imaginary[a] - vi;
                    real[a] += vr; imaginary[a] += vi;
                    double next = wr * stepR - wi * stepI;
                    wi = wr * stepI + wi * stepR; wr = next;
                }
            }
        }
        if (inverse) for (int i = 0; i < n; i++) { real[i] /= n; imaginary[i] /= n; }
    }
    static void FilterLoop(double[,] samples, int rate, double cutoff, bool highpass)
    {
        double omega = 2 * Math.PI * cutoff / rate;
        double cosine = Math.Cos(omega), alpha = Math.Sin(omega) / Math.Sqrt(2); // Butterworth response avoids a resonant peak at the cutoff.
        double a0 = 1 + alpha, a1 = -2 * cosine / a0, a2 = (1 - alpha) / a0;
        double b0 = (highpass ? 1 + cosine : 1 - cosine) / (2 * a0);
        double b1 = (highpass ? -(1 + cosine) : 1 - cosine) / a0, b2 = b0;
        int frames = samples.GetLength(0);
        for (int c = 0; c < 2; c++)
        {
            double x1 = 0, x2 = 0, y1 = 0, y2 = 0;
            // Warm up on two complete cycles; write only the third to keep filter state continuous at the seam.
            for (int pass = 0; pass < 3; pass++)
            for (int i = 0; i < frames; i++)
            {
                double x = samples[i, c];
                double y = b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2;
                x2 = x1; x1 = x; y2 = y1; y1 = y;
                if (pass == 2) samples[i, c] = y;
            }
        }
    }
    static void Write(string path, double[,] samples, int rate, double level, int repeats)
    {
        int frames = samples.GetLength(0), length = frames * repeats * 4;
        using (BinaryWriter w = new BinaryWriter(File.Create(path)))
        {
            w.Write(System.Text.Encoding.ASCII.GetBytes("RIFF")); w.Write(36 + length);
            w.Write(System.Text.Encoding.ASCII.GetBytes("WAVEfmt ")); w.Write(16);
            w.Write((short)1); w.Write((short)2); w.Write(rate); w.Write(rate * 4);
            w.Write((short)4); w.Write((short)16);
            w.Write(System.Text.Encoding.ASCII.GetBytes("data")); w.Write(length);
            for (int r = 0; r < repeats; r++)
            for (int i = 0; i < frames; i++)
            for (int c = 0; c < 2; c++) w.Write((short)Math.Round(samples[i, c] * level * 32767));
        }
    }
}
'@

$repoRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
[SlideLoopBuilder]::Build(
    (Join-Path $PSScriptRoot 'sfxSlide-source.wav'),
    (Join-Path $repoRoot 'sounds/sfxSlide/sfxSlide.wav'),
    (Join-Path $PSScriptRoot 'slide-loop-preview.wav'))
