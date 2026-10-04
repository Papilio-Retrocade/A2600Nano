# Papilio Retrocade Atari 2600 splash

Two versions are provided:

## `papilio_splash.a` (recommended — real text)

DASM assembly adapted from the official 8bitworkshop "tinyfonts2.a" example
(https://8bitworkshop.com/v3.12.1/?platform=vcs&file=examples%2Ftinyfonts2.a),
which proves the 2600 CAN render literal, spelled-out text on real hardware:
a sprite-retriggering trick loads GRP0/GRP1 mid-scanline (via a stack-pointer
copy trick) to build a 48x5-pixel line of text from a 5x7 bitmap font, 12
characters per line. This corrects an earlier assumption in this repo that
only a logo (no text) was practical on the 2600 — literal text is achievable,
it just requires this DASM kernel rather than batari Basic.

Displays 3 lines (12 chars each, uppercase/digits/punctuation only, `[` =
blank), well within one frame's 192-scanline visible budget:
```
PAPILIO
RETROCADE
 A2600 CORE
```

Note the hard limit of this kernel: exactly 12 characters per line,
uppercase/digits/punctuation only (no lowercase), so full phrases like
"Papilio Retrocade Hardware" or "Papilioworks.com" can't be spelled out
verbatim on one line — a 7-line version spelling those out in full was
tried and rejected as too visually cluttered. This 3-line version keeps
the essential branding and core name. Widening the kernel to fit longer
lines per row is possible but would need a nontrivial rework of the
sprite-retriggering timing (higher risk of glitches) — worth a follow-up if
the full phrases are still wanted.

### Build

Easiest (no local install): paste the source into
[8bitworkshop.com](https://8bitworkshop.com/redir.html?platform=vcs) (platform
`vcs`), which assembles and runs it live in an emulator — this is the same
tool the original example was verified against.

For a local build, install DASM (https://dasm-assembler.github.io/, open
source) and assemble with the `vcs.h`/`macro.h`/`xmacro.h` includes from the
8bitworkshop `presets/vcs/` folder (https://github.com/sehugg/8bitworkshop),
e.g.:

```powershell
dasm papilio_splash.a -f3 -opapilio_splash.bin -I<path-to-presets-vcs>
```

### Test

Run the `.bin` in Stella (https://stella-emu.github.io/) before flashing
hardware.

## `papilio_splash.bas` (fallback — logo only, batari Basic)

Simpler batari Basic (bB) source: color-cycling background, bordered
playfield frame, and a blocky "P" logo sprite — no spelled text, kept as a
lower-effort fallback. See file header for build notes (`2600bas` /
8bitworkshop.com, "batari Basic" language).

## Deploy to A2600Nano

`a2600crt.bin` (compiled from `papilio_splash.a`) is checked into this folder —
copy it to the SD card root as `a2600crt.bin`. This matches the core's default
cartridge file name (`src/misc/atari2600.xml`, `fileselector ... default="a2600crt.bin"`),
so it becomes the out-of-box cartridge with no bitstream rebuild required.
