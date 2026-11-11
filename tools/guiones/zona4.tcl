# LA ZONA 4, FORZADA: la misma partida que carrera.tcl, pero la primera vez que se monta una zona (0x8125) la
# zona (0xE00A) pasa de 1 a 4, la que la demostracion tambien puede sacar: el camion y lo que suelta. La velocidad,
# por debajo de 0x82 (con menos, los coches empujan y no se choca), y GRAPH (la bomba) cada 40 cuadros si hay un
# camion (el tipo 3, +4 de los coches de 0xE360). 12000 cuadros.
set ::zona4 0
debug set_bp 0x8125 {} {
    if {!$::zona4 && [debug read memory 0xE00A] == 1} { debug write memory 0xE00A 4; set ::zona4 1 }
}
proc camion {} {
    for {set j 0} {$j < 10} {incr j} { if {[debug read memory [expr {0xE364 + 32 * $j}]] == 3} { return 1 } }
    return 0
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
        if {$n % 40 == 0 && [camion]} { keymatrixdown 6 0x04 }
        if {$n % 40 == 5} { keymatrixup 6 0x04 }
    }
    return [expr {$n >= 12000}]
}
