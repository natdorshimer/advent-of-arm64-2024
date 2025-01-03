.ifndef __ARRAYS_S__
.include "common.s"

.section __TEXT,__text
.align 2

.extern _qsort


/*
    void for_each(int* buffer, size_t buffer_size, void (*callback)(int));
 */
for_each:
    stp x29, x30, [sp, #-16]!   // Save frame pointer and link register
    stp x19, x20, [sp, #-16]!   // Save callee-saved registers
    stp x21, x22, [sp, #-16]!   // Save callee-saved registers

    mov x0, x0                 // x0 = buffer (pointer to buffer)
    mov x1, x1                 // x1 = buffer_size (number of elements)
    mov x2, x2                 // x2 = callback (pointer to callback function)

    mov x19, #0                // x19 = index
    mov x20, x0                // x20 = buffer
    mov x21, x1                // x21 = buffer_size
    mov x22, x2                // x22 = callback
loop:
    cmp x19, x21                // Compare index with number of elements
    bge end_loop               // If index >= num_elements, end loop
    lsl x1, x19, #3            // x1 = index * 8
    ldr x0, [x20, x1]          // x0 = buffer[index]
    blr x22                     // callback(buffer[index])
    add x19, x19, #1           // index++
    b loop                     // Repeat loop
end_loop:
    ldp x21, x22, [sp], #16     // Restore callee-saved registers
    ldp x19, x20, [sp], #16     // Restore callee-saved registers
    ldp x29, x30, [sp], #16
    ret


/*
    int compare_ints(const int *a, const int *b);
    Returns -1, 0, or 1
 */
compare_ints:
    stp x29, x30, [sp, #-16]!   // Save frame pointer and link register

    ldr x0, [x0]                // Load a
    ldr x1, [x1]                // Load b

    cmp x0, x1                  // Compare a and b
    b.lt compare_ints_lt        // If a < b, return -1
    b.gt compare_ints_gt        // If a > b, return 1
    mov x0, #0                  // If a == b, return 0
compare_ints_lt:
    mov x0, #-1
    b 1f
compare_ints_gt:
    mov x0, #1
1:
    ldp x29, x30, [sp], #16     // Restore frame pointer and link register
    ret


/*
    void sort_int_array(int* arr, size_t size);
 */
sort_int_array:
    stp x29, x30, [sp, #-16]!   // Save frame pointer and link register
    // qsort: void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void*))

    mov x2, 8                   // sizeof(int)
    adr x3, compare_ints        // int (*compar)(const void *, const void*)
    bl _qsort                   // void qsort(void *base, size_t nitems, size_t size, int (*compar)(const void *, const void*))

    ldp x29, x30, [sp], #16     // Restore frame pointer and link register
    ret                         // Return


.set __ARRAYS_S__, 0
.endif