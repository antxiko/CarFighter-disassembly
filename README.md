# Car Fighter - commented disassembly

*(También [en castellano](README.es.md).)*

The commented disassembly of **Car Fighter** (Casio, 1985) for the MSX: a 16 KB cartridge at 0x8000.

- **100%** of the binary explained: 7,865 bytes of code and 8,519 of named data, not one byte unassigned.
- **40.7%** of the listing commented, 522 routines and labels, none below 10% of comments.
- The listing reassembles into the original ROM **byte for byte**.
- The title comes from running the ROM, checked against openMSX; the eight zones, the map, the crashes, the truck, CHECK POINT and GOAL, played in GIF; the four tunes, from its own sound engine and identical to openMSX frame by frame.

The site: <https://antxiko.github.io/CarFighter-disassembly/>
(in Spanish: <https://antxiko.github.io/CarFighter-disassembly/es/>).

## Rebuilding it

The ROM image is not distributed. Put yours in the root as `carfighter.rom` (sha256 `3a63d167...`) and run `make`. The details, in [UNDER THE HOOD](docs/UNDER-THE-HOOD.md).

## Legal

The game belongs to Casio and its rights holders. The `LICENSE` covers only the tools, comments, analysis and documentation here. See [LEGAL-NOTICE.md](LEGAL-NOTICE.md).
