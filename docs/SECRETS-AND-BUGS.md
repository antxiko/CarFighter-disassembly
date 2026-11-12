# Secrets and bugs

What was searched for in the code and what was found. A bug only goes here if it has been checked: by running the
game's own routine (`tools/bios.py`) or against the openMSX recordings.

## Secrets: none hidden

- **No hidden keys.** The controls are read in a single place (0x90C2-0x917B): the stick of joystick 1 and the cursor
  keys (GTSTCK 1 and 0), buttons A and B of joystick 1 (GTTRIG 1 and 3), and on the keyboard the space bar and GRAPH,
  read with SNSMAT on rows 8 and 6. Joystick 2 is not read. There is no other keyboard read: no key at power-on or on
  the title screen.
- **No hidden zones or laps**: the eight zones and the laps are the ones in [The zones](THE-ZONES.html). The demo picks a
  zone from 1 to 4 at random and does not score (it checks whether a game is on, 0xE000, before adding).

## Bug: the cursor keys and the joystick at once

`palanca` (0x90E1) reads the cursor keys and joystick 1 and joins them with an `or` (0x90F1). But GTSTCK does not give
bits, it gives a direction number from 1 to 8, and the `or` of two numbers is another number. Using both at once, the
car goes where neither of them points. Running the routine here with each port in one direction:

| cursor keys | joystick | the car goes |
|---|---|---|
| right | — | right |
| right | down | **left** |
| up-right | down-right | **down-left** |
| left | right | left |

Anything above 8 (for example up-left with down, 13) the car takes as up-left: it is the last thing
`coche_direccion` (0x8A90) checks.

## Checked and correct

- **The score.** Six BCD digits (0xE00C), and past 999,999 it stays there (`puntos`, 0x918D). Running it here:
  999,950 + 50 gives 999,999 on screen and in the high score, and 9,999 + 1 gives 10,000.

## Other things that go wrong, told in [Curiosities](CURIOSITIES.html)

- **The fuel zeros**: the loop that should clear the leading zeros writes another 0 (096, 057, 001).
- **A tune nobody asks for**: number 2 in the table.
- **Two lengths in zone 3**: 232 rows more than its table says.
- **Three pieces of code** that are never reached.
