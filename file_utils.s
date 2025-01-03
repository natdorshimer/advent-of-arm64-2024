.ifndef __FILE_UTILS_S__
.include "common.s"

.section __TEXT,__text
.align 2

/*
    5 int _open_file(char *path, char mode);
    'r' - read
    'w' - write
 */
open_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp
    stp x19, x20, [sp, #-16]!    

    // Set read or write
    cmp x1, 'r'
    b.eq 1f
    b 2f

1:  // Set read params
    mov x1, 0 // O_RDONLY
    b 3f
2:  // Set write params
    mov x1, 1 | 5 | 4 // O_WRONLY | O_APPEND | O_CREAT
    mov x2, 0644
    b 3f
3:  // Open file
    
    // 5	int open(const char *path, int oflag, ...)
    mov x3, 0
    mov x4, 0
    mov x16, 5
    svc 0

    // Check for error
    cmp x0, 3
    b.lt 4f

    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
4:  bl _exit_with_file_error


/*  FSTAT64
    339 int fstat64(int fildes, struct stat *buf);
    sizeof(struct stat) = 144
    offsetof(struct stat, st_size) = 96
 */
.set FSTAT64, 339
.set STAT_SIZE, 144
.set STAT_ST_SIZE_OFFSET, 96

/*
    size_t get_size_of_file_in_bytes(int fd);
 */
get_size_of_file_in_bytes:
    stp x29, x30, [sp, #-16]!
    sub sp, sp, STAT_SIZE
    mov x1, sp

    // 339 int fstat64(int fildes, struct stat *buf);
    mov x16, FSTAT64
    svc 0

    // Check for error
    cmp x0, -1
    b.eq 1f

    ldr x0, [sp, #STAT_ST_SIZE_OFFSET]

    add sp, sp, STAT_SIZE
    ldp x29, x30, [sp], #16
    ret

1:  bl _exit_with_file_error


/*
    struct { char*, size_t size } read_entire_file(int fd);
 */
read_entire_file:
    stp x29, x30, [sp, #-16]!
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!

    // x19: file descriptor
    // x20: file size (bytes)
    // x21: destination buffer
    mov x19, x0
    bl get_size_of_file_in_bytes
    mov x20, x0

    bl _malloc

    // x21: destination buffer
    mov x1, x0
    mov x21, x0

    // Read from file
    mov x0, x19 // fd
    mov x2, x20 // size
    mov x3, 0   // offset
    mov x4, 0   // flags
    mov x16, 3  // SYS_read
    svc 0

    // Check for error
    cmp x0, -1
    b.eq 1f

    mov x1, x0
    mov x0, x21

    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
    ldp x29, x30, [sp], #16
    ret
1:  bl _exit_with_file_error


_exit_with_file_error:
    adrp x0, error_reading_file@PAGE
    add x0, x0, error_reading_file@PAGEOFF
    bl exit_with_error


.section __DATA,__data
.align 3
error_reading_file:
    .ascii "Error reading file.\0"

.set __FILE_UTILS_S__, 0
.endif