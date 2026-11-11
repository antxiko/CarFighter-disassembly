# The texts

Every text in the ROM is in English. The letters are those of the BIOS: at the start the game
copies the characters 0x30 to 0x5F of the BIOS font, from its fixed address 0x1D3F, to tiles 0 to
0x2F of the three thirds of the screen (`letras`, 0x8F98). So tile 0 is the 0, 0x0A the colon,
0x0D the equals sign, 0x11 the A and 0x2A the Z; tile 0x10 is the space, painted with colour 0.
The texts are stored as those tile numbers.

| Where | Text | Meaning |
|---|---|---|
| the title (0x9284, 0x92BC) | CAR, FIGHTER | in big letters of their own, four and five rows high |
| the title (0x927E) | CASIO | in red |
| the title (0x933A) | PUSH TRIG:1 OR SPC | press button 1 or the space bar |
| the title (0x934C) | COPYRIGHT 1985 © CASIO | the © is tile 0x69 |
| the scoreboard (0x936D) | HISCORE, SCORE | the record and the score: SCORE is the end of HISCORE |
| the scoreboard (0x936D) | BOMB, FUEL, SPEED | the bombs, the fuel and the speed |
| the start (0x9432) | START | on zone 1 |
| no fuel (0x9362) | EMPTY | the tank is empty |
| no fuel (0x9429) | GAME OVER | the game is over |
| the end of a zone (0x84BF) | CHECK POINT | zones 1 to 7 |
| the end of zone 8 (0x84CA) | GOAL | the finish |

## The names on the map

Before each zone, the map writes two names letter by letter (0xB780): where the zone starts, in
eleven tiles filled with equals signs, and where it ends.

| Text | Meaning |
|---|---|
| CISCO | San Francisco |
| LOSANGELS | Los Angeles |
| SANDIEGO | San Diego |
| LASVEGAS | Las Vegas |
| TEXAS | Texas |
| DARAS | Dallas |
| MIAMI | Miami |
| CHICAGO | Chicago |
| WASINGTON | Washington |

The names have no spaces, CISCO is only the end of San Francisco, and three are spelt their own
way: DARAS with an R, LOSANGELS without the second E, WASINGTON without the H.

## CASIO

On the title, before the rest, CASIO in big letters comes into the screen from the four sides,
left, right, top and bottom, one step every three frames, and the four meet in the middle
(`presentacion`, 0x9CBD); then the title tune. Its letters are sixteen tiles of its own, two rows
of eight (0x9D24).

![CASIO from the four sides](imagenes/casio.gif)
