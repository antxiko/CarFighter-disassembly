; ==========================================================================
; CAR FIGHTER - ROM de 16 KB en 0x8000
; ==========================================================================
; Generado por tools/mkasm.py a partir del trazado de flujo real.
; Los comentarios provienen de tools/../src/*.notes y estan anclados a
; direccion, de modo que sobreviven a un retrazado.
; ==========================================================================

	org 0x08000


; ----------------------------------------------------------------------
; Direcciones que solo aparecen como VALOR -en un `ld`, no en
; un salto-: son punteros que el codigo se pasa o numeros que
; casualmente coinciden con una direccion. No hay nada que
; trazar en ellas; el equ existe para que el listado ensamble.
; ----------------------------------------------------------------------
l8691h:	equ 0x08691

; ----------------------------------------------------------------------
; DATOS cabecera: "AB", INIT (0x8028) y el resto de la cabecera a cero; 0x8010
;   empieza en 0x800F con un 0
;   0x8000..0x800f  (15 bytes)
DATA_cabecera:
	defb 041h,042h	; 8000
	defw 08028h,00000h,00000h,00000h,00000h,00000h	; 8002
	defb 000h	; 800e

; ----------------------------------------------------------------------
; DATOS tablas_zonas: Por zona (1-8, indice desde 0x800F): el color de la
;   carretera (0x8010), el color de los bordes (0x8018) y la distancia hasta
;   el CHECK POINT (0x8020)
;   0x800f..0x8028  (25 bytes)
DATA_tablas_zonas:
	defb 000h	; 800f
	defb 091h,095h,085h,08dh,0a1h,095h,0a5h,081h	; 8010  ........
	defb 032h,0bah,0eeh,068h,011h,0bah,032h,0efh	; 8018  2..h..2.
	defb 006h,006h,006h,008h,008h,009h,00ah,006h	; 8020  ........

; ======================================================================
; CODIGO 0x8028..0x8350  (808 bytes)
; ======================================================================


init:		; El arranque: la RAM a cero, la pila, la interrupcion en H.TIMI, SCREEN 2 y los colores
	di			;8028   ; sin interrupciones
	call 00041h		;8029   ; DISSCR
	ld hl,0e000h		;802c   ; 0xE000-0xF0FF...
	ld bc,01100h		;802f   ; ...0x1100 bytes...
init_borra:		; ...a cero
	ld (hl),000h		;8032   ; un byte a 0
	inc hl			;8034
	dec c			;8035   ; 256 bytes...
	jr nz,init_borra		;8036
	djnz init_borra		;8038   ; ...17 veces
	ld sp,0f100h		;803a   ; la pila
	ld hl,09021h		;803d   ; la interrupcion (0x9021)...
	ld (0fda0h),hl		;8040   ; ...en H.TIMI...
	ld a,0c3h		;8043   ; ...con su "jp"
	ld (0fd9fh),a		;8045   ; el "jp" en el gancho
	call 0007eh		;8048   ; SETGRP: SCREEN 2
	xor a			;804b   ; fondo y borde negros...
	ld (0f3eah),a		;804c   ; BAKCLR = 0
	ld (0f3ebh),a		;804f   ; BDRCLR = 0
	dec a			;8052   ; ...letras blancas (0xFF)
	ld (0f3e9h),a		;8053   ; FORCLR = 0xFF
	call 00062h		;8056   ; CHGCLR
	ld de,00000h		;8059   ; los dibujos de las casillas en los tres tercios
	call letras		;805c   ; en el primer tercio...
	call letras		;805f   ; ...el segundo...
	call letras		;8062   ; ...y el tercero
	xor a			;8065   ; el color de las casillas 0x10 en adelante, en los tres tercios
	ld hl,00080h		;8066   ; el color de la casilla 0x10 (el espacio): 0, en el primer tercio...
	call color8		;8069
	ld hl,00880h		;806c   ; ...el segundo...
	call color8		;806f
	ld hl,01080h		;8072   ; ...y el tercero
	call color8		;8075
	call colores_blanco		;8078   ; los colores de toda la pantalla a 0xF0
	call sprites_dibujos		;807b   ; los dibujos de los sprites
	ld a,0a2h		;807e   ; el registro 1 a 0xA2: la pantalla apagada, sprites de 16 x 16
	ld b,a			;8080   ; B = el valor
	ld c,001h		;8081   ; C = el registro 1
	call 00047h		;8083   ; WRTVDP
	ld a,001h		;8086   ; la zona 1
	ld (0e094h),a		;8088   ; el record: 010000 (las cifras 0xE094...)
	ld (0e08fh),a		;808b   ; ...y 0xE08F
	ei			;808e   ; con las interrupciones
titulo:		; El titulo: la pantalla en blanco, CAR FIGHTER, CASIO, PUSH TRIG:1 OR SPC y el copyright; espera el boton o la demostracion
	call sonido_calla_pide		;808f   ; el sonido, callado
	call pantalla		;8092   ; la pantalla en blanco
	call colores_juego		;8095   ; los colores del titulo
	call 00044h		;8098   ; ENASCR
	call presentacion		;809b   ; la presentacion de CASIO
	ld hl,0927eh		;809e   ; CASIO en rojo (6 casillas)...
	ld de,019edh		;80a1   ; ...en la fila 15, columna 13
	call texto6		;80a4   ; seis casillas
	ld hl,09284h		;80a7   ; CAR en letras grandes: 4 filas de 14 desde la fila 3, columna 9
	ld de,01869h		;80aa   ; desde la fila 3, columna 9
	ld b,004h		;80ad   ; cuatro filas
titulo_fila:		; Una fila
	push bc			;80af
	call texto14		;80b0   ; 14 casillas
	pop bc			;80b3
	djnz titulo_fila		;80b4   ; las cuatro
	ld b,005h		;80b6   ; FIGHTER: 5 filas de 25 desde la fila 8, columna 4
	ld de,01904h		;80b8   ; desde la fila 8, columna 4
titulo_fila2:		; Una fila
	push bc			;80bb
	call texto25		;80bc   ; 25 casillas
	pop bc			;80bf
	djnz titulo_fila2		;80c0   ; las cinco
	ld hl,0933ah		;80c2   ; PUSH TRIG:1 OR SPC...
	ld de,01a48h		;80c5   ; ...en la fila 18, columna 8
	ld c,012h		;80c8   ; 18 letras (LDIRVM)
	call 0005ch		;80ca
	ld hl,0934ch		;80cd   ; el copyright...
	ld de,01a85h		;80d0   ; ...en la fila 20, columna 5
	ld c,016h		;80d3   ; 22 letras
	call 0005ch		;80d5
	call 00044h		;80d8   ; ENASCR
	xor a			;80db   ; la cuenta de la espera a 0
	ld (0e018h),a		;80dc   ; (la cuenta de cuadros 0xE018)
titulo_espera:		; Espera: si pasan 240 cuadros, la demostracion en una zona al azar (1-4)
	ld a,(0e018h)		;80df   ; los cuadros que pasan
	cp 0f0h		;80e2   ; 240?
	jr c,titulo_boton		;80e4   ; aun no: el boton?
	ld (0e04ch),a		;80e6   ; la demostracion
	ld a,r		;80e9   ; una zona al azar...
	and 003h		;80eb   ; 0-3...
	inc a			;80ed   ; ...de 1 a 4
	ld (0e00ah),a		;80ee   ; ...+ 1: la zona
	jr zona		;80f1   ; a la zona
titulo_boton:		; El boton: una partida nueva desde la zona 1
	ld a,(0e043h)		;80f3   ; el boton
	and a			;80f6   ; pulsado?
	jr z,titulo_espera		;80f7   ; no: espera
	xor a			;80f9   ; sin demostracion
	ld (0e043h),a		;80fa   ; ya visto
	ld (0e04ch),a		;80fd   ; sin demostracion
	ld (0e009h),a		;8100   ; la vuelta 0
	inc a			;8103   ; la zona 1...
	ld (0e00ah),a		;8104   ; la zona 1
	ld (0e000h),a		;8107   ; ...y la partida en marcha
	ld hl,0e001h		;810a   ; 0xE001-0xE006 a cero
	ld b,006h		;810d   ; seis bytes (0xE001: las cifras de los puntos)
	xor a			;810f
titulo_borra:
	ld (hl),a			;8110   ; a cero
	inc hl			;8111
	djnz titulo_borra		;8112
	ld l,00ch		;8114   ; 0xE00C-0xE00E a cero
	ld b,003h		;8116   ; tres bytes (0xE00C: los puntos en BCD)
titulo_borra2:
	ld (hl),a			;8118
	inc hl			;8119
	djnz titulo_borra2		;811a
	ld hl,0e0c0h		;811c   ; 0xE0C0-0xE0CF a cero
	ld b,010h		;811f   ; 16 bytes
titulo_borra3:
	ld (hl),a			;8121
	inc hl			;8122
	djnz titulo_borra3		;8123
zona:		; Una zona: la pantalla, el mapa del recorrido, la carretera y sus colores segun la zona, los coches y la salida
	ld ix,0e300h		;8125   ; el coche del jugador
	call pantalla		;8129   ; la pantalla del juego
	call mapa		;812c   ; el mapa del recorrido
	ld a,(0e00ah)		;812f   ; la zona...
	ld hl,0800fh		;8132   ; ...en la tabla 0x8010...
	add a,l			;8135   ; + la zona
	ld l,a			;8136
	ld a,(hl)			;8137   ; ...el color de la carretera
	ld c,a			;8138   ; el color de la carretera...
	inc c			;8139   ; ...+ 2: el de los bordes de la RAM
	inc c			;813a
	ld hl,0e600h		;813b   ; la carretera en la RAM: 12 parejas...
	ld b,00ch		;813e   ; 12 parejas
	call parejas		;8140   ; (A, C)
	ld b,00ch		;8143   ; ...y otras 12
	dec a			;8145   ; el color y la casilla siguientes
	dec c			;8146
	call parejas		;8147   ; otras 12
	ld hl,08017h		;814a   ; el color de los bordes (0x8018)
	ld a,(0e00ah)		;814d   ; la zona
	add a,l			;8150
	ld l,a			;8151
	ld a,(hl)			;8152   ; el color...
	ld d,a			;8153   ; ...en D
	ld hl,02368h		;8154   ; en los tres tercios, desde la casilla 0x6D
	call colores8		;8157   ; 8 bytes de color en el primer tercio (casilla 0x6D)
	ld hl,02b68h		;815a   ; el segundo
	call colores8		;815d
	ld hl,03368h		;8160   ; el tercero
	call colores8		;8163
	and 0f0h		;8166   ; la mitad alta...
	rrca			;8168   ; la mitad alta, abajo
	rrca			;8169
	rrca			;816a
	rrca			;816b
	ld c,a			;816c   ; ...el otro color
	ld hl,022e8h		;816d   ; 112 bytes desde la casilla 0x5D, en los tres tercios
	ld b,070h		;8170   ; 112 bytes
	call colores_tabla		;8172   ; en el primer tercio
	ld hl,02ae8h		;8175   ; el segundo
	ld b,070h		;8178
	call colores_tabla		;817a
	ld hl,032e8h		;817d   ; el tercero
	ld b,070h		;8180
	call colores_tabla		;8182
	ld hl,0e8c0h		;8185   ; 0xE8C0...
	ld (0e186h),hl		;8188   ; ...en 0xE186
	ld hl,09dabh		;818b   ; la tabla de la zona (0x9DAB)...
	call tabla_zona		;818e   ; la lista de la zona
	ld (0e18dh),de		;8191   ; ...en 0xE18D
	call tramo1_sig		;8195   ; el primer tramo
	ld hl,09dbbh		;8198   ; otra (0x9DBB)...
	call tabla_zona		;819b   ; la lista de la zona
	ld (0e1a6h),de		;819e   ; ...en 0xE1A6
	call tramo2_sig		;81a2   ; el primer tramo
	ld hl,09dcbh		;81a5   ; otra (0x9DCB)...
	call tabla_zona		;81a8   ; la lista de la zona
	ld (0e1aeh),de		;81ab   ; ...en 0xE1AE
	call tramo3_sig		;81af   ; el primer tramo
	call 00041h		;81b2   ; DISSCR
	ld b,018h		;81b5   ; 24 veces
zona_baja:		; La carretera baja una fila
	push bc			;81b7
	call fila_nueva		;81b8   ; una fila nueva de carretera
	pop bc			;81bb
	djnz zona_baja		;81bc   ; 24 filas: la pantalla llena
	ld a,(0e00ah)		;81be   ; la zona 1?
	cp 001h		;81c1   ; la zona 1?
	jr nz,zona_coche		;81c3
	ld de,0196bh		;81c5   ; si: START (0x9432) en la fila 11, columna 11
	ld hl,09432h		;81c8   ; START
	call texto5		;81cb   ; 5 casillas
zona_coche:		; El coche en su sitio (Y 0x60, X 0x60) y en marcha
	call marcador		;81ce   ; el marcador
	ld (ix+001h),060h		;81d1   ; la X del coche: 0x60
	ld (ix+011h),060h		;81d5   ; la de su segundo sprite
zona_salida:
	ld (ix+000h),060h		;81d9   ; la Y: 0x60
	ld (ix+010h),060h		;81dd   ; la del segundo sprite
	ld (ix+002h),000h		;81e1   ; el dibujo 0 (mirando arriba)
	ld (ix+003h),004h		;81e5   ; color 4
	ld (ix+012h),004h		;81e9   ; el segundo sprite: dibujo 4...
	ld (ix+013h),001h		;81ed   ; ...color 1
	ld (ix+00ch),020h		;81f1   ; 20 bombas (BCD)
	ld hl,003f8h		;81f5   ; 0x3F8...
	ld (0e1c4h),hl		;81f8   ; ...en 0xE1C4
	call bombas_pinta		;81fb   ; en el marcador
	call 00044h		;81fe   ; ENASCR
	xor a			;8201
	ld (0e010h),a		;8202   ; la cuenta de cuadros a 0
carrera:		; El bucle de la carrera: un paso cada vez que la interrupcion cuenta un cuadro
	ld a,(0e183h)		;8205   ; ha chocado o se ha salido?
	and a			;8208
	jp nz,choque		;8209   ; al choque
	ld a,(0e184h)		;820c   ; se acaba la zona?
	and a			;820f
	jp nz,fin_zona		;8210   ; al final de la zona
carrera_cuadro:		; Espera al cuadro siguiente (0xE011)
	ld hl,0e011h		;8213   ; la interrupcion ha contado un cuadro?
	ld a,(hl)			;8216
	cp 001h		;8217
	jr c,carrera_sigue		;8219   ; no: espera
	ld (hl),000h		;821b   ; el cuadro, gastado
	call salen_coches		;821d   ; las partes del juego
	call coches		;8220   ; los diez coches
	call marcador_puntos		;8223   ; los puntos
	call gasolina_gasta		;8226   ; la gasolina
	call coche_mueve		;8229   ; el coche
	call sprites_vram		;822c   ; los sprites a la VRAM
	call avance		;822f   ; la carretera avanza
	call distancia		;8232   ; la marca de la distancia
	call bordes		;8235   ; los bordes
	ld hl,0801fh		;8238   ; la distancia de la zona (0x8020)...
	ld a,(0e00ah)		;823b   ; la zona
	ld c,a			;823e
	add a,l			;823f
	ld l,a			;8240
	ld b,(hl)			;8241   ; B = su distancia
	ld a,(0e19dh)		;8242   ; ...alcanzada?
	cp b			;8245   ; aun no
	jr c,carrera_sigue		;8246
	ld a,c			;8248   ; la zona 3?
	cp 003h		;8249   ; la zona 3?
	jr nz,carrera_fin		;824b
	ld a,(0e19ch)		;824d   ; ...tambien la X
	cp 0e8h		;8250   ; 0xE8 o mas
	jr c,carrera_sigue		;8252
carrera_fin:		; El final de la zona
	ld (0e184h),a		;8254   ; la zona se acaba
carrera_sigue:		; La partida sigue?
	ld a,(0e000h)		;8257
	and a			;825a   ; en partida, sigue
	jr nz,carrera		;825b
	ld a,(0e043h)		;825d   ; el boton (en la demostracion)
	and a			;8260   ; la demostracion: sin boton, sigue
	jr z,carrera		;8261
	jp titulo		;8263   ; al titulo
texto14:		; Copia 14 casillas de HL a la VRAM DE y DE pasa a la fila siguiente
	ld bc,0000eh		;8266   ; 14 casillas
texto_n:		; ...BC casillas (LDIRVM)
	call 0005ch		;8269   ; LDIRVM
	push de			;826c
	ld de,00020h		;826d   ; la fila siguiente
	add hl,de			;8270
	pop de			;8271
	ex de,hl			;8272
	ret			;8273
texto25:		; 25 casillas
	ld bc,00019h		;8274   ; 25 casillas
	jr texto_n		;8277
colores8:		; FILVRM: 8 bytes del color A en HL; A vuelve con D
	ld bc,00008h		;8279   ; 8 bytes...
	call 00056h		;827c   ; ...FILVRM
	ld a,d			;827f
	ret			;8280
coches:		; Los diez coches de 0xE360 (32 bytes cada uno)
	ld b,00ah		;8281   ; diez coches
	ld iy,0e360h		;8283   ; desde 0xE360
coche_uno:		; Uno
	push bc			;8287
	call coche_otro		;8288   ; uno
	pop bc			;828b
	ld de,00020h		;828c   ; el siguiente
	add iy,de		;828f   ; el siguiente (32 bytes)
	djnz coche_uno		;8291
	ret			;8293
pantalla:		; La pantalla del juego: apagada, la tabla de nombres, los sprites y los colores
	call 00041h		;8294   ; DISSCR
	call ram_sprites		;8297   ; la RAM de los sprites
	call pantalla_borra		;829a   ; la pantalla en blanco
	call gasolina_llena		;829d   ; la gasolina llena
	ld hl,0e040h		;82a0   ; 0xE040-0xE045 a cero
	ld b,006h		;82a3   ; 6 bytes
	xor a			;82a5
pantalla_ram_borra:
	ld (hl),a			;82a6   ; a cero
	inc hl			;82a7
	djnz pantalla_ram_borra		;82a8
	ld (0e180h),a		;82aa   ; sin palanca
	ld de,00180h		;82ad   ; las casillas del juego, desde la 0x30...
	call casillas_a800		;82b0   ; ...en el primer tercio...
	call casillas_a800		;82b3
	call casillas_a800		;82b6   ; ...y el tercero
	ld d,021h		;82b9   ; sus colores, desde 0x2180
	call casillas_b000		;82bb
	call casillas_b000		;82be
	call casillas_b000		;82c1
	jp sprites_dibujos		;82c4   ; y los dibujos de los sprites
espera_b:		; Espera B cuadros (0xE010); vuelve antes si no hay partida y se pulsa el boton
	xor a			;82c7
	ld (0e010h),a		;82c8   ; la cuenta a 0
espera_cuenta:
	ld a,(0e000h)		;82cb
	and a			;82ce   ; en partida?
	jr nz,espera_sigue		;82cf
	ld a,(0e043h)		;82d1   ; la demostracion: el boton?
	and a			;82d4
	ret nz			;82d5   ; pulsado: vuelve
espera_sigue:
	ld a,(0e010h)		;82d6   ; la cuenta...
	cp b			;82d9   ; ...llega a B?
	jr c,espera_cuenta		;82da
	ret			;82dc
colores_tabla:		; B bytes de la tabla 0xB168 en la VRAM HL: su mitad alta con el color C
	ld de,0b168h		;82dd
colores_byte:
	ld a,(de)			;82e0   ; el byte de la tabla...
	and 0f0h		;82e1   ; ...su mitad alta...
	add a,c			;82e3   ; ...con el color C
	call 0004dh		;82e4   ; WRTVRM
	inc hl			;82e7
	inc de			;82e8
	djnz colores_byte		;82e9
	ret			;82eb
parejas:		; B parejas (A, C) desde HL
	ld (hl),a			;82ec   ; A...
	inc hl			;82ed
	ld (hl),c			;82ee   ; ...y C
	inc hl			;82ef
	djnz parejas		;82f0
	ret			;82f2
tabla_zona:		; DE = la palabra de la zona en la tabla HL
	ld a,(0e00ah)		;82f3   ; la zona...
	dec a			;82f6   ; ...menos 1...
tabla_zona_suma:
	add a,a			;82f7   ; ...x 2
	add a,l			;82f8
	jr nc,tabla_zona_lee		;82f9
	inc h			;82fb
tabla_zona_lee:
	ld l,a			;82fc
	ld e,(hl)			;82fd   ; la palabra
	inc hl			;82fe
	ld d,(hl)			;82ff
	ret			;8300
choque:		; El coche choca contra el borde (0xE183 = 1 o 2) o se queda sin gasolina (3, parado)
	cp 003h		;8301   ; 3: sin gasolina...
	jr nz,choque_va		;8303
	ld a,(0e194h)		;8305   ; ...aun se mueve?
	and a			;8308
	jp nz,carrera_cuadro		;8309   ; si: sigue hasta pararse
	jp game_over		;830c   ; parado: se acaba
choque_va:
	jr choque_para		;830f   ; 1 o 2: el choque
choque_aparta:
	ld (0e441h),a		;8311   ; los sprites de 0xE440 apartados
	ld (0e443h),a		;8314
	ld (0e445h),a		;8317
	jr $+55		;831a   ; a la gasolina
L_831C:
	xor a			;831c   ; el choque a cero...
	ld (0e183h),a		;831d
	jp carrera_cuadro		;8320   ; ...y a la carrera (aqui no se llega)
choque_para:		; El coche se para: el sonido 5 y todo a cero
	xor a			;8323
	ld (0e1c3h),a		;8324   ; el motor callado
	ld a,005h		;8327   ; la musica 5
	call musica_pide		;8329
	xor a			;832c
	ld (0e012h),a		;832d   ; la cuenta de la espera
	ld (ix+010h),a		;8330   ; el coche parado del todo: sus sprites y su estado
	ld (ix+011h),a		;8333
	ld (ix+012h),a		;8336
	ld (ix+013h),a		;8339
	ld (ix+00ch),a		;833c   ; sin bombas en vuelo...
	ld (ix+004h),a		;833f   ; ...sin disparo...
	ld (ix+009h),a		;8342   ; ...ni nada
	ld (ix+006h),a		;8345
	ld (ix+008h),a		;8348
	ld (0e444h),a		;834b
	jr choque_aparta		;834e   ; y los sprites apartados

; ----------------------------------------------------------------------
; DATOS byte_8350: Un byte (0xE4) entre un "jr" y la rutina siguiente, al que
;   no se llega
;   0x8350..0x8351  (1 bytes)
DATA_byte_8350:
	defb 0e4h	; 8350

; ======================================================================
; CODIGO 0x8351..0x84bf  (366 bytes)
; ======================================================================


choque_gasolina:		; Diez litros menos de gasolina; sin gasolina, 0xE182
	ld a,0e8h		;8351   ; la Y de 0xE440 abajo
	ld (0e440h),a		;8353
	ld (ix+003h),001h		;8356   ; el coche en color 1
	ld (ix+030h),0f0h		;835a   ; la bomba...
	ld (ix+020h),0f0h		;835e   ; ...y el disparo, fuera
	ld hl,0e082h		;8362   ; las centenas de la gasolina
	xor a			;8365
	cp (hl)			;8366   ; hay 100?
	jr nz,choque_cuenta_baja		;8367
	dec hl			;8369   ; las decenas
	cp (hl)			;836a
	jr z,choque_cuenta_cero		;836b   ; 0?
	dec (hl)			;836d   ; diez litros menos
	jr choque_espera		;836e
choque_cuenta_baja:
	ld (hl),000h		;8370   ; 100: a 90...
	dec hl			;8372
	ld (hl),009h		;8373   ; ...con las decenas a 9
	jr choque_espera		;8375
choque_cuenta_cero:
	dec hl			;8377   ; menos de 10...
	ld (hl),a			;8378   ; ...las unidades a 0...
	inc a			;8379
	ld (0e182h),a		;837a   ; ...y sin gasolina
choque_espera:		; La cuenta y 64 cuadros de espera
	call gasolina_pinta		;837d   ; en el marcador
	ld hl,0e190h		;8380   ; la velocidad (siete bytes)...
	ld b,007h		;8383
L_8385:
	ld (hl),000h		;8385   ; ...a cero
	inc hl			;8387
	djnz L_8385		;8388
	call velocidad_pinta		;838a   ; en el marcador
choque_cuadro:
	ld hl,0e011h		;838d   ; un cuadro?
	ld a,(hl)			;8390
	cp 001h		;8391
	jr c,choque_cuadro		;8393
	ld (hl),000h		;8395   ; gastado
	call sprites_vram		;8397   ; los sprites
	call coches		;839a   ; y los otros coches siguen
	ld a,(0e013h)		;839d   ; el coche: el estallido, cada 4 cuadros...
	and 004h		;83a0
	add a,034h		;83a2   ; ...0x34 o 0x38
	ld (ix+002h),a		;83a4
	ld a,(0e012h)		;83a7   ; la cuenta...
	cp 040h		;83aa   ; ...64 cuadros?
	jr c,choque_cuadro		;83ac
	ld a,(0e182h)		;83ae   ; sin gasolina?
	and a			;83b1
	jr nz,game_over		;83b2
	ld a,(0e183h)		;83b4   ; por donde ha chocado: 1 a la izquierda...
	cp 001h		;83b7
	jr nz,choque_derecha		;83b9
	ld a,(ix+001h)		;83bb   ; ...16 pixeles a la derecha
	add a,010h		;83be
choque_recoloca:		; El coche vuelve a la carretera
	ld (ix+001h),a		;83c0   ; la X
	ld (ix+011h),a		;83c3
	xor a			;83c6   ; sin choque
	ld (0e183h),a		;83c7
	ld (ix+003h),a		;83ca   ; el color 0...
	ld (ix+013h),a		;83cd
	jp zona_salida		;83d0   ; ...y otra vez a la salida
choque_derecha:
	cp 002h		;83d3   ; 2 a la derecha...
	jr nz,choque_sitio		;83d5
	ld a,(ix+001h)		;83d7   ; ...16 pixeles a la izquierda
	sub 010h		;83da
	jr choque_recoloca		;83dc
choque_sitio:
	ld a,(ix+001h)		;83de   ; otro: donde estaba
	jr choque_recoloca		;83e1
game_over:		; Sin gasolina: EMPTY, el sonido 6, una espera, GAME OVER y al titulo
	call velocidad_pinta		;83e3   ; la velocidad en el marcador
	ld de,019ebh		;83e6   ; EMPTY (0x9362) en la fila 15, columna 11
	ld hl,09362h		;83e9   ; EMPTY
	call texto5		;83ec
	ld a,006h		;83ef   ; el efecto 6
	call efecto_pide		;83f1
	ld b,030h		;83f4   ; 48 cuadros
	call espera_b		;83f6
	ld de,01949h		;83f9   ; GAME OVER (0x9429) en la fila 10, columna 9
	ld hl,09429h		;83fc   ; GAME OVER
	ld bc,00009h		;83ff   ; 9 letras
	call 0005ch		;8402
	ld a,001h		;8405   ; el sonido 1
	call musica_pide		;8407   ; la musica 1
	ld b,0feh		;840a   ; 254 cuadros
	call espera_b		;840c
	xor a			;840f   ; sin demostracion
	ld (0e04ch),a		;8410
	ld (0e000h),a		;8413   ; sin partida
	ld (0e043h),a		;8416
	jp titulo		;8419   ; al titulo
fin_zona:		; El final de la zona: CHECK POINT o, en la zona 8, GOAL; el coche sale por arriba, cuenta lo que queda y la zona siguiente
	xor a			;841c
	ld (0e1c3h),a		;841d   ; el motor callado
	ld (ix+023h),a		;8420   ; el disparo y la bomba, de color 0
	ld (ix+033h),a		;8423
	ld a,003h		;8426   ; el sonido 3
	call musica_pide		;8428   ; la musica 3
	ld a,(0e00ah)		;842b   ; la zona 8?
	cp 008h		;842e   ; la zona 8?
	jr z,fin_zona_goal		;8430
	ld de,01907h		;8432   ; CHECK POINT en la fila 8, columna 7
	ld hl,084bfh		;8435   ; CHECK POINT
	ld bc,0000bh		;8438   ; 11 letras
	call 0005ch		;843b
	jr fin_zona_sale		;843e
fin_zona_goal:		; GOAL
	ld de,0190bh		;8440   ; en la fila 8, columna 11
	ld hl,084cah		;8443
	call texto4		;8446   ; GOAL
fin_zona_sale:		; El coche sale por arriba, 3 pixeles por cuadro
	ld hl,0e011h		;8449   ; un cuadro?
	ld a,(hl)			;844c
	cp 001h		;844d
	jr c,fin_zona_sale		;844f
	ld (hl),000h		;8451   ; gastado
	ld a,0fdh		;8453   ; la Y, 3 menos
	add a,(ix+000h)		;8455
	ld (ix+000h),a		;8458
	ld (ix+010h),a		;845b
	call coches		;845e   ; los otros coches
	call sprites_vram		;8461   ; los sprites
	ld a,(ix+000h)		;8464   ; ha salido por arriba (entre 0xD8 y 0xEB)?
	cp 0d8h		;8467
	jr c,fin_zona_sale		;8469
	cp 0ech		;846b
	jr nc,fin_zona_sale		;846d
fin_zona_cuenta:		; La gasolina que queda baja de litro en litro, cada uno con sus puntos
	ld hl,0e011h		;846f   ; un cuadro?
	ld a,(hl)			;8472
	cp 001h		;8473
	jr c,fin_zona_cuenta		;8475
	xor a			;8477   ; gastado
	ld (hl),a			;8478
	ld hl,0e080h		;8479   ; las unidades de la gasolina
	cp (hl)			;847c
	jr nz,fin_cuenta1		;847d
	inc hl			;847f   ; las decenas
	cp (hl)			;8480
	jr nz,fin_cuenta2		;8481
	inc hl			;8483   ; las centenas
	cp (hl)			;8484
	jr nz,fin_cuenta3		;8485
	jr fin_zona_sig		;8487   ; todo 0: la zona siguiente
fin_cuenta1:
	dec (hl)			;8489   ; un litro menos
	jr fin_cuenta_puntos		;848a
fin_cuenta2:
	dec (hl)			;848c   ; 10: a 09
	dec hl			;848d
	ld (hl),009h		;848e
	jr fin_cuenta_puntos		;8490
fin_cuenta3:
	dec (hl)			;8492   ; 100: a 099
	dec hl			;8493
	ld (hl),009h		;8494
	dec hl			;8496
	ld (hl),009h		;8497
fin_cuenta_puntos:
	ld a,001h		;8499   ; 100 puntos por litro
	call puntos_centenas		;849b
	call gasolina_pinta		;849e   ; la gasolina...
	call marcador_puntos		;84a1   ; ...y los puntos en el marcador
	jr fin_zona_cuenta		;84a4
fin_zona_sig:		; La zona siguiente; despues de la 8, otra vez la 1 y una vuelta mas
	ld b,068h		;84a6   ; 104 cuadros
	call espera_b		;84a8
	call sonido_calla_pide		;84ab   ; el sonido, callado
	ld hl,0e00ah		;84ae   ; la zona...
	inc (hl)			;84b1   ; ...siguiente
	ld a,(hl)			;84b2
	cp 009h		;84b3   ; pasa de 8?
	jp nz,zona		;84b5
	ld (hl),001h		;84b8   ; otra vez la 1...
	dec hl			;84ba
	inc (hl)			;84bb   ; ...y una vuelta mas (0xE009)
	jp zona		;84bc

; ----------------------------------------------------------------------
; DATOS textos_fin: CHECK POINT (11 casillas) y GOAL (4)
;   0x84bf..0x84ce  (15 bytes)
DATA_textos_fin:
	defb 013h,018h,015h,013h,01bh,010h,020h,01fh,019h,01eh,024h	; 84bf  ...... ...$
	defb 017h,01fh,011h,01ch	; 84ca

; ======================================================================
; CODIGO 0x84ce..0x84e9  (27 bytes)
; ======================================================================


colores_blanco:		; Toda la tabla de colores a 0xF0
	ld hl,02000h		;84ce   ; 6 KB de la tabla de colores...
	ld bc,01800h		;84d1
	ld a,0f0h		;84d4   ; ...a 0xF0
	jp 00056h		;84d6
texto5:		; 5 casillas de HL en la VRAM DE
	ld bc,00005h		;84d9   ; 5 casillas
texto_vram:		; LDIRVM
	jp 0005ch		;84dc
texto4:		; 4 casillas
	ld bc,00004h		;84df   ; 4 casillas
	jr texto_vram		;84e2
texto6:		; 6 casillas
	ld bc,00006h		;84e4   ; 6 casillas
	jr texto_vram		;84e7

; ----------------------------------------------------------------------
; DATOS mapa_marcas: Las marcas del mapa para cada zona ya hecha: 7 bytes por
;   zona, leidos hacia atras desde 0x851A (las casillas del trazo y su sitio)
;   0x84e9..0x851a  (49 bytes)
DATA_mapa_marcas:
	defb 0dfh,07dh,0efh,09eh,0dfh,0beh,03dh	; 84e9
	defb 0ddh,0ddh,0deh,0deh,0deh,0deh,0dfh	; 84f0
	defb 0dah,0dbh,0d9h,0fbh,0d9h,0fbh,09ch	; 84f7
	defb 0ddh,0d8h,0deh,0d9h,0deh,0d9h,0fah	; 84fe
	defb 0dch,0d5h,0dbh,0d6h,0dbh,0d6h,097h	; 8505
	defb 0efh,0d3h,0dfh,0f3h,0dfh,0f3h,0d4h	; 850c
	defb 0eeh,032h,0eeh,052h,0eeh,072h,092h	; 8513

; ======================================================================
; CODIGO 0x851a..0x863d  (291 bytes)
; ======================================================================


vram_marcador:		; HL = la casilla del marcador (0x18B6 + el byte de HL), y HL apunta al siguiente
	ld e,(hl)			;851a   ; el byte...
	inc hl			;851b
	ld d,000h		;851c
	ex de,hl			;851e
	ld bc,018b6h		;851f   ; ...+ 0x18B6
	add hl,bc			;8522
	ret			;8523
mapa:		; Al empezar la zona, el mapa del recorrido (RLE de 0x9210) en el centro de la pantalla, las zonas ya hechas marcadas y el coche en el sitio de la zona
	ld a,(0e000h)		;8524   ; en partida?
	and a			;8527   ; no: nada
	ret z			;8528
	call 00044h		;8529   ; ENASCR
	ld hl,0e630h		;852c   ; el mapa en 0xE630...
	ld de,09210h		;852f   ; ...de 0x9210...
	ld b,0cdh		;8532   ; ...205 casillas
mapa_byte:		; Un byte: con la mitad alta, tal cual
	ld a,(de)			;8534   ; el byte
	and 0f0h		;8535   ; la mitad alta...
	and a			;8537
	jr z,mapa_tramo		;8538   ; ...a 0: un tramo
	ld a,(de)			;853a   ; tal cual
	ld (hl),a			;853b
	inc hl			;853c
	inc de			;853d
	djnz mapa_byte		;853e   ; las 205
	jr mapa_vram		;8540
mapa_tramo:		; Con la mitad alta a 0: cuantos y que casilla
	ld a,(de)			;8542   ; cuantas...
	ld c,a			;8543
	inc de			;8544
	ld a,(de)			;8545   ; ...la casilla
mapa_repite:
	ld (hl),a			;8546   ; una
	inc hl			;8547
	dec b			;8548   ; una menos de las 205
	dec c			;8549   ; una menos del tramo
	jr nz,mapa_repite		;854a
	inc de			;854c
	jr mapa_byte		;854d
mapa_vram:		; A la pantalla: 12 filas de 17, una cada cuadro de 0xE1B8
	ld de,0e630h		;854f   ; el mapa
	ld hl,01867h		;8552   ; desde la fila 4, columna 7
mapa_fila:
	ld bc,00020h		;8555
	add hl,bc			;8558   ; la fila siguiente
	ex de,hl			;8559
	ld bc,00011h		;855a   ; 17 casillas (LDIRVM)
	call 0005ch		;855d
	ld a,(0e1b8h)		;8560   ; una fila mas...
	inc a			;8563
	ld (0e1b8h),a		;8564
	cp 00ch		;8567   ; ...12?
	jr c,mapa_fila		;8569
	xor a			;856b
	ld (0e1b8h),a		;856c   ; la cuenta a 0
	ld a,(0e00ah)		;856f   ; las zonas ya hechas...
	dec a			;8572   ; las zonas hechas
	jr z,mapa_coche		;8573   ; ...ninguna
	ld hl,vram_marcador		;8575   ; sus marcas (0x851A hacia atras, de 7 en 7)
	ld de,00007h		;8578   ; de 7 en 7 bytes
	ld b,a			;857b
	ld c,a			;857c
mapa_marca_tabla:
	and a			;857d
	sbc hl,de		;857e   ; hacia atras
	djnz mapa_marca_tabla		;8580
mapa_marca:		; Una zona hecha: tres casillas y un trazo de dos
	ld b,003h		;8582   ; tres casillas
mapa_marca_casilla:
	push bc			;8584
	ld a,(hl)			;8585   ; el sitio...
	inc hl			;8586
	call vram_marcador		;8587   ; ...en la pantalla
	call 0004dh		;858a   ; la casilla
	ex de,hl			;858d
	pop bc			;858e
	djnz mapa_marca_casilla		;858f   ; las tres
	push bc			;8591
	call vram_marcador		;8592   ; el sitio del trazo
	ld a,0d7h		;8595   ; la casilla 0xD7...
	call 0004dh		;8597
	push de			;859a
	ld de,00020h		;859b
	add hl,de			;859e
	ld a,0d8h		;859f   ; ...y la 0xD8 debajo
	call 0004dh		;85a1
	pop hl			;85a4
	pop bc			;85a5
	dec c			;85a6   ; la zona siguiente
	jr nz,mapa_marca		;85a7
mapa_coche:		; El coche (sprite) en el sitio de la zona (0x863D) y el nombre de la zona (0xB780) letra a letra
	ld hl,0863dh		;85a9   ; el sitio del coche en el mapa
	call tabla_zona		;85ac
	dec hl			;85af   ; la Y...
	ld a,(hl)			;85b0
	ld (ix+000h),a		;85b1
	inc hl			;85b4
	ld a,(hl)			;85b5   ; ...y la X
	ld (ix+001h),a		;85b6
	ld (ix+002h),048h		;85b9   ; el dibujo 0x48...
	ld (ix+003h),006h		;85bd   ; ...color 6
	ld hl,0b780h		;85c1   ; el nombre de la zona
	call tabla_zona		;85c4
	inc hl			;85c7
	push hl			;85c8   ; la segunda parte
	inc de			;85c9
	ld hl,01a87h		;85ca   ; en la fila 20, columna 7: 11 letras
	ld b,00bh		;85cd   ; 11 letras
	call letra_a_letra		;85cf
	pop hl			;85d2
	ld e,(hl)			;85d3   ; la segunda parte...
	inc hl			;85d4
	ld d,(hl)			;85d5
	ld hl,01a92h		;85d6   ; en la fila 20, columna 18: el resto
	ld a,(de)			;85d9   ; ...con su largo delante
	ld b,a			;85da
	inc de			;85db
	call letra_a_letra		;85dc
	xor a			;85df
	ld (0e010h),a		;85e0   ; las cuentas a 0
	ld (0e011h),a		;85e3
	ld (0e1b8h),a		;85e6
mapa_espera:		; 32 cuadros
	call cuatro_cuadros		;85e9   ; cuatro cuadros...
	ld a,(0e010h)		;85ec   ; ...hasta 32
	cp 020h		;85ef
	jr c,mapa_espera		;85f1
	call pantalla_borra		;85f3   ; la pantalla en blanco
	ret			;85f6
letra_a_letra:		; B letras de DE en la VRAM HL, una cada 4 cuadros con el sonido 8
	call cuatro_cuadros		;85f7
	exx			;85fa
	ld a,008h		;85fb   ; el efecto 8
	call efecto_pide		;85fd
	exx			;8600
	ld a,(de)			;8601   ; la letra
	call 0004dh		;8602   ; WRTVRM
	inc de			;8605
	inc hl			;8606
	djnz letra_a_letra		;8607   ; todas
	ret			;8609
cuatro_cuadros:		; Espera 4 cuadros; el coche parpadea en el mapa
	ld a,(0e012h)		;860a   ; el reloj de un cuadro (0xE012)
	cp 001h		;860d
	jr c,cuatro_cuadros_va		;860f
	xor a			;8611
	ld (0e012h),a		;8612
cuatro_cuadros_va:
	ld a,(0e011h)		;8615   ; cuatro cuadros?
	cp 004h		;8618
	jr c,cuatro_cuadros		;861a
	xor a			;861c
	ld (0e011h),a		;861d
	exx			;8620
	call sprites_vram		;8621   ; los sprites
	exx			;8624
	ld a,(0e1b8h)		;8625   ; encendido?
	and a			;8628
	jr nz,parpadeo_apaga		;8629
	inc a			;862b
	ld (0e1b8h),a		;862c
	ld (ix+003h),006h		;862f   ; el color 6
	ret			;8633
parpadeo_apaga:
	dec a			;8634
	ld (0e1b8h),a		;8635
	ld (ix+003h),000h		;8638   ; el color 0
	ret			;863c

; ----------------------------------------------------------------------
; DATOS mapa_sitios: El sitio del coche en el mapa de cada zona (Y, X), ocho
;   zonas
;   0x863d..0x864d  (16 bytes)
DATA_mapa_sitios:
	defb 04fh,040h	; 863d
	defb 05fh,050h	; 863f
	defb 04fh,068h	; 8641
	defb 067h,080h	; 8643
	defb 04fh,090h	; 8645
	defb 05fh,0a8h	; 8647
	defb 037h,098h	; 8649
	defb 027h,0b0h	; 864b

; ----------------------------------------------------------------------
; DATOS bytes_864d: Ocho bytes (0x70-0xA0) detras de la tabla: ninguna
;   instruccion los lee por su direccion
;   0x864d..0x8655  (8 bytes)
DATA_bytes_864d:
	defb 070h,070h,080h,080h,090h,090h,0a0h,0a0h	; 864d  pp......

; ======================================================================
; CODIGO 0x8655..0x8692  (61 bytes)
; ======================================================================


distancia:		; La marca de la distancia recorrida en la barra de la derecha (0xE19C contra el paso de la zona, 0x8692)
	ld hl,l8691h		;8655
	ld a,(0e00ah)		;8658   ; la zona
	add a,l			;865b
	ld l,a			;865c
	ld e,(hl)			;865d   ; lo que vale una marca
	ld d,000h		;865e
	ld hl,(0e19ch)		;8660   ; la distancia
	and a			;8663
	ld c,000h		;8664   ; cuantas marcas
distancia_divide:
	sbc hl,de		;8666   ; una marca menos...
	jr c,distancia_marca		;8668
	inc c			;866a   ; ...una mas
	jr distancia_divide		;866b
distancia_marca:
	ld a,c			;866d
	and a			;866e   ; ninguna
	ret z			;866f
	ld b,001h		;8670   ; de 4 en 4 por fila
distancia_fila:
	sub 004h		;8672   ; menos 4
	jr c,distancia_pon		;8674
	jr z,distancia_pon		;8676
	inc b			;8678
	jr distancia_fila		;8679
distancia_pon:
	add a,004h		;867b
	ld hl,01b1ch		;867d   ; la barra, abajo a la derecha...
	ld de,0ffe0h		;8680   ; ...una fila arriba por cada 4
distancia_sube:
	add hl,de			;8683
	djnz distancia_sube		;8684
	add a,03dh		;8686   ; la casilla de 1 a 4 marcas (0x3E-0x41)
	ld b,a			;8688
	call 0004dh		;8689   ; WRTVRM, dos casillas
	inc hl			;868c
	ld a,b			;868d
	call 0004dh		;868e
L_8691:
	ret			;8691

; ----------------------------------------------------------------------
; DATOS pasos_zona: Lo que vale cada marca de la barra en cada zona
;   0x8692..0x869a  (8 bytes)
DATA_pasos_zona:
	defb 02ah,02ah,030h,038h,038h,040h,047h,02ah	; 8692  **088@G*

; ======================================================================
; CODIGO 0x869a..0x9210  (2934 bytes)
; ======================================================================


carretera_fila:		; HL = la fila de la carretera en la RAM (0xE8C0, 24 bytes por fila, da la vuelta en 0xEB00) que esta en la Y A
	call entre8		;869a   ; la Y entre 8
	ld b,a			;869d
	ld hl,(0e186h)		;869e   ; la fila de arriba del anillo
	ld de,00018h		;86a1   ; 24 bytes por fila
carretera_fila_sig:
	add hl,de			;86a4
	ld a,h			;86a5
	cp 0ebh		;86a6   ; da la vuelta?
	jr nz,carretera_fila_va		;86a8
	ld hl,0e8c0h		;86aa   ; al principio del anillo
carretera_fila_va:
	djnz carretera_fila_sig		;86ad
	ret			;86af
bordes:		; El coche contra los bordes de la carretera: a mucha velocidad (0xE194 >= 0x82) choca; si no, rebota; las casillas 0x3C son la gasolinera
	ld a,(ix+000h)		;86b0   ; la Y del coche: su fila
	call carretera_fila		;86b3
	push hl			;86b6
	ld b,001h		;86b7   ; la columna 1
borde_izq_busca:		; Por la izquierda: la primera casilla de borde
	ld a,(hl)			;86b9   ; la casilla
	cp 06bh		;86ba   ; 0x6B o 0x6C: el borde recto
	jr z,borde_izq_recto		;86bc
	cp 06ch		;86be
	jr z,borde_izq_recto		;86c0
	cp 03ch		;86c2   ; 0x3C: la gasolinera
	jr z,gasolinera_izq		;86c4
	cp 04fh		;86c6   ; de 0x4F a 0x55: el borde en curva
	jr c,borde_izq_sig		;86c8
	cp 056h		;86ca
	jr c,borde_izq_curva		;86cc
borde_izq_sig:
	inc b			;86ce   ; la columna siguiente
	inc hl			;86cf
	jr borde_izq_busca		;86d0
borde_izq_recto:
	ld c,000h		;86d2
	jr borde_izq		;86d4
borde_izq_curva:
	ld c,a			;86d6   ; la curva: 0x56 - la casilla...
	ld a,056h		;86d7
	sub c			;86d9
	ld c,a			;86da
borde_izq:
	call borde_x_izq		;86db   ; la X del borde...
	sub 005h		;86de
	cp b			;86e0   ; ...el coche esta por fuera?
	jr nc,borde_der		;86e1
borde_izq_choque:
	ld a,(0e194h)		;86e3   ; muy deprisa?
	cp 082h		;86e6
	jr c,borde_izq_rebota		;86e8
	ld a,001h		;86ea   ; choca por la izquierda
	ld (0e183h),a		;86ec
	jr borde_der		;86ef
borde_izq_rebota:
	ld (ix+00ah),001h		;86f1   ; rebota a la derecha
	ld (ix+00bh),000h		;86f5
	jr borde_der		;86f9
gasolinera_izq:
	ld c,008h		;86fb   ; la gasolinera: 8 pixeles
	call borde_x_izq		;86fd
	sub 005h		;8700
	sub b			;8702
	cp 0f8h		;8703   ; encima?
	jr nc,borde_izq_choque		;8705
	cp 016h		;8707
	jr nc,borde_der		;8709
	call gasolinera		;870b   ; carga gasolina
borde_der:		; Por la derecha
	pop hl			;870e
	ld a,l			;870f   ; la fila de abajo...
	add a,018h		;8710
	jr nc,borde_der_va		;8712
	inc h			;8714
borde_der_va:
	ld l,a			;8715
	ld b,018h		;8716   ; desde la columna 24 hacia atras
borde_der_busca:
	ld a,(hl)			;8718   ; la casilla
	cp 06bh		;8719
	jr z,borde_der_recto		;871b
	cp 06ch		;871d
	jr z,borde_der_recto		;871f
	cp 03ch		;8721   ; la gasolinera
	jr z,gasolinera_der		;8723
	cp 056h		;8725   ; de 0x56 a 0x5C: el borde en curva
	jr c,borde_der_sig		;8727
	cp 05dh		;8729
	jr c,borde_der_curva		;872b
borde_der_sig:
	dec hl			;872d   ; la columna anterior
	dec b			;872e
	jr borde_der_busca		;872f
borde_der_recto:
	ld c,000h		;8731
	jr borde_der_mira		;8733
borde_der_curva:
	ld c,a			;8735   ; 0x5D - la casilla
	ld a,05dh		;8736
	sub c			;8738
	ld c,a			;8739
borde_der_mira:
	call borde_x_der		;873a   ; la X del borde
	add a,006h		;873d
	cp b			;873f   ; el coche por fuera?
	jr c,bordes_fin		;8740
borde_der_choque:
	ld a,(0e194h)		;8742   ; muy deprisa?
	cp 082h		;8745
	jr c,borde_der_rebota		;8747
	ld a,002h		;8749   ; choca por la derecha
	ld (0e183h),a		;874b
	jr bordes_fin		;874e
borde_der_rebota:
	ld (ix+00ah),0ffh		;8750   ; rebota a la izquierda
	ld (ix+00bh),000h		;8754
	jr bordes_fin		;8758
gasolinera_der:
	ld c,008h		;875a
	call borde_x_der		;875c
	add a,006h		;875f
	sub b			;8761
	cp 008h		;8762   ; encima?
	jr c,borde_der_choque		;8764
	cp 0eah		;8766
	jr c,bordes_fin		;8768
	call gasolinera		;876a   ; carga gasolina
bordes_fin:
	ret			;876d
gasolinera:		; En la gasolinera, cada 4 cuadros un litro mas (hasta 100) con el sonido 5
	ld a,(0e183h)		;876e   ; chocando no
	and a			;8771
	ret nz			;8772
	ld a,(0e01eh)		;8773   ; cada 4 cuadros
	cp 004h		;8776
	ret c			;8778
	xor a			;8779
	ld (0e01eh),a		;877a
	call gasolina_pinta		;877d   ; en el marcador
	ld a,(0e082h)		;8780   ; ya 100?
	cp 001h		;8783   ; hay 100?
	ret nc			;8785
	ld a,005h		;8786   ; el efecto 5
	call efecto_pide		;8788
	ld hl,0e080h		;878b   ; las unidades...
	inc (hl)			;878e   ; un litro mas
	ld a,(hl)			;878f
	cp 00ah		;8790   ; 10?
	ret nz			;8792
	ld (hl),000h		;8793   ; 0 y las decenas + 1
	inc hl			;8795   ; ...las decenas...
	inc (hl)			;8796
	ld a,(hl)			;8797
	cp 00ah		;8798   ; 10?
	ret nz			;879a
	ld (hl),000h		;879b   ; 0 y las centenas a 1
	inc hl			;879d
	ld (hl),001h		;879e   ; ...y 100
	ret			;87a0
borde_x_izq:		; B = la columna x 8 - C; A = la X del coche
	ld a,b			;87a1
	rlca			;87a2   ; la columna x 8...
	rlca			;87a3
	rlca			;87a4
	sub c			;87a5   ; ...menos C
	ld b,a			;87a6
	ld a,(ix+001h)		;87a7   ; la X del coche
	ret			;87aa
borde_x_der:		; B = la columna x 8 + C; A = la X del coche
	ld a,b			;87ab
	rlca			;87ac   ; la columna x 8...
	rlca			;87ad
	rlca			;87ae
	add a,c			;87af   ; ...mas C
	ld b,a			;87b0
	ld a,(ix+001h)		;87b1
	ret			;87b4
entre8:		; A / 8
	and 0f8h		;87b5   ; sin los 3 bits bajos...
	rrca			;87b7   ; ...entre 8
	rrca			;87b8
	rrca			;87b9
	ret			;87ba
casilla_fila:		; La casilla A / 8 de la fila HL
	call entre8		;87bb
	add a,l			;87be   ; + la fila
	jr nc,L_87C2		;87bf
	inc h			;87c1
L_87C2:
	ld l,a			;87c2
	ld a,(hl)			;87c3   ; la casilla
	ret			;87c4
marcador:		; El marcador de la derecha: HISCORE, SCORE, BOMB, FUEL, SPEED, P= y la barra
	ld de,01819h		;87c5   ; en la fila 0, columna 25
	ld hl,0936dh		;87c8   ; HISCORE (7 casillas)
	ld bc,00007h		;87cb
	call 0005ch		;87ce
	ld de,0187bh		;87d1   ; en la fila 3, columna 27
	ld hl,0936fh		;87d4   ; SCORE
	call texto5		;87d7
	ex de,hl			;87da
	ld de,018b9h		;87db   ; en la fila 5, columna 25
	call texto4		;87de   ; BOMB
	ex de,hl			;87e1
	ld de,018d9h		;87e2   ; desde la fila 6, columna 25
	ld b,005h		;87e5   ; cinco filas de 7
marcador_fila:		; Una fila del recuadro
	push bc			;87e7
	call texto7		;87e8
	pop bc			;87eb
	djnz marcador_fila		;87ec
	ld hl,0937fh		;87ee   ; las tres filas del recuadro de la velocidad
	call texto7		;87f1
	ld hl,0939bh		;87f4
	call texto7		;87f7
	ld hl,0938dh		;87fa
	call texto7		;87fd
	ld hl,019dbh		;8800   ; en la fila 14, columna 27
	ld a,020h		;8803   ; P...
	call 0004dh		;8805
	inc hl			;8808
	ld a,00dh		;8809   ; ...=
	call 0004dh		;880b
	ld hl,019fbh		;880e   ; en la fila 15, columna 27: G
	ld a,017h		;8811
	call 0004dh		;8813
	inc h			;8816   ; una fila mas abajo... (H + 1: 8 filas)
	ld a,023h		;8817   ; ...S
	call 0004dh		;8819
	ld hl,019fch		;881c   ; la barra de la distancia: desde la fila 15, columna 28
	ld de,0001fh		;881f
	ld c,009h		;8822   ; nueve filas
L_8824:
	ld a,03dh		;8824   ; dos casillas 0x3D
	call 0004dh		;8826
	inc hl			;8829
	ld a,03dh		;882a
	call 0004dh		;882c
	add hl,de			;882f   ; la fila siguiente
	dec c			;8830
	jr nz,L_8824		;8831
	call marcador_puntos		;8833   ; los puntos
	call zona_pinta		;8836   ; la zona
	call gasolina_gasta		;8839   ; la gasolina
	ret			;883c
texto7:		; 7 casillas de HL en la VRAM DE
	ld bc,00007h		;883d   ; 7 casillas
	jp texto_n		;8840
gasolina_gasta:		; El coche gasta gasolina: un litro cada tantos cuadros (60 parado; menos cuanto mas corre); con menos de 20, la luz de FUEL parpadea con el sonido 4; sin gasolina, 0xE183 = 3
	ld hl,0e184h		;8843   ; se acaba la zona?...
	xor a			;8846   ; se acaba la zona?
	cp (hl)			;8847
	ret nz			;8848
	dec hl			;8849   ; ...choca?...
	cp (hl)			;884a
	ret nz			;884b
	dec hl			;884c   ; ...sin gasolina?
	cp (hl)			;884d   ; sin gasolina?
	ret nz			;884e
	dec h			;884f   ; las centenas...
	cp (hl)			;8850   ; hay centenas?
	jr nz,gasolina_ritmo		;8851
	dec hl			;8853   ; ...y las decenas: menos de 20?
	ld a,(hl)			;8854   ; las decenas
	cp 002h		;8855
	jr nc,gasolina_ritmo		;8857
	ld a,(0e01fh)		;8859   ; la luz de FUEL: la casilla 0x31 o 0x32 cada 4 cuadros...
	and 004h		;885c   ; cada 4 cuadros...
	rrca			;885e
	rrca			;885f
	add a,031h		;8860   ; ...la casilla 0x31 o 0x32
	ld hl,018deh		;8862   ; ...en la fila 6, columna 30
	call 0004dh		;8865   ; WRTVRM
	ld a,004h		;8868   ; el sonido 4
	call efecto_pide		;886a   ; (el efecto 4)
gasolina_ritmo:		; Cada cuantos cuadros: la velocidad / 4 + 14, o 60 si va despacio
	ld a,(0e194h)		;886d   ; la velocidad
	cp 008h		;8870   ; menos de 8: 60 cuadros
	jr nc,gasolina_rapido		;8872   ; 8 o mas
	ld b,03ch		;8874   ; parado: 60 cuadros
	jr gasolina_cuenta		;8876
gasolina_rapido:
	srl a		;8878   ; entre 4...
	srl a		;887a
	add a,00eh		;887c   ; ...+ 14
	ld b,a			;887e
gasolina_cuenta:
	ld a,(0e010h)		;887f   ; los cuadros pasados...
	cp b			;8882   ; ...llegan?
	jp c,gasolina_vram		;8883
	xor a			;8886   ; un litro menos (BCD, cuatro cifras)
	ld (0e010h),a		;8887   ; la cuenta a 0
	ld hl,0e080h		;888a   ; las unidades
	cp (hl)			;888d
	jr nz,gasolina_baja1		;888e
	inc hl			;8890   ; las decenas
	cp (hl)			;8891
	jr nz,gasolina_baja2		;8892
	inc hl			;8894   ; las centenas
	cp (hl)			;8895
	jr nz,gasolina_baja3		;8896
	inc hl			;8898   ; los millares
	cp (hl)			;8899
	jr nz,gasolina_baja4		;889a
	inc a			;889c   ; sin gasolina: 0xE182...
	ld (0e182h),a		;889d   ; todo 0: sin gasolina
	ld a,003h		;88a0   ; ...y 0xE183 = 3
	ld (0e183h),a		;88a2
	ret			;88a5
gasolina_baja4:
	dec (hl)			;88a6   ; una menos...
	ld a,009h		;88a7   ; ...y las de abajo a 9
	dec hl			;88a9
	ld (hl),a			;88aa
gasolina_nueve2:
	dec hl			;88ab
	ld (hl),a			;88ac
gasolina_nueve1:
	dec hl			;88ad
	ld (hl),a			;88ae
	jr gasolina_pinta		;88af
gasolina_baja3:
	dec (hl)			;88b1
	ld a,009h		;88b2
	jr gasolina_nueve2		;88b4
gasolina_baja2:
	dec (hl)			;88b6
	ld a,009h		;88b7
	jr gasolina_nueve1		;88b9
gasolina_baja1:
	dec (hl)			;88bb
gasolina_pinta:		; La gasolina en la pantalla: las cifras al reves en 0xE084; el bucle de los ceros de la izquierda los cambia por 0
	ld b,004h		;88bc
	ld de,0e087h		;88be
	ld hl,0e080h		;88c1   ; las cuatro cifras...
gasolina_copia:
	ld a,(hl)			;88c4   ; ...al reves...
	ld (de),a			;88c5   ; ...en 0xE084-0xE087
	inc hl			;88c6
	dec de			;88c7
	djnz gasolina_copia		;88c8
	ld bc,00400h		;88ca   ; los ceros de la izquierda (B = 4, C = 0)...
	xor a			;88cd
gasolina_ceros:
	cp (hl)			;88ce
	jr nz,gasolina_vram		;88cf
	ld (hl),c			;88d1   ; ...con C = 0: la casilla 0 es el mismo 0, asi que no cambia nada (el marcador ensena 057)
	inc hl			;88d2
	djnz gasolina_ceros		;88d3
gasolina_vram:		; Tres cifras en la fila 8, columna 27
	ld hl,0e085h		;88d5
	ld de,0191bh		;88d8   ; en la fila 8, columna 27
	ld bc,00003h		;88db
	jp 0005ch		;88de
disparo:		; El disparo (boton 1): sale hacia donde mira el coche, 4 pixeles por cuadro, hasta salir de la pantalla
	ld a,(ix+004h)		;88e1   ; ya hay disparo?
	and a			;88e4   ; si: vuela
	jp nz,disparo_vuela		;88e5
	ld a,(0e040h)		;88e8   ; el boton 1?
	and a			;88eb   ; pulsado?
	ret z			;88ec
	xor a			;88ed
	ld (0e040h),a		;88ee   ; ya visto
	ld a,(0e194h)		;88f1   ; parado no dispara
	cp 008h		;88f4   ; la velocidad: 8 o mas
	ret c			;88f6
	inc (ix+004h)		;88f7   ; hay disparo
	ld a,002h		;88fa   ; el sonido 2
	call efecto_pide		;88fc   ; el efecto 2
	ld a,(0e197h)		;88ff   ; hacia donde mira el coche
	ld (ix+005h),a		;8902   ; su direccion
	cp 002h		;8905   ; a la derecha?
	jr z,disparo_derecha		;8907
	ld a,(ix+001h)		;8909   ; la X - 8
	sub 008h		;890c
disparo_sale:		; El sprite del disparo (+0x20): delante del coche, dibujo 0x40, blanco
	ld (ix+021h),a		;890e
	ld a,(ix+000h)		;8911   ; la Y
	ld (ix+020h),a		;8914
	ld (ix+022h),040h		;8917   ; el dibujo 0x40
	ld (ix+023h),00fh		;891b   ; blanco
	ret			;891f
disparo_derecha:
	ld a,(ix+001h)		;8920   ; la X + 8
	add a,008h		;8923
	jr disparo_sale		;8925
disparo_vuela:		; Vuela en su direccion
	ld a,(ix+005h)		;8927   ; la direccion
	cp 004h		;892a
	jr z,disparo_izq		;892c   ; 4: a la izquierda
	cp 002h		;892e
	jr z,disparo_der		;8930   ; 2: a la derecha
	cp 003h		;8932
	jr z,disparo_abajo		;8934   ; 3: abajo
	jr disparo_arriba		;8936
disparo_arriba:
	ld a,(ix+020h)		;8938   ; 1: arriba, 4 pixeles
	sub 004h		;893b
disparo_y:
	ld (ix+020h),a		;893d
	jr disparo_fuera		;8940
disparo_der:
	ld a,(ix+021h)		;8942   ; a la derecha, 4 pixeles
	add a,004h		;8945
	jr disparo_x		;8947
disparo_abajo:
	ld a,(ix+020h)		;8949   ; abajo
	add a,004h		;894c
	jr disparo_y		;894e
disparo_izq:
	ld a,(ix+021h)		;8950   ; a la izquierda
	sub 004h		;8953
disparo_x:
	ld (ix+021h),a		;8955
disparo_fuera:		; Fuera de la pantalla?
	ld a,(ix+020h)		;8958   ; la Y dentro (8-0xBF)?
	cp 008h		;895b
	jr c,disparo_acaba		;895d
	cp 0c0h		;895f
	jr nc,disparo_acaba		;8961
	ld a,(ix+021h)		;8963   ; la X dentro (4-0xBF)?
	cp 004h		;8966
	jr c,disparo_acaba		;8968
	cp 0c0h		;896a
	jr nc,disparo_acaba		;896c
	ret			;896e
disparo_acaba:
	xor a			;896f   ; sin disparo
	ld (ix+004h),a		;8970
	ld (ix+020h),0f0h		;8973   ; el sprite, fuera
	ret			;8977
bomba:		; La bomba (boton 2): una menos de BOMB, el sonido 3, sale hacia donde mira y a los 32 cuadros estalla (el sonido 7)
	ld a,(ix+006h)		;8978   ; hay bomba?
	and a			;897b
	jp nz,bomba_vuela		;897c
	ld a,(0e041h)		;897f   ; el boton 2?
	and a			;8982   ; pulsado?
	ret z			;8983
	xor a			;8984
	ld (0e041h),a		;8985   ; ya visto
	ld a,(0e194h)		;8988   ; parado no tira
	cp 008h		;898b   ; la velocidad: 8 o mas
	ret c			;898d
	ld a,(ix+00ch)		;898e   ; quedan bombas?
	and a			;8991   ; quedan?
	ret z			;8992
	sub 001h		;8993   ; una menos (BCD)
	daa			;8995   ; (BCD)
	ld (ix+00ch),a		;8996
	call bombas_pinta		;8999   ; en el marcador
	ld a,003h		;899c   ; el sonido 3
	call efecto_pide		;899e
	inc (ix+006h)		;89a1   ; hay bomba
	ld a,(0e197h)		;89a4   ; su direccion
	ld (ix+007h),a		;89a7
	cp 002h		;89aa   ; a la derecha?
	jr z,bomba_derecha		;89ac
	cp 004h		;89ae   ; a la izquierda?
	jr nz,bomba_sale		;89b0
	ld (ix+009h),002h		;89b2   ; marca 2: la izquierda
	jr bomba_sale		;89b6
bomba_derecha:
	ld (ix+009h),001h		;89b8   ; marca 1: la derecha
bomba_sale:		; El sprite de la bomba (+0x30): dibujo 0x44, negro
	ld a,(ix+001h)		;89bc   ; la X y la Y del coche
	ld (ix+031h),a		;89bf
	ld a,(ix+000h)		;89c2
	ld (ix+030h),a		;89c5
	ld (ix+032h),044h		;89c8   ; el dibujo 0x44
	ld (ix+033h),001h		;89cc   ; negro
	ret			;89d0
bomba_vuela:		; Vuela, 2 pixeles por cuadro
	ld b,a			;89d1
	xor a			;89d2
	ld (0e041h),a		;89d3   ; el boton, visto
	ld a,b			;89d6
	cp 001h		;89d7   ; estallando?
	jp nz,bomba_estallido		;89d9
	ld b,002h		;89dc   ; 2 pixeles
	ld a,(ix+007h)		;89de   ; su direccion
	cp 004h		;89e1
	jr z,bomba_izq		;89e3
	cp 003h		;89e5
	jr z,bomba_abajo		;89e7
	cp 002h		;89e9
	jr z,bomba_der		;89eb
	ld a,(ix+030h)		;89ed   ; arriba
	sub b			;89f0
	jr bomba_y		;89f1
bomba_der:
	add a,(ix+031h)		;89f3   ; a la derecha
	jr bomba_x		;89f6
bomba_abajo:
	ld a,(ix+030h)		;89f8   ; abajo
	add a,b			;89fb
bomba_y:
	ld (ix+030h),a		;89fc
	jr bomba_cuenta		;89ff
bomba_izq:
	ld a,(ix+031h)		;8a01   ; a la izquierda
	sub b			;8a04
bomba_x:
	ld (ix+031h),a		;8a05
bomba_cuenta:		; Dentro de la pantalla: la cuenta; entre 32 y 47, estalla
	ld a,(ix+031h)		;8a08   ; dentro de la pantalla?
	cp 004h		;8a0b
	jr c,bomba_acaba		;8a0d
	cp 0c0h		;8a0f
	jr nc,bomba_acaba		;8a11
	ld a,(ix+030h)		;8a13
	cp 0c0h		;8a16
	jr nc,bomba_acaba		;8a18
	inc (ix+008h)		;8a1a   ; la cuenta
	ld a,(ix+008h)		;8a1d
	cp 020h		;8a20   ; menos de 32: sigue
	ret c			;8a22
	cp 030h		;8a23   ; 48: se acaba
	jr nc,bomba_acaba		;8a25
	ld a,(ix+006h)		;8a27   ; ya estalla?
	cp 002h		;8a2a
	jr z,bomba_estalla		;8a2c
	ld a,007h		;8a2e   ; el sonido 7
	call efecto_pide		;8a30   ; el efecto 7
bomba_estalla:		; Estallando: color 6
	ld (ix+006h),002h		;8a33
	ld (ix+033h),006h		;8a37
	ret			;8a3b
bomba_acaba:
	ld (ix+030h),0f0h		;8a3c   ; el sprite fuera...
	xor a			;8a40   ; ...y todo a cero
	ld (ix+006h),a		;8a41
	ld (ix+008h),a		;8a44
	ld (ix+009h),a		;8a47
	ret			;8a4a
bomba_estallido:		; El dibujo del estallido, cambia cada 4 cuadros
	ld a,(0e01fh)		;8a4b   ; cada 4 cuadros...
	and 004h		;8a4e
	add a,034h		;8a50   ; ...el dibujo 0x34 o 0x38
	ld (ix+032h),a		;8a52
	jr bomba_cuenta		;8a55
coche_mueve:		; El coche: el rebote de los bordes, la palanca (0xE180: 1-8) gira y lo mueve a los lados
	ld a,(ix+00ah)		;8a57   ; un rebote?
	and a			;8a5a
	jr z,coche_palanca		;8a5b
	ld a,(ix+00ah)		;8a5d   ; un pixel a un lado
	add a,(ix+001h)		;8a60
	ld (ix+001h),a		;8a63
	ld (ix+011h),a		;8a66
	inc (ix+00bh)		;8a69   ; 8 cuadros
	ld a,(ix+00bh)		;8a6c
	cp 008h		;8a6f
	jr c,coche_armas		;8a71
	xor a			;8a73   ; se acaba
	ld (ix+00ah),a		;8a74
	ld (ix+00bh),a		;8a77
coche_armas:		; El disparo y la bomba
	call disparo		;8a7a
	jp bomba		;8a7d
coche_palanca:
	call coche_armas		;8a80
	ld a,(0e183h)		;8a83   ; sin gasolina?
	cp 003h		;8a86
	jr nz,coche_direccion		;8a88
	call frena		;8a8a   ; frena
	call frena		;8a8d
coche_direccion:		; Segun la palanca
	ld a,(0e180h)		;8a90   ; la palanca
	and a			;8a93
	jp z,coche_suelta		;8a94
	cp 001h		;8a97   ; 1: arriba
	jr z,coche_arriba		;8a99
	cp 002h		;8a9b   ; 2: arriba y derecha
	jr z,coche_dir2		;8a9d
	cp 003h		;8a9f   ; 3: derecha
	jr z,coche_dir3		;8aa1
	cp 004h		;8aa3   ; 4: abajo y derecha
	jr z,coche_dir4		;8aa5
	cp 005h		;8aa7   ; 5: abajo
	jr z,coche_abajo		;8aa9
	cp 006h		;8aab   ; 6: abajo e izquierda
	jr z,coche_dir6		;8aad
	cp 007h		;8aaf   ; 7: izquierda
	jr z,coche_dir7		;8ab1
	call coche_a_izquierda		;8ab3   ; 8: arriba e izquierda
	jr coche_arriba		;8ab6
coche_dir7:
	call coche_a_izquierda		;8ab8
	jr coche_izquierda		;8abb
coche_dir6:
	call coche_a_izquierda		;8abd
	jr coche_abajo		;8ac0
coche_dir4:
	call coche_a_derecha		;8ac2
	jr coche_abajo		;8ac5
coche_dir3:
	call coche_a_derecha		;8ac7
	jr coche_derecha		;8aca
coche_dir2:
	call coche_a_derecha		;8acc
	jr coche_arriba		;8acf
coche_a_derecha:		; Un pixel a la derecha (hasta X 0xAC), si toca
	call paso_lado		;8ad1   ; toca?
	and a			;8ad4
	ret z			;8ad5
	ld a,(ix+001h)		;8ad6   ; el borde derecho?
	cp 0ach		;8ad9
	ret nc			;8adb
	inc (ix+001h)		;8adc   ; un pixel a la derecha
	ret			;8adf
coche_a_izquierda:		; Un pixel a la izquierda (desde X 4), si toca
	call paso_lado		;8ae0   ; toca?
	and a			;8ae3
	ret z			;8ae4
	ld a,(ix+001h)		;8ae5   ; el borde izquierdo?
	cp 004h		;8ae8
	ret c			;8aea
	dec (ix+001h)		;8aeb   ; un pixel a la izquierda
	ret			;8aee
coche_arriba:		; Arriba: acelera (un cuadro de cada dos) y mira hacia arriba, el dibujo 0
	ld a,001h		;8aef
	ld (0e1c3h),a		;8af1   ; el motor
	ld hl,0e193h		;8af4   ; un cuadro de cada dos...
	inc (hl)			;8af7
	ld a,(hl)			;8af8
	cp 002h		;8af9
	jr c,coche_arriba_va		;8afb
	call acelera		;8afd   ; ...acelera
coche_arriba_va:
	xor a			;8b00
	ld (ix+002h),a		;8b01   ; el dibujo 0
	inc a			;8b04
	jr coche_mira		;8b05
coche_derecha:		; Mira a la derecha: el dibujo 8
	ld (ix+002h),008h		;8b07
	ld a,002h		;8b0b
	jr coche_mira		;8b0d
coche_abajo:		; Abajo: frena dos veces y mira hacia abajo, el dibujo 0x0C
	ld a,002h		;8b0f
	ld (0e1c3h),a		;8b11   ; el motor
	call frena		;8b14   ; frena dos veces
	call frena		;8b17
	ld (ix+002h),00ch		;8b1a   ; el dibujo 0x0C
	ld a,003h		;8b1e
	jr coche_mira		;8b20
coche_izquierda:		; Mira a la izquierda: el dibujo 0x10
	ld (ix+002h),010h		;8b22
	ld a,004h		;8b26
	jr coche_mira		;8b28
coche_suelta:		; Sin palanca: 0xE1C3 = 3 y la velocidad baja una vez
	ld a,003h		;8b2a
	ld (0e1c3h),a		;8b2c   ; el motor
	call frena		;8b2f   ; frena
	jr coche_y		;8b32
coche_mira:		; A donde mira (0xE197)
	ld (0e197h),a		;8b34
coche_y:		; La Y del coche segun la velocidad (0x60 + velocidad / 8)
	ld (ix+012h),004h		;8b37   ; el segundo sprite: dibujo 4
	ld a,(0e194h)		;8b3b   ; la velocidad / 8...
	call entre8		;8b3e
	add a,060h		;8b41   ; ...+ 0x60: la Y (mas abajo cuanto mas corre)
	ld (ix+000h),a		;8b43
	ld (ix+010h),a		;8b46
	ld a,(ix+001h)		;8b49   ; la X
	ld (ix+011h),a		;8b4c
velocidad_pinta:		; La velocidad (0xE190-0xE192, tres cifras) en la fila 12, columna 26
	ld hl,0e190h		;8b4f
	ld de,0199ah		;8b52   ; en la fila 12, columna 26
	ld bc,00003h		;8b55
	jp 0005ch		;8b58
bombas_pinta:		; Las bombas que quedan (BCD) en la fila 5, columna 30
	ld a,(ix+00ch)		;8b5b   ; las bombas (BCD)
	ld b,a			;8b5e
	and 0f0h		;8b5f   ; las decenas
	rrca			;8b61   ; las decenas abajo
	rrca			;8b62
	rrca			;8b63
	rrca			;8b64
	ld hl,018beh		;8b65   ; en la fila 5, columna 30
	call 0004dh		;8b68
	ld a,b			;8b6b   ; las unidades
	and 00fh		;8b6c   ; las unidades
	inc hl			;8b6e
	call 0004dh		;8b6f
	ret			;8b72
frena:		; La velocidad baja: las cifras (0xE190-0xE192) y el binario (0xE194); el tono del motor (0xE1C4) baja
	ld hl,0e192h		;8b73   ; las unidades...
	xor a			;8b76
	cp (hl)			;8b77   ; las unidades a 0?
	jr nz,frena_unidad		;8b78
	dec hl			;8b7a   ; ...las decenas...
	cp (hl)			;8b7b   ; las decenas?
	jr nz,frena_decena		;8b7c
	dec hl			;8b7e   ; ...las centenas: parado?
	cp (hl)			;8b7f   ; las centenas: parado
	jr nz,frena_centena		;8b80
	ret			;8b82
frena_unidad:
	dec (hl)			;8b83   ; una unidad menos
frena_binario:
	ld hl,0e194h		;8b84   ; y en binario
	dec (hl)			;8b87
	ld a,(0e1c2h)		;8b88   ; el motor de antes...
	ld b,a			;8b8b
	ld a,(0e1c3h)		;8b8c   ; ...y el de ahora...
	cp b			;8b8f   ; ...iguales?
	jr z,frena_tono		;8b90
	cp 003h		;8b92   ; 3 (soltado): tampoco
	jr z,frena_tono		;8b94
	ld (0e1c2h),a		;8b96   ; ha cambiado: el tono...
	ld hl,(0e1c4h)		;8b99
	ld de,0ff80h		;8b9c   ; ...baja 0x80 de golpe
	add hl,de			;8b9f
	ld (0e1c4h),hl		;8ba0
frena_tono:
	ld hl,(0e1c4h)		;8ba3   ; el tono...
	ld a,h			;8ba6
	cp 002h		;8ba7   ; ...desde 0x2C0 no sube
	jr c,frena_tono_pon		;8ba9
	ld a,l			;8bab
	cp 0c0h		;8bac
	jr c,frena_tono_pon		;8bae
	inc hl			;8bb0   ; +3 (mas grave)
frena_tono_pon:
	inc hl			;8bb1
	inc hl			;8bb2
	ld (0e1c4h),hl		;8bb3
	ret			;8bb6
frena_decena:
	dec (hl)			;8bb7   ; una decena menos...
	inc hl			;8bb8
	ld (hl),009h		;8bb9   ; ...unidades a 9
	jr frena_binario		;8bbb
frena_centena:
	dec (hl)			;8bbd   ; una centena menos...
	inc hl			;8bbe
	ld a,009h		;8bbf
	ld (hl),a			;8bc1   ; ...las otras a 9
	inc hl			;8bc2
	ld (hl),a			;8bc3
	jr frena_binario		;8bc4
acelera:		; La velocidad sube: mas despacio cuanto mas corre; con el coche girado no pasa de 240; el tono del motor sube
	ld a,(0e183h)		;8bc6   ; chocando no
	and a			;8bc9
	ret nz			;8bca
	ld a,(0e194h)		;8bcb   ; la velocidad / 32...
	and 0e0h		;8bce
	rlca			;8bd0
	rlca			;8bd1
	rlca			;8bd2
	ld b,a			;8bd3   ; ...los cuadros entre cada paso
	ld a,(0e195h)		;8bd4   ; la cuenta
	inc a			;8bd7
	ld (0e195h),a		;8bd8
	cp b			;8bdb   ; aun no
	ret c			;8bdc
	xor a			;8bdd
	ld (0e195h),a		;8bde
	ld a,(0e190h)		;8be1   ; 200 o mas...
	cp 002h		;8be4
	jr c,acelera_va		;8be6
	ld a,(0e191h)		;8be8   ; ...y 240?: tope
	cp 004h		;8beb
	ret nc			;8bed
acelera_va:
	ld hl,0e194h		;8bee   ; uno mas en binario
	inc (hl)			;8bf1
	ld hl,0e192h		;8bf2   ; las unidades
	ld a,009h		;8bf5
	cp (hl)			;8bf7   ; 9?
	jr nz,acelera_cifra		;8bf8
	ld (hl),000h		;8bfa   ; 0 y las decenas
	dec hl			;8bfc
	cp (hl)			;8bfd
	jr nz,acelera_cifra		;8bfe
	ld (hl),000h		;8c00   ; 0 y las centenas
	dec hl			;8c02
acelera_cifra:
	inc (hl)			;8c03   ; una mas
	ld a,(0e1c2h)		;8c04   ; el motor ha cambiado?
	ld b,a			;8c07
	ld a,(0e1c3h)		;8c08
	cp b			;8c0b
	jr z,acelera_tono		;8c0c
	ld (0e1c2h),a		;8c0e
	ld hl,(0e1c4h)		;8c11   ; el tono 0x80 mas
	ld de,00080h		;8c14
	add hl,de			;8c17
	ld (0e1c4h),hl		;8c18
acelera_tono:
	ld hl,(0e1c4h)		;8c1b   ; el tono...
	ld a,h			;8c1e
	cp 003h		;8c1f   ; ...hasta 0x300...
	jr c,acelera_tono_pon		;8c21
	dec hl			;8c23   ; ...-3 (mas agudo)
acelera_tono_pon:
	dec hl			;8c24
	dec hl			;8c25
	ld (0e1c4h),hl		;8c26
	ret			;8c29
paso_lado:		; NZ cada tantos cuadros segun la velocidad: el coche se mueve a los lados mas deprisa cuanto mas corre
	ld a,(0e194h)		;8c2a   ; parado?
	and a			;8c2d
	jr z,paso_lado_no		;8c2e
	and 0c0h		;8c30   ; la velocidad / 64
	rlca			;8c32
	rlca			;8c33
	ld b,a			;8c34
	ld a,003h		;8c35   ; 3 menos eso: cada cuantos cuadros
	sub b			;8c37
	ld hl,0e196h		;8c38
	inc (hl)			;8c3b   ; la cuenta
	cp (hl)			;8c3c
	jr nc,paso_lado_no		;8c3d
	xor a			;8c3f   ; toca: NZ
	ld (hl),a			;8c40
	inc a			;8c41
	ret			;8c42
paso_lado_no:
	xor a			;8c43
	ret			;8c44
avance:		; La carretera avanza: cada tantos cuadros segun la velocidad, una fila nueva, un punto y la distancia (0xE19C)
	ld hl,0e19bh		;8c45   ; la cuenta de avance
	inc (hl)			;8c48
	ld b,(hl)			;8c49
	ld a,(0e194h)		;8c4a   ; la velocidad: mas de 0xCC, cada cuadro; luego 0xBC, 0xAC, 0x9C...
	cp 09ch		;8c4d
	jr c,avance_lento		;8c4f
	cp 0ach		;8c51
	jr c,avance_4		;8c53
	cp 0bch		;8c55
	jr c,avance_3		;8c57
	cp 0cch		;8c59
	jr c,avance_2		;8c5b
	jr avance_punto		;8c5d
avance_2:
	ld a,b			;8c5f   ; a 0xBC-0xCB: dos de cada tres cuadros
	cp 001h		;8c60
	jr z,avance_punto		;8c62
	cp 003h		;8c64
	ret c			;8c66
	jr avance_fila		;8c67
avance_3:
	ld a,b			;8c69   ; a 0xAC-0xBB: tres de cada cinco
	cp 001h		;8c6a
	jr z,avance_punto		;8c6c
	cp 003h		;8c6e
	ret c			;8c70
	jr z,avance_punto		;8c71
	cp 005h		;8c73
	ret c			;8c75
	jr avance_fila		;8c76
avance_4:
	ld a,b			;8c78   ; a 0x9C-0xAB: uno de cada dos
	cp 002h		;8c79
	ret c			;8c7b
	jr avance_fila		;8c7c
avance_lento:
	cp 088h		;8c7e   ; mas despacio: cada 2 a 7 cuadros
	jr nc,avance_5		;8c80
	cp 060h		;8c82   ; 0x60-0x87: cada 3
	jr nc,avance_6		;8c84
	cp 048h		;8c86
	jr nc,avance_7		;8c88
	cp 02ch		;8c8a
	jr nc,avance_8		;8c8c
	cp 018h		;8c8e
	jr nc,avance_9		;8c90
	and a			;8c92   ; parado: nada
	ret z			;8c93
	jr avance_10		;8c94
avance_5:
	ld a,b			;8c96   ; cada 2 o 5
	cp 002h		;8c97
	jr z,avance_punto		;8c99
	cp 005h		;8c9b
	ret c			;8c9d
	jr avance_fila		;8c9e
avance_6:
	ld a,b			;8ca0
	cp 003h		;8ca1
	ret c			;8ca3
	jr avance_fila		;8ca4
avance_7:
	ld a,b			;8ca6
	cp 004h		;8ca7
	ret c			;8ca9
	jr avance_fila		;8caa
avance_8:
	ld a,b			;8cac
	cp 005h		;8cad
	ret c			;8caf
	jr avance_fila		;8cb0
avance_9:
	ld a,b			;8cb2
	cp 006h		;8cb3
	ret c			;8cb5
	jr avance_fila		;8cb6
avance_10:
	ld a,b			;8cb8
	cp 007h		;8cb9
	ret c			;8cbb
avance_fila:
	xor a			;8cbc   ; la cuenta a 0
	ld (0e19bh),a		;8cbd
avance_punto:		; Un punto, salvo en la demostracion
	ld a,(0e000h)		;8cc0   ; la demostracion no puntua
	and a			;8cc3
	jr z,avance_distancia		;8cc4
	ld a,001h		;8cc6   ; un punto
	call puntos		;8cc8
avance_distancia:		; La distancia, uno mas; la bomba baja con la carretera
	ld hl,(0e19ch)		;8ccb   ; la distancia, uno mas
	inc hl			;8cce
	ld (0e19ch),hl		;8ccf
	ld a,(ix+009h)		;8cd2   ; la bomba hacia abajo?
	and a			;8cd5
	jr z,avance_coches		;8cd6
	ld a,(ix+030h)		;8cd8   ; baja 8 con la carretera
	add a,008h		;8cdb
	ld (ix+030h),a		;8cdd
avance_coches:		; Los diez coches bajan con la carretera
	ld b,00ah		;8ce0   ; diez coches
	ld iy,0e345h		;8ce2   ; desde el estado del primero
avance_coche:
	push bc			;8ce6
	call coche_baja		;8ce7   ; baja
	pop bc			;8cea
	ld de,00020h		;8ceb
	add iy,de		;8cee
	djnz avance_coche		;8cf0
fila_nueva:		; Una fila nueva de la carretera (0xE800): la de la zona, la orilla del mar de la zona 2, y los tramos de 0xE188, 0xE1A8 y 0xE1B0
	ld a,(0e00ah)		;8cf2   ; la zona 2?
	cp 002h		;8cf5
	jr z,fila_costa		;8cf7
	ld hl,0e1bah		;8cf9   ; una fila de cada dos...
	inc (hl)			;8cfc
	bit 0,(hl)		;8cfd
	jr nz,fila_otra		;8cff
	ld hl,0e600h		;8d01   ; ...la de 0xE600...
fila_copia:
	ld de,0e800h		;8d04   ; ...a la fila nueva (0xE800)
	ld bc,00018h		;8d07   ; 24 casillas
	ldir		;8d0a
	jr fila_tramo1		;8d0c
fila_otra:		; Una fila si y otra no
	ld hl,0e618h		;8d0e   ; ...o la de 0xE618
	jr fila_copia		;8d11
fila_costa:		; La zona 2: la arena (0x6D) y 5 casillas de la orilla y el mar (0x939D, 27 pasos)
	ld hl,0e800h		;8d13   ; la fila nueva...
	ld b,018h		;8d16
fila_costa_arena:
	ld (hl),06dh		;8d18   ; ...toda de arena (0x6D, del color de la zona)
	inc hl			;8d1a
	djnz fila_costa_arena		;8d1b
	ld hl,0939dh		;8d1d   ; la orilla
	ld a,(0e1b9h)		;8d20   ; el paso...
	inc a			;8d23
	ld (0e1b9h),a		;8d24
	cp 01bh		;8d27   ; ...de 0 a 26
	jr c,fila_costa_paso		;8d29
	xor a			;8d2b
	ld (0e1b9h),a		;8d2c
fila_costa_paso:
	ld b,a			;8d2f
	inc b			;8d30
	xor a			;8d31   ; x 5
fila_costa_x5:
	add a,005h		;8d32
	djnz fila_costa_x5		;8d34
	add a,l			;8d36
	jr nc,fila_costa_pon		;8d37
	inc h			;8d39
fila_costa_pon:
	ld l,a			;8d3a
	ld de,0e813h		;8d3b   ; en la columna 19
	ld bc,00005h		;8d3e   ; 5 casillas
	ldir		;8d41
fila_tramo1:		; El primer tramo (0xE188): casillas que se copian; cuando se acaba, el siguiente (0x8E5F)
	ld a,(0e18ah)		;8d43   ; el primer tramo: una espera?
	cp 0feh		;8d46
	jr nz,fila_tramo1_va		;8d48
	ld hl,0e18bh		;8d4a   ; una fila menos de espera
	dec (hl)			;8d4d
	jr nz,fila_tramo2		;8d4e
	call tramo1_sig		;8d50   ; el siguiente
	jr fila_tramo2		;8d53
fila_tramo1_va:
	ld hl,(0e188h)		;8d55   ; las casillas del tramo...
	ld a,(0e18ah)		;8d58   ; ...en la columna (0xE18A)...
	ld d,0e8h		;8d5b
	ld e,a			;8d5d
	ld a,(0e18bh)		;8d5e   ; ...cuantas (0xE18B)
	ld c,a			;8d61
	ld b,000h		;8d62
	ldir		;8d64
	ld (0e188h),hl		;8d66   ; la fila siguiente del dibujo
	ld hl,0e18ch		;8d69   ; una fila menos
	dec (hl)			;8d6c
	jr nz,fila_tramo2		;8d6d
	ld a,(0e18fh)		;8d6f   ; repeticiones?
	and a			;8d72
	jr z,fila_tramo1_sig		;8d73
	dec a			;8d75   ; una menos
	ld (0e18fh),a		;8d76
	ld hl,(0e1bbh)		;8d79   ; otra vez desde el principio del dibujo
	ld (0e188h),hl		;8d7c
	ld hl,(0e1bdh)		;8d7f
	ld (0e18bh),hl		;8d82
	jr nz,fila_tramo2		;8d85
fila_tramo1_sig:
	call tramo1_sig		;8d87
fila_tramo2:		; El segundo (0xE1A8), ocho filas de cada dibujo; cuando se acaba, el siguiente (0x8EB2)
	ld hl,(0e1ach)		;8d8a   ; el segundo tramo: el dibujo...
	ld a,(0e1b6h)		;8d8d   ; ...el paso (0-7)...
	call tabla_zona_suma		;8d90
	ex de,hl			;8d93
	ld a,(0e1a8h)		;8d94   ; ...en su columna...
	ld e,a			;8d97
	ld d,0e8h		;8d98
	ld a,(0e1abh)		;8d9a   ; ...cuantas
	ld c,a			;8d9d
	ld b,000h		;8d9e
	ldir		;8da0
	ld a,(0e1b6h)		;8da2   ; el paso siguiente
	inc a			;8da5
	ld (0e1b6h),a		;8da6
	cp 008h		;8da9   ; 8: la columna se mueve
	jr c,fila_tramo3		;8dab
	xor a			;8dad
	ld (0e1b6h),a		;8dae
	ld a,(0e1a8h)		;8db1   ; la columna...
	ld b,a			;8db4
	ld a,(0e1aah)		;8db5   ; ...+ el desplazamiento
	add a,b			;8db8
	ld (0e1a8h),a		;8db9
	ld a,(0e1a9h)		;8dbc   ; una vez menos
	dec a			;8dbf
	ld (0e1a9h),a		;8dc0
	jr nz,fila_tramo3		;8dc3
	call tramo2_sig		;8dc5   ; el siguiente
fila_tramo3:		; El tercero (0xE1B0), hacia atras; cuando se acaba, el siguiente (0x8EDD)
	ld hl,(0e1b4h)		;8dc8   ; el tercer tramo
	ld a,(0e1b7h)		;8dcb
	call tabla_zona_suma		;8dce
	ex de,hl			;8dd1
	ld a,(0e1b0h)		;8dd2   ; su columna (el final)
	ld e,a			;8dd5
	ld d,0e8h		;8dd6
	ld a,(0e1b3h)		;8dd8
	ld c,a			;8ddb
	ld b,000h		;8ddc
	lddr		;8dde   ; hacia atras
	ld a,(0e1b7h)		;8de0   ; el paso siguiente
	inc a			;8de3
	ld (0e1b7h),a		;8de4
	cp 008h		;8de7
	jr c,carretera_vram		;8de9
	xor a			;8deb
	ld (0e1b7h),a		;8dec
	ld a,(0e1b0h)		;8def   ; la columna se mueve
	ld b,a			;8df2
	ld a,(0e1b2h)		;8df3
	add a,b			;8df6
	ld (0e1b0h),a		;8df7
	ld a,(0e1b1h)		;8dfa   ; una vez menos
	dec a			;8dfd
	ld (0e1b1h),a		;8dfe
	jr nz,carretera_vram		;8e01
	call tramo3_sig		;8e03   ; el siguiente
carretera_vram:		; La carretera a la pantalla: la fila nueva entra arriba en el anillo de 0xE8C0 y las 24 filas van a la tabla de nombres por el puerto del VDP
	ld a,(00006h)		;8e06   ; el puerto del VDP: la BIOS lo dice en 0x0006...
	inc a			;8e09   ; ...mas 1: el de control
	ld c,a			;8e0a   ; C = el puerto de control
	xor a			;8e0b   ; 0x00...
	out (c),a		;8e0c   ; la direccion 0x1800, para escribir (0x58)
	ld a,058h		;8e0e   ; ...y 0x58: escribir en 0x1800
	out (c),a		;8e10
	ld hl,(0e186h)		;8e12   ; el anillo, una fila arriba
	ld bc,0ffe8h		;8e15   ; 24 bytes menos
	add hl,bc			;8e18
	ld (0e186h),hl		;8e19
	ld bc,0e8a8h		;8e1c   ; da la vuelta?
	and a			;8e1f   ; 0xE8A8?
	sbc hl,bc		;8e20
	jr nz,L_8E2A		;8e22
	ld hl,0eae8h		;8e24   ; al final del anillo
	ld (0e186h),hl		;8e27
L_8E2A:
	ld de,(0e186h)		;8e2a   ; la fila nueva, arriba del anillo
	ld hl,0e800h		;8e2e   ; la fila nueva...
	ld bc,00018h		;8e31   ; ...24 casillas
	ldir		;8e34
	ld hl,01801h		;8e36   ; desde la fila 0, columna 1
	ld a,018h		;8e39   ; 24 filas
	ld de,(0e186h)		;8e3b   ; desde la fila de arriba
carretera_fila_vram:		; Una fila: SETWRT y 24 bytes por el puerto
	ex af,af'			;8e3f
	call 00053h		;8e40   ; SETWRT
	ld a,(00006h)		;8e43   ; el puerto de datos
	ld c,a			;8e46   ; C = el puerto de datos
	ld b,018h		;8e47   ; 24 casillas
carretera_byte:
	ld a,(de)			;8e49
	out (c),a		;8e4a   ; una al VDP
	inc de			;8e4c
	djnz carretera_byte		;8e4d
	ld a,d			;8e4f   ; se sale del anillo?
	cp 0ebh		;8e50   ; 0xEB00?
	jr nz,carretera_vram_sig		;8e52
	ld de,0e8c0h		;8e54   ; al principio del anillo
carretera_vram_sig:		; La fila siguiente de la pantalla
	ld c,020h		;8e57   ; la fila siguiente de la pantalla
	add hl,bc			;8e59
	ex af,af'			;8e5a
	dec a			;8e5b   ; las 24
	jr nz,carretera_fila_vram		;8e5c
	ret			;8e5e
tramo1_sig:		; El tramo siguiente de la lista de la zona (0xE18D): 0xFE una espera, 0xFF vuelve al principio, 0xE0-0xFD con repeticiones; si no, la columna y el dibujo
	ld hl,(0e18dh)		;8e5f   ; la lista
	ld a,(hl)			;8e62   ; el byte
	ld (0e18ah),a		;8e63
	cp 0e0h		;8e66   ; 0xE0 o mas: una orden
	jr c,tramo1_dibujo		;8e68
	cp 0feh		;8e6a
	jr z,tramo1_espera		;8e6c
	cp 0ffh		;8e6e
	jr z,tramo1_vuelta		;8e70
	and 00fh		;8e72   ; las repeticiones
	ld (0e18fh),a		;8e74   ; las repeticiones
	inc hl			;8e77
	ld a,(hl)			;8e78   ; la columna
	ld (0e18ah),a		;8e79
tramo1_dibujo:		; El dibujo: cuantas casillas, cuantas filas y desde donde
	inc hl			;8e7c
	ld e,(hl)			;8e7d   ; el dibujo
	inc hl			;8e7e
	ld d,(hl)			;8e7f
	inc hl			;8e80
	ld (0e18dh),hl		;8e81   ; la lista avanza
	ex de,hl			;8e84
	ld a,(hl)			;8e85   ; cuantas casillas...
	ld (0e18bh),a		;8e86
	inc hl			;8e89
	ld a,(hl)			;8e8a   ; ...cuantas filas
	ld (0e18ch),a		;8e8b
	inc hl			;8e8e
	ld (0e188h),hl		;8e8f   ; el dibujo...
	ld (0e1bbh),hl		;8e92   ; ...y su copia para repetirlo
	ld hl,(0e18bh)		;8e95
	ld (0e1bdh),hl		;8e98
	ret			;8e9b
tramo1_espera:		; 0xFE: filas sin nada
	inc hl			;8e9c
	ld a,(hl)			;8e9d   ; las filas de espera
	ld (0e18bh),a		;8e9e
	inc hl			;8ea1
	ld (0e18dh),hl		;8ea2
	ret			;8ea5
tramo1_vuelta:		; 0xFF: otra vez desde el principio (0x9DAB)
	ld hl,09dabh		;8ea6   ; la lista de la zona
	call tabla_zona		;8ea9
	ld (0e18dh),de		;8eac
	jr tramo1_sig		;8eb0
tramo2_sig:		; El tramo siguiente de la segunda lista (0xE1A6): 6 bytes; 0xFF al principio, 0xFE salta
	ld hl,(0e1a6h)		;8eb2
	ld a,(hl)			;8eb5   ; el byte
	cp 0ffh		;8eb6
	jr z,tramo2_vuelta		;8eb8
	cp 0feh		;8eba
	jr z,tramo2_salta		;8ebc
tramo2_copia:
	ld de,0e1a8h		;8ebe   ; seis bytes...
	ld bc,00006h		;8ec1   ; ...a 0xE1A8
	ldir		;8ec4
	ld (0e1a6h),hl		;8ec6
	ret			;8ec9
tramo2_vuelta:
	ld hl,09dbbh		;8eca   ; la lista de la zona
	call tabla_zona		;8ecd
	ld (0e1a6h),de		;8ed0
	jr tramo2_sig		;8ed4
tramo2_salta:
	inc hl			;8ed6
	ld e,(hl)			;8ed7   ; la direccion
	inc hl			;8ed8
	ld d,(hl)			;8ed9
	ex de,hl			;8eda
	jr tramo2_copia		;8edb
tramo3_sig:		; Lo mismo con la tercera lista (0xE1AE)
	ld hl,(0e1aeh)		;8edd
	ld a,(hl)			;8ee0   ; el byte
	cp 0ffh		;8ee1
	jr z,tramo3_vuelta		;8ee3
	cp 0feh		;8ee5
	jr z,tramo3_salta		;8ee7
tramo3_copia:
	ld de,0e1b0h		;8ee9   ; seis bytes...
	ld bc,00006h		;8eec   ; ...a 0xE1B0
	ldir		;8eef
	ld (0e1aeh),hl		;8ef1
	ret			;8ef4
tramo3_vuelta:
	ld hl,09dcbh		;8ef5   ; la lista de la zona
	call tabla_zona		;8ef8
	ld (0e1aeh),de		;8efb
	jr tramo3_sig		;8eff
tramo3_salta:
	inc hl			;8f01
	ld e,(hl)			;8f02   ; la direccion
	inc hl			;8f03
	ld d,(hl)			;8f04
	ex de,hl			;8f05
	jr tramo3_copia		;8f06
coche_baja:		; Un coche en el estado 2 baja 8 pixeles con la carretera
	ld a,002h		;8f08   ; estado 2?
	cp (iy+000h)		;8f0a
	ret nz			;8f0d
	ld a,008h		;8f0e   ; 8 pixeles mas abajo...
	add a,(iy-005h)		;8f10   ; ...su Y (5 bytes antes del estado)
	ld (iy-005h),a		;8f13
	ret			;8f16
gasolina_llena:		; La gasolina a 100 y su copia
	xor a			;8f17   ; la copia y la gasolina a 0...
	ld (0e087h),a		;8f18
	ld (0e086h),a		;8f1b
	ld (0e085h),a		;8f1e
	ld (0e080h),a		;8f21
	ld (0e081h),a		;8f24
	ld (0e082h),a		;8f27
	inc a			;8f2a   ; ...y las centenas a 1: 100
	ld (0e085h),a		;8f2b
	ld (0e082h),a		;8f2e
	ret			;8f31
zona_pinta:		; El numero de la zona en la fila 15, columna 29
	ld a,(0e00ah)		;8f32   ; la zona...
	ld hl,019ddh		;8f35   ; ...en la fila 15, columna 29
	jp 0004dh		;8f38
ram_sprites:		; 0xE100-0xF07F a cero y los 32 sprites (de 16 bytes, desde 0xE300) a Y = 0xF0
	ld hl,0e100h		;8f3b   ; 0xE100...
	ld bc,00f80h		;8f3e   ; ...0xF80 bytes
ram_sprites_borra:
	ld (hl),000h		;8f41   ; a cero
	inc hl			;8f43
	dec bc			;8f44
	ld a,c			;8f45
	or b			;8f46
	jr nz,ram_sprites_borra		;8f47
	ld hl,0e300h		;8f49   ; los sprites de la RAM...
	ld de,00010h		;8f4c   ; ...de 16 en 16...
	ld b,020h		;8f4f   ; ...32...
ram_sprites_fuera:
	ld (hl),0f0h		;8f51   ; ...con la Y fuera
	add hl,de			;8f53
	djnz ram_sprites_fuera		;8f54
	ret			;8f56
pantalla_borra:		; La pantalla con la casilla 0x10 (espacio) y los sprites fuera
	ld a,010h		;8f57   ; el espacio...
	ld hl,01800h		;8f59   ; ...en toda la pantalla
	ld bc,00300h		;8f5c
	call 00056h		;8f5f
	ld hl,0e100h		;8f62   ; la tabla de sprites que va a la VRAM...
	ld b,07fh		;8f65   ; ...127 bytes...
pantalla_borra_sprites:
	ld (hl),000h		;8f67   ; ...a cero
	inc hl			;8f69
	djnz pantalla_borra_sprites		;8f6a
	call sprites_vram		;8f6c   ; a la VRAM
	ret			;8f6f
colores_juego:		; Los colores: todo a 0xF0 y los de las casillas 0x40 en adelante (0xAE00, 0xB600) en los tres tercios
	call colores_blanco		;8f70   ; todo 0xF0
	ld de,00200h		;8f73   ; las casillas 0x40 del titulo en el primer tercio...
	call colores_ae00		;8f76
	ld de,00a00h		;8f79   ; ...el segundo...
	call colores_ae00		;8f7c
	ld de,01200h		;8f7f   ; ...y el tercero
	call colores_ae00		;8f82
	ld de,02200h		;8f85   ; sus colores
	call colores_b600		;8f88
	ld de,02a00h		;8f8b
	call colores_b600		;8f8e
	ld de,03200h		;8f91
	call colores_b600		;8f94
	ret			;8f97
letras:		; Las letras de la BIOS: 0x180 bytes desde 0x1D3F (los caracteres 0x30-0x5F de la fuente, que empieza en 0x1BBF) a la casilla 0 del tercio DE
	ld hl,01d3fh		;8f98   ; la fuente de la BIOS, desde el caracter 0x30...
	ld bc,00180h		;8f9b   ; ...48 caracteres
vram_tercio:		; LDIRVM y DE al tercio siguiente
	call 0005ch		;8f9e   ; LDIRVM
	ld a,008h		;8fa1   ; DE al tercio siguiente (+ 0x800)
	add a,h			;8fa3
	ld h,a			;8fa4
	ex de,hl			;8fa5
	ret			;8fa6
L_8FA7:
	ld hl,01cbfh		;8fa7   ; desde el caracter 0x20 (aqui no se llega)
	ld bc,00080h		;8faa   ; 16 caracteres
	jr vram_tercio		;8fad
casillas_a800:		; Las casillas de 0xA800 (0x680 bytes) en el tercio DE
	ld hl,0a800h		;8faf   ; 208 casillas
	ld bc,00680h		;8fb2
	jr vram_tercio		;8fb5
casillas_b000:		; Las de 0xB000
	ld hl,0b000h		;8fb7   ; sus colores
	ld bc,00680h		;8fba
	jr vram_tercio		;8fbd
ldirvm:		; LDIRVM
	jp 0005ch		;8fbf   ; LDIRVM
color8:		; FILVRM de 8 bytes
	ld bc,00008h		;8fc2   ; 8 bytes, FILVRM
	jp 00056h		;8fc5
colores_ae00:		; Los colores de 0xAE00 (512 bytes)
	ld hl,0ae00h		;8fc8   ; 64 casillas
	ld bc,00200h		;8fcb
	jr ldirvm		;8fce
colores_b600:		; Los colores de 0xB600 (384 bytes)
	ld hl,0b600h		;8fd0   ; 48 casillas de colores
	ld bc,00180h		;8fd3
	jr ldirvm		;8fd6
sprites_dibujos:		; Los dibujos de los sprites (0xB800, 2 KB) a 0x3800
	ld de,03800h		;8fd8   ; 2 KB...
	ld hl,0b800h		;8fdb   ; ...de 0xB800 a 0x3800
	ld bc,00800h		;8fde
	jr ldirvm		;8fe1
sonido_calla_pide:		; Pide a la interrupcion que calle el sonido (0xE089 = 0xFF)
	ld a,0ffh		;8fe3   ; 0xFF: callar
	ld (0e089h),a		;8fe5
	ret			;8fe8
sprites_vram:		; Los 32 sprites a 0x1B00, de 0xE100; antes, la tabla de la RAM (16 bytes por sprite, desde 0xE300) se pasa a 4 bytes por sprite, en otro orden
	ld de,01b00h		;8fe9   ; a 0x1B00...
	ld hl,0e100h		;8fec   ; ...desde 0xE100...
	ld bc,00080h		;8fef   ; ...32 sprites
	call 0005ch		;8ff2   ; LDIRVM
	ld hl,0e300h		;8ff5   ; los dos primeros (el coche)
	ld de,0e100h		;8ff8   ; la tabla de la VRAM, rehecha
	ld b,002h		;8ffb   ; dos
	call sprites_copia		;8ffd
	ld hl,0e340h		;9000   ; los 28 de 0xE340
	ld b,01ch		;9003   ; 28
	call sprites_copia		;9005
	ld hl,0e320h		;9008   ; y los dos de 0xE320 al final
	ld b,002h		;900b   ; dos
	call sprites_copia		;900d
	ret			;9010
L_9011:
	ld b,020h		;9011   ; 32 (aqui no se llega)
sprites_copia:		; B sprites: 4 bytes de cada 16
	push bc			;9013
	ld bc,00004h		;9014   ; Y, X, dibujo, color
	ldir		;9017   ; copiados
	ld bc,0000ch		;9019   ; los otros 12 bytes, no
	add hl,bc			;901c
	pop bc			;901d
	djnz sprites_copia		;901e
	ret			;9020
interrupcion:		; La interrupcion (H.TIMI): callar si se pide, el motor del coche en el canal A, los efectos, las cuentas de cuadros y los mandos
	ld a,(0e089h)		;9021   ; hay que callar?
	cp 0ffh		;9024   ; pide callar?
	jr nz,L_902F		;9026
	call sonido_calla		;9028   ; calla
	xor a			;902b   ; ya hecho
	ld (0e089h),a		;902c
L_902F:
	ld a,(0e000h)		;902f   ; en partida?
	and a			;9032   ; en partida?
	jp z,interrupcion_cuentas		;9033
	ld a,(0e2bdh)		;9036   ; una musica?
	and a			;9039
	jp nz,interrupcion_cuentas		;903a
	ld a,(0e2c1h)		;903d   ; 0xE2C1: los canales B y C...
	and a			;9040   ; un efecto?
	jr nz,motor		;9041
	ld e,000h		;9043   ; sin efecto: los canales B y C a volumen 0
	ld a,009h		;9045   ; ...a volumen 0
	call 00093h		;9047   ; WRTPSG
	ld e,000h		;904a   ; el C...
	ld a,00ah		;904c
	call 00093h		;904e   ; ...WRTPSG
motor:		; El motor: si va (0xE1C3), el canal A a volumen 15 con el tono de 0xE1C4, que tiembla
	ld a,(0e1c3h)		;9051   ; el motor va?
	and a			;9054
	jr z,interrupcion_cuentas		;9055
	ld a,(0e088h)		;9057   ; el canal A, solo tono
	set 3,a		;905a   ; el canal A: sin ruido...
	res 0,a		;905c   ; ...con tono
	ld (0e088h),a		;905e
	call psg_mezcla		;9061   ; el registro 7
	ld e,00fh		;9064   ; volumen 15 en el canal A
	ld a,008h		;9066   ; el registro 8
	call 00093h		;9068
	ld a,(0e1c5h)		;906b   ; la parte alta del tono...
	ld e,a			;906e   ; la parte alta del tono
	ld a,001h		;906f   ; ...en el registro 1
	call 00093h		;9071   ; WRTPSG
	ld a,(0e194h)		;9074   ; parado?
	and a			;9077   ; parado
	jr z,motor_parado		;9078
	cp 0efh		;907a   ; casi a tope: tiembla poco
	jr c,motor_tono		;907c   ; rapido
	ld a,(0e098h)		;907e   ; el temblor...
	inc a			;9081
	ld (0e098h),a		;9082
	cp 006h		;9085   ; ...hasta 6
	jr c,motor_temblor		;9087
	jr motor_temblor_cero		;9089
motor_parado:		; Parado: el tono 0x3F8 y un temblor mas grande
	ld hl,003f8h		;908b   ; parado: el tono 0x3F8
	ld (0e1c4h),hl		;908e
	ld a,(0e098h)		;9091   ; el temblor de 3 en 3...
	add a,003h		;9094
	ld (0e098h),a		;9096
	cp 014h		;9099   ; ...hasta 20
	jr c,motor_temblor		;909b
motor_temblor_cero:
	xor a			;909d   ; otra vez 0
	ld (0e098h),a		;909e
motor_temblor:		; El tono menos el temblor
	ld b,a			;90a1
	ld a,(0e1c4h)		;90a2   ; la parte baja del tono...
	sub b			;90a5   ; ...menos el temblor
	jr motor_pon		;90a6
motor_tono:
	ld a,(0e1c4h)		;90a8   ; la parte baja
motor_pon:		; La parte baja del tono en el registro 0
	ld e,a			;90ab
	xor a			;90ac   ; el registro 0
	call 00093h		;90ad
interrupcion_cuentas:		; Los efectos y las dieciseis cuentas de cuadros (0xE010-0xE01F), una mas cada una
	call sonido		;90b0   ; los efectos y la musica
	ld hl,0e010h		;90b3   ; dieciseis cuentas...
	ld b,010h		;90b6
interrupcion_cuenta:
	inc (hl)			;90b8   ; ...una mas cada una
	inc hl			;90b9
	djnz interrupcion_cuenta		;90ba
	ld a,(0e000h)		;90bc   ; en partida?
	and a			;90bf   ; en partida?
	jr z,demostracion		;90c0
	ld de,0e040h		;90c2   ; el boton 1 del mando: 0xE040 (recien pulsado) y 0xE046 (sostenido)
	ld hl,0e046h		;90c5   ; lo sostenido
	ld a,001h		;90c8   ; GTTRIG 1
	call boton_mando		;90ca
	ld de,0e041h		;90cd   ; el boton 2 del mando: 0xE041 y 0xE047
	ld hl,0e047h		;90d0   ; lo sostenido
	ld a,003h		;90d3   ; GTTRIG 3
	call boton_mando		;90d5
	ld de,0e040h		;90d8   ; o la barra y GRAPH en el teclado
	ld hl,0e049h		;90db   ; lo sostenido del teclado
	call botones_teclado		;90de
palanca:		; La palanca: los cursores o el mando 1 (GTSTCK 0 y 1), en 0xE180
	xor a			;90e1
	call 000d5h		;90e2   ; GTSTCK 0: los cursores
	ld (0e181h),a		;90e5
	ld a,001h		;90e8
	call 000d5h		;90ea   ; GTSTCK 1: el mando 1
	ld c,a			;90ed
	ld a,(0e181h)		;90ee
	or c			;90f1   ; uno u otro
	ld (0e180h),a		;90f2
	ret			;90f5
demostracion:		; En la demostracion: cada 48 cuadros una direccion al azar (1, 2, 3 cambia a 8) y dispara o tira una bomba
	ld hl,0e04ch		;90f6   ; la demostracion?
	ld a,(hl)			;90f9
	and a			;90fa
	jr z,demostracion_palanca		;90fb
	inc hl			;90fd
	inc (hl)			;90fe   ; la cuenta...
	ld a,(hl)			;90ff
	cp 030h		;9100   ; ...48 cuadros?
	jr c,boton_empieza		;9102
	ld (hl),000h		;9104   ; otra vez
	ld a,r		;9106   ; una direccion al azar (1-3)...
	and 003h		;9108
	and a			;910a
	jr nz,demostracion_dir		;910b
	inc a			;910d
demostracion_dir:
	cp 003h		;910e   ; ...la 3 es la 8
	jr nz,demostracion_pon		;9110
	ld a,008h		;9112
demostracion_pon:
	ld (0e180h),a		;9114   ; la palanca
	and 001h		;9117   ; par o impar...
	and a			;9119
	jr nz,demostracion_bomba		;911a
	inc a			;911c
	ld (0e040h),a		;911d   ; ...dispara
	jr boton_empieza		;9120
demostracion_bomba:
	ld (0e041h),a		;9122   ; ...o tira una bomba
	jr boton_empieza		;9125
demostracion_palanca:		; Sin demostracion: la palanca de verdad
	call boton_empieza		;9127   ; el boton de empezar
	jr palanca		;912a
boton_empieza:		; El boton de empezar (0xE043): la barra o el boton 1
	ld de,0e043h		;912c   ; 0xE043: el boton de empezar
	ld hl,0e048h		;912f
	call boton_barra		;9132   ; la barra
	ld a,(de)			;9135   ; lo de la barra...
	ld (0e181h),a		;9136
	ld a,001h		;9139   ; el mando 1
	ld hl,0e046h		;913b
	call boton_mando		;913e
	ld a,(de)			;9141   ; ...o lo del mando
	ld b,a			;9142
	ld a,(0e181h)		;9143
	or b			;9146
	ld (de),a			;9147
	ret			;9148
boton_mando:		; GTTRIG A: lo recien pulsado en (DE) y lo sostenido en (HL)
	call 000d8h		;9149   ; GTTRIG
	and a			;914c
boton_mira:
	jr nz,boton_nuevo		;914d   ; pulsado
boton_suelto:
	ld (hl),000h		;914f   ; suelto
	ret			;9151
boton_nuevo:
	ld a,(hl)			;9152   ; ya estaba pulsado?
	and a			;9153
	ret nz			;9154
	inc a			;9155   ; recien pulsado
	ld (hl),a			;9156
	ld (de),a			;9157
	ret			;9158
boton_barra:		; La barra (fila 8, bit 0)
	ld a,008h		;9159   ; la fila 8...
	call 00141h		;915b   ; ...SNSMAT
	rrca			;915e   ; la barra
	jr nc,boton_nuevo		;915f
	jr boton_suelto		;9161
botones_teclado:		; La barra como boton 1 y GRAPH (fila 6, bit 2) como boton 2
	ld a,008h		;9163   ; la fila 8
	call 00141h		;9165
	cpl			;9168   ; pulsado = 1
	bit 0,a		;9169   ; la barra: boton 1
	call boton_mira		;916b
	inc hl			;916e   ; el boton 2
	inc de			;916f
	nop			;9170
	ld a,006h		;9171   ; la fila 6
	call 00141h		;9173
	cpl			;9176
	bit 2,a		;9177   ; GRAPH: boton 2
	jr boton_mira		;9179
marcador_puntos:		; SCORE y HISCORE en el marcador (6 cifras)
	ld hl,0e001h		;917b   ; las cifras de los puntos...
	ld de,0189ah		;917e   ; ...en la fila 4, columna 26
	call texto6		;9181
	ld hl,0e08eh		;9184   ; las del record...
	ld de,0183ah		;9187   ; ...en la fila 1, columna 26
	jp texto6		;918a
puntos:		; Los puntos + A (BCD, tres bytes); a 999999 se quedan
	ld b,a			;918d
	ld a,(0e00eh)		;918e   ; las unidades y decenas
	add a,b			;9191
	daa			;9192   ; BCD
	ld (0e00eh),a		;9193
	jr nc,puntos_pinta		;9196   ; sin acarreo
	ld a,001h		;9198
puntos_centenas:
	ld b,a			;919a
	ld a,(0e00dh)		;919b   ; las centenas y millares
	add a,b			;919e
	daa			;919f
	ld (0e00dh),a		;91a0
	jr nc,puntos_pinta		;91a3
	ld a,001h		;91a5
	ld b,a			;91a7
	ld a,(0e00ch)		;91a8   ; las decenas y centenas de millar
	add a,b			;91ab
	daa			;91ac
	ld (0e00ch),a		;91ad
	jr nc,puntos_pinta		;91b0
	ld hl,0e00ch		;91b2   ; pasa de 999999...
	ld b,003h		;91b5
puntos_tope:
	ld (hl),099h		;91b7   ; ...999999
	inc hl			;91b9
	djnz puntos_tope		;91ba
puntos_pinta:
	call puntos_cifras		;91bc   ; las cifras
	call record		;91bf   ; el record
	ret			;91c2
puntos_cifras:		; Las seis cifras sueltas de los puntos (0xE001)
	ld hl,0e001h		;91c3   ; las seis cifras...
	ld de,0e00ch		;91c6   ; ...de los tres bytes BCD
	ld b,003h		;91c9
puntos_cifra:
	ld a,(de)			;91cb   ; un byte
	ld c,a			;91cc
	and 0f0h		;91cd   ; la alta
	rrca			;91cf
	rrca			;91d0
	rrca			;91d1
	rrca			;91d2
	ld (hl),a			;91d3
	inc hl			;91d4
	ld a,c			;91d5   ; la baja
	and 00fh		;91d6
	ld (hl),a			;91d8
	inc hl			;91d9
	inc de			;91da
	djnz puntos_cifra		;91db
	ret			;91dd
record:		; Si los puntos pasan del record, record nuevo
	ld de,0e094h		;91de   ; el record...
	ld hl,0e00ch		;91e1   ; ...contra los puntos
	ld a,(de)			;91e4
	ld b,a			;91e5
	ld a,(hl)			;91e6
	cp b			;91e7   ; menos: nada
	ret c			;91e8
	jr nz,L_91FD		;91e9
	inc de			;91eb
	inc hl			;91ec
	ld a,(de)			;91ed
	ld b,a			;91ee
	ld a,(hl)			;91ef
	cp b			;91f0
	ret c			;91f1
	jr nz,L_91FF		;91f2
	inc de			;91f4
	inc hl			;91f5
	ld a,(de)			;91f6
	ld b,a			;91f7
	ld a,(hl)			;91f8
	cp b			;91f9
	ret c			;91fa
	jr L_9201		;91fb
L_91FD:
	inc de			;91fd
	inc hl			;91fe
L_91FF:
	inc de			;91ff
	inc hl			;9200
L_9201:
	ld bc,00003h		;9201   ; los tres bytes...
	lddr		;9204   ; ...al record
	ld hl,0e08eh		;9206   ; y sus cifras
	ld de,0e094h		;9209
	ld b,003h		;920c
	jr puntos_cifra		;920e

; ----------------------------------------------------------------------
; DATOS mapa_rle: El mapa del recorrido, comprimido: un byte con la mitad alta
;   es una casilla; con la mitad alta a 0, cuantas veces y la casilla
;   0x9210..0x927e  (110 bytes)
DATA_mapa_rle:
	defb 00fh,010h,0e2h,0ech,010h,0d7h,008h,0e0h,0d4h,0e0h,0ech,0e2h,0d4h,0d5h,0ebh,0e1h	; 9210  ................
	defb 0d8h,00ah,0e0h,0d4h,0e0h,0e0h,0d6h,0eah,0e2h,00bh,0e0h,0d5h,003h,0e0h,0edh,00ch	; 9220  ................
	defb 0e0h,0d6h,003h,0e0h,0ech,00fh,0e0h,0e0h,010h,0e3h,0d5h,004h,0e0h,0d5h,004h,0e0h	; 9230  ................
	defb 0d5h,003h,0e0h,0edh,010h,0e4h,0d6h,004h,0e0h,0d6h,004h,0e0h,0d6h,003h,0e0h,0ech	; 9240  ................
	defb 010h,010h,0e3h,0e0h,0d5h,00ah,0e0h,0d5h,0ebh,010h,010h,0e4h,0e0h,0d6h,005h,0e0h	; 9250  ................
	defb 0d5h,004h,0e0h,0d6h,0eah,010h,010h,010h,0e5h,0d3h,0d3h,0d3h,0e8h,0e0h,0e0h,0d6h	; 9260  ................
	defb 0e0h,0e7h,0e6h,0e5h,0e8h,0e9h,010h,008h,010h,0e5h,0d3h,0e6h,006h,010h	; 9270  ..............

; ----------------------------------------------------------------------
; DATOS texto_casio: CASIO en el titulo (6 casillas rojas)
;   0x927e..0x9284  (6 bytes)
DATA_texto_casio:
	defb 06ah,06bh,06ch,06dh,06eh,06fh	; 927e

; ----------------------------------------------------------------------
; DATOS titulo_car: CAR en letras grandes: 4 filas de 14
;   0x9284..0x92bc  (56 bytes)
DATA_titulo_car:
	defb 040h,041h,041h,043h,010h,010h,050h,041h,043h,010h,056h,041h,041h,043h	; 9284  @AAC..PAC.VAAC
	defb 044h,045h,066h,047h,010h,051h,052h,052h,053h,010h,044h,045h,066h,053h	; 9292  DEfG.QRRS.DEfS
	defb 048h,049h,04ah,04bh,010h,048h,054h,054h,048h,010h,048h,054h,057h,058h	; 92a0  HIJK.HTTH.HTWX
	defb 04ch,04dh,04dh,04fh,010h,055h,010h,010h,055h,010h,055h,010h,059h,05ah	; 92ae  LMMO.U..U.U.YZ

; ----------------------------------------------------------------------
; DATOS titulo_fighter: FIGHTER en letras grandes: 5 filas de 25 (la ultima
;   mas corta)
;   0x92bc..0x933a  (126 bytes)
DATA_titulo_fighter:
	defb 056h,04dh,05dh,010h,062h,010h,056h,04dh,043h,010h,062h,010h,062h,010h,050h,041h,05dh,010h,056h,04dh,05dh,010h,056h,04dh,043h	; 92bc  VM].b.VMC.b.b.PA].VM].VMC
	defb 041h,010h,010h,010h,041h,010h,041h,010h,047h,010h,041h,010h,041h,010h,010h,041h,010h,010h,041h,010h,010h,010h,041h,010h,041h	; 92d5  A...A.A.G.A.A..A..A...A.A
	defb 05eh,05eh,010h,010h,05eh,010h,05eh,05ch,067h,010h,05eh,05fh,05eh,010h,010h,05eh,010h,010h,05eh,05fh,010h,010h,05eh,05eh,05bh	; 92ee  ^^..^.^\g.^_^..^..^_..^^[
	defb 060h,010h,010h,010h,060h,010h,060h,010h,060h,010h,060h,010h,060h,010h,010h,060h,010h,010h,060h,010h,010h,010h,060h,04eh,042h	; 9307  `...`.`.`.`.`..`..`...`NB
	defb 061h,010h,010h,010h,061h,010h,065h,04dh,04fh,010h,061h,010h,061h,010h,010h,061h,010h,010h,065h,04dh,05dh,010h,061h,046h,063h	; 9320  a...a.eMO.a.a..a..eM].aFc
	defb 064h	; 9339

; ----------------------------------------------------------------------
; DATOS texto_push: PUSH TRIG:1 OR SPC
;   0x933a..0x934c  (18 bytes)
DATA_texto_push:
	defb 020h,025h,023h,018h,010h,024h,022h,019h,017h,00ah,001h,010h,01fh,022h,010h,023h	; 933a   %#..$"......".#
	defb 020h,013h	; 934a

; ----------------------------------------------------------------------
; DATOS texto_copyright: COPYRIGHT 1985 (c) CASIO
;   0x934c..0x9362  (22 bytes)
DATA_texto_copyright:
	defb 013h,01fh,020h,029h,022h,019h,017h,018h,024h,010h,001h,009h,008h,005h,010h,069h	; 934c  .. )"...$......i
	defb 010h,013h,011h,023h,019h,01fh	; 935c

; ----------------------------------------------------------------------
; DATOS texto_empty: EMPTY (sin gasolina)
;   0x9362..0x9367  (5 bytes)
DATA_texto_empty:
	defb 015h,01dh,020h,024h,029h	; 9362

; ----------------------------------------------------------------------
; DATOS bytes_9367: Seis cifras (1, 0, 0, 0, 0, 0) que nadie lee: el record
;   empieza en 10000 desde INIT
;   0x9367..0x936d  (6 bytes)
DATA_bytes_9367:
	defb 001h,000h,000h,000h,000h,000h	; 9367

; ----------------------------------------------------------------------
; DATOS textos_marcador: El marcador: HISCORE (que se solapa con SCORE),
;   SCORE, BOMB, FUEL y su luz, los recuadros y SPEED
;   0x936d..0x939d  (48 bytes)
DATA_textos_marcador:
	defb 018h,019h	; 936d
	defb 023h,013h,01fh,022h,015h	; 936f
	defb 012h,01fh,01dh,012h	; 9374
	defb 016h,025h,015h,01ch,010h,031h	; 9378
	defb 010h,033h,034h,034h,034h,034h,034h,035h,036h,010h,010h,010h,010h,03bh	; 937e  .34444456....;
	defb 037h,038h,039h,039h,039h,039h,039h,03ah,023h,020h,015h,015h,014h,010h	; 938c  7899999:# ....
	defb 010h,036h	; 939a
	defb 010h	; 939c

; ----------------------------------------------------------------------
; DATOS costa: La orilla del mar de la zona 2: 27 pasos de 5 casillas (la
;   orilla y el mar, 0x7B)
;   0x939d..0x9424  (135 bytes)
DATA_costa:
	defb 010h,010h,01bh,06fh,037h	; 939d
	defb 06dh,0cch,0cdh,07bh,07bh	; 93a2
	defb 06dh,0c8h,0c9h,07bh,07bh	; 93a7
	defb 0cch,0cdh,07bh,07bh,07bh	; 93ac
	defb 0c8h,0c9h,07bh,07bh,07bh	; 93b1
	defb 0c4h,0c5h,07bh,07bh,07bh	; 93b6
	defb 0c0h,0c1h,07bh,07bh,07bh	; 93bb
	defb 0cch,0cdh,07bh,07bh,07bh	; 93c0
	defb 0c4h,0c5h,07bh,07bh,07bh	; 93c5
	defb 0c0h,0c1h,07bh,07bh,07bh	; 93ca
	defb 06dh,0c4h,0c5h,07bh,07bh	; 93cf
	defb 06dh,0c0h,0c1h,07bh,07bh	; 93d4
	defb 06dh,06dh,0c2h,07bh,07bh	; 93d9
	defb 06dh,06dh,0c4h,0c5h,07bh	; 93de
	defb 06dh,06dh,0c0h,0c1h,07bh	; 93e3
	defb 06dh,06dh,0cch,0cdh,07bh	; 93e8
	defb 06dh,06dh,0c8h,0c9h,07bh	; 93ed
	defb 06dh,0cch,0cdh,07bh,07bh	; 93f2
	defb 06dh,0c0h,0c1h,07bh,07bh	; 93f7
	defb 06dh,06dh,0c2h,07bh,07bh	; 93fc
	defb 06dh,06dh,0c4h,0c5h,07bh	; 9401
	defb 06dh,06dh,0cch,0cdh,07bh	; 9406
	defb 06dh,06dh,0c0h,0c1h,07bh	; 940b
	defb 06dh,06dh,0c8h,0c9h,07bh	; 9410
	defb 06dh,0cch,0cdh,07bh,07bh	; 9415
	defb 06dh,0c8h,0c9h,07bh,07bh	; 941a
	defb 06dh,0c4h,0c5h,07bh,07bh	; 941f

; ----------------------------------------------------------------------
; DATOS bytes_9424: Cinco bytes detras de la orilla
;   0x9424..0x9429  (5 bytes)
DATA_bytes_9424:
	defb 06dh,0c0h,0c1h,07bh,07bh	; 9424

; ----------------------------------------------------------------------
; DATOS texto_game_over: GAME OVER
;   0x9429..0x9432  (9 bytes)
DATA_texto_game_over:
	defb 017h,011h,01dh,015h,010h,01fh,026h,015h,022h	; 9429  ......&."

; ----------------------------------------------------------------------
; DATOS texto_start: START
;   0x9432..0x9437  (5 bytes)
DATA_texto_start:
	defb 023h,024h,011h,022h,024h	; 9432

; ======================================================================
; CODIGO 0x9437..0x9d24  (2285 bytes)
; ======================================================================


cerca_y:		; ¿Toca en Y? A = la Y de IY menos la del coche (IX): C (toca) si, con signo, queda entre C - 0x100 y B - 1 (B, el margen por un lado; C, 0x100 menos el del otro)
	ld a,(iy+000h)		;9437   ; la Y del otro...
	sub (ix+000h)		;943a   ; ...menos la del coche
cerca_mira:
	cp b			;943d   ; menos que B (de 0 a B - 1): toca
	ret c			;943e
	cp c			;943f   ; C o mas (de C - 0x100 a -1)?
	jr c,cerca_no		;9440
	scf			;9442   ; si: toca (C)
	ret			;9443
cerca_no:
	and a			;9444   ; NC: no
	ret			;9445
cerca_x:		; Lo mismo en X
	ld a,(iy+001h)		;9446   ; la X
	sub (ix+001h)		;9449
	jr cerca_mira		;944c
cerca_bomba_y:		; Contra la bomba (IX+0x30), en Y
	ld a,(iy+000h)		;944e   ; la Y contra la bomba
	sub (ix+030h)		;9451
	jr cerca_mira		;9454
cerca_bomba_x:		; ...en X
	ld a,(iy+001h)		;9456   ; la X contra la bomba
	sub (ix+031h)		;9459
	jr cerca_mira		;945c
cerca_disparo_y:		; Contra el disparo (IX+0x20), en Y
	ld a,(iy+000h)		;945e   ; la Y contra el disparo
	sub (ix+020h)		;9461
	jr cerca_mira		;9464
cerca_disparo_x:		; ...en X
	ld a,(iy+001h)		;9466   ; la X contra el disparo
	sub (ix+021h)		;9469
	jr cerca_mira		;946c
cosa5:		; Los tipos 5 en adelante: un sprite (dibujo 0x4C, blanco); la bomba que lo toca lo hace estallar; el coche que lo toca, 0xE183 = 4
	ld a,(iy+006h)		;946e   ; ya ha salido?
	and a			;9471
	jr nz,cosa5_bomba		;9472
	inc (iy+006h)		;9474   ; sale: dibujo 0x4C, blanco
	ld (iy+002h),04ch		;9477
	ld (iy+003h),00fh		;947b
	ret			;947f
cosa5_bomba:
	ld a,(ix+006h)		;9480   ; hay bomba?
	and a			;9483
	jr z,cosa5_coche		;9484
	ld bc,008f8h		;9486   ; la bomba lo toca?
	call cerca_bomba_y		;9489
	jr nc,cosa5_coche		;948c
	ld bc,006fah		;948e
	call cerca_bomba_x		;9491
	jr nc,cosa5_coche		;9494
	ld (ix+008h),020h		;9496   ; la bomba estalla
	jr cosa5_fuera		;949a
cosa5_coche:
	ld a,(0e01fh)		;949c   ; parpadea: el color 1 o 2
	and 004h		;949f
	rrca			;94a1
	rrca			;94a2
	add a,001h		;94a3
	ld (iy+003h),a		;94a5
	ld bc,006fah		;94a8   ; el coche lo toca?
	call cerca_y		;94ab
	jr nc,cosa5_sigue		;94ae
	ld bc,006fah		;94b0
	call cerca_x		;94b3
	jr nc,cosa5_sigue		;94b6
	ld a,004h		;94b8   ; choca
	ld (0e183h),a		;94ba
cosa5_fuera:
	ld (iy+000h),0e0h		;94bd   ; fuera
cosa5_sigue:
	jp coche_fuera		;94c1
cosa4:		; El tipo 4: sale por arriba a un lado al azar (dibujo 0x3C, color 1 o 5); si el coche lo toca, frena 96 veces
	ld a,(iy+005h)		;94c4   ; ya ha salido?
	and a			;94c7
	jr nz,cosa4_toca		;94c8
	ld (iy+000h),0f8h		;94ca   ; sale por arriba...
	ld (iy+005h),002h		;94ce
	ld (iy+002h),03ch		;94d2   ; ...dibujo 0x3C...
	call lado_azar		;94d6   ; ...a un lado al azar
	ld a,r		;94d9
	bit 2,a		;94db
	jr nz,cosa4_color		;94dd
	ld (iy+003h),001h		;94df   ; color 1...
	jr cosa4_sitio		;94e3
cosa4_color:
	ld (iy+003h),005h		;94e5   ; ...o 5
cosa4_sitio:
	call coche_otro_velocidad		;94e9   ; su velocidad y su X
	ld (iy+010h),0f0h		;94ec
cosa4_toca:
	ld a,(iy+007h)		;94f0   ; ya tocado?
	and a			;94f3
	jr nz,cosa4_sigue		;94f4
	ld bc,008f8h		;94f6   ; el coche lo toca?
	call cerca_y		;94f9
	jr nc,cosa4_sigue		;94fc
	ld bc,00cf4h		;94fe
	call cerca_x		;9501
	jr nc,cosa4_sigue		;9504
	inc (iy+007h)		;9506   ; tocado
	ld b,060h		;9509   ; 96 veces frena
cosa4_frena:
	push bc			;950b
	call frena		;950c
	pop bc			;950f
	djnz cosa4_frena		;9510
	ret			;9512
cosa4_sigue:
	jp coche_fuera		;9513
lado_azar:		; IY+9 = 0 o 1 al azar (el lado)
	ld a,r		;9516   ; 0 o 1 al azar
	and 001h		;9518
	ld (iy+009h),a		;951a
	ret			;951d
lado_cambia:		; IY+9 al reves
	ld a,(iy+009h)		;951e
	and a			;9521   ; 0?
	jr nz,lado_cero		;9522
	ld (iy+009h),001h		;9524
	ret			;9528
lado_cero:
	ld (iy+009h),000h		;9529
	ret			;952d
coche_rebote:		; Los empujones: IY+0x0B en Y y IY+0x0E en X durante 8 cuadros; y los sprites del coche en su sitio (el camion lleva cuatro)
	ld a,(iy+00bh)		;952e   ; empujon en Y?
	and a			;9531
	jr z,coche_rebote_x		;9532
	add a,(iy+000h)		;9534   ; un pixel
	ld (iy+000h),a		;9537
	inc (iy+00dh)		;953a   ; 8 cuadros
	ld a,(iy+00dh)		;953d
	cp 008h		;9540
	jr c,coche_rebote_x		;9542
	ld (iy+00dh),000h		;9544
	ld (iy+00bh),000h		;9548
coche_rebote_x:
	ld a,(iy+00eh)		;954c   ; empujon en X?
	and a			;954f
	jr z,coche_sprites		;9550
	add a,(iy+001h)		;9552   ; un pixel a un lado
	ld (iy+001h),a		;9555
	inc (iy+00fh)		;9558
	ld a,(iy+00fh)		;955b
	cp 008h		;955e   ; 8 cuadros
	jr c,coche_sprites		;9560
	ld (iy+00fh),000h		;9562
	ld (iy+00eh),000h		;9566
coche_sprites:
	ld c,(iy+000h)		;956a   ; la Y
	ld a,(iy+004h)		;956d   ; el camion?
	cp 003h		;9570
	jr nz,coche_sprites_y		;9572
	ld a,010h		;9574   ; sus sprites de detras, 16 mas abajo
	add a,c			;9576
	ld (iy+020h),a		;9577
	ld (iy+030h),a		;957a
coche_sprites_y:
	ld (iy+010h),c		;957d   ; la del segundo sprite
	ld b,(iy+001h)		;9580   ; la X
	ld a,(iy+004h)		;9583
	cp 003h		;9586
	jr nz,coche_sprites_x		;9588
	ld (iy+021h),b		;958a
	ld (iy+031h),b		;958d
coche_sprites_x:
	ld (iy+011h),b		;9590
coche_fuera:		; Si sale por abajo, el bloque a cero
	ld a,(iy+004h)		;9593   ; el camion?
	cp 003h		;9596
	jr nz,coche_fuera_otro		;9598
	ld a,(iy+000h)		;959a   ; abajo del todo?
	cp 0beh		;959d
	ret c			;959f
	cp 0e2h		;95a0
	ret nc			;95a2
	ld b,040h		;95a3   ; 64 bytes a cero
	call borra_b		;95a5
	jr coche_fuera_camion		;95a8
coche_fuera_otro:
	ld a,(iy+000h)		;95aa   ; abajo del todo?
	cp 0c0h		;95ad
	ret c			;95af
	cp 0f2h		;95b0
	ret nc			;95b2
	ld a,(iy+004h)		;95b3   ; 4 o mas: un sprite
	cp 004h		;95b6
	jr c,coche_fuera_32		;95b8
	ld b,010h		;95ba   ; 16 bytes
	call borra_b		;95bc
	jr coche_fuera_uno		;95bf
coche_fuera_32:
	ld b,020h		;95c1   ; 32 bytes
	call borra_b		;95c3
	jr coche_fuera_dos		;95c6
coche_fuera_camion:
	ld (iy+030h),0f0h		;95c8   ; los sprites fuera
	ld (iy+020h),0f0h		;95cc
coche_fuera_dos:
	ld (iy+010h),0f0h		;95d0
coche_fuera_uno:
	ld (iy+000h),0f0h		;95d4
	ret			;95d8
borra_b:		; B bytes de IY a cero
	push iy		;95d9
	pop hl			;95db
borra_b_byte:
	ld (hl),000h		;95dc
	inc hl			;95de
	djnz borra_b_byte		;95df
	ret			;95e1
coche_otro:		; Un coche de los otros (0xE360, 32 bytes): por su tipo (IY+4): 1-2 coches, 3 el camion, 4 y 5 o mas cosas sueltas
	ld a,(iy+004h)		;95e2   ; no hay?
	and a			;95e5   ; no hay
	ret z			;95e6
	cp 005h		;95e7   ; 5 o mas
	jp nc,cosa5		;95e9   ; 5 o mas
	cp 004h		;95ec   ; 4
	jp z,cosa4		;95ee   ; 4
	ld a,(iy+005h)		;95f1   ; ya ha salido?
	and a			;95f4
	jp nz,coche_otro_mueve		;95f5   ; si: a moverse
	inc (iy+005h)		;95f8   ; sale
	call lado_azar		;95fb   ; su lado
	ld a,(iy+004h)		;95fe   ; el camion?
	cp 003h		;9601   ; 3: el camion
	jr nz,coche_otro_sale		;9603
	ld (iy+000h),0e4h		;9605   ; el camion: cuatro sprites (0x24-0x30), azul claro y negro, abajo
	ld (iy+002h),024h		;9609   ; sus dibujos: 0x24, 0x28, 0x2C, 0x30
	ld (iy+012h),028h		;960d
	ld (iy+022h),02ch		;9611
	ld (iy+032h),030h		;9615
	ld (iy+003h),00dh		;9619   ; colores: 13 y 1
	ld (iy+013h),001h		;961d
	ld (iy+023h),00dh		;9621
	ld (iy+033h),001h		;9625
	ld a,(0e194h)		;9629   ; su velocidad: 16 menos que el coche
	sub 010h		;962c   ; su velocidad
	ld (iy+006h),a		;962e
	ld a,(iy+001h)		;9631   ; sin X?
	and a			;9634
	call z,coche_otro_velocidad		;9635   ; la del borde
	jp coche_rebote		;9638   ; a su sitio
coche_otro_sale:		; Un coche (dibujos 0x14 y 0x18): sale por arriba o por abajo segun las velocidades
	ld (iy+002h),014h		;963b   ; dibujos 0x14 y 0x18
	ld (iy+003h),008h		;963f   ; colores 8 y 1
	ld (iy+012h),018h		;9643
	ld (iy+013h),001h		;9647
	ld a,(0e194h)		;964b   ; el coche va despacio?
	cp 060h		;964e   ; el coche va despacio (menos de 0x60)?
	jr c,coche_otro_arriba		;9650
	ld a,r		;9652   ; o al azar...
	bit 2,a		;9654
	jr nz,coche_otro_arriba		;9656   ; ...sale por arriba
	ld a,(0e3e4h)		;9658   ; hay otro saliendo?
	and a			;965b   ; ya hay uno en 0xE3E0?
	jr z,coche_otro_abajo		;965c
	ld a,(0e3e0h)		;965e   ; en medio de la pantalla?
	cp 0e8h		;9661
	jr nc,coche_otro_arriba		;9663
	cp 008h		;9665
	jr c,coche_otro_arriba		;9667
coche_otro_abajo:
	ld (iy+000h),0f4h		;9669   ; sale por abajo (Y 0xF4)
coche_otro_velocidad:		; Su velocidad: la del coche menos algo al azar; y su X: la del borde de la carretera en la fila de arriba (0x3D)
	ld a,r		;966d   ; algo al azar...
	and 03fh		;966f
	ld b,a			;9671
	ld a,(0e194h)		;9672   ; ...menos que el coche
	sub b			;9675
	ld (iy+006h),a		;9676
	ld hl,0e800h		;9679   ; la fila nueva de la carretera
coche_otro_borde:
	ld a,(iy+009h)		;967c   ; a que lado?
	and a			;967f
	jr z,coche_otro_borde_der		;9680
	ld b,001h		;9682   ; desde la columna 1...
coche_otro_borde_izq:
	ld a,(hl)			;9684   ; ...busca el borde (0x3D)
	cp 03dh		;9685
	jp z,coche_otro_x		;9687
	inc b			;968a   ; la siguiente
	inc hl			;968b
	jr coche_otro_borde_izq		;968c
coche_otro_borde_der:
	ld b,015h		;968e   ; desde la columna 21...
	ld de,00017h		;9690   ; ...hacia atras
	add hl,de			;9693
coche_otro_borde_der_va:
	ld a,(hl)			;9694
	cp 03dh		;9695
	jr z,coche_otro_x		;9697
	dec b			;9699   ; la anterior
	dec hl			;969a
	jr coche_otro_borde_der_va		;969b
coche_otro_arriba:		; Sale por arriba, con mas velocidad
	ld (iy+000h),0bch		;969d   ; sale por arriba (Y 0xBC)
	ld a,(0e194h)		;96a1   ; la velocidad del coche...
	ld b,a			;96a4
	cp 050h		;96a5   ; ...poco: 0x60
	jr nc,coche_otro_rapido		;96a7
	ld b,060h		;96a9
coche_otro_rapido:
	ld a,r		;96ab   ; mas algo al azar
	and 03fh		;96ad
	add a,b			;96af
	jr nc,coche_otro_vel		;96b0
	ld a,0f8h		;96b2   ; tope 0xF8
coche_otro_vel:
	ld (iy+006h),a		;96b4   ; su velocidad
	cp 090h		;96b7   ; lenta: no cambia
	jr c,coche_otro_fila		;96b9
	ld a,(0e00ah)		;96bb   ; la zona 2?
	cp 002h		;96be
	jr nz,coche_otro_tipo		;96c0
	ld a,(iy+015h)		;96c2   ; ...ya tipo 2?
	cp 002h		;96c5
	jr z,coche_otro_tipo2		;96c7
coche_otro_tipo:		; Los que corren mucho: unos pasan a ser del tipo 2 (los que atacan, desde la zona 5)
	ld a,(iy+004h)		;96c9   ; el tipo 1 se queda
	cp 001h		;96cc
	jr z,coche_otro_fila		;96ce
	ld a,r		;96d0   ; al azar...
	bit 4,a		;96d2
	jr nz,coche_otro_color		;96d4
	ld a,(0e00ah)		;96d6   ; ...y desde la zona 5...
	cp 005h		;96d9
	jr c,coche_otro_color		;96db
coche_otro_tipo2:
	ld (iy+004h),002h		;96dd   ; ...el tipo 2 (color 13)
	ld (iy+003h),00dh		;96e1
	jr coche_otro_fila		;96e5
coche_otro_color:
	ld (iy+003h),002h		;96e7   ; color 2, dibujos 0x1C y 0x20
	ld (iy+002h),01ch		;96eb
	ld (iy+012h),020h		;96ef
coche_otro_fila:
	ld hl,(0e186h)		;96f3   ; la fila de arriba del anillo
	ld de,0ffe8h		;96f6
	add hl,de			;96f9
	ld a,h			;96fa
	cp 0e8h		;96fb   ; da la vuelta?
	jp nz,coche_otro_borde		;96fd
	ld a,l			;9700
	cp 0a8h		;9701
	jp nz,coche_otro_borde		;9703
	ld hl,0eae8h		;9706   ; al final
	jp coche_otro_borde		;9709
coche_otro_x:		; La X del coche: la columna del borde x 8 + 8
	ld a,008h		;970c   ; 8...
coche_otro_x_suma:
	add a,008h		;970e   ; ...+ 8 por columna
	djnz coche_otro_x_suma		;9710
	ld (iy+001h),a		;9712   ; la X
	jp coche_rebote		;9715
coche_otro_mueve:		; Ya en la carretera: baja o sube segun su velocidad contra la del coche, se aparta del borde, y lo que toca
	cp 001h		;9718   ; 1: corre
	jp nz,coche_estalla		;971a   ; otro: estalla
	inc (iy+007h)		;971d   ; la cuenta
	ld c,(iy+007h)		;9720
	ld a,(0e183h)		;9723   ; el coche choca?
	and a			;9726
	jr nz,coche_otro_choque		;9727
	ld a,(0e184h)		;9729   ; o se acaba la zona?
	and a			;972c
	jr z,coche_otro_contra		;972d
coche_otro_choque:		; Con el coche chocado o al acabar la zona, todos bajan 2 pixeles
	dec (iy+000h)		;972f   ; baja 2
	dec (iy+000h)		;9732
	jr coche_otro_persigue		;9735
coche_otro_contra:		; Mas rapido o mas lento que el coche: un pixel cada 1, 2, 3 o 4 cuadros segun la diferencia
	ld a,(0e194h)		;9737   ; la velocidad del coche menos la suya
	sub (iy+006h)		;973a
	jr z,coche_otro_persigue		;973d   ; igual: quieto
	jr c,coche_otro_mas_rapido		;973f   ; el coche es mas lento: sube
	cp 030h		;9741   ; 0x30 o mas: cada cuadro
	jr nc,coche_otro_baja		;9743
	cp 020h		;9745   ; 0x20: cada 2
	jr nc,coche_otro_ritmo2		;9747
	cp 010h		;9749   ; 0x10: cada 3
	jr nc,coche_otro_ritmo3		;974b
	ld a,c			;974d   ; si no, cada 4
	cp 004h		;974e
coche_otro_ritmo:
	jr c,coche_otro_persigue		;9750
coche_otro_baja:		; Un pixel abajo (el camion, sus cuatro sprites)
	ld (iy+007h),000h		;9752   ; la cuenta a 0
	inc (iy+000h)		;9756   ; un pixel abajo
	ld a,(iy+004h)		;9759   ; el camion?
	cp 003h		;975c
	jr nz,coche_otro_persigue		;975e
	inc (iy+030h)		;9760   ; sus otros sprites
	inc (iy+020h)		;9763
	jr coche_otro_persigue		;9766
coche_otro_ritmo3:
	ld a,c			;9768
	cp 003h		;9769
	jr coche_otro_ritmo		;976b
coche_otro_ritmo2:
	ld a,c			;976d
	cp 002h		;976e
	jr coche_otro_ritmo		;9770
coche_otro_mas_rapido:
	cp 0d0h		;9772   ; mucho mas lento?
	jr c,coche_otro_sube		;9774
	cp 0e0h		;9776
	jr c,coche_otro_ritmo2b		;9778
	cp 0f0h		;977a
	jr c,coche_otro_ritmo3b		;977c
	ld a,c			;977e
	cp 004h		;977f
coche_otro_ritmo_b:
	jr c,coche_otro_persigue		;9781
coche_otro_sube:		; Un pixel arriba
	ld (iy+007h),000h		;9783   ; la cuenta a 0
	dec (iy+000h)		;9787   ; un pixel arriba
	ld a,(iy+004h)		;978a
	cp 003h		;978d
	jr nz,coche_otro_persigue		;978f
	dec (iy+020h)		;9791
	dec (iy+030h)		;9794
	jr coche_otro_persigue		;9797
coche_otro_ritmo3b:
	ld a,c			;9799
	cp 003h		;979a
	jr coche_otro_ritmo_b		;979c
coche_otro_ritmo2b:
	ld a,c			;979e
	cp 002h		;979f
	jr coche_otro_ritmo_b		;97a1
coche_otro_persigue:		; El tipo 2, a la altura del coche, se va hacia su lado
	ld a,(iy+004h)		;97a3   ; el tipo 2?
	cp 002h		;97a6
	jr nz,coche_otro_carretera		;97a8
	ld bc,008fch		;97aa   ; a su altura?
	call cerca_y		;97ad
	jr nc,coche_otro_carretera		;97b0
	ld a,(iy+001h)		;97b2   ; a que lado esta el coche?
	cp (ix+001h)		;97b5
	jr c,coche_otro_persigue_izq		;97b8
	ld (iy+009h),001h		;97ba   ; a la derecha
	jr coche_otro_carretera		;97be
coche_otro_persigue_izq:
	ld (iy+009h),000h		;97c0   ; a la izquierda
coche_otro_carretera:		; Busca el borde de la carretera en su fila y se mantiene dentro, un pixel a cada lado
	ld hl,(0e186h)		;97c4   ; su fila
	ld a,(iy+000h)		;97c7
	cp 008h		;97ca   ; arriba del todo: la de arriba
	jr c,coche_otro_carretera_va		;97cc
	call carretera_fila		;97ce
coche_otro_carretera_va:
	push hl			;97d1
	ld a,(iy+004h)		;97d2   ; el camion...
	cp 003h		;97d5
	jr nz,coche_otro_lado		;97d7
	ld a,(0e00ah)		;97d9   ; ...en la zona 6: no
	cp 006h		;97dc
	jr z,coche_otro_choca_borde		;97de
coche_otro_lado:
	ld a,(iy+009h)		;97e0   ; su lado
	and a			;97e3
	jr nz,coche_otro_borde_i		;97e4
	ld de,00017h		;97e6   ; desde la derecha...
	add hl,de			;97e9
	ld b,015h		;97ea
coche_otro_borde_d:
	ld a,(hl)			;97ec   ; ...hasta la carretera (menos de 0x4E)
	cp 04eh		;97ed
	jr c,coche_otro_columna		;97ef
	dec hl			;97f1
	dec b			;97f2
	jr coche_otro_borde_d		;97f3
coche_otro_borde_i:
	ld b,001h		;97f5   ; desde la izquierda
coche_otro_borde_i_va:
	ld a,(hl)			;97f7   ; la casilla
	cp 04eh		;97f8
	jr c,coche_otro_columna		;97fa
	inc hl			;97fc
	inc b			;97fd
	jr coche_otro_borde_i_va		;97fe
coche_otro_columna:
	ld a,008h		;9800   ; la columna x 8 + 8
coche_otro_columna_x8:
	add a,008h		;9802
	djnz coche_otro_columna_x8		;9804
	ld c,a			;9806
	ld (iy+018h),000h		;9807   ; sin moverse
	ld a,(iy+009h)		;980b
	and a			;980e
	jr nz,coche_otro_margen		;980f
	ld a,004h		;9811   ; 4 de margen
	jr coche_otro_compara		;9813
coche_otro_margen:
	ld a,0fah		;9815   ; -6 de margen
coche_otro_compara:
	add a,c			;9817
	cp (iy+001h)		;9818   ; justo?
	jr z,coche_otro_choca_borde		;981b
	jr c,coche_otro_a_izq		;981d   ; a la izquierda
	call paso_coche		;981f   ; toca?
	and a			;9822
	jr z,coche_otro_choca_borde		;9823
	inc (iy+001h)		;9825   ; a la derecha
	ld (iy+018h),001h		;9828
	jr coche_otro_choca_borde		;982c
coche_otro_a_izq:
	call paso_coche		;982e
	and a			;9831
	jr z,coche_otro_choca_borde		;9832
	dec (iy+001h)		;9834   ; a la izquierda
	ld (iy+018h),002h		;9837
coche_otro_choca_borde:		; Si toca una casilla de borde (0x57 o mas), rebota hacia el otro lado
	pop hl			;983b
	push hl			;983c
	ld a,(iy+001h)		;983d   ; lo que pisa a la izquierda
	sub 004h		;9840
	call casilla_fila		;9842
	cp 057h		;9845   ; un borde (0x57 o mas)?
	jr c,coche_otro_mira_der		;9847
	pop hl			;9849
coche_otro_rebota:
	ld a,(iy+018h)		;984a   ; se movia?
	and a			;984d
	jr z,coche_otro_sin_rebote		;984e
	cp 001h		;9850
	jr nz,coche_otro_rebota_izq		;9852
	ld (iy+00eh),001h		;9854   ; rebota a la derecha
	jr coche_otro_sin_rebote		;9858
coche_otro_rebota_izq:
	ld (iy+00eh),0ffh		;985a   ; rebota a la izquierda
	jr coche_otro_sin_rebote		;985e
coche_otro_mira_der:
	pop hl			;9860
	ld a,(iy+001h)		;9861   ; lo que pisa a la derecha
	add a,004h		;9864
	call casilla_fila		;9866
	cp 057h		;9869
	jr c,coche_otro_pinta		;986b
	jr coche_otro_rebota		;986d
coche_otro_sin_rebote:
	ld (iy+00fh),000h		;986f   ; sin rebote
coche_otro_pinta:		; Los empujones y los sprites; despues, el camion o los coches
	call coche_rebote		;9873
	ld a,(iy+004h)		;9876   ; el camion?
	cp 003h		;9879
	jp nz,coche_empuja		;987b
	ld a,(iy+014h)		;987e   ; la cuenta del lado
	and a			;9881
	jr nz,camion		;9882
	ld a,r		;9884   ; al azar: 112-239 cuadros...
	and 07fh		;9886
	add a,070h		;9888
	ld (iy+014h),a		;988a
	call lado_cambia		;988d   ; ...y cambia de lado
camion:		; El camion: cambia de lado cada tanto al azar; desde la zona 4, cuando el coche esta en su columna, suelta algo por detras (+0x60)
	dec (iy+014h)		;9890   ; un cuadro menos
	ld a,(iy+000h)		;9893   ; en medio de la pantalla?
	cp 014h		;9896
	jr c,camion_tocado		;9898
	cp 070h		;989a
	jr nc,camion_tocado		;989c
	ld a,(iy+069h)		;989e   ; la espera de lo que suelta...
	cp 030h		;98a1
	jr nc,camion_suelta		;98a3
	inc (iy+069h)		;98a5   ; ...hasta 48
camion_suelta:
	ld bc,006fah		;98a8   ; el coche en su columna?
	call cerca_x		;98ab
	jr nc,camion_tocado		;98ae
	ld a,(0e00ah)		;98b0   ; desde la zona 4
	cp 004h		;98b3
	jr c,camion_tocado		;98b5
	ld a,(iy+064h)		;98b7   ; ya suelta?
	and a			;98ba
	jr nz,camion_tocado		;98bb
	ld a,(0e183h)		;98bd   ; el coche choca?
	and a			;98c0
	jr nz,camion_tocado		;98c1
	ld (iy+069h),000h		;98c3   ; suelta: el objeto de +0x60 es del tipo 5...
	ld (iy+064h),005h		;98c7
	ld (iy+065h),002h		;98cb
	ld a,(iy+000h)		;98cf   ; ...donde el camion
	ld (iy+060h),a		;98d2
	ld a,(iy+001h)		;98d5
	ld (iy+061h),a		;98d8
camion_tocado:		; Tocado dos veces, parpadea
	ld a,(iy+00ch)		;98db   ; tocado dos veces?
	cp 002h		;98de
	jr c,camion_disparo		;98e0
	ld a,(0e01fh)		;98e2   ; parpadea: color 9 o 10
	and 008h		;98e5
	rrca			;98e7
	rrca			;98e8
	rrca			;98e9
	add a,009h		;98ea
	ld (iy+003h),a		;98ec
	ld (iy+023h),a		;98ef
camion_disparo:		; El disparo rebota en el (el sonido 6)
	ld a,(ix+004h)		;98f2   ; el disparo?
	and a			;98f5
	jr z,camion_bomba		;98f6
	ld bc,006eah		;98f8
	call cerca_disparo_y		;98fb
	jr nc,camion_bomba		;98fe
	ld bc,006fah		;9900
	call cerca_disparo_x		;9903
	jr nc,camion_bomba		;9906
	ld a,006h		;9908   ; rebota: el efecto 6
	call efecto_pide		;990a
	call disparo_acaba		;990d
camion_bomba:		; Tres bombas lo destrozan: el sonido 1 y 500 puntos
	ld a,(ix+006h)		;9910   ; la bomba?
	and a			;9913
	jr z,camion_toca		;9914
	ld a,(ix+008h)		;9916   ; aun no estalla?
	cp 020h		;9919
	jr nc,camion_toca		;991b
	ld bc,008e8h		;991d
	call cerca_bomba_y		;9920
	jr nc,camion_toca		;9923
	ld bc,008f8h		;9925
	call cerca_bomba_x		;9928
	jr nc,camion_toca		;992b
	ld (ix+008h),021h		;992d   ; estalla
	inc (iy+00ch)		;9931   ; un golpe mas
	ld a,(iy+00ch)		;9934
	cp 003h		;9937   ; tres?
	jr c,camion_toca		;9939
	ld (iy+005h),002h		;993b   ; destrozado
	ld (iy+024h),001h		;993f
	ld (iy+004h),001h		;9943
	ld (iy+025h),002h		;9947
	ld a,(0e000h)		;994b   ; en partida...
	and a			;994e
	jr z,camion_toca		;994f
	ld a,001h		;9951   ; ...el efecto 1...
	call efecto_pide		;9953
	ld a,005h		;9956   ; ...y 500 puntos
	call puntos_centenas		;9958
camion_toca:		; Si toca al coche, 0xE183 = 4
	ld bc,00ce6h		;995b   ; el coche lo toca?
	call cerca_y		;995e
	ret nc			;9961
	ld bc,008f8h		;9962
	call cerca_x		;9965
	ret nc			;9968
	ld a,004h		;9969   ; choca
	ld (0e183h),a		;996b
	ret			;996e
coche_empuja:		; Un coche contra el de 0xE3E0: se empujan y cambian de lado
	ld a,(0e3e4h)		;996f   ; hay un coche en 0xE3E0?
	and a			;9972
	jr z,coche_contra_otros		;9973
	ld a,(0e3e1h)		;9975   ; cerca en X...
	sub (iy+001h)		;9978
	cp 00ch		;997b
	jr c,coche_empuja_y		;997d
	cp 0f4h		;997f
	jr c,coche_contra_otros		;9981
coche_empuja_y:
	ld a,(0e3e0h)		;9983   ; ...y en Y?
	sub (iy+000h)		;9986
	cp 00eh		;9989
	jr c,coche_empuja_arriba		;998b
	cp 0e2h		;998d
	jr c,coche_contra_otros		;998f
	ld (iy+00bh),002h		;9991   ; lo empuja hacia abajo...
	ld b,0c0h		;9995   ; ...frenandolo
	jr coche_empuja_vel		;9997
coche_empuja_arriba:
	ld (iy+00bh),0feh		;9999   ; hacia arriba...
	ld b,040h		;999d   ; ...acelerandolo
coche_empuja_vel:
	ld a,(iy+006h)		;999f
	add a,b			;99a2
	ld (iy+006h),a		;99a3
	ld (iy+00dh),000h		;99a6
	call lado_cambia		;99aa   ; y cambia de lado
coche_contra_otros:		; Contra los coches que vienen detras en la lista
	ld a,(0e183h)		;99ad   ; el coche choca?
	and a			;99b0
	jr z,coche_contra_va		;99b1
	cp 003h		;99b3   ; sin gasolina: sigue
	ret nz			;99b5
coche_contra_va:
	ld a,005h		;99b6   ; los que quedan detras en la lista
	sub (iy+015h)		;99b8
	jr z,coche_bomba		;99bb
	ld b,a			;99bd
	push ix		;99be
	push iy		;99c0
	pop ix		;99c2
coche_contra_uno:
	push bc			;99c4
	ld de,00020h		;99c5   ; el siguiente
	add ix,de		;99c8
	call coches_se_empujan		;99ca   ; se empujan?
	pop bc			;99cd
	djnz coche_contra_uno		;99ce
	pop ix		;99d0
coche_bomba:		; La bomba que lo toca lo destroza (el sonido 1 y sus puntos)
	ld a,(ix+006h)		;99d2   ; la bomba?
	and a			;99d5
	jr z,coche_disparo		;99d6
	ld bc,008f8h		;99d8
	call cerca_bomba_y		;99db
	jr nc,coche_disparo		;99de
	ld bc,008f8h		;99e0
	call cerca_bomba_x		;99e3
	jr nc,coche_disparo		;99e6
	ld (ix+008h),021h		;99e8   ; estalla
coche_destrozado:
	ld (iy+005h),002h		;99ec   ; el coche, destrozado
	ld a,(0e000h)		;99f0   ; en partida...
	and a			;99f3
	ret z			;99f4
	ld a,001h		;99f5   ; ...el efecto 1
	call efecto_pide		;99f7
	ld a,(iy+004h)		;99fa   ; el tipo 2?
	cp 002h		;99fd
	jr z,coche_bombas_mas		;99ff
	ld a,050h		;9a01   ; 50 puntos
	jp puntos		;9a03
coche_bombas_mas:		; El tipo 2 destrozado da 20 bombas mas y 100 puntos; los otros, 50
	ld (ix+00ch),020h		;9a06   ; 20 bombas
	call bombas_pinta		;9a0a
	ld a,001h		;9a0d   ; 100 puntos
	jp puntos_centenas		;9a0f
coche_disparo:		; El disparo: tres en el mismo coche lo destrozan (el sonido 6 en cada uno)
	ld a,(ix+004h)		;9a12   ; el disparo?
	and a			;9a15
	jr z,coche_parpadea		;9a16
	ld bc,006fah		;9a18
	call cerca_disparo_y		;9a1b
	jr nc,coche_parpadea		;9a1e
	ld bc,006fah		;9a20
	call cerca_disparo_x		;9a23
	jr nc,coche_parpadea		;9a26
	inc (iy+00ch)		;9a28   ; un golpe
	ld a,006h		;9a2b   ; el efecto 6
	call efecto_pide		;9a2d
	call disparo_acaba		;9a30
	ld a,(iy+00ch)		;9a33   ; tres?
	cp 003h		;9a36
	jr nc,coche_destrozado		;9a38
coche_parpadea:		; Tocado dos veces, parpadea
	ld a,(iy+00ch)		;9a3a   ; dos?
	cp 002h		;9a3d
	jr nz,coche_lado		;9a3f
	ld a,(0e01fh)		;9a41   ; parpadea
	and 004h		;9a44
	rrca			;9a46
	rrca			;9a47
	add a,009h		;9a48
	ld (iy+003h),a		;9a4a
coche_lado:		; Cada 64 cuadros, el tipo 2 cambia de lado
	ld a,(iy+003h)		;9a4d   ; el tipo 2 (color 13)?
	cp 00dh		;9a50
	jr nz,coche_choca		;9a52
	inc (iy+016h)		;9a54   ; la cuenta...
	ld a,(iy+016h)		;9a57
	cp 040h		;9a5a   ; ...64?
	jr c,coche_choca		;9a5c
	call lado_cambia		;9a5e   ; cambia de lado
	ld (iy+016h),000h		;9a61
coche_choca:		; El coche del jugador contra este: si va muy deprisa (0xE194 >= 0x82) choca (0xE183 = 4); si no, se empujan
	ld a,(ix+000h)		;9a65   ; la Y del coche menos la del otro
	sub (iy+000h)		;9a68
	cp 00ch		;9a6b   ; el coche por debajo?
	jr c,coche_choca_debajo		;9a6d
	cp 0f4h		;9a6f   ; por encima?
	jr nc,coche_choca_encima		;9a71
	ret			;9a73
coche_choca_debajo:
	ld a,(ix+001h)		;9a74   ; la X: el otro a la derecha?
	sub (iy+001h)		;9a77
	cp 00bh		;9a7a
	jr c,empuje1		;9a7c
	cp 0f5h		;9a7e   ; ...a la izquierda?
	jr nc,empuje2		;9a80
	ret			;9a82
coche_choca_encima:
	ld a,(ix+001h)		;9a83   ; la X
	sub (iy+001h)		;9a86
	cp 00bh		;9a89
	jr c,empuje3		;9a8b
	cp 0f5h		;9a8d
	jr nc,empuje4		;9a8f
	ret			;9a91
empuje1:
	ld a,(0e194h)		;9a92   ; muy deprisa: choca
	cp 082h		;9a95
	jp nc,choque_fuerte		;9a97
	call empuja_der		;9a9a   ; el coche a la derecha...
	call empujado_arriba		;9a9d   ; ...el otro arriba...
empuje_a_der:
	jp empujado_der		;9aa0   ; ...y a la derecha
empuje2:
	ld a,(0e194h)		;9aa3   ; muy deprisa: choca
	cp 082h		;9aa6
	jr nc,choque_fuerte		;9aa8
	call empuja_izq		;9aaa   ; el coche a la izquierda
	call empujado_arriba		;9aad
empuje_a_izq:
	jp empujado_izq		;9ab0
empuje3:
	ld a,(0e194h)		;9ab3   ; muy deprisa: choca
	cp 082h		;9ab6
	jr nc,choque_fuerte		;9ab8
	call empuja_der		;9aba
	call empujado_abajo		;9abd
	jr empuje_a_der		;9ac0
empuje4:
	ld a,(0e194h)		;9ac2   ; muy deprisa: choca
	cp 082h		;9ac5
	jr nc,choque_fuerte		;9ac7
	call empuja_izq		;9ac9
	call empujado_abajo		;9acc
	jr empuje_a_izq		;9acf
empuja_der:		; El coche hacia la derecha y frena 5 veces
	ld (ix+00ah),001h		;9ad1   ; el rebote: +1
empuja_frena:
	ld (ix+00bh),000h		;9ad5   ; la cuenta a 0
	ld b,005h		;9ad9   ; frena 5 veces
empuja_frena_uno:
	push bc			;9adb
	call frena		;9adc
	pop bc			;9adf
	djnz empuja_frena_uno		;9ae0
	ret			;9ae2
empuja_izq:		; Hacia la izquierda
	ld (ix+00ah),0ffh		;9ae3   ; el rebote: -1
	jr empuja_frena		;9ae7
empujado_abajo:		; El otro, abajo
	ld (iy+00bh),001h		;9ae9   ; el otro: +1 en Y
empujado_cuenta:
	ld (iy+00dh),000h		;9aed
	ret			;9af1
empujado_arriba:		; El otro, arriba
	ld (iy+00bh),0ffh		;9af2   ; -1 en Y
	jr empujado_cuenta		;9af6
empujado_der:
	ld (iy+009h),001h		;9af8   ; el lado
	ld (iy+00eh),0ffh		;9afc   ; -1 en X
empujado_fin:
	ld (iy+00fh),000h		;9b00
	ret			;9b04
empujado_izq:
	ld (iy+009h),000h		;9b05   ; el otro lado
	ld (iy+00eh),001h		;9b09   ; +1 en X
	jr empujado_fin		;9b0d
choque_fuerte:		; Choca: 0xE183 = 4 y el otro estalla
	ld a,004h		;9b0f   ; el coche choca
	ld (0e183h),a		;9b11
	ld (iy+005h),002h		;9b14   ; el otro estalla
	ret			;9b18
coche_estalla:		; El estallido: dibujos 0x34/0x38 cada 4 cuadros, 32 cuadros y fuera
	ld (iy+010h),0f0h		;9b19   ; su segundo sprite fuera
	ld a,(0e184h)		;9b1d   ; se acaba la zona?
	and a			;9b20
	jr z,coche_estalla_va		;9b21
	ld a,(ix+000h)		;9b23   ; con el coche arriba del todo: fuera
	cp 020h		;9b26
	jp c,coche_fuera_32		;9b28
coche_estalla_va:
	ld a,(0e013h)		;9b2b   ; el dibujo del estallido, cada 4 cuadros
	and 004h		;9b2e
	add a,034h		;9b30
	ld (iy+002h),a		;9b32
	ld (iy+003h),008h		;9b35   ; color 8
	inc (iy+00ah)		;9b39   ; la cuenta...
	ld a,(iy+00ah)		;9b3c
	cp 020h		;9b3f   ; ...32?
	jp c,coche_fuera		;9b41
	jp coche_fuera_32		;9b44   ; se acaba
paso_coche:		; NZ cada tantos cuadros segun la velocidad del coche (IY+6)
	ld a,(iy+006h)		;9b47   ; la velocidad del otro / 64
	and 0c0h		;9b4a
	rlca			;9b4c
	rlca			;9b4d
	ld b,a			;9b4e
	ld a,003h		;9b4f   ; 3 menos eso
	sub b			;9b51
	inc (iy+008h)		;9b52   ; la cuenta
	cp (iy+008h)		;9b55
	jr nc,paso_coche_no		;9b58
	ld (iy+008h),000h		;9b5a   ; toca
	ld a,001h		;9b5e
	ret			;9b60
paso_coche_no:
	xor a			;9b61
	ret			;9b62
coches_se_empujan:		; Dos coches de la lista que se tocan se empujan y se cambian la velocidad
	ld a,(ix+004h)		;9b63   ; el de detras existe?
	and a			;9b66
	ret z			;9b67
	ld a,(ix+005h)		;9b68   ; estallando no
	cp 002h		;9b6b
	ret z			;9b6d
	ld a,(ix+000h)		;9b6e   ; la Y
	sub (iy+000h)		;9b71
	cp 00ch		;9b74   ; cerca por encima?
	jr c,empujon3		;9b76
	cp 0f4h		;9b78   ; por debajo?
	ret c			;9b7a
	ld a,(ix+001h)		;9b7b   ; la X
	sub (iy+001h)		;9b7e
	cp 008h		;9b81
	jr c,empujon2		;9b83
	cp 0f8h		;9b85
	ret c			;9b87
	ld hl,0ffffh		;9b88   ; los empujones
	ld de,00101h		;9b8b
empujon:
	ld (ix+009h),001h		;9b8e   ; los lados
	ld (iy+009h),000h		;9b92
empujon_pon:
	ld (ix+00eh),h		;9b96   ; los empujones de los dos
	ld (ix+00bh),l		;9b99
	ld (iy+00eh),d		;9b9c
	ld (iy+00bh),e		;9b9f
	ld b,(ix+006h)		;9ba2   ; se cambian la velocidad
	ld c,(iy+006h)		;9ba5
	ld (iy+006h),b		;9ba8
	ld (ix+006h),c		;9bab
	ld (iy+00dh),000h		;9bae   ; las cuentas a 0
	ld (iy+00fh),000h		;9bb2
	ret			;9bb6
empujon2:
	ld hl,001ffh		;9bb7   ; los empujones al reves
	ld de,0ff01h		;9bba
empujon2_va:
	ld (ix+009h),000h		;9bbd
	ld (iy+009h),001h		;9bc1
	jr empujon_pon		;9bc5
empujon3:
	ld a,(ix+001h)		;9bc7   ; la X
	sub (iy+001h)		;9bca
	cp 008h		;9bcd
	jr c,empujon4		;9bcf
	cp 0f8h		;9bd1
	ret c			;9bd3
	ld hl,0ff01h		;9bd4
	ld de,001ffh		;9bd7
	jr empujon		;9bda
empujon4:
	ld hl,00101h		;9bdc
	ld de,0ffffh		;9bdf
	jr empujon2_va		;9be2
salen_coches:		; Cada tanto salen coches: el uno, el dos, el camion (el tres, en las zonas 3+), uno del tipo 4 y otro del 5 (zonas 6+); mas a menudo cuanto mas alta la zona
	ld a,(0e3e4h)		;9be4   ; ya hay un coche en 0xE3E0?
	and a			;9be7
	jr nz,salen_coches_cuenta		;9be8
	ld a,(0e009h)		;9bea   ; la segunda vuelta?
	and a			;9bed
	jr nz,salen_coches_rapido		;9bee
	ld a,(0e00ah)		;9bf0   ; desde la zona 3
	cp 003h		;9bf3
	jr c,salen_coches_cuenta		;9bf5
salen_coches_rapido:
	ld a,(0e194h)		;9bf7   ; y el coche deprisa
	cp 050h		;9bfa
	jr c,salen_coches_cuenta		;9bfc
	ld a,(0e1c1h)		;9bfe   ; la cuenta...
	inc a			;9c01
	ld (0e1c1h),a		;9c02
	cp 0f0h		;9c05   ; ...240 cuadros
	jr c,salen_coches_cuenta		;9c07
	xor a			;9c09
	ld (0e1c1h),a		;9c0a
	ld a,003h		;9c0d   ; un coche del tipo 3: el camion
	ld (0e3e4h),a		;9c0f
	ld a,(0e00ah)		;9c12   ; en la zona 6...
	cp 006h		;9c15
	jr nz,salen_coches_cuenta		;9c17
	ld a,060h		;9c19   ; ...en la X 0x60
	ld (0e3e1h),a		;9c1b
salen_coches_cuenta:
	ld a,(0e009h)		;9c1e   ; la segunda vuelta?
	and a			;9c21
	jr nz,salen_coches_marca		;9c22
	ld a,(0e00ah)		;9c24   ; o desde la zona 4
	cp 004h		;9c27
	jr c,salen_coches_espera		;9c29
salen_coches_marca:
	ld a,(0e19ch)		;9c2b   ; a la distancia 0x80...
	cp 080h		;9c2e
	jr nz,salen_coches_espera		;9c30
	ld a,004h		;9c32   ; ...una cosa del tipo 4
	ld (0e464h),a		;9c34
salen_coches_espera:
	ld a,(0e1c0h)		;9c37   ; la espera...
	dec a			;9c3a   ; ...un cuadro menos
	ld (0e1c0h),a		;9c3b
	ret nz			;9c3e
	ld a,(0e00ah)		;9c3f   ; la zona...
	ld b,a			;9c42
salen_coches_zona:
	add a,008h		;9c43   ; ...x 8 + 8
	djnz salen_coches_zona		;9c45
	ld b,a			;9c47
	ld a,080h		;9c48   ; 0x80 menos eso...
	sub b			;9c4a
	ld b,a			;9c4b
	ld a,r		;9c4c   ; ...mas algo al azar: la espera siguiente
	and 03fh		;9c4e
	add a,b			;9c50
	ld (0e1c0h),a		;9c51
	ld a,(0e344h)		;9c54   ; el primer hueco libre?
	and a			;9c57
	jr nz,sale_coche2		;9c58
	inc a			;9c5a   ; un coche del tipo 1
	ld (0e344h),a		;9c5b
	ld (0e355h),a		;9c5e
	ret			;9c61
sale_coche2:
	ld a,(0e364h)		;9c62   ; el segundo?
	and a			;9c65
	jr nz,sale_coche3		;9c66
	inc a			;9c68   ; tipo 1, lado 2
	ld (0e364h),a		;9c69
	inc a			;9c6c
	ld (0e375h),a		;9c6d
	ld a,(0e3e4h)		;9c70   ; con el camion fuera...
	and a			;9c73
	ret z			;9c74
	ld a,002h		;9c75   ; ...del tipo 2
	ld (0e364h),a		;9c77
	ret			;9c7a
sale_coche3:
	ld a,(0e384h)		;9c7b   ; el tercero?
	and a			;9c7e
	jr nz,sale_coche4		;9c7f
	inc a			;9c81   ; tipo 2, lado 3
	inc a			;9c82
	ld (0e384h),a		;9c83
	inc a			;9c86
	ld (0e395h),a		;9c87
	ret			;9c8a
sale_coche4:
	ld a,(0e3e4h)		;9c8b   ; con el camion fuera, nada mas
	and a			;9c8e
	ret nz			;9c8f
	ld a,(0e00ah)		;9c90   ; desde la zona 3
	cp 003h		;9c93
	ret c			;9c95
	ld a,(0e3a4h)		;9c96   ; el cuarto?
	and a			;9c99
	jr nz,sale_coche5		;9c9a
	inc a			;9c9c   ; tipo 1, lado 4
	ld (0e3a4h),a		;9c9d
	ld a,004h		;9ca0
	ld (0e3b5h),a		;9ca2
	ret			;9ca5
sale_coche5:
	ld a,(0e00ah)		;9ca6   ; desde la zona 6
	cp 006h		;9ca9
	ret c			;9cab
	ld a,(0e3c4h)		;9cac   ; el quinto?
	and a			;9caf
	jr nz,salen_coches_fin		;9cb0
	inc a			;9cb2   ; tipo 1, lado 5
	ld (0e3c4h),a		;9cb3
	ld a,005h		;9cb6
	ld (0e3d5h),a		;9cb8
	ret			;9cbb
salen_coches_fin:
	ret			;9cbc
presentacion:		; La presentacion: cuatro CASIO entran por la izquierda, la derecha, arriba y abajo y se juntan en el centro (filas 11 y 12), un paso cada 3 cuadros, 21 pasos; despues la musica 4 y 128 cuadros; el boton la corta
	ld a,001h		;9cbd   ; el paso 1
	ld (0e1a1h),a		;9cbf
	ld hl,0180ch		;9cc2   ; desde la fila 0, columna 12...
	ld (0e1a2h),hl		;9cc5
	ld hl,01aech		;9cc8   ; ...y desde la fila 23, columna 12
	ld (0e1a4h),hl		;9ccb
presentacion_cuadro:
	ld a,(0e043h)		;9cce   ; el boton?
	and a			;9cd1
	jr nz,presentacion_corta		;9cd2
	ld a,(0e014h)		;9cd4   ; cada 3 cuadros
	cp 003h		;9cd7
	jr c,presentacion_cuadro		;9cd9
	xor a			;9cdb   ; la cuenta a 0
	ld (0e014h),a		;9cdc
	call presentacion_final		;9cdf   ; el final, si toca
	call presentacion_filas		;9ce2   ; las filas de CASIO
	ld hl,0e1a1h		;9ce5   ; el paso siguiente
	inc (hl)			;9ce8
	ld a,(hl)			;9ce9
	cp 015h		;9cea   ; 21: se acaba
	jr nc,presentacion_fin		;9cec
	cp 009h		;9cee   ; desde el 9...
	jr c,presentacion_sig		;9cf0
	ld hl,(0e1a2h)		;9cf2   ; ...la de arriba baja una fila...
	ld bc,00020h		;9cf5
	add hl,bc			;9cf8
	ld (0e1a2h),hl		;9cf9
	ld hl,(0e1a4h)		;9cfc   ; ...y la de abajo sube una
	sbc hl,bc		;9cff
	ld (0e1a4h),hl		;9d01
presentacion_sig:
	jr presentacion_cuadro		;9d04
presentacion_fin:
	ld a,004h		;9d06   ; la musica 4
	call musica_pide		;9d08
presentacion_espera:
	ld a,(0e043h)		;9d0b   ; el boton?
	and a			;9d0e
	jr nz,presentacion_corta		;9d0f
	ld a,(0e014h)		;9d11   ; 128 cuadros
	cp 080h		;9d14
	jr c,presentacion_espera		;9d16
	ret			;9d18
presentacion_corta:
	xor a			;9d19
	ld (0e043h),a		;9d1a   ; ya visto
	call sonido_calla_pide		;9d1d   ; el sonido callado
	call pantalla_borra		;9d20   ; la pantalla en blanco
	ret			;9d23

; ----------------------------------------------------------------------
; DATOS casio_casillas: Las casillas de CASIO en grande: un espacio, ocho de
;   arriba, otro espacio, ocho de abajo y otro
;   0x9d24..0x9d37  (19 bytes)
DATA_casio_casillas:
	defb 010h	; 9d24
	defb 070h,072h,074h,076h,078h,07ah,07ch,07eh	; 9d25  prtvxz|~
	defb 010h	; 9d2d
	defb 071h,073h,075h,077h,079h,07bh,07dh,07fh	; 9d2e  qsuwy{}.
	defb 010h	; 9d36

; ======================================================================
; CODIGO 0x9d37..0x9da0  (105 bytes)
; ======================================================================


presentacion_filas:		; Un paso de la presentacion: los dos CASIO de los lados (sus dos filas, 0x9D25 y 0x9D2E) en las filas 11 y 12, que entran por la izquierda y la derecha casilla a casilla
	ld a,(0e1a1h)		;9d37   ; el paso...
	ld c,a			;9d3a
	cp 009h		;9d3b   ; ...no mas de 9
	jr c,presentacion_arriba		;9d3d
	ld c,009h		;9d3f
presentacion_arriba:
	ld hl,01980h		;9d41   ; en la fila 12, columna 0, menos el paso
	ld b,a			;9d44
	ld a,l			;9d45
	sub b			;9d46
	ld l,a			;9d47
	ex de,hl			;9d48
	ld hl,09d25h		;9d49   ; la fila de arriba de CASIO...
	ld b,000h		;9d4c
	call 0005ch		;9d4e   ; ...C casillas
	ld de,00020h		;9d51   ; la fila de abajo
	add hl,de			;9d54
	ex de,hl			;9d55
	ld hl,09d2eh		;9d56   ; la de abajo
	ld a,(0e1a1h)		;9d59
	cp 009h		;9d5c
	jr c,presentacion_abajo		;9d5e
	ld a,009h		;9d60
presentacion_abajo:
	ld c,a			;9d62
	call 0005ch		;9d63   ; LDIRVM
	ld hl,01960h		;9d66   ; la otra mitad, desde la fila 11
	ld a,(0e1a1h)		;9d69
	ld c,a			;9d6c
	cp 009h		;9d6d
	jr c,presentacion_izq		;9d6f
	sub 009h		;9d71   ; pasado el 9: se corre
	add a,l			;9d73
	ld l,a			;9d74
	ld c,009h		;9d75
presentacion_izq:
	ex de,hl			;9d77
	ld hl,09d2dh		;9d78   ; desde el final, hacia atras
	ld a,l			;9d7b
	sub c			;9d7c
	jr nc,presentacion_izq_va		;9d7d
	dec h			;9d7f
presentacion_izq_va:
	ld l,a			;9d80
	call 0005ch		;9d81   ; LDIRVM
	ld de,00020h		;9d84
	add hl,de			;9d87
	ex de,hl			;9d88
	ld a,(0e1a1h)		;9d89
	ld c,a			;9d8c
	cp 009h		;9d8d
	jr c,presentacion_der		;9d8f
	ld c,009h		;9d91
presentacion_der:
	ld hl,09d36h		;9d93   ; la ultima fila
	ld a,l			;9d96
	sub c			;9d97
	jr nc,presentacion_der_va		;9d98
	dec h			;9d9a
presentacion_der_va:
	ld l,a			;9d9b
	call 0005ch		;9d9c   ; LDIRVM
	ret			;9d9f

; ----------------------------------------------------------------------
; DATOS presentacion_fondo: Ocho espacios: el fondo de la presentacion
;   0x9da0..0x9da8  (8 bytes)
DATA_presentacion_fondo:
	defb 010h,010h,010h,010h,010h,010h,010h,010h	; 9da0  ........

; ----------------------------------------------------------------------
; DATOS bytes_9da8: Tres bytes sin lectura directa
;   0x9da8..0x9dab  (3 bytes)
DATA_bytes_9da8:
	defb 04fh,0cdh,05ch	; 9da8

; ----------------------------------------------------------------------
; DATOS tablas_tramos: Las listas de tramos de cada zona: la primera (0x9DAB),
;   la segunda (0x9DBB) y la tercera (0x9DCB), una palabra por zona
;   0x9dab..0x9ddb  (48 bytes)
DATA_tablas_tramos:
	defw 0a4cfh,0a600h,0a6d6h,0a734h,0a6c1h,0a6c4h,0a4deh,0a6d6h	; 9dab
	defw 0a0e1h,0a044h,09fffh,0a0e1h,09fa8h,09f56h,09f5dh,09fffh	; 9dbb
	defw 0a303h,0a284h,0a233h,0a303h,0a1beh,0a16ch,0a173h,0a233h	; 9dcb

; ----------------------------------------------------------------------
; DATOS tramos: Las listas de tramos de la carretera y sus dibujos (las
;   casillas de cada fila), por zona
;   0x9ddb..0xa800  (2597 bytes)
DATA_tramos:
	defb 06dh,06bh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh	; 9ddb  mk==============
	defb 06bh,06dh,06bh,03dh,03dh,04eh,03dh,03dh,04eh,03dh,03dh,04eh,03dh,03dh,04eh,03dh	; 9deb  kmk==N==N==N==N=
	defb 03dh,06bh,06ch,03dh,03dh,04eh,03dh,03dh,04eh,03dh,03dh,04eh,03dh,03dh,04eh,03dh	; 9dfb  =kl==N==N==N==N=
	defb 03dh,06ch,05dh,04fh,03dh,048h,03dh,03dh,048h,03dh,03dh,048h,03dh,03dh,048h,03dh	; 9e0b  =l]O=H==H==H==H=
	defb 03dh,05ch,06ah,05eh,050h,03dh,049h,03dh,03dh,049h,03dh,03dh,049h,03dh,03dh,049h	; 9e1b  =\j^P=I==I==I==I
	defb 03dh,03dh,05bh,069h,05fh,051h,03dh,04ah,03dh,03dh,04ah,03dh,03dh,04ah,03dh,03dh	; 9e2b  ==[i_Q=J==J==J==
	defb 04ah,03dh,03dh,05ah,068h,060h,052h,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh,03dh	; 9e3b  J==Zh`R=========
	defb 03dh,03dh,03dh,03dh,059h,067h,061h,053h,03dh,03dh,04bh,03dh,03dh,04bh,03dh,03dh	; 9e4b  ====YgaS==K==K==
	defb 04bh,03dh,03dh,04bh,03dh,058h,066h,062h,054h,03dh,03dh,04ch,03dh,03dh,04ch,03dh	; 9e5b  K==K=XfbT==L==L=
	defb 03dh,04ch,03dh,03dh,04ch,03dh,057h,065h,063h,055h,03dh,03dh,04dh,03dh,03dh,04dh	; 9e6b  =L==L=WecU==M==M
	defb 03dh,03dh,04dh,03dh,03dh,04dh,03dh,056h,064h,06bh,042h,044h,045h,046h,043h,06bh	; 9e7b  ==M==M=VdkBDEFCk
	defb 06dh,06bh,047h,047h,047h,047h,06bh,06dh,06dh,06bh,042h,044h,045h,046h,043h,06bh	; 9e8b  mkGGGGkmmkBDEFCk
	defb 06dh,098h,099h,03ch,03ch,03ch,03ch,098h,099h,095h,097h,03ch,03ch,03ch,03ch,03ch	; 9e9b  m..<<<<....<<<<<
	defb 095h,097h,094h,096h,03ch,03ch,03ch,03ch,03ch,094h,096h,0edh,09dh,0fdh,09dh,0edh	; 9eab  ....<<<<<.......
	defb 09dh,084h,09eh,0edh,09dh,0fdh,09dh,0edh,09dh,0dch,09dh,08bh,09eh,093h,09eh,0a4h	; 9ebb  ................
	defb 09eh,09ch,09eh,09ch,09eh,09ch,09eh,09ch,09eh,0adh,09eh,0edh,09dh,0fdh,09dh,0edh	; 9ecb  ................
	defb 09dh,0dch,09dh,0edh,09dh,0fdh,09dh,0edh,09dh,0dch,09dh,00dh,09eh,01eh,09eh,02fh	; 9edb  .............../
	defb 09eh,040h,09eh,051h,09eh,062h,09eh,073h,09eh,0dbh,09dh,073h,09eh,062h,09eh,051h	; 9eeb  .@.Q.b.s...s.b.Q
	defb 09eh,040h,09eh,02fh,09eh,01eh,09eh,00dh,09eh,0dch,09dh,0fch,09dh,00ch,09eh,0fch	; 9efb  .@./............
	defb 09dh,08ah,09eh,0fch,09dh,00ch,09eh,0fch,09dh,0ebh,09dh,092h,09eh,09bh,09eh,0ach	; 9f0b  ................
	defb 09eh,0a3h,09eh,0a3h,09eh,0a3h,09eh,0a3h,09eh,0b5h,09eh,0fch,09dh,00ch,09eh,0fch	; 9f1b  ................
	defb 09dh,0ebh,09dh,0fch,09dh,00ch,09eh,0fch,09dh,0ebh,09dh,01dh,09eh,02eh,09eh,03fh	; 9f2b  ...............?
	defb 09eh,050h,09eh,061h,09eh,072h,09eh,083h,09eh,0ebh,09dh,083h,09eh,072h,09eh,061h	; 9f3b  .P.a.r.......r.a
	defb 09eh,050h,09eh,03fh,09eh,02eh,09eh,01dh,09eh,0ech,09dh,007h,0ffh,000h,005h,0d6h	; 9f4b  .P.?............
	defb 09eh,0ffh,007h,006h,000h,005h,0d6h,09eh,007h,006h,001h,005h,0e6h,09eh,00dh,003h	; 9f5b  ................
	defb 000h,005h,0d6h,09eh,00ch,00ch,0ffh,006h,0f6h,09eh,001h,00ah,000h,005h,0d6h,09eh	; 9f6b  ................
	defb 001h,006h,001h,006h,0e6h,09eh,007h,003h,000h,005h,0d6h,09eh,006h,006h,0ffh,006h	; 9f7b  ................
	defb 0f6h,09eh,001h,014h,000h,005h,0d6h,09eh,001h,00ch,001h,006h,0e6h,09eh,00dh,00ah	; 9f8b  ................
	defb 000h,005h,0d6h,09eh,00ch,006h,0ffh,005h,0f6h,09eh,0feh,0aah,0a0h,007h,006h,000h	; 9f9b  ................
	defb 005h,0d6h,09eh,007h,008h,000h,00bh,0d6h,09eh,006h,003h,0ffh,004h,0f6h,09eh,004h	; 9fab  ................
	defb 01eh,000h,003h,0d6h,09eh,004h,009h,001h,003h,0e6h,09eh,00dh,00fh,000h,001h,0d6h	; 9fbb  ................
	defb 09eh,00ch,00ah,0ffh,004h,0f6h,09eh,003h,008h,000h,003h,0d6h,09eh,003h,003h,000h	; 9fcb  ................
	defb 007h,0d6h,09eh,003h,003h,000h,00ah,0d6h,09eh,003h,008h,000h,00dh,0d6h,09eh,003h	; 9fdb  ................
	defb 003h,001h,003h,0e6h,09eh,006h,003h,000h,00ah,0d6h,09eh,006h,001h,001h,006h,0e6h	; 9feb  ................
	defb 09eh,0feh,053h,0a1h,007h,009h,000h,005h,0d6h,09eh,007h,009h,001h,006h,0e6h,09eh	; 9ffb  ..S.............
	defb 010h,008h,000h,004h,0d6h,09eh,00fh,00eh,0ffh,004h,0f6h,09eh,002h,004h,000h,004h	; a00b  ................
	defb 0d6h,09eh,002h,00fh,001h,004h,0e6h,09eh,011h,007h,000h,004h,0d6h,09eh,010h,00dh	; a01b  ................
	defb 0ffh,004h,0f6h,09eh,004h,00fh,000h,004h,0d6h,09eh,004h,003h,001h,004h,0e6h,09eh	; a02b  ................
	defb 007h,005h,000h,007h,0d6h,09eh,0feh,0aah,0a0h,007h,006h,000h,005h,0d6h,09eh,006h	; a03b  ................
	defb 005h,0ffh,006h,0f6h,09eh,002h,007h,000h,007h,0d6h,09eh,002h,006h,001h,006h,0e6h	; a04b  ................
	defb 09eh,008h,002h,000h,005h,0d6h,09eh,007h,006h,0ffh,006h,0f6h,09eh,002h,014h,000h	; a05b  ................
	defb 005h,0d6h,09eh,002h,004h,001h,006h,0e6h,09eh,006h,003h,000h,005h,0d6h,09eh,006h	; a06b  ................
	defb 003h,000h,008h,0d6h,09eh,006h,004h,000h,004h,0d6h,09eh,006h,005h,001h,005h,0e6h	; a07b  ................
	defb 09eh,00bh,00fh,000h,004h,0d6h,09eh,00ah,003h,0ffh,005h,0f6h,09eh,008h,004h,000h	; a08b  ................
	defb 004h,0d6h,09eh,008h,003h,000h,008h,0d6h,09eh,007h,001h,0ffh,006h,0f6h,09eh,007h	; a09b  ................
	defb 003h,000h,005h,0d6h,09eh,007h,001h,000h,005h,0b6h,09eh,007h,002h,000h,005h,0d6h	; a0ab  ................
	defb 09eh,007h,001h,000h,005h,0b6h,09eh,007h,001h,000h,005h,0d6h,09eh,007h,002h,000h	; a0bb  ................
	defb 005h,0b6h,09eh,006h,003h,0ffh,005h,0f6h,09eh,003h,001h,000h,006h,0c6h,09eh,004h	; a0cb  ................
	defb 003h,001h,005h,0e6h,09eh,0ffh,007h,006h,000h,005h,0d6h,09eh,007h,004h,001h,005h	; a0db  ................
	defb 0e6h,09eh,00bh,00ah,000h,005h,0d6h,09eh,00ah,007h,0ffh,005h,0f6h,09eh,004h,014h	; a0eb  ................
	defb 000h,005h,0d6h,09eh,004h,003h,000h,00bh,0d6h,09eh,004h,00ah,000h,007h,0d6h,09eh	; a0fb  ................
	defb 004h,005h,001h,007h,0e6h,09eh,009h,00ah,000h,007h,0d6h,09eh,009h,003h,001h,007h	; a10b  ................
	defb 0e6h,09eh,00ch,00ah,000h,005h,0d6h,09eh,00bh,00ah,0ffh,005h,0f6h,09eh,002h,004h	; a11b  ................
	defb 000h,005h,0d6h,09eh,002h,007h,001h,005h,0e6h,09eh,009h,00fh,000h,003h,0d6h,09eh	; a12b  ................
	defb 008h,003h,0ffh,004h,0f6h,09eh,006h,003h,000h,003h,0d6h,09eh,006h,001h,001h,008h	; a13b  ................
	defb 0e6h,09eh,007h,003h,000h,008h,0d6h,09eh,007h,00ah,000h,005h,0d6h,09eh,007h,003h	; a14b  ................
	defb 000h,009h,0d6h,09eh,007h,001h,000h,008h,0d6h,09eh,007h,003h,000h,009h,0d6h,09eh	; a15b  ................
	defb 0ffh,010h,0ffh,000h,005h,026h,09fh,0ffh,010h,006h,000h,005h,026h,09fh,011h,006h	; a16b  .....&......&...
	defb 001h,006h,036h,09fh,016h,003h,000h,005h,026h,09fh,016h,00ch,0ffh,005h,046h,09fh	; a17b  ..6.....&.....F.
	defb 00ah,00ah,000h,005h,026h,09fh,00bh,006h,001h,005h,036h,09fh,010h,003h,000h,005h	; a18b  ....&.....6.....
	defb 026h,09fh,010h,006h,0ffh,005h,046h,09fh,00ah,014h,000h,005h,026h,09fh,00bh,00ch	; a19b  &.....F.....&...
	defb 001h,005h,036h,09fh,016h,00ah,000h,005h,026h,09fh,016h,006h,0ffh,006h,046h,09fh	; a1ab  ..6.....&.....F.
	defb 0feh,0eah,0a2h,010h,006h,000h,005h,026h,09fh,011h,003h,001h,004h,036h,09fh,013h	; a1bb  .......&.....6..
	defb 005h,000h,003h,026h,09fh,013h,001h,000h,00ch,026h,09fh,013h,020h,000h,00dh,026h	; a1cb  ...&.....&.. ..&
	defb 09fh,013h,001h,000h,00dh,026h,09fh,013h,002h,000h,00ch,026h,09fh,013h,001h,000h	; a1db  .....&.....&....
	defb 00ah,026h,09fh,013h,002h,000h,009h,026h,09fh,013h,001h,000h,007h,026h,09fh,013h	; a1eb  .&.....&.....&..
	defb 011h,000h,006h,026h,09fh,013h,00ah,0ffh,004h,046h,09fh,009h,008h,000h,004h,026h	; a1fb  ...&.....F.....&
	defb 09fh,00ah,009h,001h,003h,036h,09fh,012h,005h,000h,003h,026h,09fh,012h,001h,000h	; a20b  .....6.....&....
	defb 00dh,026h,09fh,012h,002h,000h,00ch,026h,09fh,012h,003h,0ffh,003h,046h,09fh,010h	; a21b  .&.....&.....F..
	defb 001h,001h,005h,036h,09fh,0feh,069h,0a3h,010h,009h,000h,005h,026h,09fh,011h,006h	; a22b  ...6..i.....&...
	defb 001h,005h,036h,09fh,016h,003h,000h,006h,026h,09fh,016h,008h,000h,003h,026h,09fh	; a23b  ..6.....&.....&.
	defb 016h,00eh,0ffh,004h,046h,09fh,008h,004h,000h,003h,026h,09fh,009h,00fh,001h,004h	; a24b  ....F.....&.....
	defb 036h,09fh,017h,007h,000h,003h,026h,09fh,017h,007h,0ffh,004h,046h,09fh,010h,001h	; a25b  6.....&.....F...
	defb 000h,006h,026h,09fh,010h,002h,000h,007h,026h,09fh,010h,015h,000h,009h,026h,09fh	; a26b  ..&.....&.....&.
	defb 010h,005h,000h,003h,026h,09fh,0feh,0eah,0a2h,010h,006h,000h,005h,026h,09fh,010h	; a27b  ....&........&..
	defb 005h,0ffh,005h,046h,09fh,00bh,007h,000h,003h,026h,09fh,00ch,006h,001h,005h,036h	; a28b  ...F.....&.....6
	defb 09fh,011h,002h,000h,005h,026h,09fh,011h,006h,0ffh,005h,046h,09fh,00bh,014h,000h	; a29b  .....&.....F....
	defb 005h,026h,09fh,00ch,004h,001h,005h,036h,09fh,00fh,003h,000h,005h,026h,09fh,00fh	; a2ab  .&.....6.....&..
	defb 003h,0ffh,002h,046h,09fh,00ch,004h,000h,003h,026h,09fh,00dh,005h,001h,003h,036h	; a2bb  ...F.....&.....6
	defb 09fh,011h,00fh,000h,003h,026h,09fh,011h,003h,0ffh,003h,046h,09fh,00eh,004h,000h	; a2cb  .....&.....F....
	defb 003h,026h,09fh,00fh,003h,001h,002h,036h,09fh,011h,001h,0ffh,005h,046h,09fh,010h	; a2db  .&.....6.....F..
	defb 00ah,000h,005h,026h,09fh,010h,003h,000h,009h,026h,09fh,010h,001h,000h,008h,026h	; a2eb  ...&.....&.....&
	defb 09fh,010h,003h,000h,009h,026h,09fh,0ffh,010h,006h,000h,005h,026h,09fh,011h,004h	; a2fb  .....&......&...
	defb 001h,006h,036h,09fh,014h,00ah,000h,005h,026h,09fh,014h,007h,0ffh,006h,046h,09fh	; a30b  ..6.....&.....F.
	defb 00dh,014h,000h,005h,026h,09fh,00eh,003h,001h,002h,036h,09fh,010h,00ah,000h,006h	; a31b  ....&.....6.....
	defb 026h,09fh,011h,005h,001h,007h,036h,09fh,015h,017h,000h,006h,026h,09fh,015h,00ah	; a32b  &.....6.....&...
	defb 0ffh,006h,046h,09fh,00bh,004h,000h,005h,026h,09fh,00ch,004h,001h,006h,036h,09fh	; a33b  ..F.....&.....6.
	defb 00fh,002h,000h,007h,026h,09fh,00fh,010h,000h,005h,026h,09fh,00fh,003h,0ffh,004h	; a34b  ....&.....&.....
	defb 046h,09fh,00ch,003h,000h,004h,026h,09fh,00dh,004h,001h,002h,036h,09fh,010h,003h	; a35b  F.....&.....6...
	defb 000h,005h,026h,09fh,010h,001h,000h,005h,006h,09fh,010h,002h,000h,005h,026h,09fh	; a36b  ..&...........&.
	defb 010h,001h,000h,005h,006h,09fh,010h,001h,000h,005h,026h,09fh,010h,002h,000h,005h	; a37b  ..........&.....
	defb 006h,09fh,011h,003h,001h,005h,036h,09fh,014h,001h,000h,006h,016h,09fh,013h,003h	; a38b  ......6.........
	defb 0ffh,005h,046h,09fh,0ffh,018h,002h,07bh,07bh,07bh,07bh,08bh,0a9h,0abh,06dh,06dh	; a39b  ..F....{{{{...mm
	defb 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,0a9h,0abh,0adh,07bh,07bh,07bh,07bh,07bh	; a3ab  mmmmmmmm...{{{{{
	defb 07bh,07bh,07bh,08bh,0a8h,0aah,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh	; a3bb  {{{...mmmmmmmmmm
	defb 0a8h,0aah,0adh,07bh,07bh,07bh,07bh,018h,001h,07bh,07bh,07bh,07bh,07bh,07bh,0ach	; a3cb  ...{{{{..{{{{{{.
	defb 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,0ach,07bh,07bh,07bh,07bh,07bh	; a3db  mmmmmmmmmm.{{{{{
	defb 07bh,018h,001h,09bh,09bh,09bh,09bh,09bh,09bh,0ach,06dh,06dh,06dh,06dh,06dh,06dh	; a3eb  {.........mmmmmm
	defb 06dh,06dh,06dh,06dh,0ach,09bh,09bh,09bh,09bh,09bh,09bh,00eh,002h,0a9h,0abh,06dh	; a3fb  mmmm...........m
	defb 006h,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,0a9h,0abh,0a8h,0aah,06dh,006h,06dh	; a40b  .mmmmmmmm....m.m
	defb 06dh,06dh,06dh,06dh,06dh,06dh,06dh,0a8h,0aah,003h,001h,088h,089h,08ah,004h,002h	; a41b  mmmmmmm.........
	defb 0a5h,0a7h,0a5h,0a7h,0a4h,0a6h,0a4h,0a6h,008h,002h,081h,083h,081h,083h,081h,083h	; a42b  ................
	defb 081h,083h,080h,082h,080h,082h,080h,082h,080h,082h,004h,002h,081h,083h,081h,083h	; a43b  ................
	defb 080h,082h,080h,082h,004h,004h,07ch,07dh,07dh,07fh,074h,075h,075h,077h,074h,075h	; a44b  ......|}}.tuuwtu
	defb 075h,077h,070h,071h,071h,073h,002h,002h,081h,083h,080h,082h,002h,002h,095h,097h	; a45b  uwpqqs..........
	defb 094h,096h,004h,002h,095h,097h,095h,097h,094h,096h,094h,096h,002h,002h,079h,07bh	; a46b  ..............y{
	defb 078h,07ah,002h,004h,079h,07bh,079h,07bh,079h,07bh,078h,07ah,002h,006h,095h,097h	; a47b  xz..y{y{y{xz....
	defb 098h,099h,098h,099h,098h,099h,098h,099h,094h,096h,002h,002h,0a5h,0a7h,0a4h,0a6h	; a48b  ................
	defb 004h,004h,0b6h,09eh,09eh,0b7h,09ch,0b4h,0b5h,09dh,09ch,0b2h,0b3h,09dh,0b0h,09eh	; a49b  ................
	defb 09eh,0b1h,006h,001h,06dh,06dh,06dh,06dh,06dh,06dh,004h,004h,06dh,06dh,06dh,06dh	; a4ab  ....mmmmmm..mmmm
	defb 06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,06dh,002h,003h,0ceh,0cfh	; a4bb  mmmmmmmmmmmm....
	defb 0c6h,0cbh,0c6h,0c7h,000h,0a0h,0a3h,0eeh,000h,0d2h,0a3h,000h,0ech,0a3h,005h,006h	; a4cb  ................
	defb 0a4h,0feh,009h,0feh,005h,0e3h,012h,029h,0a4h,0feh,00ah,002h,0b5h,0a4h,0feh,008h	; a4db  .......)........
	defb 0e2h,002h,029h,0a4h,0feh,00ah,002h,04fh,0a4h,0feh,00ah,0efh,004h,029h,0a4h,0feh	; a4eb  ..)....O.....)..
	defb 010h,002h,0b5h,0a4h,0feh,00ch,002h,0b5h,0a4h,0feh,028h,0e2h,012h,0b5h,0a4h,0feh	; a4fb  ..........(.....
	defb 010h,012h,04fh,0a4h,0feh,010h,0efh,012h,029h,0a4h,0feh,00ch,0e3h,012h,0b5h,0a4h	; a50b  ..O.....).......
	defb 0feh,00ah,0e4h,010h,029h,0a4h,0feh,008h,0e2h,010h,029h,0a4h,0e4h,012h,029h,0a4h	; a51b  ....).....)...).
	defb 0feh,002h,0e8h,012h,029h,0a4h,0feh,006h,0e4h,010h,029h,0a4h,0feh,006h,0e4h,012h	; a52b  ....).....).....
	defb 029h,0a4h,0feh,020h,0e7h,012h,0b5h,0a4h,0e8h,014h,0b5h,0a4h,0feh,01eh,0efh,002h	; a53b  ).. ............
	defb 029h,0a4h,0feh,010h,002h,04fh,0a4h,0feh,006h,0e2h,002h,0b5h,0a4h,0feh,002h,0e2h	; a54b  )....O..........
	defb 002h,0b5h,0a4h,0feh,002h,0e6h,002h,0b5h,0a4h,0feh,004h,0e2h,002h,029h,0a4h,0feh	; a55b  .............)..
	defb 008h,0eeh,002h,0adh,0a4h,0feh,002h,0eeh,002h,0adh,0a4h,0feh,002h,0e8h,002h,0adh	; a56b  ................
	defb 0a4h,0feh,004h,0e2h,002h,045h,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h,004h	; a57b  .....E..........
	defb 04fh,0a4h,0feh,02ch,0e4h,012h,0b5h,0a4h,0feh,010h,0e8h,010h,0adh,0a4h,0feh,008h	; a58b  O..,............
	defb 0e6h,010h,0adh,0a4h,0feh,00ch,0efh,012h,029h,0a4h,0feh,020h,002h,04fh,0a4h,0feh	; a59b  ........).. .O..
	defb 002h,012h,04fh,0a4h,0feh,002h,002h,04fh,0a4h,0feh,002h,012h,04fh,0a4h,0feh,002h	; a5ab  ..O....O....O...
	defb 002h,04fh,0a4h,0feh,002h,012h,04fh,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h	; a5bb  .O....O.........
	defb 0eeh,002h,0adh,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h,0e4h,012h,0b5h,0a4h	; a5cb  ................
	defb 0feh,010h,0eeh,012h,0adh,0a4h,0feh,008h,0eeh,012h,0adh,0a4h,0feh,020h,0eeh,012h	; a5db  ............. ..
	defb 0adh,0a4h,0feh,020h,0eeh,000h,0adh,0a4h,0feh,026h,002h,04fh,0a4h,0feh,004h,002h	; a5eb  ... .....&.O....
	defb 024h,0a4h,0feh,016h,0ffh,0feh,01fh,002h,087h,0a4h,0feh,003h,003h,067h,0a4h,0feh	; a5fb  $............g..
	defb 002h,003h,067h,0a4h,0feh,004h,002h,087h,0a4h,0feh,006h,0e3h,011h,067h,0a4h,0feh	; a60b  ..g..........g..
	defb 010h,00fh,07dh,0a4h,0feh,002h,00fh,095h,0a4h,0feh,010h,00eh,04fh,0a4h,0feh,008h	; a61b  ..}.........O...
	defb 0e4h,010h,087h,0a4h,0feh,024h,002h,095h,0a4h,0feh,002h,002h,087h,0a4h,0feh,004h	; a62b  .....$..........
	defb 0e2h,003h,087h,0a4h,0feh,002h,002h,095h,0a4h,0feh,004h,002h,095h,0a4h,0feh,004h	; a63b  ................
	defb 002h,095h,0a4h,0feh,021h,00eh,04fh,0a4h,0feh,004h,0e4h,00eh,06dh,0a4h,0feh,004h	; a64b  ....!.O.....m...
	defb 0e3h,00fh,07dh,0a4h,00fh,095h,0a4h,0feh,010h,0e2h,00fh,07dh,0a4h,0feh,002h,00fh	; a65b  ..}........}....
	defb 087h,0a4h,0feh,00ch,0e8h,00fh,0c7h,0a4h,0feh,002h,0e4h,00fh,077h,0a4h,0feh,008h	; a66b  ............w...
	defb 0e8h,00fh,0c7h,0a4h,0feh,010h,00dh,04fh,0a4h,0feh,020h,0e8h,001h,06dh,0a4h,0feh	; a67b  .......O.. ..m..
	defb 010h,0e8h,001h,06dh,0a4h,0feh,00ch,0e8h,00eh,06dh,0a4h,0feh,010h,0e8h,002h,07dh	; a68b  ...m.....m.....}
	defb 0a4h,0feh,010h,0e8h,001h,033h,0a4h,0feh,00ch,0e8h,001h,033h,0a4h,0feh,008h,0e4h	; a69b  .....3.....3....
	defb 003h,07dh,0a4h,0feh,010h,0e8h,001h,033h,0a4h,0feh,010h,002h,04fh,0a4h,0feh,010h	; a6ab  .}.....3....O...
	defb 002h,04fh,0a4h,0feh,0c0h,0ffh,0feh,0ffh,0ffh,0feh,001h,000h,0a0h,0a3h,0edh,000h	; a6bb  .O..............
	defb 0d2h,0a3h,000h,0ech,0a3h,005h,006h,0a4h,0feh,013h,0ffh,0feh,00bh,012h,04fh,0a4h	; a6cb  ..............O.
	defb 0feh,002h,002h,04fh,0a4h,0feh,008h,0e8h,012h,0b5h,0a4h,0feh,040h,0eeh,002h,0adh	; a6db  ...O........@...
	defb 0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h,004h	; a6eb  ................
	defb 09bh,0a4h,0feh,006h,008h,09bh,0a4h,0feh,008h,006h,09bh,0a4h,0feh,008h,004h,04fh	; a6fb  ...............O
	defb 0a4h,0feh,060h,0e6h,00eh,0b5h,0a4h,0feh,060h,0efh,002h,045h,0a4h,0feh,010h,0e4h	; a70b  ..`.....`..E....
	defb 006h,09bh,0a4h,0feh,004h,0e4h,006h,09bh,0a4h,0feh,008h,002h,04fh,0a4h,0feh,004h	; a71b  ............O...
	defb 0eeh,002h,045h,0a4h,0feh,0ffh,0feh,080h,0ffh,0feh,059h,0eeh,002h,0adh,0a4h,0feh	; a72b  ..E.......Y.....
	defb 008h,0eeh,002h,0adh,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,008h,004h,09bh,0a4h	; a73b  ................
	defb 0feh,004h,004h,04fh,0a4h,0feh,008h,0eeh,002h,061h,0a4h,0feh,010h,0efh,012h,045h	; a74b  ...O.....a.....E
	defb 0a4h,0feh,008h,0eeh,010h,0adh,0a4h,0feh,008h,0eeh,010h,0adh,0a4h,0feh,008h,0eeh	; a75b  ................
	defb 010h,0adh,0a4h,0feh,010h,012h,04fh,0a4h,0feh,008h,0e2h,012h,09bh,0a4h,0feh,008h	; a76b  ......O.........
	defb 0eeh,010h,0adh,0a4h,0feh,008h,0e6h,012h,0b5h,0a4h,0feh,010h,0efh,000h,0b5h,0a4h	; a77b  ................
	defb 0feh,020h,0efh,002h,09bh,0a4h,0feh,008h,002h,04fh,0a4h,0feh,008h,0efh,002h,09bh	; a78b  . .......O......
	defb 0a4h,0feh,010h,0eeh,002h,0adh,0a4h,0feh,008h,0eeh,002h,0adh,0a4h,0feh,040h,0eeh	; a79b  ..............@.
	defb 010h,0adh,0a4h,0feh,008h,0eeh,010h,0adh,0a4h,0feh,008h,0e4h,012h,04fh,0a4h,0feh	; a7ab  .............O..
	defb 040h,002h,09bh,0a4h,0feh,004h,012h,04fh,0a4h,0feh,004h,002h,09bh,0a4h,0feh,004h	; a7bb  @......O........
	defb 012h,04fh,0a4h,0feh,004h,002h,04fh,0a4h,0feh,004h,012h,09bh,0a4h,0feh,008h,002h	; a7cb  .O....O.........
	defb 09bh,0a4h,0feh,008h,012h,04fh,0a4h,0feh,008h,002h,04fh,0a4h,0feh,008h,012h,09bh	; a7db  .....O....O.....
	defb 0a4h,0feh,008h,002h,09bh,0a4h,0feh,008h,012h,04fh,0a4h,0feh,0b0h,002h,04fh,0a4h	; a7eb  .........O....O.
	defb 0feh,013h,0ffh,0fbh,000h	; a7fb

; ----------------------------------------------------------------------
; DATOS casillas_juego: Las casillas 0x30-0xEF del juego (los dibujos, 8
;   bytes); la carga de 0x680 bytes sigue hasta 0xAE80: las 16 ultimas son los
;   primeros bytes de 0xAE00
;   0xa800..0xae00  (1536 bytes)
DATA_casillas_juego:
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a800  ........
	defb 03ch,07eh,0ffh,0ffh,0ffh,0ffh,07eh,03ch	; a808  <~....~<
	defb 03ch,07eh,0ffh,0ffh,0ffh,0ffh,07eh,03ch	; a810  <~....~<
	defb 000h,000h,000h,01fh,01fh,01fh,01ch,01ch	; a818  ........
	defb 000h,000h,000h,0ffh,0ffh,0ffh,000h,000h	; a820  ........
	defb 000h,000h,000h,0f8h,0f8h,0f8h,038h,038h	; a828  ......88
	defb 01ch,01ch,01ch,01ch,01ch,01ch,01ch,01ch	; a830  ........
	defb 038h,038h,038h,038h,038h,038h,038h,038h	; a838  88888888
	defb 01ch,01ch,01fh,01fh,01fh,000h,000h,000h	; a840  ........
	defb 000h,000h,0ffh,0ffh,0ffh,000h,000h,000h	; a848  ........
	defb 038h,038h,0f8h,0f8h,0f8h,000h,000h,000h	; a850  88......
	defb 01ch,034h,024h,024h,028h,038h,030h,0deh	; a858  .4$$(80.
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a860  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a868  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a870  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a878  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a880  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a888  ........
	defb 0f8h,0f0h,0e0h,0c0h,0c0h,0e0h,0f0h,0f8h	; a890  ........
	defb 01fh,00fh,007h,003h,003h,007h,00fh,01fh	; a898  ........
	defb 0ffh,0c3h,09dh,0bfh,0b1h,09dh,0c1h,0ffh	; a8a0  ........
	defb 0ffh,0e7h,0dbh,0bdh,0bdh,081h,0bdh,0ffh	; a8a8  ........
	defb 0ffh,081h,0bdh,08fh,0e1h,0bdh,081h,0ffh	; a8b0  ........
	defb 0ffh,055h,055h,055h,055h,055h,055h,0ffh	; a8b8  .UUUUUU.
	defb 00ch,00ch,00ch,00ch,00ch,00ch,00ch,00ch	; a8c0  ........
	defb 006h,006h,006h,006h,006h,006h,006h,006h	; a8c8  ........
	defb 003h,003h,003h,003h,003h,003h,003h,003h	; a8d0  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; a8d8  ........
	defb 060h,060h,060h,060h,060h,060h,060h,060h	; a8e0  ````````
	defb 030h,030h,030h,030h,030h,030h,030h,030h	; a8e8  00000000
	defb 018h,018h,018h,018h,018h,018h,018h,018h	; a8f0  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; a8f8  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,03fh,03fh	; a900  ......??
	defb 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h	; a908  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; a910  ........
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h	; a918  ........
	defb 0fch,0fch,0fch,0fch,0fch,0fch,003h,003h	; a920  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; a928  ........
	defb 001h,001h,001h,001h,001h,001h,001h,001h	; a930  ........
	defb 003h,003h,003h,003h,003h,003h,0fch,0fch	; a938  ........
	defb 007h,007h,007h,007h,007h,007h,007h,007h	; a940  ........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; a948  ........
	defb 01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; a950  ........
	defb 03fh,03fh,03fh,03fh,03fh,03fh,0c0h,0c0h	; a958  ??????..
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; a960  ........
	defb 07fh,07fh,07fh,07fh,07fh,07fh,07fh,07fh	; a968  ........
	defb 03fh,03fh,03fh,03fh,03fh,03fh,03fh,03fh	; a970  ????????
	defb 01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; a978  ........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; a980  ........
	defb 007h,007h,007h,007h,007h,007h,007h,007h	; a988  ........
	defb 003h,003h,003h,003h,003h,003h,003h,003h	; a990  ........
	defb 001h,001h,001h,001h,001h,001h,001h,001h	; a998  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; a9a0  ........
	defb 0fch,0fch,0fch,0fch,0fch,0fch,0fch,0fch	; a9a8  ........
	defb 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h	; a9b0  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; a9b8  ........
	defb 0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h,0e0h	; a9c0  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; a9c8  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; a9d0  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a9d8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; a9e0  ........
	defb 0ffh,0dfh,0ffh,0fbh,0ffh,0dfh,0ffh,0ffh	; a9e8  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; a9f0  ........
	defb 000h,000h,054h,0aah,02ah,02ah,02bh,000h	; a9f8  ..T.**+.
	defb 07fh,0bfh,0dfh,0e0h,0e0h,0e0h,0e1h,0e2h	; aa00  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; aa08  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aa10  ........
	defb 0ffh,0feh,0fch,0f8h,0f8h,0f8h,0f8h,078h	; aa18  .......x
	defb 0e3h,0e3h,0e3h,0e3h,0e3h,0e3h,0e3h,0e3h	; aa20  ........
	defb 0aah,055h,0aah,055h,0aah,055h,0aah,055h	; aa28  .U.U.U.U
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aa30  ........
	defb 038h,038h,038h,038h,038h,038h,038h,038h	; aa38  88888888
	defb 0ffh,07fh,040h,050h,040h,044h,040h,040h	; aa40  ..@P@D@@
	defb 040h,040h,048h,040h,042h,040h,048h,0ffh	; aa48  @@H@B@H.
	defb 0ffh,0feh,0ffh,010h,010h,0ffh,088h,0ffh	; aa50  ........
	defb 0ffh,0ffh,0ffh,010h,0ffh,040h,002h,0ffh	; aa58  .....@..
	defb 0e1h,0e0h,0e0h,0e0h,0e0h,0c0h,080h,0ffh	; aa60  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; aa68  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aa70  ........
	defb 0b8h,078h,0f8h,0f8h,0f8h,004h,002h,001h	; aa78  .x......
	defb 07fh,0ffh,01fh,0ffh,007h,0ffh,001h,0ffh	; aa80  ........
	defb 0ffh,0fch,0ffh,0f0h,0ffh,0c0h,0ffh,080h	; aa88  ........
	defb 0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h,0ffh	; aa90  ........
	defb 0ffh,0ffh,0c0h,0ffh,0f0h,0ffh,0fch,0ffh	; aa98  ........
	defb 0ffh,0ffh,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; aaa0  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,080h	; aaa8  ........
	defb 0feh,0fch,0fch,0fch,0fch,0fch,0fch,0fch	; aab0  ........
	defb 0fch,0fch,0fch,0fch,0fch,0fch,0ffh,0ffh	; aab8  ........
	defb 0ffh,0ffh,07bh,042h,043h,042h,07ah,0ffh	; aac0  ..{BCBz.
	defb 0ffh,0ffh,0deh,050h,0deh,042h,05eh,0ffh	; aac8  ...P.B^.
	defb 0ffh,0ffh,0bch,0a4h,0a4h,0a4h,0bch,0ffh	; aad0  ........
	defb 005h,021h,007h,007h,09fh,001h,02bh,001h	; aad8  .!....+.
	defb 0ffh,0ffh,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; aae0  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,080h	; aae8  ........
	defb 0feh,0fch,0fch,0fch,0fch,0fch,0fch,0fch	; aaf0  ........
	defb 0fch,0fch,0fch,0fch,0fch,0fch,0ffh,0ffh	; aaf8  ........
	defb 0ffh,0ffh,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h	; ab00  ........
	defb 0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,0c0h,080h	; ab08  ........
	defb 0feh,0fch,003h,003h,003h,003h,003h,003h	; ab10  ........
	defb 003h,003h,003h,003h,003h,003h,0ffh,0ffh	; ab18  ........
	defb 080h,0ffh,0e0h,0ffh,0f8h,0ffh,0feh,0ffh	; ab20  ........
	defb 0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; ab28  ........
	defb 0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; ab30  ........
	defb 0ffh,080h,0ffh,0e0h,0ffh,0f8h,0ffh,0feh	; ab38  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab40  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab48  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab50  ........
	defb 002h,080h,038h,07fh,044h,0e3h,0c1h,0ffh	; ab58  ..8.D...
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab60  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ab68  ........
	defb 055h,055h,055h,055h,055h,055h,055h,055h	; ab70  UUUUUUUU
	defb 055h,055h,055h,055h,055h,055h,055h,055h	; ab78  UUUUUUUU
	defb 0ffh,0c0h,0a0h,090h,088h,084h,082h,081h	; ab80  ........
	defb 081h,082h,084h,088h,090h,0a0h,0c0h,0ffh	; ab88  ........
	defb 0ffh,003h,005h,009h,011h,021h,041h,081h	; ab90  .....!A.
	defb 081h,041h,021h,011h,009h,005h,003h,0ffh	; ab98  .A!.....
	defb 0c0h,080h,080h,0ffh,0f8h,0ffh,0ffh,0feh	; aba0  ........
	defb 0feh,0ffh,0fch,0ffh,0f0h,0ffh,080h,0c0h	; aba8  ........
	defb 003h,001h,007h,00fh,01fh,03fh,0ffh,07fh	; abb0  .....?..
	defb 080h,07fh,0ffh,01fh,0ffh,007h,0feh,0fch	; abb8  ........
	defb 0ffh,03fh,05fh,060h,060h,067h,064h,065h	; abc0  .?_``gde
	defb 065h,064h,067h,060h,060h,05fh,03fh,0ffh	; abc8  edg``_?.
	defb 0ffh,0fch,0fah,006h,006h,0e6h,026h,0a6h	; abd0  ......&.
	defb 0a6h,026h,0e6h,006h,006h,0fah,0fch,0ffh	; abd8  .&......
	defb 07eh,07eh,07eh,07eh,07eh,07eh,07eh,07eh	; abe0  ~~~~~~~~
	defb 090h,0e2h,0c8h,0c0h,0f0h,0e0h,0c2h,090h	; abe8  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; abf0  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; abf8  ........
	defb 003h,005h,00fh,015h,03fh,055h,0ffh,055h	; ac00  ....?U.U
	defb 0c7h,063h,0f1h,058h,0fch,056h,0ffh,055h	; ac08  .c.X.V.U
	defb 0ffh,0ffh,0ffh,01fh,01fh,01fh,01fh,01fh	; ac10  ........
	defb 0ffh,001h,003h,003h,003h,003h,003h,003h	; ac18  ........
	defb 01fh,01fh,01fh,01fh,01fh,01fh,03fh,07fh	; ac20  ......?.
	defb 003h,003h,003h,003h,003h,003h,0ffh,0ffh	; ac28  ........
	defb 0ffh,0ffh,07fh,03fh,01fh,08fh,0c7h,0e3h	; ac30  ...?....
	defb 0aah,001h,0aah,004h,0a8h,010h,0a0h,040h	; ac38  .......@
	defb 0ffh,0ffh,0ffh,0ffh,07fh,03fh,01fh,01fh	; ac40  .....?..
	defb 01fh,01fh,01fh,01fh,01fh,01fh,01fh,01fh	; ac48  ........
	defb 01fh,01fh,01fh,01fh,01fh,03fh,07fh,0ffh	; ac50  .....?..
	defb 0f0h,0f8h,0fch,0ffh,0ffh,0ffh,0ffh,0ffh	; ac58  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ac60  ........
	defb 001h,003h,007h,0ffh,0ffh,0ffh,0ffh,0ffh	; ac68  ........
	defb 0ffh,07fh,001h,07fh,001h,07fh,001h,0ffh	; ac70  ........
	defb 0ffh,0ffh,010h,0ffh,0ffh,022h,0ffh,0ffh	; ac78  ....."..
	defb 0fch,0f8h,0f0h,0f0h,0e0h,0c0h,0c0h,0c0h	; ac80  ........
	defb 0eeh,0feh,0dch,0fch,0fch,0feh,0fch,0f8h	; ac88  ........
	defb 0ffh,0ffh,0fdh,0ffh,0fbh,0efh,0ffh,0ffh	; ac90  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; ac98  ........
	defb 080h,084h,080h,0ffh,0ffh,0ffh,0ffh,004h	; aca0  ........
	defb 0f0h,0e0h,0e0h,0c0h,0c0h,088h,080h,088h	; aca8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; acb0  ........
	defb 001h,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; acb8  ........
	defb 0ffh,0ffh,002h,0ffh,080h,080h,0c0h,0e0h	; acc0  ........
	defb 080h,080h,0c4h,0c0h,0e0h,0f0h,0e0h,0e2h	; acc8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; acd0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; acd8  ........
	defb 0e0h,0f0h,0f8h,0f8h,0fch,0feh,0feh,0feh	; ace0  ........
	defb 0f0h,0f2h,0f0h,0f8h,0ech,0feh,0f6h,0ffh	; ace8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,080h	; acf0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0ffh	; acf8  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; ad00  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; ad08  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; ad10  ........
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h	; ad18  ........
	defb 080h,083h,0c7h,0dfh,0ffh,0ffh,0ffh,0ffh	; ad20  ........
	defb 0ffh,02ah,055h,02ah,055h,02ah,055h,07fh	; ad28  .*U*U*U.
	defb 07fh,07fh,07fh,07fh,07fh,0ffh,0ffh,0ffh	; ad30  ........
	defb 0ffh,02ah,055h,02ah,055h,02ah,055h,07fh	; ad38  .*U*U*U.
	defb 07fh,07fh,07fh,07fh,07fh,0ffh,0ffh,0ffh	; ad40  ........
	defb 0e7h,0cfh,0cfh,09fh,09fh,03fh,03fh,07fh	; ad48  .....??.
	defb 0feh,0fch,0fch,0f9h,0f9h,0f3h,0f3h,0e7h	; ad50  ........
	defb 0f8h,0e1h,087h,01fh,07fh,0ffh,0ffh,0ffh	; ad58  ........
	defb 0ffh,0ffh,0ffh,0feh,0f8h,0e1h,087h,01fh	; ad60  ........
	defb 01fh,087h,0e1h,0f8h,0feh,0ffh,0ffh,0ffh	; ad68  ........
	defb 0ffh,0ffh,0ffh,07fh,01fh,087h,0e1h,0f8h	; ad70  ........
	defb 0e7h,0f3h,0f3h,0f9h,0f9h,0fch,0fch,0feh	; ad78  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ad80  ........
	defb 001h,001h,003h,003h,007h,007h,00fh,00fh	; ad88  ........
	defb 01fh,01fh,03fh,03fh,07fh,07fh,0ffh,0ffh	; ad90  ..??....
	defb 0ffh,0ffh,07fh,07fh,03fh,03fh,01fh,01fh	; ad98  ....??..
	defb 00fh,00fh,007h,007h,003h,003h,001h,001h	; ada0  ........
	defb 0ffh,03fh,00fh,003h,000h,000h,000h,000h	; ada8  .?......
	defb 0ffh,0fch,0f0h,0c0h,000h,000h,000h,000h	; adb0  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0fch,0f0h,0c0h	; adb8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,03fh,00fh,003h	; adc0  .....?..
	defb 0ffh,0feh,0fch,0f8h,0f0h,0e0h,0c0h,080h	; adc8  ........
	defb 0f8h,0f8h,0fch,0fch,0feh,0feh,0ffh,0ffh	; add0  ........
	defb 080h,080h,0c0h,0c0h,0e0h,0e0h,0f0h,0f0h	; add8  ........
	defb 0f0h,0f0h,0e0h,0e0h,0c0h,0c0h,080h,080h	; ade0  ........
	defb 0ffh,0ffh,0feh,0feh,0fch,0fch,0f8h,0f8h	; ade8  ........
	defb 0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h,0e7h	; adf0  ........
	defb 07fh,03fh,03fh,09fh,09fh,0cfh,0cfh,0e7h	; adf8  .??.....

; ----------------------------------------------------------------------
; DATOS casillas_titulo: Las casillas 0x40-0x7F del titulo y la presentacion
;   0xae00..0xb000  (512 bytes)
DATA_casillas_titulo:
	defb 00fh,03fh,07fh,07fh,0ffh,0ffh,0ffh,0ffh	; ae00  .?......
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ae08  ........
	defb 080h,080h,0c0h,0c0h,0e0h,0f0h,0f0h,0f8h	; ae10  ........
	defb 0f0h,0fch,0feh,0feh,0ffh,0ffh,0ffh,0ffh	; ae18  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0bfh,0ffh	; ae20  ........
	defb 080h,000h,000h,000h,000h,000h,000h,000h	; ae28  ........
	defb 003h,003h,001h,001h,000h,000h,000h,000h	; ae30  ........
	defb 0ffh,0ffh,0ffh,0ffh,000h,000h,000h,000h	; ae38  ........
	defb 0ffh,010h,044h,0a9h,024h,095h,06eh,0bbh	; ae40  ..D.$.n.
	defb 000h,000h,000h,000h,000h,000h,000h,080h	; ae48  ........
	defb 000h,000h,000h,000h,000h,000h,000h,001h	; ae50  ........
	defb 000h,000h,000h,000h,000h,0ffh,0ffh,0ffh	; ae58  ........
	defb 06eh,0ffh,0ffh,080h,080h,07fh,03fh,00fh	; ae60  n.....?.
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; ae68  ........
	defb 07fh,03fh,03fh,01fh,01fh,00fh,00fh,007h	; ae70  .??.....
	defb 0ffh,0ffh,0ffh,0ffh,0feh,0feh,0f8h,0f0h	; ae78  ........
	defb 07fh,000h,000h,000h,000h,000h,000h,07fh	; ae80  ........
	defb 03fh,07fh,07fh,000h,000h,000h,03fh,000h	; ae88  ?.....?.
	defb 000h,000h,000h,000h,000h,000h,004h,000h	; ae90  ........
	defb 000h,000h,000h,000h,000h,000h,003h,001h	; ae98  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aea0  ........
	defb 06eh,000h,000h,000h,000h,000h,000h,000h	; aea8  n.......
	defb 03fh,07fh,07fh,000h,000h,000h,000h,000h	; aeb0  ?.......
	defb 000h,000h,000h,000h,000h,000h,000h,06ah	; aeb8  .......j
	defb 000h,000h,000h,000h,001h,003h,01fh,03fh	; aec0  .......?
	defb 07fh,03fh,01fh,00fh,007h,003h,001h,001h	; aec8  .?......
	defb 01fh,00fh,007h,003h,001h,000h,000h,000h	; aed0  ........
	defb 001h,001h,000h,000h,000h,001h,003h,007h	; aed8  ........
	defb 00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh	; aee0  ........
	defb 001h,000h,000h,000h,000h,000h,000h,001h	; aee8  ........
	defb 048h,000h,000h,000h,000h,000h,000h,000h	; aef0  H.......
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; aef8  ........
	defb 02ah,055h,07ch,0d7h,0ffh,0ffh,0ffh,0ffh	; af00  *U|.....
	defb 0ffh,0ffh,0ffh,0ffh,080h,0ffh,080h,080h	; af08  ........
	defb 07eh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; af10  ~.......
	defb 0f8h,0fch,0feh,0feh,0ffh,0ffh,07fh,07fh	; af18  ........
	defb 000h,000h,000h,000h,000h,000h,080h,0c0h	; af20  ........
	defb 0ffh,0ffh,0ffh,080h,07fh,07fh,03fh,01fh	; af28  ......?.
	defb 001h,000h,000h,000h,000h,000h,000h,000h	; af30  ........
	defb 0feh,001h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; af38  ........
	defb 000h,000h,000h,000h,000h,000h,000h,000h	; af40  ........
	defb 07eh,081h,0bdh,0a1h,0a1h,0bdh,081h,07eh	; af48  ~......~
	defb 07fh,080h,080h,080h,080h,080h,080h,07fh	; af50  ........
	defb 003h,004h,008h,008h,00fh,008h,008h,008h	; af58  ........
	defb 0c0h,020h,010h,010h,0f0h,010h,010h,010h	; af60  . ......
	defb 07fh,080h,080h,07eh,001h,001h,001h,0feh	; af68  ...~....
	defb 010h,010h,010h,010h,010h,010h,010h,010h	; af70  ........
	defb 07eh,081h,081h,081h,081h,081h,081h,07eh	; af78  ~......~
	defb 000h,000h,03fh,07fh,0ffh,0f0h,0e0h,0e0h	; af80  ..?.....
	defb 0e0h,0e0h,0e0h,0f0h,0ffh,07fh,03fh,000h	; af88  ......?.
	defb 000h,000h,0e0h,0f0h,0f8h,078h,000h,000h	; af90  .....x..
	defb 000h,000h,039h,079h,0f9h,0f3h,0e3h,000h	; af98  ..9y....
	defb 000h,000h,03eh,03eh,07fh,077h,077h,0e3h	; afa0  ..>>.ww.
	defb 0e3h,0e3h,0ffh,0ffh,0c1h,080h,080h,000h	; afa8  ........
	defb 000h,000h,003h,007h,00fh,00fh,00fh,08fh	; afb0  ........
	defb 087h,083h,0c0h,0cfh,0cfh,0e7h,0e3h,000h	; afb8  ........
	defb 000h,000h,0feh,0ffh,0ffh,007h,000h,0feh	; afc0  ........
	defb 0ffh,0ffh,007h,007h,0ffh,0ffh,0feh,000h	; afc8  ........
	defb 000h,000h,038h,039h,0bbh,0bbh,03bh,03bh	; afd0  ..89..;;
	defb 03bh,0bbh,0bbh,0bbh,0bbh,039h,038h,000h	; afd8  ;....98.
	defb 000h,000h,0ffh,0ffh,0ffh,0c1h,080h,080h	; afe0  ........
	defb 080h,080h,080h,0c1h,0ffh,0ffh,0ffh,000h	; afe8  ........
	defb 000h,000h,080h,0c0h,0e0h,0e0h,0e0h,0e0h	; aff0  ........
	defb 0e0h,0e0h,0e0h,0e0h,0e0h,0c0h,080h,000h	; aff8  ........

; ----------------------------------------------------------------------
; DATOS colores_juego: Los colores de las casillas del juego (0x680 bytes
;   desde aqui: siguen por 0xB600); en 0xB168, los de los bordes de la
;   carretera
;   0xb000..0xb600  (1536 bytes)
DATA_colores_juego:
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b000  ........
	defb 0b0h,0b0h,0bfh,0bfh,0bfh,0bfh,0b0h,0b0h	; b008  ........
	defb 080h,080h,08fh,08fh,08fh,08fh,080h,080h	; b010  ........
	defb 0f0h,0f0h,0f0h,070h,070h,070h,040h,040h	; b018  ...ppp@@
	defb 0f0h,0f0h,0f0h,07fh,07fh,07fh,0f0h,0f0h	; b020  ........
	defb 0f0h,0f0h,0f0h,070h,070h,070h,070h,070h	; b028  ...ppppp
	defb 040h,040h,040h,040h,040h,040h,040h,040h	; b030  @@@@@@@@
	defb 070h,070h,070h,070h,070h,070h,070h,070h	; b038  pppppppp
	defb 040h,040h,040h,040h,040h,0f0h,0f0h,0f0h	; b040  @@@@@...
	defb 0f0h,0f0h,04fh,04fh,04fh,0f0h,0f0h,0f0h	; b048  ..OOO...
	defb 070h,070h,040h,040h,040h,0f0h,0f0h,0f0h	; b050  pp@@@...
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b058  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b060  ........
	defb 0efh,0efh,0efh,0efh,0efh,0efh,0efh,0efh	; b068  ........
	defb 0efh,0efh,0efh,0efh,0efh,0efh,08fh,0ffh	; b070  ........
	defb 0efh,0efh,0efh,0efh,08fh,0ffh,08fh,0ffh	; b078  ........
	defb 0efh,0efh,08fh,0ffh,08fh,0ffh,08fh,0ffh	; b080  ........
	defb 08fh,0ffh,08fh,0ffh,08fh,0ffh,08fh,0ffh	; b088  ........
	defb 0e8h,0e8h,0e8h,0e8h,0e8h,0e8h,0e8h,0e8h	; b090  ........
	defb 0e8h,0e8h,0e8h,0e8h,0e8h,0e8h,0e8h,0e8h	; b098  ........
	defb 0ffh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0ffh	; b0a0  ........
	defb 0ffh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0ffh	; b0a8  ........
	defb 0ffh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0ffh	; b0b0  ........
	defb 08fh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,08fh	; b0b8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0c0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0c8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0d0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0d8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0e0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0e8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0f0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b0f8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0e8h,0e8h	; b100  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b108  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b110  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b118  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0e8h,0e8h	; b120  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b128  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b130  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0e8h,0e8h	; b138  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b140  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b148  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b150  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0e8h,0e8h	; b158  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b160  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b168  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,082h,082h	; b170  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b178  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b180  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b188  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,082h,082h	; b190  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b198  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b1a0  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,082h,082h	; b1a8  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b1b0  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b1b8  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b1c0  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,082h,082h	; b1c8  ........
	defb 0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h,0f2h	; b1d0  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh	; b1d8  ........
	defb 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,08fh,08fh	; b1e0  ........
	defb 023h,023h,023h,023h,023h,023h,023h,023h	; b1e8  ########
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b1f0  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b1f8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b200  ........
	defb 0ffh,0ffh,0ffh,0efh,0efh,0efh,0ffh,0ffh	; b208  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b210  ........
	defb 0ffh,0f1h,0f1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b218  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b220  ........
	defb 0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h	; b228  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b230  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b238  ........
	defb 04fh,074h,074h,074h,074h,074h,074h,074h	; b240  Ottttttt
	defb 074h,074h,074h,074h,074h,074h,074h,04fh	; b248  tttttttO
	defb 04fh,074h,04fh,074h,074h,04fh,074h,04fh	; b250  OtOttOtO
	defb 04fh,04fh,04fh,074h,04fh,074h,074h,04fh	; b258  OOOtOttO
	defb 0feh,0feh,0feh,0feh,0feh,0f1h,0f1h,01fh	; b260  ........
	defb 01fh,01fh,0efh,0efh,0efh,01fh,01fh,01fh	; b268  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b270  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b278  ........
	defb 0feh,0ffh,0feh,0ffh,0feh,0ffh,0feh,0ffh	; b280  ........
	defb 0efh,0feh,0efh,0feh,0efh,0feh,0efh,0feh	; b288  ........
	defb 0f1h,0feh,0f1h,0feh,0f1h,0feh,0f1h,0efh	; b290  ........
	defb 01fh,0efh,0e1h,0efh,0e1h,0efh,0e1h,0efh	; b298  ........
	defb 0ffh,0ffh,0feh,0feh,0feh,0feh,0feh,0feh	; b2a0  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0f1h,0f1h	; b2a8  ........
	defb 0f1h,0f1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b2b0  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,01fh,01fh	; b2b8  ........
	defb 08fh,08fh,0f8h,0f8h,0f8h,0f8h,0f8h,08fh	; b2c0  ........
	defb 08fh,08fh,0f8h,0f8h,0f8h,0f8h,0f8h,08fh	; b2c8  ........
	defb 08fh,08fh,0f8h,0f8h,0f8h,0f8h,0f8h,08fh	; b2d0  ........
	defb 0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h	; b2d8  ........
	defb 09fh,09fh,096h,096h,096h,096h,096h,096h	; b2e0  ........
	defb 096h,096h,096h,096h,096h,096h,091h,091h	; b2e8  ........
	defb 091h,091h,061h,061h,061h,061h,061h,061h	; b2f0  ..aaaaaa
	defb 061h,061h,061h,061h,061h,061h,01fh,01fh	; b2f8  aaaaaa..
	defb 0ffh,0ffh,0f3h,0f3h,0f3h,0f3h,0f3h,0f3h	; b300  ........
	defb 0f3h,0f3h,0f3h,0f3h,0f3h,0f3h,0fch,0fch	; b308  ........
	defb 0fch,0fch,0c3h,0c3h,0c3h,0c3h,0c3h,0c3h	; b310  ........
	defb 0c3h,0c3h,0c3h,0c3h,0c3h,0c3h,0cfh,0cfh	; b318  ........
	defb 0f7h,07fh,0f7h,07fh,0f7h,07fh,0f7h,07fh	; b320  ........
	defb 0ffh,074h,0f4h,074h,0f4h,074h,0f4h,074h	; b328  .t.t.t.t
	defb 07fh,071h,074h,071h,074h,071h,074h,071h	; b330  .qtqtqtq
	defb 04fh,041h,04fh,041h,04fh,041h,04fh,041h	; b338  OAOAOAOA
	defb 0ffh,07fh,0ffh,07fh,0ffh,07fh,0ffh,07fh	; b340  ........
	defb 04fh,01fh,04fh,01fh,04fh,01fh,04fh,01fh	; b348  O.O.O.O.
	defb 04fh,04fh,04fh,04fh,04fh,04fh,04fh,04fh	; b350  OOOOOOOO
	defb 032h,032h,072h,072h,0f7h,074h,074h,04fh	; b358  22rr.ttO
	defb 0efh,0ffh,0efh,0ffh,0efh,0ffh,0efh,0ffh	; b360  ........
	defb 01fh,0efh,01fh,0efh,01fh,0efh,01fh,0efh	; b368  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0feh,0feh	; b370  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b378  ........
	defb 0bfh,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h	; b380  ........
	defb 0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0bfh	; b388  ........
	defb 0bfh,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h	; b390  ........
	defb 0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,0bfh	; b398  ........
	defb 0e3h,0e3h,0f3h,03fh,0f3h,03fh,0ffh,031h	; b3a0  ...?.?.1
	defb 0f1h,03fh,0fch,03fh,0fch,03fh,0ech,0ech	; b3a8  .?.?.?..
	defb 0e3h,0e3h,0c3h,0c3h,0c3h,0c3h,0cfh,0c1h	; b3b0  ........
	defb 0fch,0c3h,0cfh,0c3h,0cfh,0c3h,0c1h,0c1h	; b3b8  ........
	defb 06fh,096h,096h,096h,096h,096h,096h,096h	; b3c0  o.......
	defb 096h,096h,096h,096h,096h,096h,096h,06fh	; b3c8  .......o
	defb 06fh,096h,096h,096h,096h,096h,096h,096h	; b3d0  o.......
	defb 096h,096h,096h,096h,096h,096h,096h,06fh	; b3d8  .......o
	defb 061h,061h,091h,091h,061h,061h,091h,091h	; b3e0  aa..aa..
	defb 0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h,0f4h	; b3e8  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b3f0  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b3f8  ........
	defb 0feh,0feh,0feh,0feh,0feh,0feh,0ffh,0feh	; b400  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0efh,0e1h	; b408  ........
	defb 01fh,01fh,01fh,061h,061h,061h,061h,061h	; b410  ...aaaaa
	defb 01fh,0f1h,0f1h,0f6h,0f6h,0f6h,0f6h,0f6h	; b418  ........
	defb 061h,061h,061h,061h,061h,061h,0f1h,0f1h	; b420  aaaaaa..
	defb 0f6h,0f6h,0f6h,0f6h,0f6h,0f6h,0ffh,0ffh	; b428  ........
	defb 0efh,0efh,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b430  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b438  ........
	defb 0efh,0efh,0efh,0efh,0e1h,0e1h,0e1h,0e1h	; b440  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h	; b448  ........
	defb 0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0e1h,0efh	; b450  ........
	defb 0e1h,0e1h,0e1h,0efh,0efh,0efh,0efh,0efh	; b458  ........
	defb 01fh,01fh,01fh,0efh,0efh,0efh,0efh,0efh	; b460  ........
	defb 0e1h,0e1h,0e1h,0efh,0efh,0efh,0efh,0efh	; b468  ........
	defb 01fh,0e1h,0feh,0e1h,0feh,0e1h,0feh,0ffh	; b470  ........
	defb 02fh,02fh,032h,02fh,02fh,032h,02fh,02fh	; b478  //2//2//
	defb 0b7h,0b7h,0b7h,0b7h,0b7h,0b7h,0b7h,0b7h	; b480  ........
	defb 074h,074h,074h,074h,074h,074h,074h,074h	; b488  tttttttt
	defb 07fh,07fh,074h,07fh,074h,074h,07fh,07fh	; b490  ..t.tt..
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b498  ........
	defb 0b7h,0b7h,0b7h,07fh,07fh,07fh,07fh,0b7h	; b4a0  ........
	defb 074h,074h,074h,074h,074h,074h,074h,074h	; b4a8  tttttttt
	defb 09fh,09fh,09fh,09fh,09fh,09fh,09fh,09fh	; b4b0  ........
	defb 0e6h,061h,061h,061h,061h,061h,061h,061h	; b4b8  .aaaaaaa
	defb 07fh,07fh,0b7h,07fh,0b7h,0b7h,0b7h,0b7h	; b4c0  ........
	defb 074h,074h,074h,074h,074h,074h,074h,074h	; b4c8  tttttttt
	defb 09fh,09fh,09fh,09fh,09fh,09fh,09fh,09fh	; b4d0  ........
	defb 061h,061h,061h,061h,061h,061h,061h,061h	; b4d8  aaaaaaaa
	defb 0b7h,0b7h,0b7h,0b7h,0b7h,0b7h,0b7h,0b7h	; b4e0  ........
	defb 074h,074h,074h,074h,074h,074h,074h,07fh	; b4e8  ttttttt.
	defb 09fh,09fh,09fh,09fh,09fh,09fh,09fh,0e1h	; b4f0  ........
	defb 061h,061h,061h,061h,061h,061h,061h,01fh	; b4f8  aaaaaaa.
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b500  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b508  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b510  ........
	defb 02fh,02fh,02fh,02fh,0f0h,0f0h,0f0h,0f0h	; b518  ////....
	defb 020h,020h,020h,020h,02fh,02fh,02fh,02fh	; b520      ////
	defb 02fh,0b1h,0b1h,0b1h,0b1h,0b1h,0b1h,021h	; b528  /......!
	defb 021h,021h,021h,021h,021h,02fh,02fh,02fh	; b530  !!!!!///
	defb 02fh,041h,041h,041h,041h,041h,041h,021h	; b538  /AAAAAA!
	defb 021h,021h,021h,021h,021h,02fh,02fh,02fh	; b540  !!!!!///
	defb 021h,021h,021h,021h,021h,021h,021h,021h	; b548  !!!!!!!!
	defb 021h,021h,021h,021h,021h,021h,021h,021h	; b550  !!!!!!!!
	defb 021h,021h,021h,021h,021h,02fh,02fh,02fh	; b558  !!!!!///
	defb 02fh,02fh,02fh,021h,021h,021h,021h,021h	; b560  ///!!!!!
	defb 021h,021h,021h,021h,021h,02fh,02fh,02fh	; b568  !!!!!///
	defb 02fh,02fh,02fh,021h,021h,021h,021h,021h	; b570  ///!!!!!
	defb 021h,021h,021h,021h,021h,021h,021h,021h	; b578  !!!!!!!!
	defb 02fh,02fh,02fh,02fh,02fh,02fh,02fh,02fh	; b580  ////////
	defb 020h,020h,020h,020h,020h,020h,020h,020h	; b588          
	defb 020h,020h,020h,020h,020h,020h,02fh,02fh	; b590        //
	defb 02fh,02fh,020h,020h,020h,020h,020h,020h	; b598  //      
	defb 020h,020h,020h,020h,020h,020h,020h,020h	; b5a0          
	defb 02fh,020h,020h,020h,0f0h,0f0h,0f0h,0f0h	; b5a8  /   ....
	defb 02fh,020h,020h,020h,0f0h,0f0h,0f0h,0f0h	; b5b0  /   ....
	defb 02fh,02fh,02fh,02fh,02fh,020h,020h,020h	; b5b8  /////   
	defb 02fh,02fh,02fh,02fh,02fh,020h,020h,020h	; b5c0  /////   
	defb 02fh,020h,020h,020h,020h,020h,020h,020h	; b5c8  /       
	defb 020h,020h,020h,020h,020h,020h,02fh,02fh	; b5d0        //
	defb 020h,020h,020h,020h,020h,020h,020h,020h	; b5d8          
	defb 020h,020h,020h,020h,020h,020h,020h,020h	; b5e0          
	defb 02fh,02fh,020h,020h,020h,020h,020h,020h	; b5e8  //      
	defb 021h,021h,021h,021h,021h,021h,021h,021h	; b5f0  !!!!!!!!
	defb 021h,021h,021h,021h,021h,021h,021h,021h	; b5f8  !!!!!!!!

; ----------------------------------------------------------------------
; DATOS colores_titulo: Los colores de las casillas del titulo
;   0xb600..0xb780  (384 bytes)
DATA_colores_titulo:
	defb 0b0h,0b0h,0b0h,0b0h,0bfh,0bfh,0bfh,0bfh	; b600  ........
	defb 0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,0bfh	; b608  ........
	defb 0a0h,0a0h,0b0h,0a0h,0b0h,0b0h,0b0h,0b0h	; b610  ........
	defb 0b0h,0b0h,0b0h,0b0h,0bfh,0bfh,0bfh,0bfh	; b618  ........
	defb 0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,0fbh,0afh	; b620  ........
	defb 060h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b628  `.......
	defb 0b0h,0b0h,0b0h,0b0h,0f0h,0f0h,0f0h,0f0h	; b630  ........
	defb 0bfh,0bfh,0bfh,06fh,0f0h,0f0h,0f0h,0f0h	; b638  ...o....
	defb 0afh,0bah,0bah,0bah,0bah,0bah,0bah,0bah	; b640  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0b0h	; b648  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0b0h	; b650  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0bfh,0bfh,0bfh	; b658  ........
	defb 0bah,0bfh,0bfh,0fbh,0fbh,0b0h,0b0h,060h	; b660  .......`
	defb 0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,06fh	; b668  .......o
	defb 0a0h,0a0h,0a0h,0a0h,0b0h,0b0h,0b0h,0b0h	; b670  ........
	defb 0bfh,0bfh,0bfh,0bfh,0b0h,0b0h,0b0h,060h	; b678  .......`
	defb 0b0h,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,060h	; b680  .......`
	defb 0b0h,0b0h,0b0h,0fbh,0fbh,0fbh,0fbh,0fah	; b688  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0afh,0fah	; b690  ........
	defb 0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0bfh,0fah	; b698  ........
	defb 0fah,0fah,0fah,0fah,0fah,0fah,0fah,0f6h	; b6a0  ........
	defb 0bah,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,0f6h	; b6a8  ........
	defb 0b0h,0b0h,0b0h,0fbh,0fbh,0fbh,0fbh,0fbh	; b6b0  ........
	defb 0fah,0fah,0fah,0fah,0fah,0fah,0fah,0abh	; b6b8  ........
	defb 0fah,0fah,0fah,0fah,00ah,00ah,00bh,00ah	; b6c0  ........
	defb 0a0h,0b0h,0b0h,0b0h,0b0h,0b0h,0b0h,060h	; b6c8  .......`
	defb 00bh,00bh,00bh,00bh,00bh,0fbh,0fbh,0f6h	; b6d0  ........
	defb 0afh,0fah,0fah,0fah,0fah,00ah,00ah,00ah	; b6d8  ........
	defb 0f0h,0a0h,0a0h,0a0h,0a0h,0a0h,0a0h,060h	; b6e0  .......`
	defb 00bh,0fbh,0fbh,0fbh,0fbh,0fbh,0fbh,006h	; b6e8  ........
	defb 0bfh,0fah,0fah,0fah,0fah,0fah,0fah,0fah	; b6f0  ........
	defb 0ffh,0fah,0fah,0fah,0fah,0fah,0fah,0f6h	; b6f8  ........
	defb 0bah,0bah,0bah,0bah,0bfh,0bfh,0bfh,0bfh	; b700  ........
	defb 0bfh,0bfh,0bfh,0bfh,0fbh,0bfh,0fbh,0f6h	; b708  ........
	defb 0b0h,0bfh,0bfh,0bfh,0bfh,0bfh,0bfh,0bfh	; b710  ........
	defb 0b0h,0b0h,0b0h,0b0h,0bfh,0bfh,0b0h,060h	; b718  .......`
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0b0h,060h	; b720  .......`
	defb 0bfh,0bfh,0bfh,0fbh,0b0h,0b0h,0b0h,060h	; b728  .......`
	defb 060h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b730  `.......
	defb 0f0h,0fah,0afh,0afh,0afh,0afh,0afh,0afh	; b738  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b740  ........
	defb 0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h,0f0h	; b748  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b750  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b758  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b760  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b768  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b770  ........
	defb 080h,080h,080h,080h,080h,080h,080h,080h	; b778  ........

; ----------------------------------------------------------------------
; DATOS nombres_zonas: Los nombres de las zonas: la tabla y los textos que se
;   escriben letra a letra en el mapa
;   0xb780..0xb800  (128 bytes)
DATA_nombres_zonas:
	defw 0b79eh,0b792h,0b7aah,0b7b6h,0b7c2h,0b7ceh,0b7dah,0b7e6h,0b7f2h	; b780
	defb 009h,01ch,01fh,023h,011h,01eh,017h,015h,01ch,023h,00dh,00dh	; b792  ...#.....#..
	defb 005h,013h,019h,023h,013h,01fh,00dh,00dh,00dh,00dh,00dh,00dh	; b79e  ...#........
	defb 008h,023h,011h,01eh,014h,019h,015h,017h,01fh,00dh,00dh,00dh	; b7aa  .#..........
	defb 008h,01ch,011h,023h,026h,015h,017h,011h,023h,00dh,00dh,00dh	; b7b6  ...#&...#...
	defb 005h,024h,015h,028h,011h,023h,00dh,00dh,00dh,00dh,00dh,00dh	; b7c2  .$.(.#......
	defb 005h,014h,011h,022h,011h,023h,00dh,00dh,00dh,00dh,00dh,00dh	; b7ce  ...".#......
	defb 005h,01dh,019h,011h,01dh,019h,00dh,00dh,00dh,00dh,00dh,00dh	; b7da  ............
	defb 007h,013h,018h,019h,013h,011h,017h,01fh,00dh,00dh,00dh,00dh	; b7e6  ............
	defb 009h,027h,011h,023h,019h,01eh,017h,024h,01fh,01eh,0f0h,0f0h	; b7f2  .'.#...$....
	defb 0f0h,0f0h	; b7fe

; ----------------------------------------------------------------------
; DATOS sprites: Los dibujos de los sprites; la copia de 2 KB sigue por las
;   tablas, el codigo y la musica hasta el final de la ROM
;   0xb800..0xba80  (640 bytes)
DATA_sprites:
	defb 003h,00fh,017h,01bh,007h,0c7h,0ceh,0f4h,0f0h,005h,013h,01bh,01ch,01eh,01fh,00ch	; b800  ................
	defb 0c0h,0f0h,0e8h,0f8h,0f0h,0f0h,070h,038h,018h,0e0h,0e8h,0f8h,038h,078h,0f0h,030h	; b810  ......p8....8x.0
	defb 000h,000h,000h,000h,010h,010h,011h,003h,007h,018h,008h,000h,003h,001h,000h,003h	; b820  ................
	defb 010h,008h,004h,006h,00eh,00fh,08fh,0c7h,0e7h,01fh,017h,007h,0c6h,086h,00ch,0c8h	; b830  ................
	defb 003h,00fh,017h,01bh,007h,007h,00eh,01ch,018h,005h,013h,019h,01ch,01eh,00fh,00ch	; b840  ................
	defb 0c0h,0f0h,0e8h,0f8h,0f0h,0f0h,070h,03fh,01fh,0e0h,0e8h,0f8h,038h,078h,0f8h,030h	; b850  ......p?....8x.0
	defb 003h,00fh,017h,01bh,007h,007h,00eh,0f4h,0f0h,0c5h,0d3h,01bh,01ch,01eh,01fh,00ch	; b860  ................
	defb 0c0h,0f0h,0e8h,0f8h,0f0h,0f0h,070h,038h,018h,0e0h,0e8h,0f8h,038h,078h,0f0h,030h	; b870  ......p8....8x.0
	defb 003h,00fh,017h,01bh,007h,007h,00eh,0f4h,0f0h,005h,013h,01bh,01ch,01eh,01fh,00ch	; b880  ................
	defb 0c0h,0f0h,0e8h,0f8h,0f0h,0f0h,070h,038h,018h,0e0h,0e8h,0f8h,038h,078h,0f0h,030h	; b890  ......p8....8x.0
	defb 007h,00fh,01fh,00fh,00ch,00ch,018h,013h,013h,013h,018h,008h,009h,00dh,01fh,00ch	; b8a0  ................
	defb 0e0h,0f0h,0f8h,0f0h,030h,010h,018h,0e8h,0e8h,0e8h,018h,030h,0f0h,0b0h,0f8h,030h	; b8b0  ....0......0...0
	defb 000h,000h,000h,010h,011h,013h,003h,008h,008h,008h,007h,013h,010h,012h,000h,003h	; b8c0  ................
	defb 010h,008h,004h,00ch,0cch,0ech,0e6h,017h,017h,017h,0e7h,0cfh,00fh,04eh,006h,0c8h	; b8d0  .............N..
	defb 001h,01bh,003h,00ah,00fh,01fh,01fh,01fh,01ch,008h,008h,018h,00fh,00dh,00ch,00fh	; b8e0  ................
	defb 080h,0d8h,0c0h,050h,0f0h,0f8h,0f8h,0f8h,038h,010h,010h,018h,0f0h,0f0h,030h,0f0h	; b8f0  ...P....8.....0.
	defb 000h,004h,010h,011h,010h,000h,000h,000h,003h,004h,005h,005h,010h,010h,013h,010h	; b900  ................
	defb 040h,020h,008h,088h,00ch,004h,006h,006h,0c6h,0efh,0efh,0e7h,00fh,00eh,0cch,008h	; b910  @ ..............
	defb 00fh,010h,013h,013h,00bh,006h,00bh,017h,017h,016h,014h,014h,016h,017h,017h,017h	; b920  ................
	defb 0f0h,008h,0e8h,0e8h,0f0h,060h,0f0h,0f8h,0f8h,078h,038h,078h,0f8h,0f8h,0f8h,0f8h	; b930  .....`...x8x....
	defb 000h,007h,008h,008h,000h,000h,000h,000h,000h,001h,003h,001h,000h,000h,000h,000h	; b940  ................
	defb 008h,0e6h,016h,016h,00eh,018h,00eh,007h,007h,087h,0c7h,087h,007h,007h,007h,007h	; b950  ................
	defb 016h,014h,014h,016h,017h,017h,017h,016h,014h,014h,016h,017h,017h,017h,013h,00eh	; b960  ................
	defb 078h,038h,078h,0f8h,0f8h,0f8h,0f8h,078h,038h,078h,0f8h,0f8h,0f8h,0f8h,0f8h,070h	; b970  x8x....x8x.....p
	defb 001h,003h,001h,000h,000h,000h,000h,001h,003h,001h,000h,000h,000h,000h,000h,001h	; b980  ................
	defb 087h,0c7h,087h,007h,007h,007h,007h,087h,0c7h,087h,007h,007h,007h,007h,006h,08ch	; b990  ................
	defb 000h,000h,000h,002h,000h,000h,002h,008h,003h,001h,008h,000h,000h,000h,000h,000h	; b9a0  ................
	defb 000h,000h,000h,000h,040h,008h,080h,040h,040h,0d0h,008h,080h,010h,000h,000h,000h	; b9b0  ....@..@@.......
	defb 089h,000h,040h,020h,000h,084h,008h,000h,084h,011h,000h,004h,001h,010h,000h,040h	; b9c0  ..@ ...........@
	defb 020h,002h,000h,014h,081h,000h,020h,080h,002h,050h,005h,000h,000h,010h,001h,088h	; b9d0   ..... ..P......
	defb 000h,000h,000h,003h,006h,00dh,01bh,03bh,07bh,07dh,03fh,00fh,003h,001h,000h,000h	; b9e0  .......;{}?.....
	defb 000h,000h,0f8h,0fch,0fch,0feh,0ffh,0ffh,0ffh,0feh,0fch,0fch,0f8h,0e0h,002h,000h	; b9f0  ................
	defb 000h,000h,000h,000h,000h,003h,003h,003h,003h,000h,000h,000h,000h,000h,000h,000h	; ba00  ................
	defb 000h,000h,000h,000h,000h,0c0h,0c0h,0c0h,0c0h,000h,000h,000h,000h,000h,000h,000h	; ba10  ................
	defb 000h,000h,000h,000h,001h,002h,003h,001h,003h,002h,001h,000h,000h,000h,000h,000h	; ba20  ................
	defb 000h,000h,000h,080h,0c0h,0a0h,0e0h,040h,0e0h,0a0h,0c0h,080h,000h,000h,000h,000h	; ba30  .......@........
	defb 000h,0aah,055h,0aah,055h,0aah,055h,000h,080h,080h,080h,080h,080h,000h,000h,000h	; ba40  ..U.U.U.........
	defb 000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h,000h	; ba50  ................
	defb 000h,000h,000h,000h,007h,00eh,000h,01dh,01dh,000h,01dh,01dh,000h,000h,000h,000h	; ba60  ................
	defb 000h,000h,000h,000h,078h,0f8h,018h,0d0h,0c8h,018h,0d0h,0c0h,000h,000h,000h,000h	; ba70  ....x...........

; ----------------------------------------------------------------------
; DATOS musicas: Las seis musicas: los tres canales de cada una (0 calla; 1,
;   2... 5)
;   0xba80..0xbaa4  (36 bytes)
DATA_musicas:
	defw 0be59h,0be59h,0be59h	; ba80  -> DATA_piezas DATA_piezas DATA_piezas
	defw 0be5dh,0be91h,0bec6h	; ba86
	defw 0bef7h,0bef7h,0bef7h	; ba8c
	defw 0bef7h,0bf17h,0bf2ah	; ba92
	defw 0bf39h,0bf3dh,0bf41h	; ba98
	defw 0bf47h,0bf4ch,0bf94h	; ba9e

; ----------------------------------------------------------------------
; DATOS efectos: Los nueve efectos: los canales B y C de cada uno
;   0xbaa4..0xbac8  (36 bytes)
DATA_efectos:
	defw 0be59h,0be59h	; baa4  -> DATA_piezas DATA_piezas
	defw 0bf47h,0bf4ch	; baa8
	defw 0bf51h,0bf94h	; baac
	defw 0bf58h,0bf94h	; bab0
	defw 0bf6ah,0bf71h	; bab4
	defw 0bf78h,0bf94h	; bab8
	defw 0bf7eh,0bf94h	; babc
	defw 0bf87h,0bf94h	; bac0
	defw 0bf8ch,0bf94h	; bac4

; ======================================================================
; CODIGO 0xbac8..0xbd82  (698 bytes)
; ======================================================================


efecto_pide:		; Pide el efecto A (0xE2C2), solo en partida: si ya hay uno, se queda el de numero mas bajo
	ld b,a			;bac8   ; el numero
	ld a,(0e000h)		;bac9   ; en partida?
	and a			;bacc
	ret z			;bacd
	ld a,b			;bace
	ld hl,0e2c2h		;bacf   ; el efecto pedido
pide_va:
	ld b,a			;bad2
	ld a,(hl)			;bad3   ; ya hay uno?
	and a			;bad4
	jr z,pide_pon		;bad5
	cp b			;bad7   ; el de antes es menor: se queda
	ret c			;bad8
pide_pon:
	ld (hl),b			;bad9   ; el nuevo
	ret			;bada
musica_pide:		; Pide la musica A (0xE2BE), con la misma regla
	ld hl,0e2beh		;badb   ; la musica pedida
	jr pide_va		;bade
sonido:		; El sonido de cada cuadro (desde la interrupcion): una musica nueva o un efecto nuevo empiezan; los tres canales (0xE280, 0xE292, 0xE2A4, 18 bytes) siguen
	ld hl,0e2bdh		;bae0   ; una musica sonando?
	xor a			;bae3
	cp (hl)			;bae4
	jr nz,sonido_musica_va		;bae5
	inc hl			;bae7   ; una pedida?
	cp (hl)			;bae8
	jp nz,musica_empieza		;bae9
	inc hl			;baec
	inc hl			;baed
	xor a			;baee
	inc hl			;baef   ; un efecto sonando?
	cp (hl)			;baf0
	jr nz,sonido_efecto_va		;baf1
	inc hl			;baf3   ; uno pedido?
	cp (hl)			;baf4
	jp nz,efecto_empieza		;baf5
sonido_musica_va:
	call prioridad		;baf8   ; la pedida puede mas?
	jp c,musica_empieza		;bafb
	jr sonido_canal_a		;bafe
sonido_efecto_va:
	call prioridad		;bb00   ; el pedido puede mas?
	jp c,efecto_empieza		;bb03
sonido_canal_a:		; El canal A: su bloque a 0xE2C3, un paso y de vuelta
	ld a,(0e2bdh)		;bb06   ; la musica?
	and a			;bb09
	jr nz,sonido_canal_a_va		;bb0a
	ld a,(0e2bfh)		;bb0c   ; o un efecto que use el canal A?
	and a			;bb0f
	jr z,sonido_canal_b		;bb10
sonido_canal_a_va:
	ld hl,0e280h		;bb12   ; el canal A
	call canal_a_trabajo		;bb15
	ld bc,00008h		;bb18   ; sus registros 0 y 8
	xor a			;bb1b
	call canal_numero		;bb1c   ; el canal 0
	push af			;bb1f
	ld de,0e280h		;bb20   ; de vuelta
	call canal_de_trabajo		;bb23
	pop af			;bb26
	and a			;bb27   ; sigue
	jr z,sonido_canal_b		;bb28
	cp 001h		;bb2a   ; 1: se acaba
	jp z,musica_acaba		;bb2c
	cp 002h		;bb2f   ; 2: calla
	jp z,canal_a_calla		;bb31
sonido_canal_b:		; El canal B
	ld a,(0e2bdh)		;bb34   ; la musica o un efecto?
	and a			;bb37
	jr nz,sonido_canal_b_va		;bb38
	ld a,(0e2c1h)		;bb3a
	and a			;bb3d
	ret z			;bb3e
sonido_canal_b_va:
	ld hl,0e292h		;bb3f   ; el canal B
	call canal_a_trabajo		;bb42
	ld bc,00209h		;bb45   ; los registros 2 y 9
	ld a,(0e088h)		;bb48   ; los bits del canal B
	rrca			;bb4b
	ld (0e088h),a		;bb4c
	ld a,001h		;bb4f   ; el canal 1
	call canal_numero		;bb51
	push af			;bb54
	ld de,0e292h		;bb55   ; de vuelta
	call canal_de_trabajo		;bb58
	pop af			;bb5b
	cp 003h		;bb5c   ; 3: sigue
	jr z,sonido_canal_c		;bb5e
	ld b,a			;bb60
	ld a,(0e088h)		;bb61   ; los bits de vuelta
	rlca			;bb64
	ld (0e088h),a		;bb65
	ld a,b			;bb68
	and a			;bb69
	jp nz,efecto_acaba		;bb6a   ; acabado
sonido_canal_c:		; El canal C
	ld hl,0e2a4h		;bb6d   ; el canal C
	call canal_a_trabajo		;bb70
	ld bc,0040ah		;bb73   ; los registros 4 y 10
	ld a,(0e088h)		;bb76   ; los bits del canal C
	rrca			;bb79
	rrca			;bb7a
	ld (0e088h),a		;bb7b
	ld a,002h		;bb7e   ; el canal 2
	call canal_numero		;bb80
	push af			;bb83
	ld de,0e2a4h		;bb84   ; de vuelta
	call canal_de_trabajo		;bb87
	pop af			;bb8a
	cp 003h		;bb8b   ; 3: sigue
	jp z,ruido_barrido		;bb8d
	ld b,a			;bb90
	ld a,(0e088h)		;bb91
	rlca			;bb94
	rlca			;bb95
	ld (0e088h),a		;bb96
	ld a,b			;bb99
	and a			;bb9a   ; acabado
	jp nz,efecto_acaba		;bb9b
	jp ruido_barrido		;bb9e   ; el barrido del ruido
canal_a_trabajo:		; Copia el bloque del canal (HL, 18 bytes) a 0xE2C3
	ld de,0e2c3h		;bba1   ; al canal de trabajo
copia18:
	ld bc,00012h		;bba4   ; 18 bytes
	ldir		;bba7
	ret			;bba9
canal_de_trabajo:		; Y de vuelta a DE
	ld hl,0e2c3h		;bbaa
	jr copia18		;bbad
canal_paso:		; Un paso del canal de trabajo: si la nota sigue, nada; si no, el byte siguiente de la pieza: una nota (menos de 0xF0) o una orden
	ld hl,0e2cdh		;bbaf   ; la nota sigue?
	ld a,(hl)			;bbb2
	and a			;bbb3
	jr z,canal_lee		;bbb4
	call canal_cuenta		;bbb6   ; su cuenta
	and a			;bbb9
	ret z			;bbba   ; sigue
canal_lee:
	ld iy,0e2cdh		;bbbb
	ld hl,(0e2c3h)		;bbbf   ; por donde va
	ld a,(hl)			;bbc2
	cp 0f0h		;bbc3   ; una orden?
	jr nc,canal_orden		;bbc5
	call nota_pon		;bbc7   ; la nota
	call nota_periodo		;bbca   ; su periodo
	ld (0e2c3h),hl		;bbcd
	ld a,(0e088h)		;bbd0   ; el canal con tono, sin ruido
	res 0,a		;bbd3
	set 3,a		;bbd5
canal_mezcla:
	ld c,a			;bbd7
	ld a,(0e2d5h)		;bbd8   ; corrido al canal
	and a			;bbdb
	ld b,a			;bbdc
	ld a,c			;bbdd
	jr z,canal_mezcla_pon		;bbde
canal_mezcla_corre:
	rlca			;bbe0
	djnz canal_mezcla_corre		;bbe1
canal_mezcla_pon:
	ld (0e088h),a		;bbe3   ; el registro 7
	call psg_mezcla		;bbe6
	ld a,003h		;bbe9   ; 3: sigue
	ret			;bbeb
canal_orden:		; Las ordenes: 0xF0, 0xFF el final (1), 0xF7 (2), 0xFE...
	jp z,canal_ruido		;bbec   ; 0xF0: ruido
	cp 0ffh		;bbef   ; 0xFF: el final
	jr nz,canal_orden_f7		;bbf1
	ld a,001h		;bbf3
	ret			;bbf5
canal_orden_f7:
	cp 0f7h		;bbf6   ; 0xF7: callar
	jr nz,canal_orden_fe		;bbf8
	ld a,002h		;bbfa
	ret			;bbfc
canal_orden_fe:
	cp 0feh		;bbfd   ; 0xFE: al principio
	jr nz,canal_orden_fd		;bbff
	ld hl,(0e2c5h)		;bc01
	jr canal_orden_sigue		;bc04
canal_orden_fd:		; 0xFD n: la marca 1 y cuantas veces
	cp 0fdh		;bc06
	jr nz,canal_orden_fc		;bc08
	inc hl			;bc0a   ; cuantas veces...
	ld a,(hl)			;bc0b
	ld (iy+005h),a		;bc0c   ; ...en +5
	inc hl			;bc0f
	ld (0e2c7h),hl		;bc10   ; la marca 1
	jr canal_orden_sigue		;bc13
canal_orden_fc:		; 0xFC: vuelve a la marca 1 si quedan
	cp 0fch		;bc15
	jr nz,canal_orden_fb		;bc17
	dec (iy+005h)		;bc19   ; una vez menos
	jr nz,canal_orden_fc_vuelve		;bc1c
	inc hl			;bc1e   ; ya: sigue
	jr canal_orden_sigue		;bc1f
canal_orden_fc_vuelve:
	ld hl,(0e2c7h)		;bc21   ; a la marca 1
	jr canal_orden_sigue		;bc24
canal_orden_fb:		; 0xFB n: la marca 2
	cp 0fbh		;bc26
	jr nz,canal_orden_fa		;bc28
	inc hl			;bc2a   ; cuantas veces...
	ld a,(hl)			;bc2b
	ld (iy+006h),a		;bc2c   ; ...en +6
	inc hl			;bc2f
	ld (0e2c9h),hl		;bc30   ; la marca 2
canal_orden_sigue:		; Sigue leyendo
	ld (0e2c3h),hl		;bc33   ; por donde va
	jr canal_lee		;bc36
canal_orden_fa:		; 0xFA: vuelve a la marca 2
	cp 0fah		;bc38
	jr nz,canal_orden_f9		;bc3a
	dec (iy+006h)		;bc3c   ; una vez menos
	jr nz,canal_orden_fa_vuelve		;bc3f
	inc hl			;bc41   ; ya: sigue
	jr canal_orden_sigue		;bc42
canal_orden_fa_vuelve:
	ld hl,(0e2c9h)		;bc44   ; a la marca 2
	jr canal_orden_sigue		;bc47
canal_orden_f9:		; 0xF9 n: la marca 3
	cp 0f9h		;bc49
	jr nz,canal_orden_f8		;bc4b
	inc hl			;bc4d   ; cuantas veces...
	ld a,(hl)			;bc4e
	ld (iy+007h),a		;bc4f   ; ...en +7
	inc hl			;bc52
	ld (0e2cbh),hl		;bc53   ; la marca 3
	jr canal_orden_sigue		;bc56
canal_orden_f8:		; 0xF8 (o mas): vuelve a la marca 3
	dec (iy+007h)		;bc58   ; una vez menos
	jr nz,canal_orden_f8_vuelve		;bc5b
	inc hl			;bc5d   ; ya: sigue
	jr canal_orden_sigue		;bc5e
canal_orden_f8_vuelve:
	ld hl,(0e2cbh)		;bc60   ; a la marca 3
	jr canal_orden_sigue		;bc63
canal_ruido:		; 0xF0: una nota de ruido (el periodo y su barrido) y su duracion; el canal, a ruido en el registro 7
	call ruido_pon		;bc65   ; el ruido
	inc hl			;bc68
	call nota_pon		;bc69   ; la duracion y el volumen
	inc hl			;bc6c
	ld (0e2c3h),hl		;bc6d   ; por donde va
	ld a,(0e088h)		;bc70   ; el canal con ruido, sin tono
	res 3,a		;bc73
	set 0,a		;bc75
	jp canal_mezcla		;bc77
ruido_barrido:		; El barrido del ruido: cada tantos cuadros, el periodo + el paso, unas cuantas veces
	ld a,(0e2b6h)		;bc7a   ; hay ruido?
	and a			;bc7d
	ret z			;bc7e
	ld a,(0e2b7h)		;bc7f   ; con barrido?
	and a			;bc82
	ret z			;bc83
	ld a,(0e2b9h)		;bc84   ; quedan pasos?
	and a			;bc87
	ret z			;bc88
	ld a,(0e2bbh)		;bc89   ; la espera...
	dec a			;bc8c   ; ...un cuadro menos
	ld (0e2bbh),a		;bc8d
	ret nz			;bc90
	ld a,(0e2b9h)		;bc91   ; un paso menos
	dec a			;bc94
	ld (0e2b9h),a		;bc95
	ld a,(0e2bah)		;bc98   ; otra vez la espera
	ld (0e2bbh),a		;bc9b
	ld a,(0e2b8h)		;bc9e   ; el periodo...
	ld b,a			;bca1
	ld a,(0e2bch)		;bca2   ; ...mas el paso
	add a,b			;bca5
	ld (0e2b8h),a		;bca6
	jp psg_ruido		;bca9   ; al registro 6
canal_numero:		; El numero de canal (0xE2D5) y un paso
	ld (0e2d5h),a		;bcac   ; el canal
	call canal_paso		;bcaf   ; un paso
	ret			;bcb2
prioridad:		; C si el sonido de (HL+1) es de numero menor que el de (HL)
	ld b,(hl)			;bcb3   ; el que suena
	inc hl			;bcb4
	ld a,(hl)			;bcb5   ; el pedido: ninguno?
	and a			;bcb6
	ret z			;bcb7
	cp b			;bcb8   ; C si es menor
	ret			;bcb9
canal_cuenta:		; La nota: la duracion baja; el volumen baja cada tanto (la envolvente); a 0, A = 1
	inc hl			;bcba
	dec (hl)			;bcbb   ; la duracion, uno menos
	jp z,canal_cuenta_fin		;bcbc   ; acabada
	inc hl			;bcbf
	ld a,(hl)			;bcc0   ; el volumen: 0?
	and a			;bcc1
	jp z,canal_cuenta_sigue		;bcc2
	cp 00fh		;bcc5   ; 15: la envolvente corta
	jr z,canal_cuenta_15		;bcc7
	inc hl			;bcc9
	dec (hl)			;bcca   ; la cuenta de la envolvente
	jr nz,canal_cuenta_sigue		;bccb
	dec hl			;bccd
	ld a,(hl)			;bcce   ; la espera...
	inc hl			;bccf
	ld (hl),a			;bcd0   ; ...otra vez
	inc hl			;bcd1
	dec (hl)			;bcd2   ; el volumen, uno menos
	ld a,(hl)			;bcd3
	call psg_c		;bcd4   ; al PSG
	and a			;bcd7
	jr nz,canal_cuenta_sigue		;bcd8
	dec hl			;bcda
	dec hl			;bcdb
	ld (hl),a			;bcdc
canal_cuenta_sigue:
	xor a			;bcdd
	ret			;bcde
canal_cuenta_15:
	inc hl			;bcdf
	dec (hl)			;bce0   ; la cuenta
	jr nz,canal_cuenta_sigue		;bce1
	xor a			;bce3
	dec hl			;bce4
	ld (hl),a			;bce5   ; el volumen a 0
	call psg_c		;bce6
	ret			;bce9
canal_cuenta_fin:
	dec hl			;bcea
	xor a			;bceb
	ld (hl),a			;bcec   ; acabada: A = 1
	ld a,001h		;bced
	ret			;bcef
ruido_pon:		; El ruido: su periodo fijo o con barrido (periodo, cuantas veces, cada cuanto, el paso)
	ld (iy+000h),a		;bcf0   ; la nota
	inc hl			;bcf3
	ld a,(hl)			;bcf4   ; con barrido?
	ld (0e2b7h),a		;bcf5
	and a			;bcf8
	jr nz,ruido_barre		;bcf9
	inc hl			;bcfb
	ld a,(hl)			;bcfc   ; el periodo...
	ld (0e2b8h),a		;bcfd
	call psg_ruido		;bd00   ; ...registro 6
	xor a			;bd03   ; sin barrido
	ld (0e2b9h),a		;bd04
	ld (0e2bah),a		;bd07
	ld (0e2bbh),a		;bd0a
	ld (0e2bch),a		;bd0d
	inc a			;bd10   ; hay ruido
	ld (0e2b6h),a		;bd11
	ret			;bd14
ruido_barre:
	ld (0e2b6h),a		;bd15   ; hay ruido con barrido
	ld (0e2bch),a		;bd18
	inc hl			;bd1b
	ld a,(hl)			;bd1c   ; el periodo...
	ld (0e2b8h),a		;bd1d
	call psg_ruido		;bd20   ; ...registro 6
	inc hl			;bd23
	ld a,(hl)			;bd24   ; cuantas veces...
	ld (0e2b9h),a		;bd25
	inc hl			;bd28
	ld a,(hl)			;bd29   ; ...cada cuanto
	ld (0e2bah),a		;bd2a
	ld (0e2bbh),a		;bd2d
	ret			;bd30
nota_pon:		; Una nota: el byte de arriba es la duracion (0xBD82, o el byte siguiente con 0xE), el de abajo el volumen (15: la mitad)
	ld a,(hl)			;bd31   ; la nota...
	ld (iy+000h),a		;bd32
	and 00fh		;bd35   ; ...el volumen (la mitad baja)
	ld (iy+002h),a		;bd37
	ld a,(hl)			;bd3a   ; la duracion (la mitad alta)...
	and 0f0h		;bd3b
	rrca			;bd3d
	rrca			;bd3e
	rrca			;bd3f
	rrca			;bd40
	cp 00eh		;bd41   ; ...0xE: en el byte siguiente
	jr z,nota_duracion_byte		;bd43
	ld de,0bd82h		;bd45   ; la tabla de duraciones
	add a,e			;bd48
	jr nc,nota_duracion		;bd49
	inc d			;bd4b
nota_duracion:
	ld e,a			;bd4c
	ld a,(de)			;bd4d   ; la duracion
	jr nota_volumen		;bd4e
nota_duracion_byte:
	inc hl			;bd50
	ld a,(hl)			;bd51
nota_volumen:
	ld (iy+001h),a		;bd52
	ld a,(iy+002h)		;bd55   ; volumen 15?
	cp 00fh		;bd58
	jr nz,nota_cuenta		;bd5a
	ld a,(iy+001h)		;bd5c   ; la duracion...
	push bc			;bd5f
	ld c,a			;bd60
	srl a		;bd61   ; ...menos la mitad: la espera
	ld b,a			;bd63
	ld a,c			;bd64
	sub b			;bd65
	pop bc			;bd66
nota_cuenta:
	ld (iy+003h),a		;bd67   ; la cuenta de la envolvente
	ld a,00fh		;bd6a   ; el volumen 15
	ld (iy+004h),a		;bd6c
	jp psg_c		;bd6f   ; al PSG
nota_periodo:		; El periodo: un byte (menos de 0x10, la parte alta) y otro
	inc hl			;bd72
	ld a,(hl)			;bd73   ; el byte
	cp 010h		;bd74   ; menos de 0x10: la parte alta
	jr nc,nota_periodo_bajo		;bd76
	call psg_b1		;bd78   ; al registro B + 1
	inc hl			;bd7b
	ld a,(hl)			;bd7c   ; la parte baja
nota_periodo_bajo:
	call psg_b		;bd7d   ; al registro B
	inc hl			;bd80
	ret			;bd81

; ----------------------------------------------------------------------
; DATOS duraciones: Las 14 duraciones de las notas (de 128 a 1 cuadros)
;   0xbd82..0xbd90  (14 bytes)
DATA_duraciones:
	defb 080h,060h,040h,030h,020h,018h,010h,00ch,008h,006h,004h,003h,002h,001h	; bd82  .`@0 .........

; ======================================================================
; CODIGO 0xbd90..0xbe55  (197 bytes)
; ======================================================================


psg_c:		; WRTPSG: el registro C
	ld e,a			;bd90   ; el valor...
	ld a,c			;bd91   ; ...el registro C
psg:
	jp 00093h		;bd92   ; WRTPSG
psg_b:		; El registro B
	ld e,a			;bd95   ; el registro B
	ld a,b			;bd96
	jr psg		;bd97
psg_b1:		; El registro B + 1
	ld e,a			;bd99   ; el registro B + 1
	ld a,b			;bd9a
	inc a			;bd9b
	jr psg		;bd9c
psg_mezcla:		; El registro 7
	ld e,a			;bd9e   ; el registro 7
	ld a,007h		;bd9f
	jr psg		;bda1
psg_ruido:		; El registro 6
	ld e,a			;bda3   ; el registro 6
	ld a,006h		;bda4
	jr psg		;bda6
musica_empieza:		; Una musica: los tres canales de la tabla 0xBA80 (6 bytes por musica)
	ld hl,0ba80h		;bda8   ; la tabla de musicas
	ld a,(0e2beh)		;bdab   ; la musica pedida...
	ld (0e2bdh),a		;bdae   ; ...es la que suena
	ld b,a			;bdb1   ; x 6
	add a,b			;bdb2
	add a,b			;bdb3
	add a,b			;bdb4
	add a,b			;bdb5
	add a,b			;bdb6
	call canal_a_tabla		;bdb7   ; el canal A
	inc hl			;bdba
	call canales_bc		;bdbb   ; los canales B y C
	ld (0e28ah),a		;bdbe
	ld (0e2beh),a		;bdc1   ; la pedida, gastada
	ld a,0f8h		;bdc4   ; los tres canales con tono
sonido_mezcla:
	ld (0e088h),a		;bdc6
	call psg_mezcla		;bdc9
	jp sonido_canal_a		;bdcc
musica_acaba:		; El canal A acaba: si hay otra musica pedida, empieza; si no, todo callado
	ld a,(0e2beh)		;bdcf   ; otra pedida?
	and a			;bdd2
	jr nz,musica_empieza		;bdd3
	ld (0e2bdh),a		;bdd5   ; sin musica
	dec a			;bdd8   ; 0xFF: todo callado...
sonido_calla:		; Todo callado: el registro 7 a 0xFF y los canales (0xE280, 67 bytes) a cero
	ld (0e088h),a		;bdd9
	call psg_mezcla		;bddc   ; ...registro 7
	ld hl,0e280h		;bddf   ; los canales...
	ld b,043h		;bde2   ; ...67 bytes...
borra_b2:
	ld (hl),000h		;bde4   ; ...a cero
	inc hl			;bde6
	djnz borra_b2		;bde7
	ret			;bde9
canal_a_calla:
	ld a,(0e088h)		;bdea   ; el canal A callado
	or 009h		;bded
mezcla_pon:
	ld (0e088h),a		;bdef
	jp psg_mezcla		;bdf2
efecto_empieza:		; Un efecto: los canales B y C de la tabla 0xBAA4 (4 bytes por efecto)
	ld hl,0baa4h		;bdf5   ; la tabla de efectos
	ld a,(0e2c2h)		;bdf8   ; el pedido...
	ld (0e2c1h),a		;bdfb   ; ...es el que suena
	add a,a			;bdfe   ; x 4
	add a,a			;bdff
	add a,l			;be00
	ld l,a			;be01
	call canales_bc		;be02   ; los canales B y C
	ld (0e2c2h),a		;be05   ; el pedido, gastado
	ld a,(0e088h)		;be08   ; B y C con tono
	and 0f9h		;be0b
	jp sonido_mezcla		;be0d
efecto_acaba:		; El canal B acaba: otro efecto pedido o los canales B y C callados
	ld a,(0e2c2h)		;be10   ; otro pedido?
	and a			;be13
	jr nz,efecto_empieza		;be14
	ld (0e2c1h),a		;be16   ; sin efecto
	ld hl,0e292h		;be19   ; los canales B y C...
	ld b,024h		;be1c   ; ...36 bytes a cero
	call borra_b2		;be1e
	ld a,(0e088h)		;be21   ; B y C callados
	or 036h		;be24
	jr mezcla_pon		;be26
canales_bc:		; Los canales B y C desde la tabla HL
	ld e,(hl)			;be28   ; el canal B: su pieza...
	inc hl			;be29
	ld d,(hl)			;be2a
	ld (0e292h),de		;be2b   ; ...y su principio
	ld (0e294h),de		;be2f
	inc hl			;be33
	ld e,(hl)			;be34   ; el canal C
	inc hl			;be35
	ld d,(hl)			;be36
	ld (0e2a4h),de		;be37
	ld (0e2a6h),de		;be3b
	xor a			;be3f   ; sin nota en marcha
	ld (0e29ch),a		;be40
	ld (0e2aeh),a		;be43
	ret			;be46
canal_a_tabla:		; El canal A desde la tabla
	add a,l			;be47   ; + la musica x 6
	ld l,a			;be48
	ld e,(hl)			;be49   ; el canal A: su pieza...
	inc hl			;be4a
	ld d,(hl)			;be4b
	ld (0e280h),de		;be4c   ; ...y su principio
	ld (0e282h),de		;be50
	ret			;be54

; ----------------------------------------------------------------------
; DATOS bytes_be55: Cuatro bytes antes de la primera pieza
;   0xbe55..0xbe59  (4 bytes)
DATA_bytes_be55:
	defb 01ch,000h,000h,0f7h	; be55

; ----------------------------------------------------------------------
; DATOS piezas: Las piezas de las musicas y los efectos: notas (duracion y
;   volumen, y el periodo) y ordenes desde 0xF0
;   0xbe59..0xbfa0  (327 bytes)
DATA_piezas:
	defb 01ch,000h,000h,0ffh,0fdh,003h,082h,003h,057h,0fch,0fdh,002h,082h,004h,075h,0fch	; be59  ........W.....u.
	defb 0fdh,004h,081h,003h,057h,0fch,082h,002h,0a7h,057h,002h,0fah,0fdh,003h,082h,002h	; be69  ....W....W......
	defb 081h,0fch,0fdh,002h,082h,003h,057h,0fch,0fdh,004h,081h,002h,081h,0fch,082h,001h	; be79  ......W.........
	defb 0fch,057h,002h,03bh,03ch,001h,0ach,0ffh,0fdh,003h,082h,000h,0aah,0fch,0fdh,004h	; be89  .W.;<...........
	defb 081h,000h,0a0h,0fch,082h,000h,0aah,082h,0beh,082h,0aah,082h,0beh,082h,07fh,082h	; be99  ................
	defb 08fh,0fdh,003h,082h,000h,07fh,0fch,0fdh,004h,081h,000h,071h,0fch,082h,000h,07fh	; bea9  ...........q....
	defb 082h,08fh,082h,07fh,082h,08fh,082h,05fh,082h,06bh,03ch,08fh,0feh,0fdh,003h,081h	; beb9  ......._.k<.....
	defb 000h,0d6h,0fch,0fdh,004h,081h,000h,0beh,0fch,0fdh,002h,081h,000h,0d6h,0fch,082h	; bec9  ................
	defb 000h,0beh,057h,0beh,0fdh,003h,081h,000h,0a0h,0fch,0fdh,004h,081h,000h,08fh,0fch	; bed9  ..W.............
	defb 0fdh,002h,081h,000h,0a0h,0fch,082h,000h,08fh,057h,08fh,03ch,0aah,0feh,082h,001h	; bee9  .........W.<....
	defb 0ach,082h,053h,063h,01dh,082h,040h,081h,053h,081h,040h,082h,01dh,064h,000h,0d6h	; bef9  ..Sc..@.S.@..d..
	defb 082h,0a0h,082h,0aah,081h,0a0h,081h,0d6h,063h,06bh,026h,001h,01dh,0ffh,0fdh,004h	; bf09  ........ck&.....
	defb 0f0h,000h,001h,062h,0f0h,000h,001h,081h,0f0h,000h,001h,081h,0fch,026h,001h,053h	; bf19  ...b.........&.S
	defb 0ffh,0fdh,004h,064h,003h,057h,081h,001h,0ach,082h,0ach,0fch,026h,001h,0ach,0ffh	; bf29  ...d.W......&...
	defb 026h,000h,050h,0ffh,026h,000h,040h,0ffh,081h,000h,000h,026h,020h,0ffh,0f0h,000h	; bf39  &.P.&.@....& ...
	defb 01fh,028h,0ffh,0f0h,000h,01fh,025h,0ffh,0f0h,002h,00fh,006h,001h,073h,0ffh,0d1h	; bf49  .(....%......s..
	defb 001h,010h,0d1h,0f0h,0d1h,020h,0d1h,0e0h,0d1h,030h,0d1h,0d0h,0d1h,040h,0d1h,0c0h	; bf59  ..... ...0...@..
	defb 0ffh,06ch,000h,090h,06ch,000h,000h,0ffh,06ch,000h,030h,06ch,000h,000h,0ffh,0a8h	; bf69  .l..l...l.0l....
	defb 000h,040h,0a8h,060h,0ffh,0fdh,002h,0a1h,000h,040h,0a1h,070h,0fch,0ffh,0f0h,000h	; bf79  .@.`.....@.p....
	defb 01fh,053h,0ffh,0f0h,000h,010h,0d1h,0b1h,000h,088h,0ffh,081h,000h,000h,0feh,000h	; bf89  .S..............
	defb 000h,000h,000h,000h,000h,000h,000h	; bf99

; ======================================================================
; CODIGO 0xbfa0..0xbffd  (93 bytes)
; ======================================================================


presentacion_final:		; El final de la presentacion: CASIO entero en sus dos filas y el fondo (0x9DA0) arriba y abajo
	ld a,(0e1a1h)		;bfa0   ; el paso...
	cp 009h		;bfa3   ; ...9 o mas
	ret c			;bfa5
	ld bc,00008h		;bfa6   ; 8 casillas
	ld hl,09d2eh		;bfa9   ; la fila de abajo de CASIO...
	ld de,(0e1a2h)		;bfac   ; ...en la fila de arriba
	call 0005ch		;bfb0
	ld de,00020h		;bfb3   ; la fila de encima...
	and a			;bfb6
	sbc hl,de		;bfb7
	ex de,hl			;bfb9
	ld hl,09d25h		;bfba   ; ...con la de arriba de CASIO
	ld bc,00008h		;bfbd
	call 0005ch		;bfc0
	ld de,00020h		;bfc3   ; y la de encima...
	and a			;bfc6
	sbc hl,de		;bfc7
	ex de,hl			;bfc9
	ld hl,09da0h		;bfca   ; ...en blanco
	ld bc,00008h		;bfcd
	call 0005ch		;bfd0
	ld bc,00008h		;bfd3   ; abajo: la de arriba de CASIO
	ld hl,09d25h		;bfd6
	ld de,(0e1a4h)		;bfd9
	call 0005ch		;bfdd
	ld de,00020h		;bfe0
	add hl,de			;bfe3
	ex de,hl			;bfe4
	ld hl,09d2eh		;bfe5   ; y la de abajo
	ld bc,00008h		;bfe8
	call 0005ch		;bfeb
	ld de,00020h		;bfee
	add hl,de			;bff1
	ex de,hl			;bff2
	ld hl,09da0h		;bff3   ; y una en blanco
	ld bc,00008h		;bff6
	call 0005ch		;bff9
	ret			;bffc

; ----------------------------------------------------------------------
; DATOS bytes_bffd: Los tres ultimos bytes de la ROM
;   0xbffd..0xc000  (3 bytes)
DATA_bytes_bffd:
	defb 010h,001h,088h	; bffd
