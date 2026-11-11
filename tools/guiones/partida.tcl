# Una partida: la barra en el cuadro 300 (deja la presentacion) y en el 600 (empieza). Despues, arriba sostenido
# (acelera), a ratos izquierda o derecha (cada 90 cuadros, 20 cuadros), la barra (disparo) cada 25 y GRAPH (bomba,
# fila 6 0x04) cada 400. 12000 cuadros.
proc pulsa {n a f b} {
    if {$n == $a} { keymatrixdown $f $b }
    if {$n == $a + 5} { keymatrixup $f $b }
}
proc guion {n} {
    pulsa $n 300 8 0x01
    pulsa $n 600 8 0x01
    if {$n > 700} {
        if {$n % 25 == 0} { keymatrixdown 8 0x01 }
        if {$n % 25 == 5} { keymatrixup 8 0x01 }
        if {$n % 400 == 200} { keymatrixdown 6 0x04 }
        if {$n % 400 == 205} { keymatrixup 6 0x04 }
        set m [expr {$n % 180}]
        keymatrixup 8 0xD0
        keymatrixdown 8 0x20
        if {$m >= 40 && $m < 60} { keymatrixdown 8 0x10 }
        if {$m >= 130 && $m < 150} { keymatrixdown 8 0x80 }
    }
    return [expr {$n >= 12000}]
}
