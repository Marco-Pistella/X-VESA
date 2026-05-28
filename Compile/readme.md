# X-VESA — Build Documentation

**X-VESA V2.0.0** — by Marco Pistella  
Assembler: ASMC (Windows) + TLINK (DOS)  
Memory model: SuperDoubleTiny (SDT)

---

## Table of Contents

1. [Source Structure](#1-source-structure)
2. [Tools Required](#2-tools-required)
3. [Build Modes](#3-build-modes)
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
├── LIBS\               ~120 include files (one routine per file)
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
EXE from the single assembled OBJ.

---

## 2. Tools Required

| Tool | Environment | Role |
|---|---|---|
| ASMC | Windows | Assembles X-VESA.ASM → X-VESA.OBJ |
| TLINK | DOS | Links X-VESA.OBJ → X-VESA.EXE |
| SAW.COM | DOS | Splits X-VESA.EXE → CODE.COM + DATA.COM |
| APACK | DOS | Compresses CODE.COM and DATA.COM separately |
| PREPSTUB.COM | DOS | Patches STUB.COM with compressed sizes |
| CRYPT.COM | DOS | XOR-encrypts X-VESA.COM (release only) |
| CHECKSUM (SAVID) | DOS | Embeds CRC at end of X-VESA.COM |
| exe2com | DOS | Standard EXE→COM converter (standard build only) |

ASMC runs on Windows and produces X-VESA.OBJ. The OBJ is copied to the DOS
environment (DOSBox-X or real hardware) via floppy image (drive B:/A:) where
the remainder of the build runs.

---

## 3. Build Modes

`MAKE_PRG.BAT` supports three modes selected by argument:

```
MAKE_PRG.BAT           standard build  (EXE → exe2com → single-segment COM)
MAKE_PRG.BAT saw       SAW build       (EXE → SAW → APACK data only → COM, no stub)
MAKE_PRG.BAT release   SDT release     (EXE → SAW → APACK both → STUB → CRYPT → CHECKSUM)
```

Only the **release** build produces the final distributable `X-VESA.COM` with
the full SDT memory model.

---

## 4. SuperDoubleTiny Memory Model

### 4.1 Problem: why COM, why two 64KB segments

A standard DOS COM file is loaded in a single segment: CS = DS = ES = SS.
The entire 64KB is shared between code, data, and stack, which is sufficient
for small programs but not for X-VESA, which requires:

- ~32KB of code
- 64KB of data (mode tables, EDID buffers, VBE structures, strings)
- 64KB text/graphics buffer (10 video pages of 80×40)
- 64KB stack + font buffer
- 64KB I/O buffer (SEGMENT_4)
- 32KB video window at B800h (FS)

Total: ~302,048 bytes of conventional memory.

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
 CS               32KB       Code (X-VESA.ASM routines)
 DS               64KB       Data (DATA.ASM: tables, buffers, strings)
 [unnamed]        64KB       Text/graphics buffer (10 pages 80×40)
 SS               64KB       Stack + VGA font buffer (max 8192 bytes)
 SEGMENT_4        64KB       I/O buffer (file read/write staging)
 FS               32KB       Video VRAM window at B800h
```

Segment registers are set explicitly by the bootstrap and by `start_x_vesa`;
no DOS relocation is involved after the initial load.

### 4.3 Source structure: CODE and DATA segments

`X-VESA.ASM` opens with:

```asm
CODE SEGMENT PARA PUBLIC USE16 'CODE'
ASSUME CS:CODE, DS:CODE, ES:CODE, SS:CODE
ORG 100h
```

All ~22,000 lines of code are assembled into the CODE segment. At the very end:

```asm
end_code:
CODE ENDS

    include INCLUDE\DATA.ASM

END start_code
```

`DATA.ASM` opens with:

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
COM and must not have the PSP prefix. `start_data` begins at offset 0. The
opening `retf` is the landing point used by the bootstrap (see §5, step n).

`NUM_TO_CHAR_PREP` is a compile-time TASM macro that converts a numeric
constant to a string of decimal digit characters via `CATSTR` prepend, producing
natural (non-reversed) digit order without runtime code.

TLINK with two segments produces `X-VESA.EXE` with:
- Segment 1 (CODE): from `start_code` to `end_code`
- Segment 2 (DATA): from `start_data` onward

### 4.4 SAW.COM — splitting the EXE

`SAW.COM` reads `X-VESA.EXE` and splits it into two COM files:

```
X-VESA.EXE  →  CODE.COM   (CODE segment only, raw binary)
                DATA.COM   (DATA segment only, raw binary, ORG 0h)
```

SAW seeks to offset 768 (0x300) into the EXE, reads the segment header to
determine the boundary between the two segments, then writes each portion
to its output file independently. The split is exact: CODE.COM contains
only the assembled code bytes; DATA.COM contains only the data bytes starting
at `start_data` offset 0.

### 4.5 APACK compression

Both files are compressed independently with APACK using the `-x` flag
(maximum compression, decompressor included):

```bat
apack -x DATA.COM DATA.COM
apack -x CODE.COM CODE.COM
```

Each compressed file is self-decompressing: when executed, it decompresses
itself in-place. APACK's decompressor becomes the new entry point (at offset
100h in each COM). The original content is reconstructed at the same load
address.

After compression:
- `CODE.COM`: APACK header + decompressor + compressed code bytes
- `DATA.COM`: APACK header + decompressor + compressed data bytes

The compressed sizes of both files are needed by PREPSTUB.

### 4.6 STUB.COM — the bootstrap

`STUB.COM` is an `.8086`-compatible COM that performs the two-stage
decompression and segment relocation. Its source (`STUB.ASM`) assembles
to a small binary that contains two patching slots near its end:

```asm
code_comp_len:  DW 0h
data_comp_len:  DW 0h
end_code:
```

These two words are left at zero in the source; PREPSTUB fills them at
build time with the actual compressed sizes of CODE.COM and DATA.COM.

STUB is intentionally written in `.8086` instructions to maximize
compatibility. It performs no VESA or 386-specific operations.

### 4.7 PREPSTUB.COM — patching the stub

`PREPSTUB.COM` performs three steps:

1. Opens `CODE.COM`, seeks to end, records file size → `code_comp_len`
2. Opens `DATA.COM`, seeks to end, records file size → `data_comp_len`
3. Opens `STUB.COM` for write, seeks to offset `0FFFFh - 4` (four bytes
   before the 64KB boundary, where `code_comp_len` and `data_comp_len`
   reside), writes the two WORDs

After PREPSTUB, `STUB.COM` carries the exact compressed sizes embedded
at the correct offsets, ready for the bootstrap to use at runtime.

### 4.8 Final assembly

The three files are concatenated in order:

```bat
copy STUB.COM + CODE.COM + DATA.COM X-VESA.COM /B
```

The resulting `X-VESA.COM` layout in memory after DOS loads it:

```
 CS:0100h  STUB code (bootstrap)
            ...
 CS:FFFFh  code_comp_len, data_comp_len   ← patched by PREPSTUB
 [immediately after STUB, in the same segment]:
            CODE.COM body (APACK header + compressed code)
 [after CODE.COM]:
            DATA.COM body (APACK header + compressed data)
```

DOS loads the entire file as one flat COM segment. The total file size
remains well within the COM limit because both segments are compressed;
the uncompressed footprint is reconstructed entirely in conventional
memory by the bootstrap.

---

## 5. SDT Bootstrap Sequence (step by step)

The following describes what STUB.COM does at runtime after DOS loads
`X-VESA.COM` at `CS:0100h`.

```
 a)  DOS loads X-VESA.COM at CS:0100h, jumps to CS:0100h.
     STUB entry point executes.

 b)  STUB reads available conventional memory from BIOS data area
     (segment 40h, word at offset 13h), converts from KB to bytes.
     Subtracts CS × 16 to obtain free bytes above the load point.
     If less than 192KB (3000h paragraphs): prints error, INT 20h.

 c)  STUB sets:
       SS = CS + 20h      (new stack, 32 paragraphs above CS)
       ES = SS            (ES used as work segment)

 d)  STUB copies itself to ES:0100h (same relative offset as loaded),
     so subsequent code runs from the relocated copy. This frees the
     original CS:0100h area for decompression targets.
     The copy is word-granular (movsw), with a leading movsb if
     the byte count is odd.

 e)  Far jump to ES:reloc_jmp_1 — execution continues from the
     relocated STUB copy. CS is now the segment that was ES.

 f)  STUB moves DATA.COM body from its load position
     (immediately after CODE.COM, at STUB_CS:end_code + code_comp_len)
     to STUB_CS:end_code (immediately after the STUB code area).
     This packs CODE.COM and DATA.COM contiguously starting at end_code.

 g)  STUB moves CODE.COM body from STUB_CS:end_code (original position)
     to STUB_CS:0100h (over the STUB code itself, which has already
     been relocated in step d).
     After this move, STUB_CS:0100h contains the APACK-compressed
     CODE.COM, ready to self-decompress.

 h)  Far call to STUB_CS:0100h — APACK decompressor for CODE runs.
     CODE.COM decompresses in place: the decompressed code overwrites
     STUB_CS starting at 0100h.
     On return, STUB_CS:0100h is the decompressed code (start_code).

     The far call pushes CS:next_instruction on the stack. APACK's
     decompressor ends with a near ret, which returns to the pushed
     offset inside the relocated STUB. STUB saves the return address
     (the two stack words: offset and segment) and uses them later.

 i)  STUB moves DATA.COM body (at end_code, step f position)
     to STUB_CS:start_code offset (0100h area within the DATA segment
     — which at this point is at STUB_CS + code_size_paragraphs).

     Actually: STUB does a far ret to DS:start_data (offset 0)
     to trigger APACK's DATA decompressor. DS is set to the segment
     where DATA.COM was placed.

 j)  Far call to DS:0100h — APACK decompressor for DATA runs.
     DATA.COM decompresses in place within its segment.
     After decompression, DS:0000h contains start_data with the
     retf instruction at offset 0.

 k)  STUB far-rets to DS:0000h (start_data: retf) — this retf
     pops the return address that was pushed when STUB called the
     DATA decompressor, landing back in the STUB flow.

 l)  Bootstrap is complete. STUB pushes CS (code segment) and
     OFFSET start_x_vesa, then pushes DS (data segment) and
     OFFSET start_data + 100h, and executes a retf.

 m)  Execution transfers to CODE:start_x_vesa.
     At this point:
       CS → code segment (decompressed X-VESA code)
       DS → data segment (decompressed X-VESA data, via the retf chain)
```

---

## 6. CODE.ASM entry point and SDT detection

`start_code` at `CS:0100h` contains a dual-path entry:

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

When STUB launches CODE via the far call chain (step h), SP is not `0FFFEh`
(STUB has used the stack). The SDT path executes: it pops the APACK return
address (bx:cx), then reconstructs a new far return frame that will land at
`no_sdt_stub` after exchanging the return addresses. This is the trampoline
that allows APACK's decompressor (which ends with a near `ret`) to return
to the correct continuation point inside STUB.

After `no_sdt_stub`:

```asm
    mov  ax, es          ; ES = segment just above CODE
    mov  ds, ax          ; DS = data segment (passed by STUB)
    add  ax, START_STACK
    mov  ss, ax          ; SS = stack segment
    push cs
    push OFFSET start_x_vesa
    push ds
    push OFFSET start_data + 100h
    retf                 ; jump to start_x_vesa in CODE segment
```

The double push/retf pattern (push target CS:IP, then push DATA:start_data,
then retf) achieves a far jump while simultaneously passing the data segment
pointer through the stack — a clean way to initialize DS and transfer control
in a single instruction.

`start_x_vesa` then sets up DS, ES, CLD, and begins normal initialization:
DOS version check, 80386 detection, MUL bug test, memory check, environment
scan for the executable path, file open and checksum verification, VGA
detection, VESA enumeration, and main loop.

---

## 7. Auxiliary Utilities

### 7.1 CRYPT.COM

`CRYPT.COM` XOR-encrypts the body of `X-VESA.COM` in place. The encryption
is applied from offset 3 onward (skipping the COM entry jump), with each
byte XORed against its successor. A self-decrypting stub is prepended: the
stub reconstructs the original bytes before transferring control to
`start_code`. Three patch points (`_PATCH_0`, `_PATCH_1`, `_PATCH_2`,
`_PATCH_3`) are filled at encryption time with the original first bytes and
the loop bounds.

In the release build, CRYPT runs after the SDT assembly:

```bat
.\utility\crypt\crypt X-VESA.COM
```

Version 2 of CRYPT fixed a 25-year-old 8086 compatibility bug: the original
stub used `dword ptr` operands which generated a `66h` prefix (386
instruction), incompatible with 8086. The fix uses two separate
`mov word ptr` instructions.

### 7.2 CHECKSUM / SAVID

After CRYPT, `CHECKSUM` (compiled from `SAVID.ASM`) appends a 4-byte CRC
to `X-VESA.COM`. The CRC algorithm (`Get_Checksum`) is a custom multiplicative
hash using the first two DWORDs of the file as seeds:

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
separately addressable as a full 64KB segment. This mode is used during
development to avoid the full SDT pipeline on every iteration.

In the `saw` build, DATA is compressed but CODE is not, and no stub is used.
The resulting COM still uses a simplified two-segment layout but without the
APACK decompressor on CODE. This intermediate mode is useful for testing
SAW and APACK behavior without committing to the full release pipeline.

The release build is required for distribution: only it produces the correct
memory layout with separate 64KB segments, full compression, encryption,
and checksum.

---

## 9. Full build sequence summary

```
[Windows]
  ASMC X-VESA.ASM
  → X-VESA.OBJ

[copy OBJ to DOS via floppy image]

[DOS — MAKE_PRG.BAT release]

  TLINK X-VESA.OBJ
  → X-VESA.EXE        (two-segment: CODE + DATA)

  SAW.COM
  → CODE.COM           (CODE segment, raw)
  → DATA.COM           (DATA segment, raw, ORG 0h)

  apack -x DATA.COM DATA.COM
  → DATA.COM           (self-decompressing)

  apack -x CODE.COM CODE.COM
  → CODE.COM           (self-decompressing)

  copy .\utility\stub\STUB.COM
  PREPSTUB.COM
  → STUB.COM           (patched: code_comp_len, data_comp_len embedded)

  copy STUB.COM + CODE.COM + DATA.COM X-VESA.COM /B
  → X-VESA.COM         (SDT binary: stub + compressed code + compressed data)

  crypt X-VESA.COM
  → X-VESA.COM         (XOR-encrypted body, self-decrypting stub prepended)

  checksum
  → X-VESA.COM         (4-byte CRC appended)

  [cleanup: del OBJ BAK MAP EXE CODE.COM DATA.COM STUB.COM asm.err]
  [copy X-VESA.COM to floppy A:]
```

Final `X-VESA.COM`: ~32 KiB compressed, expands to 302,048 bytes at runtime.
