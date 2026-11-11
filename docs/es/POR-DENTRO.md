# Por dentro

## Rehacer la ROM

`make verify` ensambla `src/carfighter.asm` con pasmo y sale la ROM de 16 KB **byte a byte**.
`make sanity` comprueba lo que el reensamblado no cubre: que ningún byte declarado como dato se
lea como código, que ningún punto de entrada caiga en datos y que los 16.384 bytes estén
explicados. `make test` pasa las pruebas. La ROM no está en el repositorio: hay que ponerla en la
raíz como `carfighter.rom` (el volcado de GoodMSX, `[!]`, sha1 `e93c3966...`).

| | bytes |
|---|---|
| código trazado | 7.865 |
| datos con nombre | 8.519 |
| sin explicar | 0 |

El listado tiene 1.496 comentarios en 3.672 instrucciones (40,7 %), 522 rutinas y etiquetas,
ninguna por debajo del 10 % comentado, y ninguna rutina llamada sin nombre.

## El cartucho

16 KB en la **página 2** (0x8000-0xBFFF), con INIT en 0x8028. La mitad son datos: los trozos de
carretera de las ocho zonas y sus casillas (0x9DDB-0xA800), las casillas y los colores de la
pantalla, los sprites, el mapa de Estados Unidos en tramos, las letras grandes del título, los
nombres de las ciudades y la música.

## La BIOS que usa

SETGRP, CHGCLR, DISSCR, ENASCR y WRTVDP para poner la pantalla; FILVRM, LDIRVM, WRTVRM y SETWRT
para llenarla; GTSTCK, GTTRIG y SNSMAT para los mandos, y WRTPSG para el sonido. Lee la fuente de
la BIOS en su dirección fija (0x1D3F) y cuenta con los registros que deja LDIRVM (ver
[Curiosidades](CURIOSIDADES.html)).

## La interrupción y el bucle

INIT pone un salto a 0x9021 en el gancho H.TIMI (0xFD9F). La interrupción calla el sonido si se
ha pedido, toca el motor del coche en el canal A, hace correr el motor de sonido, avanza dieciséis
cuentas de cuadros (0xE010-0xE01F) y lee los mandos (`interrupcion`, 0x9021). El bucle de la
carrera espera a cada cuadro que cuenta la interrupción (0xE011) y da un paso: los coches que
salen, los otros coches, los puntos, la gasolina, el coche del jugador, los sprites, la
carretera, la distancia y los bordes (`carrera`, 0x8205).

## La carretera

La carretera es un anillo de 24 filas de 24 casillas en la RAM (0xE8C0-0xEAFF). Cada tantos
cuadros, según la velocidad, entra una fila nueva por arriba (`avance`, 0x8C45): la fila propia
de la zona, o la orilla en la zona 2, con los trozos de las tres listas de la zona encima
(0xE188, 0xE1A8, 0xE1B0), y el anillo va a la pantalla por el puerto del VDP.

## Cómo se ha hecho

El trazado sigue el código desde INIT y la interrupción, más tres trozos de código a los que no
se llega, declarados en `src/carfighter.entries`. Lo demás se ha **medido en openMSX**
(`tools/omsx_cobertura.tcl`: una condición en cada instrucción apunta cada dirección nueva de la
ROM), jugando y esperando la demostración en un Philips VG 8020.

## La RAM

| | |
|---|---|
| 0xE000 | la partida en marcha (0 en la demostración) |
| 0xE009 / 0xE00A | la vuelta y la zona (1-8) |
| 0xE00C-0xE00E | los puntos (BCD) |
| 0xE010-0xE01F | dieciséis cuentas de cuadros |
| 0xE043 | el botón de empezar |
| 0xE080-0xE083 | la gasolina, cifra a cifra |
| 0xE088 | la copia del registro 7 del PSG |
| 0xE094 | el récord |
| 0xE180 | la palanca (1-8) |
| 0xE183 | el choque: 1 o 2 los bordes, 3 sin gasolina, 4 otro coche |
| 0xE184 | el final de la zona |
| 0xE190-0xE194 | la velocidad: tres cifras y en binario |
| 0xE19C / 0xE19D | la distancia |
| 0xE280-0xE2D5 | el motor de sonido |
| 0xE300 | el coche del jugador (32 bytes; el disparo en 0xE320, la bomba en 0xE330) |
| 0xE360 | los otros diez (32 bytes cada uno) |
| 0xE600 | las filas de la zona |
| 0xE8C0-0xEAFF | la carretera |
