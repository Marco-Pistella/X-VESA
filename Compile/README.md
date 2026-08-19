# X-VESA — Build Documentation

**X-VESA V2.0.0** — by Marco Pistella
Assembler: ASMC (Windows) + TLINK (DOS)
Memory model: SuperDoubleTiny (SDT)

---

## Table of Contents

1. [Source Structure](#1-source-structure)
2. [Tools Required](#2-tools-required)
3. [Build Orchestration and Build Modes](#3-build-orchestration-and-build-modes)
4. [SuperDoubleTiny Memory Model](#4-superdoubletiny-memory-model)
   - 4.1 [Problem: why COM, why two 64KB segments](#41-problem-why-com-why-two-64kb-segments)
   - 4.2 [Segment layout](#42-segment-layout)
   - 4.3 [Source structure: CODE and DATA segments](#43-source-structure-code-and-data-segments)
   - 4.4 [SAW.COM — splitting the EXE](#44-sawcom--splitting-the-exe)
   - 4.5 [APACK compression](#45-apack-compression)
   - 4.6 [STUB.COM — the bootstrap](#46-stubcom--the-bootstrap)
   - 4.7 [PREPSTUB.COM — patching the stub](#47-prepstubcom--patching-the-stub)
   - 4.8 [Final assembly](#48-final-assembly)
5. [SDT Bootstrap Sequence (step by step)](#5-sdt-bootstrap-sequence-step-by-step)
6. [CODE.ASM entry point and SDT detection](#6-codeasm-entry-point-and-sdt-detection)
7. [Auxiliary Utilities](#7-auxiliary-utilities)
   - 7.1 [CRYPT.COM](#71-cryptcom)
   - 7.2 [CHECKSUM / SAVID](#72-checksum--savid)
8. [Standard (non-release) build](#8-standard-non-release-build)
9. [Full build sequence summary](#9-full-build-sequence-summary)
10. [Open points not yet verified](#10-open-points-not-yet-verified)

---

## 1. Source Structure

```
X-VESA\
│
├── X-VESA.ASM          Main source — CODE segment only
├── INCLUDE\
│   ├── DATA.ASM        DATA segment (included at end of X-VESA.ASM)
│   ├── DOS.INC
│   ├── VIDEO.INC
│   ├── VESA.INC
│   ├── X-VESA.INC      Constants: X_VESA_MEM, segment offsets, flags
│   ├── HARDWARE.INC
│   ├── KEY.INC
│   ├── STRUCT.INC
│   └── MACRO.INC       NUM_TO_CHAR_PREP and other compile-time macros
├── LIBS\               148 include files (one routine per file)
│   ├── VESA_COMMAND_01.ASM .. VESA_COMMAND_09.ASM
│   ├── VESA_Speed_Routines.ASM
│   └── ... (all other library routines)
└── utility\
    ├── SAW\SAW.COM     EXE splitter
    ├── stub\
    │   ├── STUB.COM    SDT bootstrap stub
    │   └── PREPSTUB.COM Stub patcher
    ├── crypt\CRYPT.COM Executable encryptor
    └── checksum\       Checksum embedder (SAVID)
```

`X-VESA.ASM` contains a single `CODE SEGMENT`. At its end, `INCLUDE\DATA.ASM` is
included, which defines a separate `DATA SEGMENT`. TLINK produces a two-segment
EXE from the single assembled OBJ. The main source uses the `.X64P` processor
directive (the auxiliary build tools below use `.386` or `.8086`).

---

## 2. Tools Required

| Tool | Environment | Role |
|---|---|---|
| ASMC | Windows | Assembles X-VESA.ASM → X-VESA.OBJ |
| SYNC64.EXE | Windows | Syncs the build folder to the shared drive used by DOSBox-X |
| dosbox-x.exe | Windows | Runs the DOS-side toolchain |
| TLINK | DOS | Links X-VESA.OBJ → X-VESA.EXE |
| SAW.COM | DOS | Splits X-VESA.EXE → CODE.COM + DATA.COM |
| APACK | DOS | Compresses CODE.COM and DATA.COM separately |
| PREPSTUB.COM | DOS | Patches STUB.COM with compressed sizes |
| CRYPT.COM | DOS | XOR-encrypts X-VESA.COM (release only) |
| CHECKSUM (SAVID) | DOS | Embeds CRC at end of X-VESA.COM (every build mode) |
| exe2com | DOS | Standard EXE→COM converter (standard build only) |
| VC.COM | DOS | Volkov Commander, opened after the DOS-side build finishes |

ASMC runs on Windows and produces X-VESA.OBJ. `SYNC64.EXE` then syncs the
project folder onto a drive shared with DOSBox-X (mounted as `B:` on the
Windows side, `A:` inside DOSBox-X). The remainder of the build runs inside
DOSBox-X.

---

## 3. Build Orchestration and Build Modes

Unlike a simple "assemble here, link there" split, the whole pipeline is
driven by a **single `MAKE_PRG.BAT`** that invokes itself across both
environments:

1. Run without arguments on **Windows**, it assembles `X-VESA.ASM` with ASMC,
   runs `SYNC64.EXE B:` to push the OBJ and itself onto the shared folder,
   then checks (via `tasklist`) whether `dosbox-x.exe` is already running.
   If not, it relaunches itself with the `INIT` argument, which starts
   DOSBox-X and returns.
2. DOSBox-X's `[autoexec]` section (in `dosbox-x.conf`) sets the
   `DOSBOX-X` environment variable, mounts the shared folder as `A:`
   (mirroring Windows' `B:`) and `C:` as the DOS toolchain folder, then
   calls `A:\MAKE_PRG.BAT DOSBOX`.
3. That `DOSBOX` branch copies `MAKE_PRG.BAT` and `X-VESA.OBJ` from `A:` into
   `C:\PROJECTS\X-VESA`, calls `MAKE_PRG.BAT` again **with no arguments**
   (which — because `DOSBOX-X=1` is now set — runs the actual DOS build
   below in **standard** mode by default), and finally opens
   `C:\VC\VC.COM` (Volkov Commander) once the build finishes.
4. To build in `saw` or `release` mode instead of the default `standard`
   one, invoke `MAKE_PRG.BAT saw` or `MAKE_PRG.BAT release` manually from
   inside DOSBox-X, in `C:\PROJECTS\X-VESA`.

The actual DOS-side build, in the script's `:DOS` label, supports three
modes selected by the argument passed to it:

```
MAKE_PRG.BAT           standard build  (EXE → exe2com → single-segment COM)
MAKE_PRG.BAT saw       SAW build       (EXE → SAW → APACK data only → COM, no stub)
MAKE_PRG.BAT release   SDT release     (EXE → SAW → APACK both → STUB → CRYPT → CHECKSUM)
```

Only the **release** build produces the final distributable `X-VESA.COM` with
the full SDT memory model and encryption. **CHECKSUM runs for every mode**
(standard, saw, and release alike) — it sits at a shared `:end` label all
three branches fall through to, not only after the release-specific steps.

---

## 4. SuperDoubleTiny Memory Model

### 4.1 Problem: why COM, why two 64KB segments

A standard DOS COM file is loaded in a single segment: CS = DS = ES = SS.
The entire 64KB is shared between code, data, and stack, which is sufficient
for small programs but not for X-VESA, which requires:

- ~34KB of code (the CODE segment's actual assembled size, see §10)
- 64KB of data (mode tables, EDID buffers, VBE structures, strings)
- 64KB text/graphics buffer (10 video pages of 80×40)
- 64KB stack + font buffer
- 64KB I/O buffer (SEGMENT_4)
- 32KB video window at B800h (FS)

There are two separate, independent memory checks in the pipeline: STUB.COM
performs a coarse check for at least 192 KiB of free conventional memory
before even starting its own bootstrap; X-VESA's own code later performs a
second, precise check against `X_VESA_MEM` — a constant computed as the
actual assembled CODE-segment size (rounded to a paragraph) plus a fixed
256 KiB floor (`MIN_MEM`). With the current build this works out to roughly
296,720 bytes required (302,048 with Command 8's extra buffer).

A standard EXE with two segments solves the layout problem but suffers from
DOS EXE overhead and, more importantly, cannot be packed with a self-contained
bootstrap without significant complications. The SDT model achieves a
**two-segment COM**: separate 64KB code segment and 64KB data segment, inside
a file that DOS loads as an ordinary COM program.

The key constraint: DOS loads a COM file at CS:0100h and jumps to CS:0100h.
Everything must bootstrap from that single entry point.

### 4.2 Segment layout

After SDT bootstrap completes, the runtime memory map is:

```
 Segment          Size       Content
─────────────────────────────────────────────────────────────
 CS               ~34KB      Code (X-VESA.ASM routines, 148 LIBS\*.ASM files)
 DS               64KB       Data (DATA.ASM: tables, buffers, strings)
 [unnamed]        64KB       Text/graphics buffer (10 pages 80×40)
 SS               64KB       Stack + VGA font buffer (max 8192 bytes)
 SEGMENT_4        64KB       I/O buffer (file read/write staging)
 FS               32KB       Video VRAM window at B800h
```

Segment registers are set explicitly by the bootstrap and by `start_x_vesa`;
no DOS relocation is involved after the initial load. `SEGMENT_2`,
`SEGMENT_3`, `SEGMENT_4` and `START_STACK` are generic 4096-paragraph
(64KB) spacing constants (`1000h`/`2000h`/`3000h`/`2000h`) reused at several
points in X-VESA.ASM for different working segments — see §10 for an open
question about how one of these relates to STUB.COM's own relocation offset.

### 4.3 Source structure: CODE and DATA segments

`X-VESA.ASM` opens with:

```asm
CODE SEGMENT PARA PUBLIC USE16 'CODE'
ASSUME CS:CODE, DS:CODE, ES:CODE, SS:CODE
ORG 100h
```

All the code — X-VESA.ASM's own `start_code`/`start_x_vesa` routines plus 148
included LIBS\*.ASM files — is assembled into the CODE segment. At the very
end:

```asm
end_code:
CODE ENDS

    include INCLUDE\DATA.ASM

END start_code
```

`DATA.ASM` opens with (verified verbatim against the real source):

```asm
DATA SEGMENT PARA PUBLIC USE16 'DATA'
ORG 0h
ASSUME DS:NOTHING
NUM_TO_CHAR_PREP X_VESA_MEM, X_VESA_MEM_STR
NUM_TO_CHAR_PREP MAX_VESA_MODE, MAX_VESA_MODE_STR
start_data:
    retf
```

The `ORG 0h` (not 100h) is intentional: the DATA segment is not a standalone
COM and must not have the PSP prefix. `start_data` sits at offset 0 — the
`NUM_TO_CHAR_PREP` invocations above it are pure assembly-time macros (they
build compile-time text via `CATSTR`/`SUBSTR` and emit no bytes), so nothing
precedes `start_data` in the assembled segment. Its single instruction,
`retf`, is not incidental: it is the deliberate landing point the bootstrap
relies on to hand control back to CODE once DATA has been decompressed (see
§5, step l).

`NUM_TO_CHAR_PREP` is a compile-time TASM macro that converts a numeric
constant to a string of decimal digit characters via `CATSTR` prepend,
producing natural (non-reversed) digit order without runtime code.

TLINK with two segments produces `X-VESA.EXE` with:
- Segment 1 (CODE): from `start_code` to `end_code`
- Segment 2 (DATA): from `start_data` onward

### 4.4 SAW.COM — splitting the EXE

`SAW.COM` reads `X-VESA.EXE` and splits it into two COM files:

```
X-VESA.EXE  →  CODE.COM   (CODE segment content)
                DATA.COM   (DATA segment content, ORG 0h)
```

SAW seeks to absolute offset 768 (0x300) into the EXE, reads a 5-byte header
there, and uses the word at header+3 — shifted left 4 (paragraphs→bytes) — as
the CODE segment's size; it reads that many bytes (minus the 5 header bytes
already consumed) to complete the CODE segment content in a work buffer, then
creates and writes `CODE.COM`, followed by reading the rest of the EXE file
(the DATA segment) and writing it to `DATA.COM`.

**Note (unverified):** when writing `CODE.COM`, SAW recomputes the byte count
from the same header word — this time *without* subtracting the 5 header
bytes — and writes starting from the very beginning of its work buffer. On a
literal register trace this means the first 5 bytes of `CODE.COM` would be
the header bytes read at EXE offset 768 rather than assembled code; this may
simply be legitimate content of the segment at that position in TLINK's EXE
layout rather than an error — unconfirmed. Separately, the DOS file handle
returned when `DATA.COM` is created does not appear, on a register-by-register
trace, to be saved anywhere before the final write — the code only works if
DOS reassigns `DATA.COM` the same handle number just freed when `CODE.COM`
was closed (plausible, since DOS allocates the lowest free handle, but not an
explicit invariant in the source). Both points are flagged here for the
author to confirm rather than asserted as fact.

### 4.5 APACK compression

In the **release** build, both `CODE.COM` and `DATA.COM` are compressed
independently with APACK using the `-x` flag (maximum compression,
decompressor included):

```bat
apack -x DATA.COM DATA.COM
apack -x CODE.COM CODE.COM
```

In the **saw** build, only `DATA.COM` is compressed this way; `CODE.COM` is
left uncompressed and no stub is used (see §8).

Each compressed file is self-decompressing: when executed, it decompresses
itself in-place. APACK's decompressor becomes the new entry point (at offset
100h in each COM). The original content is reconstructed at the same load
address. The compressed sizes of both files are needed by PREPSTUB.

### 4.6 STUB.COM — the bootstrap

`STUB.COM` (`.8086`-compatible, banner `SDT-STUB V1.0.0`) performs the
two-stage decompression and segment relocation. Its source (`STUB.ASM`)
assembles to a small binary with two patch slots near its end:

```asm
code_comp_len:  DW 0h
data_comp_len:  DW 0h
end_code:
```

These two words are left at zero in the source; PREPSTUB fills them at
build time with the actual compressed sizes of CODE.COM and DATA.COM.

At runtime, STUB relocates itself to a work segment computed as
**`CS + 2000h`** (128 KiB above its own load segment) — via
`mov ax,cs` / `add ah,20h` / `mov ss,ax` / `mov es,ax`. `add ah,20h` adds to
the high byte of AX, which is arithmetically equivalent to adding `2000h` to
the full word — this segment is **128 KiB above CS, not 512 bytes**, despite
what a byte-literal reading of `20h` might suggest.

### 4.7 PREPSTUB.COM — patching the stub

`PREPSTUB.COM` performs three steps, with no error checking at any point
(unlike CRYPT.COM and CHECKSUM, which both check every DOS call):

1. Opens `CODE.COM` read-only, seeks to end, records the file size →
   `code_comp_len`.
2. Opens `DATA.COM` read-only, seeks to end, records the file size →
   `data_comp_len`.
3. Opens `STUB.COM` write-only and seeks **4 bytes before the end of the
   file** — a *relative* seek from EOF (`AX=4202h`, `CX:DX=0FFFFFFFCh`, i.e.
   -4), not a fixed absolute offset. It then writes both length words (4
   bytes total, in a single write) at that position.

Because the seek is relative to STUB.COM's actual end-of-file rather than a
hardcoded address, this works regardless of the stub's exact assembled size,
as long as `code_comp_len`/`data_comp_len` are the very last 4 bytes in the
source (which they are, per §4.6).

### 4.8 Final assembly

The three files are concatenated in order:

```bat
copy STUB.COM + CODE.COM + DATA.COM X-VESA.COM /B
```

The resulting `X-VESA.COM` layout on disk, before encryption, is:

```
 [start]    STUB.COM body (bootstrap)
            ...
            code_comp_len, data_comp_len   ← patched by PREPSTUB
 [after STUB]:
            CODE.COM body (APACK header + compressed code)
 [after CODE.COM]:
            DATA.COM body (APACK header + compressed data)
```

In the release build, this file is then run through CRYPT (§7.1), which
changes its on-disk layout again by moving a decryption stub to the *end*
of the file and replacing the first 3 bytes with a jump — see §7.1 for the
precise mechanism, and §5 step (a) for how this affects the runtime
bootstrap order.

---

## 5. SDT Bootstrap Sequence (step by step)

The following describes what happens at runtime after DOS loads a
**release-build** `X-VESA.COM` at `CS:0100h`, verified against the actual
STUB.ASM, X-VESA.ASM and DATA.ASM sources.

```
 a)  DOS loads X-VESA.COM at CS:0100h, jumps to CS:0100h. In a release
     build the first 3 bytes there are CRYPT's inserted near JMP (see
     §7.1), which transfers control to CRYPT's decryption stub appended
     at the end of the file. That stub restores the original first 3
     bytes and XOR-decrypts the rest, then jumps back to CS:0100h — which
     now holds STUB.COM's real entry point (start_code, STUB.ASM).

 b)  STUB reads available conventional memory from the BIOS data area
     (segment 40h, word at offset 13h), converts from KB to bytes/
     paragraphs. Subtracts CS to obtain free paragraphs above the load
     point. If less than 192KB (3000h paragraphs): prints the
     "SDT-STUB V1.0.0 ... Not enough memory" message, INT 20h.

 c)  STUB sets SS = ES = CS + 2000h (128 KiB above CS) — see §4.6.

 d)  STUB copies itself (start_code..end_code) to ES:0100h (same relative
     offset as loaded), word-granular (movsw), with a leading movsb if
     the byte count is odd. This frees the original CS:0100h area for
     decompression targets.

 e)  Far jump to ES:reloc_jmp_1 — execution continues from the relocated
     STUB copy. CS is now the segment that was ES (call it SEG_RELOC).

 f)  STUB moves DATA.COM's compressed body from its load position
     (immediately after CODE.COM's compressed body, in the *original*
     load segment, at end_code + code_comp_len) to SEG_RELOC:end_code
     (immediately after the relocated STUB code).

 g)  STUB moves CODE.COM's compressed body from the original segment's
     end_code offset down to that same original segment's offset 0100h,
     overwriting the (already relocated) original STUB code.

 h)  STUB builds a synthetic return frame on the stack and far-returns
     into the original segment at offset 0100h — where CODE.COM's
     compressed body now sits. This runs APACK's decompressor for CODE,
     which decompresses X-VESA's own code in place and ends with a near
     RET, using the address STUB set up on the stack.

 i)  Because SP is not 0FFFEh (the value DOS sets for a normally loaded
     COM), the freshly decompressed X-VESA code's own entry point
     (start_code, CODE.ASM) detects the mismatch and runs a short
     trampoline (see §6): it pops the mismatched near-RET address APACK
     left behind and reconstructs a correct far return that lands back
     inside the relocated STUB, at SEG_RELOC:reloc_jmp_2.

 j)  At reloc_jmp_2, STUB moves DATA.COM's compressed body (parked at
     SEG_RELOC:end_code since step f) down to SEG_RELOC:0100h — it does
     NOT decompress it here. STUB's own work ends with one last retf,
     which — via the frame X-VESA's trampoline set up in step (i) —
     lands execution at X-VESA's own no_sdt_stub continuation (CODE.ASM),
     back in the original CODE segment.

 k)  no_sdt_stub (CODE.ASM) computes DS = ES = CS + ceil(codesize/16) —
     see §10 for an open question about whether this numerically lands
     on SEG_RELOC — and SS = DS + START_STACK. It then pushes a synthetic
     far-return frame (CS:start_x_vesa, then DS:(start_data+100h)) and
     executes retf, landing at DS:0100h, where DATA.COM's compressed
     body is expected to sit.

 l)  APACK's decompressor for DATA runs there, decompressing DATA.ASM's
     content in place. The decompressed image's very first byte, at
     offset 0 (the start_data label), is itself a bare `retf` instruction
     — placed there specifically to serve as the final handoff (§4.3).

 m)  That `retf` pops the remaining synthetic frame from step (k)
     (CS:start_x_vesa), transferring execution to CODE:start_x_vesa.
     Bootstrap is complete: CS is the code segment, DS is the (now
     decompressed) data segment.
```

---

## 6. CODE.ASM entry point and SDT detection

`start_code` at `CS:0100h` contains a dual-path entry, verified verbatim
against the real source:

```asm
start_code:
    mov  ax, cs
    add  ax, ((OFFSET end_code - OFFSET start_code) + 0Fh) SHR 4h
    mov  es, ax
    cmp  sp, 0FFFEh
    je   no_sdt_stub
    ; SDT path: SP ≠ 0FFFEh → stub called us via stack manipulation
    pop  cx
    pop  bx
    push cs
    mov  ax, OFFSET no_sdt_stub
    push ax
    push bx
    push cx
    retf
no_sdt_stub:
    ; Direct path: standard COM load (standard or saw build)
    ...
```

When DOS loads a COM file normally, SP is initialized to `0FFFEh`. The check
`cmp sp, 0FFFEh` / `je no_sdt_stub` detects this case.

When STUB launches CODE via the far call chain (§5, step h), SP is not
`0FFFEh` (STUB has used the stack). The SDT path executes: it pops the APACK
return address (bx:cx), then reconstructs a new far return frame that will
land at `no_sdt_stub` after exchanging the return addresses. This is the
trampoline that allows APACK's decompressor (which ends with a near `ret`) to
return to the correct continuation point inside STUB.

After `no_sdt_stub`:

```asm
    mov  ax, es          ; ES = segment computed from CODE's own assembled size
    mov  ds, ax          ; DS = data segment (expected to hold decompressed DATA)
    add  ax, START_STACK
    mov  ss, ax           ; SS = stack segment
    push cs
    push OFFSET start_x_vesa
    push ds
    push OFFSET start_data + 100h
    retf                 ; jump to DS:0100h, triggering DATA's APACK decompressor
```

The double push/retf pattern (push target CS:IP, then push DATA:start_data,
then retf) achieves a far jump while simultaneously passing the data segment
pointer through the stack — a clean way to initialize DS and transfer control
in a single instruction. See §5 steps (k)–(m) and §10 for how this resolves.

`start_x_vesa` then adds a further 256 bytes (`10h` paragraphs) to DS/ES,
sets CLD, and begins normal initialization: DOS version check, 80386
detection, MUL bug test, the precise `X_VESA_MEM` memory check (distinct
from STUB's coarse 192KiB check — see §4.1), environment scan for the
executable path, file open and checksum verification, VGA detection, VESA
enumeration, and main loop.

---

## 7. Auxiliary Utilities

### 7.1 CRYPT.COM

`CRYPT.COM` (banner `Crypt V1.2 by M.Pistella`) is a command-line tool
(`CRYPT.COM <file>`) that takes exactly one argument, parsed via a small
custom PSP argument parser (`Get_Args`); with zero or more than one argument
it prints a usage message and exits.

Contrary to a "stub prepended, body follows" description, the mechanism is:

1. The target file is read whole into a work buffer (segment `CS+1000h`).
   Files under 5 bytes, or larger than `0FF00h` minus the stub's own size,
   are rejected as "Unsupported .COM file".
2. The file's original first 3 bytes are saved into two patch slots
   (`_PATCH_0`, a word, and `_PATCH_3`, a byte) inside CRYPT's own
   decryption-stub code.
3. **The decryption stub (`crypt_on`..`crypt_off`) is written to the file
   first, at the current file position — which is end-of-file after the
   read. It is appended, not prepended.**
4. The buffer is then encrypted in memory: `byte[i] ^= byte[i+1]` (XOR with
   the following byte), computed forward for `i = 3 .. filesize-2`. Offset 3
   onward, as originally documented, but computed against the byte that
   follows it, not a fixed key; the final byte of the file is left
   untouched (it has no successor).
5. The buffer's first 3 bytes are overwritten with a near JMP (`0E9h` +
   16-bit relative offset) that targets exactly `100h + filesize` — i.e.
   the start of the stub just appended in step 3. The whole buffer
   (filesize bytes) is then written back to the file at offset 0,
   replacing the original content.

At runtime, DOS loads the file and executes the 3-byte JMP at offset 100h,
landing in the appended decryption stub. That stub restores the original
first 3 bytes (via `_PATCH_0`/`_PATCH_3`), then decrypts backward — from the
top of the file down to offset 103h — undoing the forward XOR-with-successor
scheme (this direction is required: byte `i` can only be recovered once byte
`i+1` is already decrypted). A final patched near JMP (`_PATCH_2`) then
transfers control back to `CS:0100h`, now correctly restored. There are
**four** patch points in total (`_PATCH_0`, `_PATCH_1`, `_PATCH_2`,
`_PATCH_3`), not three.

### 7.2 CHECKSUM / SAVID

After CRYPT, `CHECKSUM` (compiled from `SAVID.ASM`) appends a 4-byte CRC
to `X-VESA.COM` — and, per §3, this step runs for every build mode, not
release alone. It opens the hardcoded filename `X-VESA.COM` in the current
directory (read/write, existing file only — it does not create one), reads
up to `MAX_LEN = 0FF00h` (65,280) bytes into a separate work segment
(`CS+1000h`), computes the checksum, and appends the 4-byte result at the
current file position (which, having just read the whole file, is EOF —
this is a genuine append via low-level I/O, not merely conceptual). Any DOS
call failure (open/read/write/close) is caught and reported via
`"Errore in fase di modifica"`.

The CRC algorithm (`Get_Checksum`) is a custom multiplicative hash using the
first two DWORDs of the file as seeds:

```asm
Get_Checksum:
    ; EAX = checksum of DS:SI block, length CX
    mov  eax, ds:dword ptr [si+4h]  ; seed 1
    mov  edx, ds:dword ptr [si]     ; seed 2
loop_crc:
    lodsb
    mul  dx
    not  eax
    xor  al, ds:byte ptr [si-1h]
    sub  edx, eax
    xor  eax, edx
    mul  edx
    loop loop_crc
    rol  eax, 11h
```

At startup, `start_x_vesa` reads `X-VESA.COM` from disk (located via the
DOS environment block), computes the checksum over all bytes except the last
4, and compares against the stored value. A mismatch causes immediate exit
with an error message. This detects both corruption and unauthorized
modification of the executable.

---

## 8. Standard (non-release) build

```bat
MAKE_PRG.BAT           → exe2com X-VESA.EXE X-VESA.COM
MAKE_PRG.BAT saw       → SAW + apack DATA only + concatenate (no STUB, no CRYPT)
```

In the standard build, `exe2com` converts the two-segment EXE to a flat COM.
Only the CODE segment is accessible; the DATA segment is appended but not
separately addressable as a full 64KB segment. This mode is the *default*
when the build is launched from inside DOSBox-X (see §3) and is used during
development to avoid the full SDT pipeline on every iteration.

In the `saw` build, DATA is compressed but CODE is not, and no stub is used.
The resulting COM still uses a simplified two-segment layout but without the
APACK decompressor on CODE. This intermediate mode is useful for testing
SAW and APACK behavior without committing to the full release pipeline.

CHECKSUM still runs at the end of both of these modes (§3, §7.2). The
release build is required for distribution: only it produces the correct
memory layout with separate 64KB segments, full compression, and
encryption.

---

## 9. Full build sequence summary

```
[Windows]
  ASMC X-VESA.ASM
  → X-VESA.OBJ
  SYNC64.EXE B:                      (pushes OBJ + MAKE_PRG.BAT to shared folder)
  → launches dosbox-x.exe if not already running

[DOSBox-X autoexec]
  mounts A: = shared folder, C: = DOS toolchain
  MAKE_PRG.BAT DOSBOX
  → copies OBJ + batch file into C:\PROJECTS\X-VESA
  → calls MAKE_PRG.BAT (no args → standard build by default)

[DOS — MAKE_PRG.BAT release, run manually for a release build]

  TLINK X-VESA.OBJ
  → X-VESA.EXE        (two-segment: CODE + DATA)

  SAW.COM
  → CODE.COM           (CODE segment)
  → DATA.COM           (DATA segment, ORG 0h)

  apack -x DATA.COM DATA.COM
  → DATA.COM           (self-decompressing)

  apack -x CODE.COM CODE.COM
  → CODE.COM           (self-decompressing)

  copy .\utility\stub\STUB.COM
  PREPSTUB.COM
  → STUB.COM           (patched: code_comp_len, data_comp_len embedded)

  copy STUB.COM + CODE.COM + DATA.COM X-VESA.COM /B
  → X-VESA.COM         (SDT binary: stub + compressed code + compressed data)
  [del code.com, del data.com, del stub.com]

  crypt X-VESA.COM
  → X-VESA.COM         (first 3 bytes replaced by a JMP; decryption stub
                         appended at the end — see §7.1)

  checksum              (runs for EVERY build mode, not just release)
  → X-VESA.COM         (4-byte CRC appended)

  [cleanup, shared by all modes: del X-VESA.BAK, X-VESA.MAP, X-VESA.EXE,
   asm.err; dir listing; copy X-VESA.COM back to A:\ ]
  [X-VESA.OBJ is NOT deleted — the delete line is commented out]

[back inside DOSBox-X, after the DOSBOX branch's build call]
  C:\VC\VC.COM opens (Volkov Commander)
```

Final `X-VESA.COM`: ~32 KiB compressed, expands to roughly 302,048 bytes at
runtime (see §4.1 for how this figure is computed).

---

## 10. Open points not yet verified

These are documented here rather than silently asserted, pending further
source review:

- **ES/DS segment arithmetic (§5, §6).** `no_sdt_stub` computes
  `DS = CS + ceil((end_code-start_code)/16)`. Given `X_VESA_MEM`'s formula
  (§4.1) and its known value (~296,720 bytes, `MIN_MEM` = 262,144), the
  CODE segment's actual assembled size works out to roughly 34.5 KB — which
  would put this computed DS at only `CS+871h` paragraphs, not at the
  `CS+2000h` STUB.COM fixes for its own relocation segment (§4.6, §5 step c).
  If DATA's compressed body genuinely needs to be found by CODE.ASM at this
  computed DS, the two offsets would need to coincide, and on current
  evidence they don't appear to. This may be resolved by a LIBS\*.ASM
  routine not yet reviewed (possibly around `Init_X_VESA.ASM`), or by a
  detail of the relocation this document has not captured correctly — it is
  flagged here rather than resolved.
- **SAW.COM / CODE.COM header bytes (§4.4).** Whether the 5 bytes read at
  EXE offset 768 are legitimately part of CODE.COM's content or are
  incidentally carried into the output.
- **SAW.COM / DATA.COM file handle (§4.4).** Whether the write to DATA.COM
  genuinely relies on DOS reassigning the just-freed CODE.COM handle number,
  or whether this document's register trace has missed something.
