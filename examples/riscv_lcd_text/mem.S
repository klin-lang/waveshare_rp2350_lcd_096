/* Minimal memcpy/memset for -nostdlib (Ubuntu riscv64-unknown-elf has no nano.specs). */
.section .text
.globl memcpy
.globl memset

memcpy:
    /* a0=dst, a1=src, a2=n */
    mv   t0, a0
1:
    beqz a2, 2f
    lbu  t1, 0(a1)
    sb   t1, 0(a0)
    addi a0, a0, 1
    addi a1, a1, 1
    addi a2, a2, -1
    j    1b
2:
    mv   a0, t0
    ret

memset:
    /* a0=dst, a1=val, a2=n */
    mv   t0, a0
1:
    beqz a2, 2f
    sb   a1, 0(a0)
    addi a0, a0, 1
    addi a2, a2, -1
    j    1b
2:
    mv   a0, t0
    ret
