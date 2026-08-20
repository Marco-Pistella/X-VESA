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
| SYNC64.EXE | Windows | Prepares the drive shared with DOSBox-X (exact function undocumented; the actual file copy is done by separate `copy` commands, see §3) |
| dosbox-x.exe | Windows | Runs the DOS-side toolchain |
| TLINK | DOS | Links X-VESA.OBJ → X-VESA.EXE |
| SAW.COM | DOS | Splits X-VESA.EXE → CODE.COM + DATA.COM |
| APACK | DOS | Compresses CODE.COM and DATA.COM separately |
| PREPSTUB.COM | DOS | Patches STUB.COM with compressed sizes |
| CRYPT.COM | DOS | XOR-encrypts X-VESA.COM (release only) |
| CHECKSUM (SAVID) | DOS | Embeds CRC at end of X-VESA.COM (every build mode) |
| exe2com | DOS | Standard EXE→COM converter (standard build only) |
| VC.COM | DOS | Volkov Commander, opened after the DOS-side build finishes |

ASMC runs on Windows and produces X-VESA.OBJ, which is then placed (via
`SYNC64.EXE` and explicit `copy` commands, see §3) onto a drive shared with
DOSBox-X (mounted as `B:` on the Windows side, `A:` inside DOSBox-X). The
remainder of the build runs inside DOSBox-X.

---

## 3. Build Orchestration and Build Modes

Unlike a simple "assemble here, link there" split, the whole pipeline is
driven by a **single `MAKE_PRG.BAT`** that invokes itself across both
environments:

1. Run without arguments on **Windows**, it assembles `X-VESA.ASM` with ASMC,
   then runs `SYNC64.EXE B:` — its exact function isn't documented here, but
   given the drive-letter argument it most likely prepares/mounts the shared
   drive rather than doing the file transfer itself, since two explicit
   `copy` commands follow it (`copy X-VESA.OBJ B:\` and
   `copy MAKE_PRG.BAT B:\`) to actually place the files there. The script
   then checks (via `tasklist`) whether `dosbox-x.exe` is already running.
   If not, it relaunches itself with the `INIT` argument, which starts
   DOSBox-X and returns.
2. DOSBox-X's `[autoexec]` section (in `dosbox-x.conf`) sets the
   `DOSBOX-X` environment variable, mounts the shared folder as `A:`
   (mirroring Windows' `B:`) and `C:` as the DOS toolchain folder, then
   calls `A:\MAKE_PRG.BAT DOSBOX`. **This autoexec, and the copy+build chain
   it triggers, only runs once — when DOSBox-X itself starts.**
3. That `DOSBOX` branch copies `MAKE_PRG.BAT` and `X-VESA.OBJ` from `A:` into
   `C:\PROJECTS\X-VESA`, calls `MAKE_PRG.BAT` again **with no arguments**
   (which — because `DOSBOX-X=1` is now set — runs the actual DOS build
   below in **standard** mode by default), and finally opens
   `C:\VC\VC.COM` (Volkov Commander) once the build finishes.
4. To build in `saw` or `release` mode instead of the default `standard`
   one, invoke `MAKE_PRG.BAT saw` or `MAKE_PRG.BAT release` manually from
   inside DOSBox-X, in `C:\PROJECTS\X-VESA`.

**Practical consequence:** if DOSBox-X is already open when the Windows side
reassembles, the tasklist check finds it running and does nothing further —
the fresh OBJ lands on the shared drive but is *not* automatically pulled
into `C:\PROJECTS\X-VESA`. From an already-open DOSBox-X session, re-copying
`A:\X-VESA.OBJ` (and rerunning `MAKE_PRG.BAT`) by hand is needed to pick up
a new assembly.

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
no DOS relocation is involved after the initial load. `SEGMENT_2`
(`1000h`), `SEGMENT_3`/`START_STACK` (`2000h`) and `SEGMENT_4` (`3000h`)
are absolute offsets from DS spaced 64KB apart from each other (one, two,
and three 64KB blocks past DS respectively) — not each individually "64KB",
despite the round numbers. They line up with this table: DS+`1000h` lands on
the unnamed text buffer, DS+`2000h` (`START_STACK`) on SS, DS+`3000h`
(`SEGMENT_4`) on the I/O buffer — consistent with the sequential layout
above. See §10 for an open question about whether STUB.COM's own,
unrelated use of a `+2000h` relocation offset is a coincidence with
`SEGMENT_3`/`START_STACK` or not.

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

SAW seeks to absolute offset 768 (0x300) into the EXE — this is where
TLINK's header ends and the load module begins, i.e. exactly where
`CS:0100h` lands once the program runs. There is no EXE/TLINK header
structure being parsed here: SAW reads the first **5 bytes of the CODE
segment's own compiled content**, which are the first two assembled
instructions of `start_code` (X-VESA.ASM) itself:

```asm
start_code:
    mov ax,cs                                                    ; 8C C8      (2 bytes)
    add ax,((OFFSET end_code - OFFSET start_code)+0Fh) SHR 4h     ; 05 lo hi   (3 bytes)
```

`mov ax,cs` assembles to `8C C8`; the short accumulator-form `add ax,imm16`
assembles to `05` followed by its 2-byte immediate — five bytes total. That
immediate operand is exactly the CODE segment's own size, rounded up to a
paragraph, computed by the assembler at build time (the same value the SDT
trampoline in §6 recomputes at runtime, and the same formula behind
`X_VESA_MEM`, §4.1). SAW simply reads that immediate straight out of the
instruction stream — `mov cx, word ptr [header+3]; shl cx,4` gives the
CODE segment's size in bytes, no separate size field or header structure
required anywhere. **`start_code`'s own opening instructions double as a
machine-readable size record for SAW to consume.** Confirmed against a hex
dump of the actual `CODE.COM` output (first bytes `8C C8 05 ...`).

With that size in hand, SAW reads the remaining code bytes (that count
minus the 5 already consumed) to complete the CODE segment in a work
buffer, then creates and writes `CODE.COM` — this time writing the *full*
size, header-derived bytes included, since they are genuine assembled code,
not incidental header bytes. It then reads the rest of the EXE file (the
DATA segment) and writes it to `DATA.COM`.

**Note on the DATA.COM file handle:** the DOS file handle returned when
`DATA.COM` is created is never explicitly saved to a register that
survives — but it doesn't need to be. DOS allocates file handles from the
lowest free slot in the Job File Table: `X-VESA.EXE` gets handle 5 (0–4 are
the standard reserved handles), `CODE.COM` gets 6, and once `CODE.COM` is
closed that slot is freed — so when `DATA.COM` is created next, it is
assigned that same handle, 6, deterministically. The BX value the trace
carries forward as "CODE.COM's stale handle" is numerically identical to
DATA.COM's own handle, because DOS reused the slot. This is a deliberate
reliance on standard, documented DOS handle-allocation behavior, not a
fragile coincidence — the same kind of low-level trick as the header bytes
above: relying on a guaranteed platform invariant instead of spending a
register on an explicit save.

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

`STUB.COM` (`.8086`-compatible, banner `SDT-STUB V1.0.0, 15/04/2026`) performs the
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

This particular offset is not arbitrary: 128 KiB is the exact, guaranteed
maximum combined footprint of `CODE.COM` + `DATA.COM` under the
SuperDoubleTiny model (64 KiB each, by definition — §4.1). Relocating STUB
there means it can never collide with either segment, *regardless of their
actual compressed or decompressed sizes* — the relocation offset is chosen
against the model's worst case, not computed from this particular build's
actual code size. This is also why STUB's own memory check (§5, step b)
requires 192 KiB, not 128: 128 KiB covers the maximum CODE+DATA footprint,
and the remaining 64 KiB is headroom needed to decompress DATA.COM into its
own segment.

**Important:** this relocation segment is purely a private, temporary
staging area STUB uses for its own internal bootstrap shuffling. It has no
fixed relationship to where DATA.COM's compressed body ultimately ends up —
see §5 for how the *real* destination is communicated to STUB implicitly,
through the ES register, without STUB ever needing to compute or know it.

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
     (segment 40h, word at offset 13h) in KB, shifts it left 6 bits to
     convert directly to paragraphs (1 KB = 64 paragraphs). Subtracts CS
     to obtain free paragraphs above the load point. If less than 192KB
     (3000h paragraphs): prints the "SDT-STUB V1.0.0 ... Not enough
     memory" message, INT 20h. This figure is 128 KiB (the maximum
     combined CODE+DATA footprint, §4.6) plus 64 KiB of headroom needed
     to decompress DATA.COM into its own segment.

 c)  STUB sets SS = ES = CS + 2000h (128 KiB above CS) — a fixed, worst-case
     safe distance from both segments regardless of their actual size; see
     §4.6.

 d)  STUB copies itself (start_code..end_code) to ES:0100h (same relative
     offset as loaded), word-granular (movsw), with a leading movsb if
     the byte count is odd. This frees the original CS:0100h area for
     decompression targets.

 e)  Far jump to ES:reloc_jmp_1 — execution continues from the relocated
     STUB copy. CS is now the segment that was ES (call it SEG_RELOC).

 f)  STUB moves DATA.COM's compressed body from its load position
     (immediately after CODE.COM's compressed body, in the *original*
     load segment, at end_code + code_comp_len) to SEG_RELOC:end_code —
     a temporary parking spot inside STUB's own staging segment.

 g)  STUB moves CODE.COM's compressed body from the original segment's
     end_code offset down to that same original segment's offset 0100h,
     overwriting the (already relocated) original STUB code. Immediately
     before this move, STUB explicitly sets ES = DS (both = the original
     load segment), so the move's implicit ES:DI destination lands where
     intended.

 h)  STUB builds a synthetic return frame on the stack and far-returns
     into the original segment at offset 0100h — where CODE.COM's
     compressed body now sits. This runs APACK's decompressor for CODE,
     which decompresses X-VESA's own code in place and ends with a near
     RET, using the address STUB set up on the stack.

 i)  The freshly decompressed X-VESA code's own entry point (start_code,
     CODE.ASM) immediately computes `ES = CS + ceil(codesize/16)` — this
     is X-VESA's own actual, final DATA segment, positioned so that
     `ES:0100h` lands exactly at the paragraph-rounded end of CODE (the
     same natural position DATA occupies in the standard/saw builds too,
     where it simply follows CODE contiguously). **This value is set once
     here and is never touched again until DATA is fully in place** — it
     survives the entire round-trip back into STUB below, because nothing
     STUB does from this point on modifies ES.

     Because SP is not 0FFFEh (the value DOS sets for a normally loaded
     COM), start_code also detects a mismatch and runs a short trampoline
     (see §6): it pops the mismatched near-RET address APACK left behind
     and reconstructs a correct far return that lands back inside the
     relocated STUB, at SEG_RELOC:reloc_jmp_2.

 j)  At reloc_jmp_2, STUB moves DATA.COM's compressed body from its
     staging spot (SEG_RELOC:end_code, since step f) using `rep movsw`.
     STUB sets DS to SEG_RELOC (the *source*) but never touches ES — and
     the x86 string instructions always target **ES:DI**, not DS:DI, for
     the destination. So this move lands DATA's compressed body at
     `ES:0100h` — the real, code-size-dependent segment X-VESA computed
     and left in ES back in step (i), not at SEG_RELOC. STUB neither
     knows nor needs to know that segment's value; it is simply relayed
     through the register. STUB's own work ends with one last retf,
     which — via the frame X-VESA's trampoline set up in step (i) —
     lands execution at X-VESA's own no_sdt_stub continuation (CODE.ASM),
     back in the original CODE segment.

 k)  no_sdt_stub (CODE.ASM) sets DS = ES (still the same value computed
     in step i, untouched throughout) and SS = DS + START_STACK. It then
     pushes a synthetic far-return frame (CS:start_x_vesa, then
     DS:(start_data+100h)) and executes retf, landing at DS:0100h —
     exactly where DATA.COM's compressed body was delivered in step (j).

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
    mov  ax, es          ; ES was set once, back at the very top of start_code
    mov  ds, ax          ; (§5 step i), and carried unchanged through STUB's
    add  ax, START_STACK ; entire relocation dance — DS = the real data segment
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
in a single instruction. See §5 steps (i)–(m) for the full round-trip: this
ES value is what STUB's own `reloc_jmp_2` (§5 step j) delivers DATA's
compressed body into, via the default ES:DI destination of `movsw` — STUB
never needs to know this segment's value, only to leave ES alone.

`start_x_vesa` then adds a further 256 bytes (`10h` paragraphs) to DS/ES,
sets CLD, and begins normal initialization: DOS version check, 80386
detection, MUL bug test, the precise `X_VESA_MEM` memory check (distinct
from STUB's coarse 192KiB check — see §4.1), environment scan for the
executable path, file open and checksum verification, VGA detection, VESA
enumeration, and main loop.

---

## 7. Auxiliary Utilities

### 7.1 CRYPT.COM

`CRYPT.COM` (banner `Crypt V1.2 by M.Pistella, 18/04/2026`) is a command-line tool
(`CRYPT.COM <file>`) that takes exactly one argument, parsed via a small
custom PSP argument parser (`Get_Args`); with zero or more than one argument
it prints a usage message and exits.

Contrary to a "stub prepended, body follows" description, the mechanism is
(steps below are in actual execution order):

1. The target file is read whole into a work buffer (segment `CS+1000h`).
   Files under 5 bytes, or larger than `0FF00h` minus the stub's own size,
   are rejected as "Unsupported .COM file".
2. The file's original first 3 bytes are saved into two patch slots
   (`_PATCH_0`, a word, and `_PATCH_3`, a byte) inside CRYPT's own
   decryption-stub code.
3. The buffer is encrypted in memory, in place: `byte[i] ^= byte[i+1]` (XOR
   with the following byte), computed forward for `i = 3 .. filesize-2`.
   Offset 3 onward, as originally documented, but computed against the byte
   that follows it, not a fixed key; the final byte of the file is left
   untouched (it has no successor). This happens *before* the stub is
   written anywhere.
4. Two more patch slots (`_PATCH_1`, the decrypt-loop's starting offset, and
   `_PATCH_2`, the final jump back to `CS:0100h`) are computed and filled
   in, based on the file's size and the stub's own assembled size.
5. **Only now is the decryption stub (`crypt_on`..`crypt_off`) written to
   the file, at the current file position — which is end-of-file after the
   read. It is appended, not prepended.**
6. The buffer's first 3 bytes are overwritten with a near JMP (`0E9h` +
   16-bit relative offset) that targets exactly `100h + filesize` — i.e.
   the start of the stub just appended in step 5. The whole (now-encrypted,
   JMP-patched) buffer is then written back to the file at offset 0,
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
separately addressable as a full 64KB segment. **This is why the standard
and saw builds don't run into the open question flagged in §10:** the same
generic `ES = CS + ceil(codesize/16)` computation in `start_code` (§6) works
correctly here, because `exe2com` places DATA immediately and contiguously
after CODE — there is no STUB-imposed fixed relocation offset to reconcile
with, unlike the release build. This mode is the *default*
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
  SYNC64.EXE B:                      (prepares the shared drive; exact function undocumented)
  copy X-VESA.OBJ B:\  /  copy MAKE_PRG.BAT B:\
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
