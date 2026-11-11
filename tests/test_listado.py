"""Lo que se afirma de la ROM, comprobado contra sus bytes.

Corre con la ROM delante y sin ella: cuando no esta, la imagen se rehace desde
las filas defb/defw del listado, que si viaja con el repositorio. Sin la ROM
solo se comprueba lo que cae en datos.
"""

import os
import re
import subprocess
import sys
import unittest

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(RAIZ, "tools"))

ROM = os.path.join(RAIZ, "carfighter.rom")
ASM = os.path.join(RAIZ, "src", "carfighter.asm")
NOTAS = os.path.join(RAIZ, "src", "carfighter.notes")
ORG = 0x8000
TAM = 16384

FILA = re.compile(r"^\s+def(b|w)\s+([0-9a-fA-F,h ]+)\s*;\s*([0-9a-f]{4})")


def imagen_desde_el_listado():
    img = bytearray(TAM)
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = FILA.match(ln)
            if not m:
                continue
            ancho, cuerpo, dirr = m.group(1), m.group(2), int(m.group(3), 16)
            p = dirr - ORG
            for tok in cuerpo.split(","):
                tok = tok.strip().rstrip("h")
                if not tok:
                    continue
                v = int(tok, 16)
                if ancho == "b":
                    img[p] = v
                    p += 1
                else:
                    img[p] = v & 0xFF
                    img[p + 1] = v >> 8
                    p += 2
    return bytes(img)


def lee():
    if os.path.exists(ROM):
        with open(ROM, "rb") as f:
            return f.read()
    return imagen_desde_el_listado()


def b(a):
    return lee()[a - ORG]


def w(a):
    rom = lee()
    return rom[a - ORG] | (rom[a - ORG + 1] << 8)


def instruccion(dirr):
    """La instruccion del listado en esa direccion (sin el comentario)."""
    with open(ASM, encoding="utf-8") as f:
        for ln in f:
            m = re.match(r"^\t(\S.*?)\s*;([0-9a-f]{4})", ln)
            if m and int(m.group(2), 16) == dirr:
                return m.group(1).replace("\t", " ").strip()
    return None


class Cabecera(unittest.TestCase):
    def test_ab_e_init_en_0x8028(self):
        rom = lee()
        self.assertEqual(rom[:2], b"AB")
        self.assertEqual(w(0x8002), 0x8028)
        self.assertEqual(rom[4:15], bytes(11))

    def test_son_16_kb(self):
        self.assertEqual(len(lee()), TAM)


class LaInterrupcion(unittest.TestCase):
    def test_va_por_h_timi(self):
        self.assertEqual([instruccion(a) for a in (0x803D, 0x8040, 0x8043, 0x8045)],
                         ["ld hl,09021h", "ld (0fda0h),hl", "ld a,0c3h", "ld (0fd9fh),a"])


class LosTextos(unittest.TestCase):
    @staticmethod
    def texto(a, n):
        s = ""
        for c in lee()[a - ORG:a - ORG + n]:
            s += str(c) if c < 10 else (" " if c == 0x10 else (chr(0x40 + c - 0x10) if 0x11 <= c <= 0x2A else "?"))
        return s

    def test_las_letras_son_casillas_propias(self):
        self.assertEqual(self.texto(0x84BF, 11), "CHECK POINT")
        self.assertEqual(self.texto(0x84CA, 4), "GOAL")
        self.assertEqual(self.texto(0x9429, 9), "GAME OVER")
        self.assertEqual(self.texto(0x9362, 5), "EMPTY")
        self.assertEqual(self.texto(0x9432, 5), "START")

    def test_la_fuente_de_la_bios_por_su_direccion(self):
        self.assertEqual(instruccion(0x8F98), "ld hl,01d3fh")


class LaPartida(unittest.TestCase):
    def test_ocho_zonas(self):
        self.assertEqual([instruccion(a) for a in (0x84B3, 0x84B8)], ["cp 009h", "ld (hl),001h"])

    def test_la_gasolina_deja_los_ceros(self):
        """El bucle de los ceros de la izquierda escribe C = 0: la casilla del 0."""
        self.assertEqual([instruccion(a) for a in (0x88CA, 0x88D1)], ["ld bc,00400h", "ld (hl),c"])

    def test_la_carretera_va_al_vdp_por_su_puerto(self):
        self.assertEqual([instruccion(a) for a in (0x8E06, 0x8E0E, 0x8E10)],
                         ["ld a,(00006h)", "ld a,058h", "out (c),a"])


class Sonido(unittest.TestCase):
    def test_seis_musicas_y_nueve_efectos(self):
        self.assertEqual(w(0xBA80), 0xBE59)
        self.assertEqual([w(0xBAA4 + 4 * k) for k in range(9)][0], 0xBE59)
        self.assertEqual(list(lee()[0xBD82 - ORG:0xBD90 - ORG]),
                         [0x80, 0x60, 0x40, 0x30, 0x20, 0x18, 0x10, 0x0C, 0x08, 0x06, 0x04, 0x03, 0x02, 0x01])


class LoQueNadieUsa(unittest.TestCase):
    def test_tres_trozos_sin_llamada(self):
        rom = lee()
        for d in (0x831C, 0x8FA7, 0x9011):
            for op in (0xCD, 0xC3, 0xC4, 0xCC, 0xD4, 0xDC, 0xC2, 0xCA, 0xD2, 0xDA):
                self.assertNotIn(bytes([op, d & 0xFF, d >> 8]), rom)


class ElListado(unittest.TestCase):
    def test_densidad_y_flojas(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "densidad.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        m = re.search(r"(\d+) instrucciones, (\d+) comentarios", salida)
        self.assertGreaterEqual(int(m.group(2)) * 100, 40 * int(m.group(1)))
        self.assertIn("---- 0 rutinas por debajo del 10 %", salida)

    def test_ningun_call_sin_nombre(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "sin_bautizar.py"), ASM],
            capture_output=True, text=True, check=True).stdout
        self.assertTrue(salida.startswith("0 rutinas sin bautizar"), salida[:200])

    def test_cada_comentario_en_su_instruccion(self):
        salida = subprocess.run(
            [sys.executable, os.path.join(RAIZ, "tools", "valida_c.py"), ASM, NOTAS],
            capture_output=True, text=True, check=True).stdout
        self.assertIn("0 fuera de sitio, 0 repetidos", salida)


if __name__ == "__main__":
    unittest.main()
