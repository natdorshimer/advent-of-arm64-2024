.ifndef __ADVENT_01_S__

.include "common.s"
.include "file_utils.s"
.include "arrays.s"

.section __TEXT,__text
.global _main
.align 2

.extern _atoi
.extern _sprintf

// This took... much longer than python. 
// Especially when considering all the supporting code I had to write, even with the help of C libraries.

/*
    int advent_01(); // Returns the answer to the advent of code 01 challenge.
 */
advent_01:        
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    
    adrp x0, file@PAGE
    add x0, x0, file@PAGEOFF
    mov x1, 'r'
    bl open_file
    
    bl read_entire_file
    mov x19, x0
    bl num_lines_in_str

    mov x1, x0   //x1: num_lines
    mov x0, x19  //x0: file_data
    bl load_advent_data

    mov x19, x0 // left_arr_p
    mov x20, x1 // num_elements
    mov x21, x2 // right_arr_p
    mov x22, x3 // num_elements

    mov x0, x19
    mov x1, x20
    bl sort_int_array
    
    mov x0, x21
    mov x1, x22
    bl sort_int_array

    mov x0, x19
    mov x1, x21
    mov x2, x20
    bl calculate_difference

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/*
    int calculate_difference(int* left_arr, int* right_arr, int num_elements);
 */
 calculate_difference:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!


    mov x19, x0     // left_arr
    mov x20, x1     // right_arr
    mov x21, x2     // num_elements
    mov x22, 0      // Difference sum
    mov x23, 0      // Counter

1:
    ldr x4, [x19, x23, lsl #3]
    ldr x5, [x20, x23, lsl #3]
    sub x0, x5, x4
    bl _abs
    add x22, x22, x0
    add x23, x23, 1

    cmp x23, x21
    b.le 1b

    mov x0, x22

    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


/*
    struct { int* left_arr_p; int num_elements; } arr;
    struct { arr* left_arr; arr* right_arr; } load_advent_data(char* input_data, int num_lines);

    Returns values:
    x0 = left_arr.left_arr_p
    x1 = left_arr.num_elements
    x2 = right_arr.left_arr_p
    x3 = right_arr.num_elements

    File format:

    38665   13337
    84587   21418
    93374   50722
    68298   57474
    54771   18244
    ...
 */
load_advent_data:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26,  [sp, #-16]!

    // x19: left_buffer
    // x20: size to allocate for buffers
    // x21: input_data
    // x22: right_buffer

    // x23: counter for input_data
    // x24: counter for line number
    // x25: stack offset

    lsl x20, x1, #3
    mov x21, x0 

    mov x0, x20
    bl _malloc
    mov x19, x0

    mov x0, x20
    bl _malloc
    mov x22, x0

    sub sp, sp, #32

    mov x23, #0 // Counter for input_data
    mov x24, #0 // Counter for line number
    mov x1, #0 // Input data byte storage
    mov x25, #0 // Stack offset
1:
    ldrb w1, [x21, x23]
    cmp w1, 0
    b.eq 4f

    cmp w1, ' '
    b.eq 2f
    cmp w1, '\n'
    b.eq 3f

    strb w1, [sp, x25]
    add x23, x23, 1
    add x25, x25, 1

    b 1b
2:  // Left integer
    mov w1, 0
    strb w1, [sp, x25]
    mov x0, sp
    bl _atoi
    str x0, [x19, x24, lsl #3]

    mov x25, 0      // Reset stack offset for new number
    add x23, x23, 3 // Skip spaces

    b 1b
3:  // Right integer
    mov w1, 0
    strb w1, [sp, x25]
    mov x0, sp
    bl _atoi
    str x0, [x22, x24, lsl #3]

    mov x25, 0        // Reset stack offset for new number
    add x24, x24, 1   // Increment line number
    add x23, x23, 1   // Skip newline

    b 1b
4:

    mov x0, x19
    mov x1, x24
    mov x2, x22
    mov x3, x24

    add sp, sp, #32

    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

.section __DATA,__data
.align 2

file: 
    .ascii "advent/advent_01.txt\0"

.set __ADVENT_01_S__, 1
.endif