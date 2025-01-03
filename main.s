.include "common.s"
.include "advent/advent_01.s"

.section __TEXT,__text
.global _main
.align 2

_main:     
    bl advent_01
    bl print_int
    bl exit


.section __DATA,__data
.align 2
