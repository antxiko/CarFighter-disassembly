#!/usr/bin/env python3
"""Los sprites de Car Fighter MONTADOS DESDE LA ROM (ninguna imagen es una captura).

Los dibujos son los 2 KB de 0xB800 que `sprites_dibujos` (0x8FD8) pone tal cual en 0x3800 (los de verdad son los
0x280 primeros; la copia sigue por las tablas, el codigo y la musica hasta el final de la ROM).

  sprites.png    el coche: el dibujo de su direccion (`coche_arriba` 0, `coche_derecha` 8, `coche_abajo` 0x0C,
                 `coche_izquierda` 0x10) en azul con el dibujo 4 en negro encima (0x81E1-0x81ED, 0x8B37), y en negro
                 al chocar (0x8356); los otros coches (`coche_otro_sale`, 0x963B: 0x14 rojo y 0x18 negro; los que
                 atacan, en magenta, 0x96DD; y los de 0x1C y 0x20 en verde, 0x96E7); el camion (0x9605: 0x24 y 0x2C en
                 magenta con 0x28 y 0x30 en negro, la pareja de detras 16 puntos mas abajo, `coche_sprites` 0x9574);
                 las cosas sueltas (`cosa4` 0x3C en negro o azul claro, `cosa5` 0x4C en blanco), el disparo (0x40,
                 blanco), la bomba (0x44, negra) y su estallido (0x34 y 0x38, rojo oscuro); y el coche tocado dos
                 veces, que parpadea en 9 y 10 (0x9A41; el camion, 0x98E2), y derribado, que estalla en rojo (0x9B2B)
  estallido_cuadros.gif   la bomba que estalla: 0x34 y 0x38 cada 4 cuadros (`bomba_estallido`, 0x8A4B)

Uso: hojas.py docs/imagenes | hojas.py cotejo
"""
import os
import sys

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))
import vdp          # noqa: E402

ORG = 0x8000
ROM = open(os.path.join(RAIZ, "carfighter.rom"), "rb").read()
FONDO = (96, 96, 104)        # un gris de carretera


def patrones():
    return ROM[0xB800 - ORG:0xB800 - ORG + 0x800]


def pinta(im, pat, n, x, y, color, escala=1):
    if color == 0:
        return
    n &= 0xFC
    d = pat[n * 8:n * 8 + 32]
    c = vdp.PALETA[color]
    for fila in range(16):
        for col in range(16):
            if (d[fila + (16 if col >= 8 else 0)] >> (7 - (col & 7))) & 1:
                for ey in range(escala):
                    for ex in range(escala):
                        px, py = (x + col) * escala + ex, (y + fila) * escala + ey
                        if 0 <= px < im.width and 0 <= py < im.height:
                            im.putpixel((px, py), c)


COCHE = [(0x00, "arriba"), (0x08, "derecha"), (0x0C, "abajo"), (0x10, "izquierda")]
OTROS = [((0x14, 8), (0x18, 1)), ((0x14, 13), (0x18, 1)), ((0x1C, 2), (0x20, 1))]
CAMION = [(0, 0x24, 13), (0, 0x28, 1), (16, 0x2C, 13), (16, 0x30, 1)]


def hoja(Image):
    pat, E = patrones(), 3
    im = Image.new("RGB", (9 * 24 * E, 3 * 40 * E), FONDO)
    for k, (d, _) in enumerate(COCHE):
        pinta(im, pat, d, 4 + 24 * k, 4, 4, E)
        pinta(im, pat, 4, 4 + 24 * k, 4, 1, E)
    pinta(im, pat, 0, 4 + 24 * 4, 4, 1, E)
    pinta(im, pat, 4, 4 + 24 * 4, 4, 1, E)
    for k, ((d1, c1), (d2, c2)) in enumerate(OTROS):
        pinta(im, pat, d1, 4 + 24 * k, 44, c1, E)
        pinta(im, pat, d2, 4 + 24 * k, 44, c2, E)
    for dy, d, c in CAMION:
        pinta(im, pat, d, 4 + 24 * 3, 36 + dy, c, E)
    for k, cc in enumerate((9, 10)):                   # tocado dos veces: parpadea (0x9A41)
        pinta(im, pat, 0x14, 4 + 24 * (4 + k), 44, cc, E)
        pinta(im, pat, 0x18, 4 + 24 * (4 + k), 44, 1, E)
    for k, d in enumerate((0x34, 0x38)):              # derribado: estalla en rojo (0x9B2B)
        pinta(im, pat, d, 4 + 24 * (6 + k), 44, 8, E)
    for k, (d, c) in enumerate(((0x3C, 1), (0x3C, 5), (0x4C, 15), (0x40, 15), (0x44, 1), (0x34, 6), (0x38, 6))):
        pinta(im, pat, d, 4 + 24 * k, 84, c, E)
    return im


def anima(Image):
    pat, E, cuadros = patrones(), 4, []
    for n in range(64):
        im = Image.new("RGB", (24 * E, 24 * E), FONDO)
        pinta(im, pat, 0x34 + (n & 4), 4, 4, 6, E)
        cuadros.append(im)
    return cuadros


def guarda_gif(cuadros, ruta, ms=1000 / 60):
    imgs, durs = [], []
    for im in cuadros:
        if imgs and list(im.getdata()) == list(imgs[-1].getdata()):
            durs[-1] += ms
        else:
            imgs.append(im)
            durs.append(ms)
    imgs[0].save(ruta, save_all=True, append_images=imgs[1:], duration=[max(20, int(round(d))) for d in durs],
                 loop=0, disposal=1)


def cotejo():
    """Contra las grabaciones de openMSX (work/*.bin, la RAM 0xE000-0xF0FF):
    1) la tabla de dibujos de los sprites (VRAM 0x3800-0x3FFF) contra los 2 KB de 0xB800;
    2) los sprites de los diez coches de 0xE360 (32 bytes; sus sprites en +0 y +0x10, el camion tambien en +0x20 y
       +0x30), que el juego copia a la tabla de sprites (`sprites_copia`, 0x9013): los dibujos y colores de cada
       tipo y que los sprites de cada pareja vayan juntos (el camion, la de detras 16 puntos mas abajo)."""
    pat = patrones()
    tot = dict(patrones=0, pat_mal=0, coches=0, coches_y=0, coches_mal=0, camiones=0, camiones_mal=0)
    for grab in ("atraccion", "partida", "carrera", "zonas", "zona4"):
        ruta = os.path.join(RAIZ, "work", grab + ".bin")
        if not os.path.exists(ruta):
            continue
        for c in vdp.cuadros(ruta, 0x1100):
            v, ram = c["vram"], c["ram"]
            t = v[0x3800:0x4000]
            if any(t):
                tot["patrones"] += t == pat
                tot["pat_mal"] += t != pat
            for k in range(10):
                bl = ram[0x360 + 32 * k:0x360 + 32 * k + 0x40]
                tipo = bl[4]
                if tipo in (1, 2) and bl[2] in (0x14, 0x1C):
                    tot["coches"] += 1
                    par = ((bl[2], bl[3]), (bl[0x12], bl[0x13]))
                    validos = [tuple(o) for o in OTROS]
                    if bl[0x0C] >= 2:                   # tocado dos veces: parpadea en 9 y 10 (0x9A41)
                        validos += [((d1, cc), o2) for (d1, _), o2 in OTROS for cc in (9, 10)]
                    if par in validos and bl[0x10:0x12] == bl[0:2]:
                        continue
                    if par in validos and bl[0x11] == bl[1] or par in validos and ((bl[0x10] - bl[0]) & 0xFF) >= 0xF8:
                        tot["coches_y"] += 1            # la Y del segundo sprite, aun la de antes de moverse
                    else:
                        tot["coches_mal"] += 1
                elif tipo == 3 and bl[2] == 0x24 and k < 9:
                    tot["camiones"] += 1
                    hay = [(((bl[16 * j] - bl[0]) & 0xFF), bl[16 * j + 2], bl[16 * j + 3]) for j in range(4)]
                    quiero = [CAMION] if bl[0x0C] < 2 else [[(dy, d, cc if c == 13 else c) for dy, d, c in CAMION]
                                                            for cc in (9, 10)]   # tocado dos veces (0x98E2)
                    ok = hay in quiero and all(bl[16 * j + 1] == bl[1] for j in range(4))
                    tot["camiones_mal"] += not ok
    return tot


def main(argv):
    if argv and argv[0] == "cotejo":
        print(cotejo())
        return 0
    from PIL import Image
    salida = argv[0]
    os.makedirs(salida, exist_ok=True)
    hoja(Image).save(os.path.join(salida, "sprites.png"))
    guarda_gif(anima(Image), os.path.join(salida, "estallido_cuadros.gif"))
    for f in ("sprites.png", "estallido_cuadros.gif"):
        print(f, os.path.getsize(os.path.join(salida, f)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
