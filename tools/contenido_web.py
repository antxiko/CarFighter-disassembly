#!/usr/bin/env python3
"""EL CONTENIDO de la web de esta ROM: lo unico que es de este juego.

jekyll.py y make_web.py son la maquinaria y no llevan dentro el nombre de
ningun juego: lo leen de aqui.

Todas las cifras de aqui estan medidas sobre esta ROM, con las herramientas
de tools/: CODIGO y DATOS los imprime tools/presupuesto.py (make sanity),
INSTRUCCIONES, COMENTARIOS y RUTINAS los da tools/densidad.py (make densidad:
"de N" rutinas, "N instrucciones, M comentarios").
"""

NOMBRE = "Car Fighter"
EDITOR = "Casio"
ANIO = 1985
REPOSITORIO = "https://github.com/antxiko/CarFighter-disassembly"
SHA1 = "e93c396649bf6328103e8da0247952ebef2a04e9"

CODIGO = 7865
DATOS = 8519
RUTINAS = 522
INSTRUCCIONES = 3672
COMENTARIOS = 1496


def densidad(idioma):
    """El porcentaje comentado, con la coma o el punto de cada idioma."""
    d = "%.1f" % (100.0 * COMENTARIOS / INSTRUCCIONES)
    return d.replace(".", ",") if idioma == "es" else d


PIE_LEGAL = {
    "es": "<em>Car Fighter</em> es un juego de Casio para MSX, de 1985, en un cartucho de 16 KB. "
          "Todos los derechos sobre el juego siguen siendo de sus titulares. Este trabajo es de "
          "preservaci&oacute;n, estudio y documentaci&oacute;n, y la imagen de la ROM no se distribuye.",
    "en": "<em>Car Fighter</em> is a 1985 Casio game for the MSX, on a 16 KB cartridge. All rights in "
          "the game remain with their holders. This is preservation, study and documentation work, and the "
          "ROM image is not distributed.",
}

PORTADA = {
    "es": dict(
        titulo="Car Fighter - desensamblado comentado",
        claim="De San Francisco a Washington por carretera, en ocho zonas: la gasolina que se gasta "
              "seg&uacute;n la velocidad, los choques a partir de 130 km/h, los coches que persiguen, el "
              "cami&oacute;n que aguanta tres bombas y el mapa entre zona y zona. El t&iacute;tulo desde los "
              "bytes de la ROM, cotejado con openMSX; las ocho zonas, el mapa, los choques, CHECK POINT y GOAL "
              "en GIF, y las cuatro m&uacute;sicas de su propio motor, id&eacute;nticas a openMSX cuadro a "
              "cuadro.",
        ficha=["Casio - <b>(c) 1985</b>",
               "Cartucho de <b>16 KB</b> en 0x8000",
               "<b>MSX</b>", "Volcado <b>e93c3966...</b>"],
        aviso="<b>Aqu&iacute; no hay capturas del juego.</b> El logotipo y el t&iacute;tulo salen de "
              "ejecutar la ROM (cotejados con openMSX), y los GIF son la ROM <b>funcionando en "
              "openMSX</b>: en cada cuadro se apuntan la VRAM y los registros del VDP, y <b>c&oacute;digo "
              "nuestro los pinta</b>.",
    ),
    "en": dict(
        titulo="Car Fighter - commented disassembly",
        claim="From San Francisco to Washington by road, in eight zones: the fuel burnt according to the "
              "speed, the crashes from 130 km/h up, the cars that chase, the truck that takes three bombs "
              "and the map between zones. The title from the ROM's bytes, checked against openMSX; the eight "
              "zones, the map, the crashes, CHECK POINT and GOAL in GIF, and the four tunes from its own "
              "engine, identical to openMSX frame by frame.",
        ficha=["Casio - <b>(c) 1985</b>",
               "<b>16 KB</b> cartridge at 0x8000",
               "<b>MSX</b>", "Dump <b>e93c3966...</b>"],
        aviso="<b>There are no screenshots of the game here.</b> The logo and the title come from running "
              "the ROM (checked against openMSX), and the GIFs are the ROM <b>running in openMSX</b>: on every "
              "frame the VRAM and the VDP registers are logged, and <b>our own code paints them</b>.",
    ),
}

PAGINAS = [
    [("THE-GAME.html", "LA-PARTIDA.html", "The game", "La partida",
      "the controls, the fuel, the crashes and the points, as the code has them",
      "los mandos, la gasolina, los choques y los puntos, como los tiene el c&oacute;digo"),
     ("THE-ZONES.html", "LAS-ZONAS.html", "The zones", "Las zonas",
      "the map of the journey, the eight zones, CHECK POINT and GOAL, in GIF",
      "el mapa del viaje, las ocho zonas, CHECK POINT y GOAL, en GIF"),
     ("THE-CARS.html", "LOS-COCHES.html", "The other cars", "Los otros coches",
      "the cars that chase, the truck and what it drops, the shots and the bombs",
      "los coches que persiguen, el cami&oacute;n y lo que suelta, los disparos y las bombas"),
     ("THE-SPRITES.html", "LOS-SPRITES.html", "The sprites", "Los sprites",
      "the car, the other cars and the truck, hit and blowing up, the bomb and the loose things, put together from "
      "the ROM tables",
      "el coche, los otros coches y el cami&oacute;n, tocados y estallando, la bomba y las cosas sueltas, montados "
      "desde las tablas de la ROM"),
     ("THE-TEXTS.html", "LOS-TEXTOS.html", "The texts", "Los textos",
      "every text in the ROM, the names of the cities and CASIO from the four sides",
      "todos los textos de la ROM, los nombres de las ciudades y CASIO por los cuatro lados"),
     ("THE-MUSIC.html", "LA-MUSICA.html", "The music", "La m&uacute;sica",
      "the four tunes, from its own sound engine and checked against openMSX",
      "las cuatro m&uacute;sicas, de su propio motor de sonido y cotejadas con openMSX")],
    [("CURIOSITIES.html", "CURIOSIDADES.html", "Curiosities", "Curiosidades",
      "the zeros that stay, a tune nobody asks for, the letters at a fixed address and the code nobody reaches",
      "los ceros que se quedan, una m&uacute;sica que nadie pide, las letras en una direcci&oacute;n fija y el "
      "c&oacute;digo al que no se llega")],
    [("UNDER-THE-HOOD.html", "POR-DENTRO.html", "Under the hood", "Por dentro",
      "rebuilding the ROM, the BIOS it uses, the interrupt, the road in RAM and the tools",
      "rehacer la ROM, la BIOS que usa, la interrupci&oacute;n, la carretera en la RAM y las herramientas")],
]

# Repositorio nuevo: no hay paginas viejas que redirigir.
VIEJAS = {}

LOGOTIPO = "logotipo.png"
