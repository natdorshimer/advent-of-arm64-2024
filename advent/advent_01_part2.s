.ifndef __ADVENT_01_PART2_S__

.include "common.s"
.include "file_utils.s"
.include "arrays.s"
.include "advent/advent_01.s"

.section __TEXT,__text
.global _main
.align 2

.extern _atoi
.extern _sprintf

.set FREQUENCY_BUFFER_SIZE, 800000 // 100000 * 8

// The maximum number of elements to store every possible number in the input: 100000
// Create an array to store the frequency of each element
// The array is initialized to 0

/*
    int advent_01_part2(); // Returns the answer to the advent of code 01 part 2 challenge.
 */
advent_01_part2:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    bl load_advent_data_from_file
    mov x19, x0 // left_arr_p
    mov x20, x1 // num_elements
    mov x21, x2 // right_arr_p
    mov x22, x3 // num_elements

    mov x0, x21
    mov x1, x22
    bl add_frequency_info

    mov x0, x19
    mov x1, x20
    bl multiply_by_frequency

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/*
    int multiply_by_frequency(int* arr, int num_elements); 
 */
multiply_by_frequency:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    mov x19, 0 // counter
    mov x20, 0 // Sum of multiplications
1:
    cmp x19, x1 // counter < num_elements
    bge 2f

    lsl x2, x19, #3            // x2 = counter * 8
    ldr x3, [x0, x2]           // x3 = arr[counter] - number

    adrp x4, frequency_buffer@PAGE
    add x4, x4, frequency_buffer@PAGEOFF

    ldr x5, [x4, x3, lsl #3]    // x5 = frequency_buffer[number]
    mul x3, x3, x5              // x3 = number * frequency_buffer[number]

    add x20, x20, x3 // Sum += arr[counter] * frequency_buffer[arr[counter]]
    add x19, x19, 1  // counter++
    b 1b
2:
    mov x0, x20 
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

/*  
    void add_frequency_info(int* arr_p, int num_elements);

    Adds frequency information to the array.
 */
add_frequency_info:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // arr_p
    mov x20, x1 // num_elements

    mov x0, x19
    mov x1, x20
    adr x2, _set_x64_number_in_freq_buffer
    bl for_each

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret

// void set_x64_number_in_buffer(int number);
_set_x64_number_in_freq_buffer:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    mov x19, x0 // number

    // Moving 100000, or 0x186A0000, into x1
    movz x1, 0x0000
    movk x1, 0x186A, lsl #16
    cmp x19, x1
    bge 1f

    adrp x20, frequency_buffer@PAGE
    add x20, x20, frequency_buffer@PAGEOFF

    ldr x21, [x20, x19, lsl #3] // Exisiting number
    add x21, x21, 1 // Increment the number
    str x21, [x20, x19, lsl #3] // Store the number

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
1:
    adrp x0, number_too_large_error@PAGE
    add x0, x0, number_too_large_error@PAGEOFF
    bl exit_with_error

.section __DATA,__data
.align 2

number_too_large_error:
    .ascii "Number too large to store in buffer.\0"

frequency_buffer:
    .space FREQUENCY_BUFFER_SIZE

.set __ADVENT_01_PART2_S__, 1
.endif

