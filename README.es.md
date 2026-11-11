# Car Fighter - desensamblado comentado

*(Also [in English](README.md).)*

El desensamblado comentado de **Car Fighter** (Casio, 1985) para MSX: un cartucho de 16 KB en 0x8000.

- **100 %** del binario explicado: 7.865 bytes de código y 8.519 de datos con nombre, ni un byte sin asignar.
- **40,7 %** del listado comentado, 522 rutinas y etiquetas, ninguna por debajo del 10 % de comentarios.
- El listado se reensambla en la ROM original **byte a byte**.
- El título sale de ejecutar la ROM, cotejado con openMSX; las ocho zonas, el mapa, los choques, el camión, CHECK POINT y GOAL, jugados en GIF; las cuatro músicas, de su propio motor de sonido e idénticas a openMSX cuadro a cuadro.

La web: <https://antxiko.github.io/CarFighter-disassembly/es/>
(en inglés: <https://antxiko.github.io/CarFighter-disassembly/>).

## Reproducirlo

La imagen de la ROM no se distribuye. Pon la tuya en la raíz como `carfighter.rom` (sha256 `3a63d167...`) y ejecuta `make`. El detalle, en [POR DENTRO](docs/es/POR-DENTRO.md).

## Legal

El juego es de Casio y de sus titulares. La licencia de `LICENSE` cubre solo las herramientas, los comentarios, el análisis y la documentación de aquí. Mira [AVISO-LEGAL.md](AVISO-LEGAL.md).
