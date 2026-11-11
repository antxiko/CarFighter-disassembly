# Curiosities

## The zeros that stay

The fuel is shown with three digits, and the leading zeros stay: 096, 057, 001. The routine
that paints it has a loop for them (`gasolina_pinta`, 0x88BC): it goes over the digits from the
left and, while they are 0, writes the value of C on them. But C is 0 (`ld bc,0400h`, 0x88CA), and
tile 0 is the 0 itself: nothing changes. With the space, tile 0x10, the zeros would have gone.

## A tune nobody asks for

The table of tunes (0xBA80) has six entries, 0 to 5. Number 0 means no tune, and the game asks
for 1, 3, 4 and 5. **Number 2 is never asked for**: its three channels are the same piece
(0xBEF7), the first channel of the CHECK POINT tune, three times over.

## The letters at a fixed address

The game takes its letters from the BIOS font at a fixed address, 0x1D3F, where the MSX BIOS
keeps the character 0x30 (`letras`, 0x8F98). The address of the font is also written at 0x0004 of
the BIOS, for programs to read; the game does not use it.

## It counts on the BIOS registers

To write the texts row by row, the game counts on how LDIRVM leaves the registers: on its way
back the BIOS leaves the VRAM address in HL and the RAM address already advanced in DE. The
routine that copies 14 tiles adds 32 to HL and swaps them (`texto14`, 0x8266): the next row of
the screen and the next row of the text, without saving anything.

## Two road lengths in zone 3

The length of each zone is one byte in 0x8020 (in units of 256 rows), but zone 3 has one more
condition in the main loop: also the low byte of the distance has to reach 0xE8 (0x8248). Zone 3
is 232 rows longer than its table says.

## Code and bytes nobody uses

Three pieces of code that are never reached: no `call`, jump or table leads to them, and they do
not run in the openMSX measurements.

- 0x831C: it clears the crash and goes back to the race loop; the `jr` just before it jumps over
  it.
- 0x8FA7: it copies sixteen more BIOS characters (0x20 to 0x2F, from 0x1CBF) to the VRAM, like
  `letras` does with the others.
- 0x9011: `ld b,32` just before the routine that copies the sprites: the 32 at once.

And some bytes: six digits at 0x9367, 1 0 0 0 0 0, that nobody reads (the record starts at 10000,
set by INIT), eight at 0x864D after the places of the map, and one at 0x8350 between a `jr` and
the next routine.
