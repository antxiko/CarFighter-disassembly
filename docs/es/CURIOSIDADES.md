# Curiosidades

## Los ceros que se quedan

La gasolina se enseña con tres cifras, y los ceros de la izquierda se quedan: 096, 057, 001. La
rutina que la pinta tiene un bucle para ellos (`gasolina_pinta`, 0x88BC): recorre las cifras
desde la izquierda y, mientras son 0, escribe encima el valor de C. Pero C es 0 (`ld bc,0400h`,
0x88CA), y la casilla 0 es el mismo 0: no cambia nada. Con el espacio, la casilla 0x10, los ceros
se habrían ido.

## Una música que nadie pide

La tabla de músicas (0xBA80) tiene seis entradas, de la 0 a la 5. La 0 es ninguna música, y el
juego pide la 1, la 3, la 4 y la 5. **La 2 no la pide nadie**: sus tres canales son la misma
pieza (0xBEF7), el primer canal de la música de CHECK POINT, tres veces.

## Las letras en una dirección fija

El juego toma sus letras de la fuente de la BIOS en una dirección fija, 0x1D3F, donde la BIOS del
MSX tiene el carácter 0x30 (`letras`, 0x8F98). La dirección de la fuente también está escrita en
0x0004 de la BIOS, para que la lean los programas; el juego no la usa.

## Cuenta con los registros de la BIOS

Para escribir los textos fila a fila, el juego cuenta con cómo deja LDIRVM los registros: a la
vuelta, la BIOS deja en HL la dirección de la VRAM y en DE la de la RAM ya avanzada. La rutina que
copia 14 casillas suma 32 a HL y los intercambia (`texto14`, 0x8266): la fila siguiente de la
pantalla y la fila siguiente del texto, sin guardar nada.

## Dos largos en la zona 3

El largo de cada zona es un byte en 0x8020 (en unidades de 256 filas), pero la zona 3 tiene una
condición más en el bucle de la carrera: también el byte bajo de la distancia tiene que llegar a
0xE8 (0x8248). La zona 3 es 232 filas más larga de lo que dice su tabla.

## Código y bytes que no usa nadie

Tres trozos de código a los que nunca se llega: ningún `call`, salto ni tabla lleva a ellos, y no
corren en las medidas de openMSX.

- 0x831C: pone el choque a cero y vuelve al bucle de la carrera; el `jr` de justo antes salta por
  encima.
- 0x8FA7: copia dieciséis caracteres más de la BIOS (del 0x20 al 0x2F, desde 0x1CBF) a la VRAM,
  como hace `letras` con los otros.
- 0x9011: `ld b,32` justo antes de la rutina que copia los sprites: los 32 de una vez.

Y algunos bytes: seis cifras en 0x9367, 1 0 0 0 0 0, que nadie lee (el récord empieza en 10000,
lo pone INIT), ocho en 0x864D detrás de los sitios del mapa, y uno en 0x8350 entre un `jr` y la
rutina siguiente.
