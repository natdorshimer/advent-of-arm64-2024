.ifndef __COMMON_S__
.section __TEXT,__text
.align 2

.extern _malloc
.extern _sprintf
.extern _abs
.extern _strlen
.extern _memcpy
.extern _strcpy

.set BUFFER_SIZE, 256

// Utility functions common to most programs

// Input/Output -----------------------------------------------------------

/*
    void print_line(char *str);
    str: A pointer to a null-terminated string.
 */
print_line:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!

    mov x1, x0

    adrp x0, string_line_format@PAGE
    add x0, x0, string_line_format@PAGEOFF

    str x1, [sp, #-16]!
    mov x1, x19
    bl _printf
    add sp, sp, 16

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret


/*
    void print_empty_line();
 */
print_empty_line:
    stp x29, x30, [sp, #-16]!

    adrp x0, empty_line@PAGE
    add x0, x0, empty_line@PAGEOFF
    bl print_line

    ldp x29, x30, [sp], #16
    ret

/*
    void print_int(int number);
    number: The number to print.
 */
print_int:
    stp x29, x30, [sp, #-16]!

    bl int_to_str
    bl print_line

    ldp x29, x30, [sp], #16
    ret

/*
    struct { char *buffer; size_t length; } read_line();
    Returns: A pointer to a null-terminated string read from the standard input.
 */
read_line:
    stp x29, x30, [sp, #-16]! // Save the frame pointer

    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]! 

    // x19: buffer for the read input
    // x20: number of bytes read from the standard input
    // x21: Properly fit destination buffer
    sub sp, sp, BUFFER_SIZE
    mov x19, sp

    /*
     63 ssize_t read(int fildes, void *buf, size_t nbyte);
     error: -1
     */
    mov x0, 1   
    mov x1, x19 
    mov x2, BUFFER_SIZE 
    mov x16, 3
    svc 0

    cmp x0, -1
    b.eq 1f

    cmp x0, BUFFER_SIZE
    b.gt 1f

    mov x20, x0
    
    sub x20, x20, 1

    // Replace \n with \0
    mov x9, 0
    strb w9, [x19, x20]

    add x20, x20, 1

    mov x0, x20
    bl _malloc
    
    mov x21, x0 // destination buffer

    mov x0, x21
    mov x1, x19
    mov x2, x20
    bl _memcpy

    mov x0, x21
    mov x1, x20
return:
    // Free the buffer
    add sp, sp, BUFFER_SIZE

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
1:  
    adrp x0, read_error_message@PAGE
    add x0, x0, read_error_message@PAGEOFF
    bl exit_with_error


/*
    size_t get_num_digits(int number);
    number: The number to count the digits of.
    Returns: The number of digits in the number.
 */
get_num_digits:
    stp x29, x30, [sp, #-16]!

    bl _abs

    mov x2, x0
    mov x1, 10
    mov x0, 0

1:  udiv x2, x2, x1
    add x0, x0, 1
    cbnz x2, 1b
    
    ldp x29, x30, [sp], #16
    ret

// String util functions --------------------------------------------------------

/*
    struct { char* str, size_t size } int_to_str(int number);
    number: The number to convert to a string.
    buffer: A pointer to a buffer that will hold the string representation of the number.
    Returns: The length of the string representation of the number.
 */
int_to_str:
    //Prologue
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

   // x19: number
   // x20: number of digits
   // x21: destination buffer

    mov x19, x0

    bl get_num_digits
    mov x20, x0

    cmp x19, 0
    bge 1f
    
    add x20, x20, 1  // Add space for negative sign
1:  
    add x20, x20, 1  // Add space for null terminator
    mov x0, x20
    bl _malloc

    mov x21, x0 // destination buffer

    // int sprintf(char *str, const char *string,...);
    // varargs are stored on the stack
    mov x0, x21
    adrp x1, int_to_str_format@PAGE
    add x1, x1, int_to_str_format@PAGEOFF
    str x19, [sp, #-16]! // Store the argument on the stack
    bl _sprintf
    ldr x19, [sp], #16 // Restore the stack pointer

    cmp x0, -1
    b.eq 2f

    mov x1, x0  // size
    mov x0, x21 // destination buffer

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
2:
    adrp x0, error@PAGE
    add x0, x0, error@PAGEOFF
    bl exit_with_error


/*
    int num_lines_in_str(char* str);
 */
num_lines_in_str:
    stp x29, x30, [sp, #-16]!

    mov x1, 0 // Line counter
    mov x2, 0 // Byte holder
    mov x3, 0 // Byte counter
1:
    ldrb w2, [x0, x3]
    cmp w2, 0
    b.eq 3f
    cmp w2, '\n'
    b.eq 2f
    cmp w2, '\r'
    b.eq 2f
    add x3, x3, 1
    b 1b
2:
    add x3, x3, 1
    add x1, x1, 1
    b 1b
3:
    add x1, x1, 1

    mov x0, x1

    ldp x29, x30, [sp], #16
    ret


// Exit and error -----------------------------------------------------------

/*
    void exit();
 */
exit:
    mov x16, 1
    mov x0, 0
    svc 0


/*
    void exit_with_error(char *error);
    error: A pointer to a null-terminated string describing the error.
 */
exit_with_error:
    stp x29, x30, [sp, #-16]!
    mov x29, sp             // FP points to frame record

    cmp x0, 0
    b.eq 1f
    bl print_line

1:  adrp x0, error@PAGE
    add x0, x0, error@PAGEOFF
    bl print_line

    mov x16, 1
    mov x0, 1
    svc 0

    mov x0, -1
    ldp x29, x30, [sp], #16
    ret


.section __DATA,__data
.align 3

error: 
    .ascii "An error has occurred.\0"

string_line_format:
    .ascii "%s\n\0"

empty_line: 
    .ascii "\0"

int_to_str_format:
    .ascii "%i\0"

read_error_message:
    .ascii "Error while reading from standard input.\0"


.set __COMMON_S__, 0
.endif