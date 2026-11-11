# La música

Cuatro músicas, en los tres canales del PSG. No están grabadas a mano: `tools/musica.py`
**ejecuta el propio motor de sonido de la ROM** con `tools/z80run.py` -`musica_pide` (0xBADB)
con el número de la música y, en cada cuadro, `sonido` (0xBAE0)- y apunta lo que escribe en el
PSG por la BIOS (WRTPSG).

**Cotejadas con openMSX**: los registros de tono y de volumen coinciden con los grabados, **0
distintos** en las cuatro, mientras suena cada música. Se grabaron en una partida jugada en
openMSX (`tools/guiones/carrera.tcl`), en la que salen las cuatro: el título, un choque, el final
de una zona y GAME OVER. Cada cuadro grabado se empareja con el cuadro del motor que tiene la
misma RAM en los tres canales.

Los sonidos del juego no están aquí: el motor del coche, los disparos, las bombas, la
gasolinera, las letras del mapa y los demás.

## El motor

La petición va a 0xE2BE, y en el cuadro siguiente el motor empieza los tres canales de la música
de la tabla 0xBA80, tres piezas por música (`musica_empieza`, 0xBDA8). Los tres canales están en
0xE280, 0xE292 y 0xE2A4, 18 bytes cada uno, y en cada cuadro se copian por turno a un bloque de
trabajo en 0xE2C3, avanzan un paso y vuelven a su sitio. Una pieza es una lista de bytes: una
nota es un byte con la duración (de la tabla 0xBD82, de 128 cuadros a 1) y el volumen, y detrás
el periodo del tono; desde 0xF0 son órdenes: ruido, tres marcas de repetición con sus cuentas,
vuelta al principio, silencio y el final (`canal_orden`, 0xBBEC). Los efectos de sonido usan el
mismo motor en los canales B y C (0xBAA4), y solo empiezan si no suena ninguna música; de dos
peticiones, se queda la de número más bajo (`efecto_pide`, 0xBAC8).

| | Quién la pide | Duración |
|---|---|---:|
| el título | CASIO, cuando ya se ha juntado (0x9D08) | 1,1 s |
| CHECK POINT | el final de una zona, CHECK POINT o GOAL (0x8428) | 3,2 s |
| el choque | el coche choca (0x8329) | 1,1 s |
| GAME OVER | sin gasolina (0x8407) | 4,3 s |

## El título

<audio controls src="../audio/musica_titulo.mp3"></audio>

## CHECK POINT

<audio controls src="../audio/musica_check_point.mp3"></audio>

## El choque

<audio controls src="../audio/musica_choque.mp3"></audio>

## GAME OVER

<audio controls src="../audio/musica_game_over.mp3"></audio>
