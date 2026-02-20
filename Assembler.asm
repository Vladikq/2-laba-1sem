  .text
    .p2align 2
    .globl _main
    .extern _scanf
    .extern _printf

_main:
    // Пролог: сохраняем frame pointer и return address
    stp x29, x30, [sp, -16]!
    mov x29, sp
    stp x19, x20, [sp, -16]!
    stp x21, x22, [sp, -16]!

    // scanf("%d", &n)
    adrp    x0, fmt_read@PAGE
    add     x0, x0, fmt_read@PAGEOFF      // x0 = &fmt_read
    adrp    x1, n@PAGE
    add     x1, x1, n@PAGEOFF             // x1 = &n
    bl      _scanf

    // ecx-like счётчик в w19 (callee-saved регистр)
    ldr     w19, [x1]                     // w19 = n
    cmp     w19, #0
    ble     print                         // если n <= 0 -> печать 0

loop_n:
    // scanf("%d", &number)
    adrp    x0, fmt_read@PAGE
    add     x0, x0, fmt_read@PAGEOFF
    adrp    x1, number@PAGE
    add     x1, x1, number@PAGEOFF
    bl      _scanf

    // w20 = number
    ldr     w20, [x1]
    cmp     w20, #0
    blt     next                          // отрицательные не считаем
    beq     is_square                     // 0 = 0^2

    // root = 0
    adrp    x2, root@PAGE
    add     x2, x2, root@PAGEOFF
    mov     w21, #0
    str     w21, [x2]

loop_root:
    // root++
    ldr     w21, [x2]
    add     w21, w21, #1
    str     w21, [x2]

    // square = root * root (64-bit, чтобы не словить переполнение по пути)
    uxtw    x3, w21                       // x3 = (uint64)root
    mul     x3, x3, x3                    // x3 = root*root
    uxtw    x4, w20                       // x4 = (uint64)number

    cmp     x3, x4
    beq     is_square                     // square == number
    blt     loop_root                     // square < number -> дальше
    b       next                          // square > number -> не квадрат

is_square:
    // c++
    adrp    x5, c@PAGE
    add     x5, x5, c@PAGEOFF
    ldr     w6, [x5]
    add     w6, w6, #1
    str     w6, [x5]

next:
    subs    w19, w19, #1                  // n--
    bgt     loop_n

print:
    // printf("%d\n", c)
    adrp    x0, fmt_write@PAGE
    add     x0, x0, fmt_write@PAGEOFF     // x0 = fmt
    adrp    x1, c@PAGE
    add     x1, x1, c@PAGEOFF
    ldr     w1, [x1]                      // printf arg #2 (int) в w1/x1
    bl      _printf

    // return 0
    mov     w0, #0
    ldp     x29, x30, [sp], 16
    ret

    .data
    .p2align 2
n:          .long   0      // int n
number:     .long   0      // int number
c:          .long   0      // int c (сколько квадратов)
root:       .long   0      // int root

fmt_read:   .asciz  "%d"
fmt_write:  .asciz  "%d\n"