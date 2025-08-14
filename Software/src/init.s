    .section .init
    .globl _start

_start:
    #li t0, 0x1000
    #li t1, 0x8000
    #sw t1, 0(t0)
    #lw t2, 0(t0)

    #sb x0, 0(t0)
    #lw t2, 0(t0)
    #lbu t2, 0(t0)


    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    li sp, 0x8000
    li t0, 43
    sw t0, 0(sp)
	
    call main
    j .