# X-VESA

**X-VESA** is a DOS diagnostic program for in-depth analysis and verification of VESA interfaces on real hardware, written entirely in x86 assembly language.

> Developed by [Marco Pistella](mailto:mpistella@libero.it)  
> License: [GPL-3.0](https://www.gnu.org/licenses/gpl-3.0.html)  
> Official thread: [Vogons](https://www.vogons.org/viewtopic.php?t=111021)

---

## Overview

X-VESA enumerates all available VESA video modes, decodes the information returned by the VESA interface for each mode, and performs functional tests and measurements on the hardware resources actually accessible. It supports VBE specifications from version 1.0 to version 3.0, including non-standard versions and partial or defective implementations.

X-VESA is designed for use on **real hardware**. Operation on emulators or virtual machines is technically possible but discouraged: timing, jitter and VRAM access speed measurements produce meaningless results in an emulated environment.

---

## Features

- Enumeration of all available VESA video modes (up to 256), with technical information adapted to the declared VBE version (1.0 / 1.1 / 1.2 / 2.0 / 3.0)
- Full support for video memory models: Text, Planar (1–4 bpp), Packed-pixel (1–8 bpp), Direct color (9–32 bpp)
- VRAM access via banked (paged windows) and linear frame buffer modes
- Bank switching via INT 10h or direct far pointer to BIOS function
- Handling of common VESA implementation anomalies and automatic correction of invalid parameters
- VRAM read/write benchmark: 8 / 16 / 32 / 64 / 128 / 256 / 512 bit (FPU / SSE / AVX / AVX-512F where available), with overhead measurement and graphical results
- VRAM reliability test with three distinct patterns (BITS, BURST, MATRIX), configurable range and passes, real-time monitoring, navigable error table and file save
- Video scan timing analysis: vertical/horizontal frequency, bandwidth, interlace detection, sigma/mu jitter parameter, graphical sample distribution with zoom (10%–400%)
- Video mode visualization test (text, planar, packed pixel, direct color)
- Dual-page test with vertical retrace synchronization (OFF / VGA / VESA), with detection and handling of the Nvidia BL=80h retrace inversion bug
- Virtual resolution test via 4F06h/4F07h, with automatic characterization of alignment granularity and upper offset limit on both axes, keyboard and mouse navigation
- DAC 6/8-bit switch test with graphical gradient display; DAC type detection via direct probe on PEL mask register (3C6h)
- Available VRAM measurement via direct physical probe, independent of VbeInfoBlock declarations; aliasing detection
- Complete EDID read and decode via 4F15h: up to 8 DDC controllers, automatic deduplication, 9 decoded pages, extension block navigation, file save
- VBE/PM (Power Management) check with interactive power state activation
- System hardware detection: CPU mode (real / Unreal / V86), FPU, A20, CPUID, SSE, AVX, AVX-512F
- Video BIOS ROM dump to disk (C000h segment, size from ROM header)
- Screenshot in compressed IFF-PBM format via F2 key, available at any point
- INT 00h / INT 04h handler: "Guru Meditation" red screen with full 32-bit register dump (EAX–ESP, DS/ES/FS/GS, EFLAGS, CS:IP); CS:IP at C000h identifies crashes inside the VESA BIOS ROM
- Detection and handling of the divide-by-zero bug present in several 1990s VESA BIOS implementations (3dfx, Trident, Cirrus Logic, early Nvidia) for virtual resolutions exceeding 8 MB VRAM

---

## System Requirements

| Requirement | Minimum |
|---|---|
| Operating system | MS-DOS 5.0 or higher |
| Processor | Intel 80386 or higher (MUL-bug affected 80386 not supported) |
| Conventional memory | 302,048 bytes free |
| Graphics card | VESA 1.0 or higher compatible |

For cards without native VESA support, a compatible software VESA driver (TSR) must be loaded beforehand.

---

## Usage

```
X-VESA.COM
```

Launch from the DOS prompt. The main screen displays the enumerated VESA video mode list. Navigation is via cursor keys; ENTER opens the command menu for the selected mode.

### Main screen keys

| Key | Function |
|---|---|
| UP / DOWN | Navigate mode list |
| PGUP / PGDN | Navigate one page at a time |
| HOME / END | Beginning / end of list |
| ENTER | Open command menu for selected mode |
| F10 | Extended VESA interface information |
| F9 | Monitor EDID read |
| F8 | System and CPU extension information |
| F7 | VBE/PM Power Management check |
| F6 | Available VRAM per video mode |
| F2 | Screenshot (IFF-PBM) |
| ESC | Exit |

### Command menu options (per video mode)

| # | Command | Description |
|---|---|---|
| 1 | Detailed mode information | All VBE fields decoded for the selected mode |
| 2 | VRAM access speed | Benchmark 8–512 bit with overhead measurement |
| 3 | VRAM reliability | Three-pattern test with configurable range and passes |
| 4 | Detect scan timings | Frequency, bandwidth, interlace, jitter analysis |
| 5 | Video mode visualization | Renders test screen for the selected mode |
| 6 | Dual page test | Double-buffered flip with retrace synchronization |
| 7 | Virtual resolution | 4F06h/4F07h test with keyboard/mouse navigation |
| 8 | DAC 6/8-bit switch | Palette gradient test with toggle |
| 9 | Detect available VRAM | Physical probe, independent of BIOS declarations |

### Command menu modifier keys

| Key | Function |
|---|---|
| F10 | Enable / disable Linear frame buffer mode |
| F9 | Select bank switching via INT 10h or far pointer (banked mode) |
| F8 | Enable / disable AVX / AVX-512F support |

> **Warning:** On some systems, Legacy USB support (SMI) causes unrecoverable crashes when AVX is enabled. If in doubt, keep AVX disabled.

---

## Archive Contents (XVESA200.ZIP)

| File | Description |
|---|---|
| `X-VESA.COM` | Executable |
| `X-VESA.TXT` | Full documentation |
| `PBM2PNG.EXE` | IFF-PBM to PNG converter |
| `PBM2PNG.TXT` | PBM2PNG documentation |
| `IPEREDID.COM` | DOS TSR for multiple monitor EDID management |
| `IPEREDID.TXT` | IPEREDID documentation |
| `FILE_ID.DIZ` | Brief description |

---

## Notes

X-VESA 2.0 is a complete rewrite from scratch of version 1.x, developed in approximately 4 months entirely in x86 assembly language. The source code consists of over 22,000 lines written manually by the author. The compressed executable occupies approximately 33 KiB.

Screenshots are saved in IFF-PBM format and can be converted to PNG using the included `PBM2PNG.EXE` utility.

---

## License

X-VESA is released under the **GNU General Public License version 3** (GPL-3.0).  
Full license text: https://www.gnu.org/licenses/gpl-3.0.html

---

## Contact

Bug reports, anomalous behavior on specific hardware, and suggestions for future versions are welcome.

**Marco Pistella** — mpistella@libero.it
