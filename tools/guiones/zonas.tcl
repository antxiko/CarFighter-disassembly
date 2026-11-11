# LAS OCHO ZONAS, FORZADAS: la partida de carrera.tcl con la velocidad por debajo de 0x82 (sin choques), pero cada
# zona se acaba a la fuerza 450 cuadros despues de empezar: el guion pone 0xE184 (el final de la zona) a 1, lo que
# el juego hace al llegar a la distancia del CHECK POINT. Asi salen las ocho, con su CHECK POINT, y la meta (GOAL)
# de la 8. 6500 cuadros.
set ::zona 0
set ::desde 0
proc fuerza {n} {
    set z [debug read memory 0xE00A]
    if {$z != $::zona} { set ::zona $z; set ::desde $n }
    if {[debug read memory 0xE000] == 1 && [debug read memory 0xE009] == 0 && $n - $::desde == 450} {
        debug write memory 0xE184 1
    }
}
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
        if {[debug read memory 0xE194] < 0x81} { keymatrixdown 8 0x20 } else { keymatrixup 8 0x20 }
        piloto
        fuerza $n
    }
    return [expr {$n >= 6500}]
}
