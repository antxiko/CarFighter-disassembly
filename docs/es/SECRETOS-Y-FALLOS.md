# Secretos y fallos

Lo que se ha buscado en el código y lo que se ha encontrado. Un fallo solo entra aquí si está comprobado:
ejecutando la propia rutina del juego (`tools/bios.py`) o contra las grabaciones de openMSX.

## Secretos: ninguno escondido

- **Ninguna tecla escondida.** Los mandos se leen en un solo sitio (0x90C2-0x917B): la palanca del mando 1 y los
  cursores (GTSTCK 1 y 0), los botones A y B del mando 1 (GTTRIG 1 y 3), y en el teclado la barra y GRAPH, leídas con
  SNSMAT en las filas 8 y 6. El mando 2 no se lee. No hay ninguna otra lectura del teclado: ninguna tecla al
  encender ni en el título.
- **Ni zonas ni vueltas escondidas**: las ocho zonas y las vueltas son las de [Las zonas](LAS-ZONAS.html). La
  demostración elige una zona del 1 al 4 al azar y no puntúa (mira si hay partida, 0xE000, antes de sumar).

## Fallo: los cursores y el mando a la vez

`palanca` (0x90E1) lee los cursores y el mando 1 y los junta con un `or` (0x90F1). Pero GTSTCK no da bits, da un número
de dirección del 1 al 8, y el `or` de dos números es otro número. Si se usan los dos a la vez, el coche va hacia donde
no apunta ninguno. Ejecutando aquí la rutina con cada puerto en una dirección:

| cursores | mando | el coche va |
|---|---|---|
| derecha | — | derecha |
| derecha | abajo | **izquierda** |
| arriba-derecha | abajo-derecha | **abajo-izquierda** |
| izquierda | derecha | izquierda |

Lo que pasa de 8 (por ejemplo arriba-izquierda con abajo, 13) el coche lo toma como arriba-izquierda: es lo último
que mira `coche_direccion` (0x8A90).

## Comprobado y correcto

- **Los puntos.** Seis cifras en BCD (0xE00C), y al pasar de 999.999 se quedan ahí (`puntos`, 0x918D). Ejecutándolo
  aquí: 999.950 + 50 da 999.999 en pantalla y en el récord, y 9.999 + 1 da 10.000.

## Otras cosas que fallan, contadas en [Curiosidades](CURIOSIDADES.html)

- **Los ceros de la gasolina**: el bucle que debería borrar los ceros de la izquierda escribe otro 0 (096, 057, 001).
- **Una música que nadie pide**: la 2 de la tabla.
- **Dos largos en la zona 3**: 232 filas más de lo que dice su tabla.
- **Tres trozos de código** a los que no se llega.
