# Los textos

Todos los textos de la ROM están en inglés. Las letras son las de la BIOS: al arrancar, el juego
copia los caracteres 0x30 a 0x5F de la fuente de la BIOS, desde su dirección fija 0x1D3F, a las
casillas 0 a 0x2F de los tres tercios de la pantalla (`letras`, 0x8F98). Así, la casilla 0 es el
0, la 0x0A los dos puntos, la 0x0D el signo igual, la 0x11 la A y la 0x2A la Z; la casilla 0x10
es el espacio, pintada con el color 0. Los textos van guardados con esos números de casilla.

| Dónde | Texto | Qué dice |
|---|---|---|
| el título (0x9284, 0x92BC) | CAR, FIGHTER | en letras grandes propias, de cuatro y cinco filas |
| el título (0x927E) | CASIO | en rojo |
| el título (0x933A) | PUSH TRIG:1 OR SPC | pulsa el botón 1 o la barra |
| el título (0x934C) | COPYRIGHT 1985 © CASIO | el © es la casilla 0x69 |
| el marcador (0x936D) | HISCORE, SCORE | el récord y los puntos: SCORE es el final de HISCORE |
| el marcador (0x936D) | BOMB, FUEL, SPEED | las bombas, la gasolina y la velocidad |
| la salida (0x9432) | START | en la zona 1 |
| sin gasolina (0x9362) | EMPTY | el depósito está vacío |
| sin gasolina (0x9429) | GAME OVER | se acabó la partida |
| el final de una zona (0x84BF) | CHECK POINT | las zonas 1 a 7 |
| el final de la zona 8 (0x84CA) | GOAL | la meta |

## Los nombres del mapa

Antes de cada zona, el mapa escribe dos nombres letra a letra (0xB780): dónde empieza la zona,
en once casillas rellenas con signos igual, y dónde acaba.

| Texto | Qué dice |
|---|---|
| CISCO | San Francisco |
| LOSANGELS | Los Ángeles |
| SANDIEGO | San Diego |
| LASVEGAS | Las Vegas |
| TEXAS | Texas |
| DARAS | Dallas |
| MIAMI | Miami |
| CHICAGO | Chicago |
| WASINGTON | Washington |

Los nombres van sin espacios, CISCO es solo el final de San Francisco, y tres van escritos a su
manera: DARAS con R, LOSANGELS sin la segunda E, WASINGTON sin la H.

## CASIO

En el título, antes que lo demás, CASIO en letras grandes entra en la pantalla por los cuatro
lados, por la izquierda, la derecha, arriba y abajo, un paso cada tres cuadros, y los cuatro se
juntan en el centro (`presentacion`, 0x9CBD); después, la música del título. Sus letras son
dieciséis casillas propias, dos filas de ocho (0x9D24).

![CASIO por los cuatro lados](../imagenes/casio.gif)
