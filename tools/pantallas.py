#!/usr/bin/env python3
"""Las pantallas de Car Fighter.

  - el titulo: EJECUTANDO la ROM (tools/bios.py: el Z80 con la BIOS que usa) desde INIT (0x8028) hasta la
    espera del boton (0x80DF). La presentacion de CASIO (0x9CBD) espera cuadros que cuenta la interrupcion,
    y aqui no hay interrupcion: se salta (de 0x809B a 0x809E); despues el titulo pinta CASIO entero en el
    mismo sitio. Las letras las copia el juego de la fuente de la BIOS (0x1D3F): aqui salen de la VRAM que
    grabo openMSX con C-BIOS. SETGRP es SCREEN 2;
  - logotipo.png, la cabecera de la web: CAR FIGHTER del titulo;
  - las ocho zonas, de los cuadros que grabo openMSX (work/zonas.bin): el centro de la carretera de cada una,
    juntas en zonas.png; una pantalla entera de la zona 1 (work/carrera.bin) y el mapa de la zona 1.

El titulo se coteja con la VRAM grabada (work/carrera.bin, cuadro 400): la imagen sin sprites punto a punto,
la tabla de nombres y los registros.

Uso: pantallas.py <dir> [cotejo]
"""
import os
import sys

from PIL import Image

AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, AQUI)
import vdp                  # noqa: E402
from bios import Msx, SCREEN2        # noqa: E402

RAIZ = os.path.dirname(AQUI)
COTEJO = ("carrera", 400)
PANTALLAS = {"zona1.png": ("carrera", 1000), "mapa.png": ("zonas", 865)}
ZONAS = ("zonas", (1100, 1800, 2500, 3200, 3900, 4600, 5300, 6000))


def cuadro(grab, n):
    for i, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin"))):
        if i == n:
            return c


class CarFighter(Msx):
    def _bios(self):
        if self.pc == 0x007E:                             # SETGRP: SCREEN 2
            self.vdp.regs[:] = SCREEN2
            self.pc = self._pop()
            return
        super()._bios()


def titulo():
    rom = open(os.path.join(RAIZ, "carfighter.rom"), "rb").read()
    m = CarFighter(rom, 0x8000)
    m.mem[0x1D3F:0x1D3F + 0x180] = bytes(cuadro(*COTEJO)["vram"][0:0x180])   # la fuente, desde el caracter 0x30
    m.hasta(0x8028, 0x809B)
    m.hasta(0x809E, 0x80DF)
    return bytes(m.vdp.vram), bytes(m.vdp.regs)


def cotejo(v, regs):
    suya = cuadro(*COTEJO)
    nombres = [a - 0x1800 for a in range(0x1800, 0x1B00) if v[a] != suya["vram"][a]]
    t1, t2 = vdp.tela(v, regs, False), vdp.tela(suya["vram"], suya["regs"], False)
    puntos = [(x, y) for y in range(192) for x in range(256) if t1[y][x] != t2[y][x]]
    print("titulo contra %s/%d: puntos distintos %d de 49152; nombres distintos %d; registros %s"
          % (COTEJO[0], COTEJO[1], len(puntos), len(nombres),
             "iguales" if regs == bytes(suya["regs"]) else "%s / %s" % (regs.hex(), bytes(suya["regs"]).hex())))
    return len(puntos), len(nombres)


def zonas(ruta):
    """Las ocho zonas, en dos filas de cuatro: de cada una, la carretera (las columnas 0-24, sin el marcador)."""
    grab, ns = ZONAS
    ims = {}
    for i, c in enumerate(vdp.cuadros(os.path.join(RAIZ, "work", grab + ".bin"))):
        if i in ns:
            ims[i] = vdp.imagen(c["vram"], c["regs"], 1).crop((0, 0, 200, 192))
        if i > max(ns):
            break
    hoja = Image.new("RGB", (4 * 200 + 3 * 8, 2 * 192 + 8), (0, 0, 0))
    for k, n in enumerate(ns):
        hoja.paste(ims[n], ((k % 4) * 208, (k // 4) * 200))
    hoja.resize((hoja.width * 2, hoja.height * 2), Image.NEAREST).save(ruta)


def main(argv):
    v, regs = titulo()
    vdp.imagen(v, regs, 2, con_sprites=False).save(os.path.join(argv[0], "titulo.png"))
    vdp.imagen(v, regs, 4, con_sprites=False).crop((96, 64, 960, 448)).save(os.path.join(argv[0], "logotipo.png"))
    for f, (g, n) in PANTALLAS.items():
        c = cuadro(g, n)
        vdp.imagen(c["vram"], c["regs"], 2).save(os.path.join(argv[0], f))
    zonas(os.path.join(argv[0], "zonas.png"))
    if len(argv) > 1:
        cotejo(v, regs)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
