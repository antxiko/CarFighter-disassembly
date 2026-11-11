# The music

Four tunes, on the three channels of the PSG. They are not recorded by hand: `tools/musica.py`
**runs the ROM's own sound engine** with `tools/z80run.py` -`musica_pide` (0xBADB) with the
number of the tune and, every frame, `sonido` (0xBAE0)- and logs what it writes to the PSG
through the BIOS (WRTPSG).

**Checked against openMSX**: the tone and volume registers match the recorded ones, **0
different** in all four, for as long as each tune plays. They were recorded in a game played in
openMSX (`tools/guiones/carrera.tcl`), where the four come out: the title, a crash, the end of a
zone and GAME OVER. Each recorded frame is paired with the engine frame that has the same RAM in
the three channels.

The sounds of the game are not here: the engine of the car, the shots, the bombs, the
petrol station, the letters of the map and the rest.

## The engine

A request goes into 0xE2BE, and on the next frame the engine starts the three channels of the
tune from the table 0xBA80, three pieces per tune (`musica_empieza`, 0xBDA8). The three channels
are at 0xE280, 0xE292 and 0xE2A4, 18 bytes each, and each frame they are copied in turn to a work
block at 0xE2C3, advanced one step and copied back. A piece is a list of bytes: a note is one
byte with the length (from the table 0xBD82, from 128 frames down to 1) and the volume, followed
by the tone period; from 0xF0 up they are orders: noise, three loop marks with their counts, back
to the start, silence and the end (`canal_orden`, 0xBBEC). The sound effects use the same engine
on channels B and C (0xBAA4), and only start when no tune is playing; of two requests, the one
with the lower number stays (`efecto_pide`, 0xBAC8).

| | Who asks for it | Length |
|---|---|---:|
| the title | CASIO, once it has come together (0x9D08) | 1.1 s |
| CHECK POINT | the end of a zone, CHECK POINT or GOAL (0x8428) | 3.2 s |
| the crash | the car crashes (0x8329) | 1.1 s |
| GAME OVER | no fuel left (0x8407) | 4.3 s |

## The title

<audio controls src="audio/musica_titulo.mp3"></audio>

## CHECK POINT

<audio controls src="audio/musica_check_point.mp3"></audio>

## The crash

<audio controls src="audio/musica_choque.mp3"></audio>

## GAME OVER

<audio controls src="audio/musica_game_over.mp3"></audio>
