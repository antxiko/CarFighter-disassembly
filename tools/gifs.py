#!/usr/bin/env python3
"""Los GIF de la web: tramos de las grabaciones de openMSX (tools/guiones/*.tcl, grabados con
tools/lanza_graba.ps1 en C-BIOS_MSX1_JP, -ram "0xE000 0x1100"), pintados con tools/vdp.py.

Los tramos salen de la RAM grabada: 0xE00A la zona, 0xE183 el choque o la gasolina acabada, 0xE184 el final
de la zona, 0xE080-0xE082 la gasolina y +4 de cada coche de 0xE360 su tipo (3 el camion).

  carrera  una partida de 16000 cuadros (carrera.tcl: un piloto en Tcl que lleva el coche al centro de la
           carretera, acelera hasta 0xB0 y dispara): choques, EMPTY y GAME OVER, y un CHECK POINT
  zona4    la zona 4, forzada al empezar (zona4.tcl): el camion, lo que suelta y las bombas
  zonas    las ocho zonas, cada una acabada a la fuerza (zonas.tcl): la meta, GOAL

Uso: gifs.py docs/imagenes
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import vdp          # noqa: E402

# (fichero, grabacion, desde, hasta, cada)
TRAMOS = [
    ("casio.gif", "carrera", 131, 300, 2),              # la presentacion: cuatro CASIO que se juntan en el centro
    ("mapa.gif", "zonas", 5597, 5716, 2),               # el mapa de la zona 8: CHICAGO, WASINGTON
    ("salida.gif", "carrera", 750, 1060, 2),            # la zona 1: el mapa, START y el coche arranca
    ("choque.gif", "carrera", 1530, 1720, 2),           # un choque a 175 km/h (1590): diez litros menos
    ("game_over.gif", "carrera", 4120, 4545, 2),        # sin gasolina: EMPTY y GAME OVER
    ("check_point.gif", "carrera", 11880, 12300, 2),    # la distancia de la zona 1: CHECK POINT (12020), la zona 2
    ("camion.gif", "zona4", 1190, 1420, 2),             # la zona 4: el camion suelta cosas y se le tiran bombas
    ("goal.gif", "zonas", 5990, 6300, 2),               # la zona 8: GOAL y otra vez la zona 1
]


def main(salida):
    raiz = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    for fichero, grab, desde, hasta, cada in TRAMOS:
        n, s = vdp.gif(os.path.join(raiz, "work", grab + ".bin"),
                       os.path.join(salida, fichero), desde, hasta, cada=cada, tope_ms=4000)
        print("%-20s %4d imagenes, %5.1f s, %8d bytes" % (
            fichero, n, s, os.path.getsize(os.path.join(salida, fichero))))


if __name__ == "__main__":
    main(sys.argv[1])
