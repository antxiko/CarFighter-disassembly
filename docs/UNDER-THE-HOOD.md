# Under the hood

## Rebuilding the ROM

`make verify` assembles `src/carfighter.asm` with pasmo and the 16 KB ROM comes out **byte for
byte**. `make sanity` checks what reassembling does not cover: that no byte declared as data is
read as code, that no entry point falls in data and that all 16,384 bytes are explained. `make
test` runs the tests. The ROM is not in the repository: it has to be placed in the root as
`carfighter.rom` (the GoodMSX dump, `[!]`, sha1 `e93c3966...`).

| | bytes |
|---|---|
| traced code | 7,865 |
| named data | 8,519 |
| unexplained | 0 |

The listing has 1,496 comments on 3,672 instructions (40.7%), 522 routines and labels, none
below 10% commented, and no called routine without a name.

## The cartridge

16 KB in **page 2** (0x8000-0xBFFF), with INIT at 0x8028. Half is data: the pieces of road of
the eight zones and their tiles (0x9DDB-0xA800), the tiles and colours of the screen, the
sprites, the map of the United States in runs, the big letters of the title, the names of the
cities and the music.

## The BIOS it uses

SETGRP, CHGCLR, DISSCR, ENASCR and WRTVDP to set the screen; FILVRM, LDIRVM, WRTVRM and SETWRT
to fill it; GTSTCK, GTTRIG and SNSMAT for the controls, and WRTPSG for the sound. It reads the
BIOS font at its fixed address (0x1D3F) and counts on the registers LDIRVM leaves (see
[Curiosities](CURIOSITIES.html)).

## The interrupt and the loop

INIT puts a jump to 0x9021 in the H.TIMI hook (0xFD9F). The interrupt silences the sound if it
has been asked for, plays the engine of the car on channel A, runs the sound engine, advances
sixteen frame counters (0xE010-0xE01F) and reads the controls (`interrupcion`, 0x9021). The
race loop waits for each frame the interrupt counts (0xE011) and does one step: the cars that
come out, the other cars, the score, the fuel, the player's car, the sprites, the road, the
distance and the edges (`carrera`, 0x8205).

## The road

The road is a ring of 24 rows of 24 tiles in RAM (0xE8C0-0xEAFF). Every so many frames,
depending on the speed, a new row comes in at the top (`avance`, 0x8C45): the zone's own row,
or the shore in zone 2, with the pieces of the three lists of the zone on top (0xE188, 0xE1A8,
0xE1B0), and the ring is sent to the screen through the VDP port.

## How it was done

The trace follows the code from INIT and the interrupt, plus three pieces of code nobody
reaches, declared in `src/carfighter.entries`. The rest has been **measured in openMSX**
(`tools/omsx_cobertura.tcl`: a condition on every instruction logs every new ROM address),
playing and waiting for the demonstration on a Philips VG 8020.

## The RAM

| | |
|---|---|
| 0xE000 | the game running (0 in the demonstration) |
| 0xE009 / 0xE00A | the lap and the zone (1-8) |
| 0xE00C-0xE00E | the score (BCD) |
| 0xE010-0xE01F | sixteen frame counters |
| 0xE043 | the start button |
| 0xE080-0xE083 | the fuel, digit by digit |
| 0xE088 | the copy of PSG register 7 |
| 0xE094 | the record |
| 0xE180 | the stick (1-8) |
| 0xE183 | the crash: 1 or 2 the edges, 3 no fuel, 4 another car |
| 0xE184 | the end of the zone |
| 0xE190-0xE194 | the speed: three digits and in binary |
| 0xE19C / 0xE19D | the distance |
| 0xE280-0xE2D5 | the sound engine |
| 0xE300 | the player's car (32 bytes; the shot at 0xE320, the bomb at 0xE330) |
| 0xE360 | the ten others (32 bytes each) |
| 0xE600 | the rows of the zone |
| 0xE8C0-0xEAFF | the road |
