.include "common.s"
.include "advent/advent_01.s"
.include "advent/advent_01_part2.s"
.include "file_utils.s"

.section __TEXT,__text
.global _main
.align 2


_main:     
    bl print_advent_01_answer
    bl print_advent_01_part2_answer
    bl exit


print_advent_01_answer:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    bl advent_01
    str x0, [sp, #-16]!

    adrp x0, first_answer_str@PAGE
    add x0, x0, first_answer_str@PAGEOFF

    bl _printf

    add sp, sp, 16

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

print_advent_01_part2_answer:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    bl advent_01_part2
    str x0, [sp, #-16]!

    adrp x0, second_answer_str@PAGE
    add x0, x0, second_answer_str@PAGEOFF

    bl _printf

    add sp, sp, 16

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.section __DATA,__data
.align 2

first_answer_str: 
    .ascii "The answer to the advent of code 01 challenge is: %d\n\0"
second_answer_str: 
    .ascii "The answer to the advent of code 01 part 2 challenge is: %d\n\0"