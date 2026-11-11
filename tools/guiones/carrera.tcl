# Una partida con un piloto en Tcl: la barra en el cuadro 300 y en el 600 empieza. Despues, cada cuadro, arriba
# (acelerar) mientras la velocidad (0xE194) no pasa de 0xB0, y la palanca lleva el coche al centro de la carretera:
# la fila de la carretera a su altura (el anillo de 0xE8C0, 24 bytes por fila, desde 0xE186) y sus bordes (las
# casillas 0x4F-0x5C, 0x6B y 0x6C). La barra (disparo) cada 25 cuadros. 16000 cuadros.
proc pulsa {n a f b} {
    if {$n == $a} { keymatrixdown $f $b }
    if {$n == $a + 5} { keymatrixup $f $b }
}
proc borde {t} { return [expr {($t >= 0x4F && $t <= 0x5C) || $t == 0x6B || $t == 0x6C}] }
proc piloto {} {
    set y [debug read memory 0xE300]
    set x [debug read memory 0xE301]
    set p [expr {[debug read memory 0xE186] | ([debug read memory 0xE187] << 8)}]
    set p [expr {$p + ($y / 8) * 24}]
    while {$p >= 0xEB00} { set p [expr {$p - 0x240}] }
    set izq 0
    for {set c 0} {$c < 24} {incr c} { if {[borde [debug read memory [expr {$p + $c}]]]} { set izq $c; break } }
    set der 23
    for {set c 23} {$c >= 0} {incr c -1} { if {[borde [debug read memory [expr {$p + $c}]]]} { set der $c; break } }
    set centro [expr {($izq + $der) * 4}]
    keymatrixup 8 0x90
    if {$x < $centro - 6} { keymatrixdown 8 0x80 }
    if {$x > $centro + 6} { keymatrixdown 8 0x10 }
}
proc guion {n} {
    pulsa $n 300 8 0x01
    pulsa $n 600 8 0x01
    if {$n > 700} {
        if {$n % 25 == 0} { keymatrixdown 8 0x01 }
        if {$n % 25 == 5} { keymatrixup 8 0x01 }
        if {[debug read memory 0xE194] < 0xB0} { keymatrixdown 8 0x20 } else { keymatrixup 8 0x20 }
        piloto
    }
    return [expr {$n >= 16000}]
}
