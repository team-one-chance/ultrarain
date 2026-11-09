# Ari and Samuel dialogue voices

The existing `sfxAriTalk` and `sfxSamTalk` resources now contain short mono,
44.1 kHz, 16-bit PCM syllables remixed from existing game effects:

| Voice | Sources | Treatment |
| --- | --- | --- |
| Ari | `sfxInitOpen`, `sfxInitEnter2` | 80 ms, brighter playback, vowel-like filtering and light flutter |
| Samuel | `sfxInitEnter1`, `sfxScoutStunMini` | 105 ms, lower playback, darker filtering and slower flutter |

Run `powershell -NoProfile -ExecutionPolicy Bypass -File docs/audio/build-dialogue-voices.ps1`
from the project directory to regenerate the assets and five-second previews.
The script reads the originals without changing them and limits peaks below 0.70.

`oAri` owns the shared voice timing and cleanup; `oSamuel` overrides the voice
configuration after inheriting Create. Syllables follow newly revealed letters,
with small deterministic pitch changes. Spaces are silent and punctuation adds
pauses. Skipping, advancing, departing, and removing a speaker stop its voice.
The existing typewriter speed and interaction flow are preserved.

Validation: Windows VM compile passed with runtime 2026.0.0.23. A disposable copy
under `output/dialogue-voices-check/project` exercised the actual inherited Begin
Step events in the Windows runner. All 16 checks passed: distinct assets, active
audio during typing, unchanged text timing, no retrigger on completed lines,
skip/advance cleanup, punctuation pauses, silent spaces, and departure cleanup
for both speakers. See `output/dialogue-voices-check/runner.log`.

The previews are `sfxAriTalk-preview.wav` and `sfxSamTalk-preview.wav` alongside
this file. Final subjective balance with music and combat still needs listening
in a normal playthrough.
