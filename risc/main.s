	.text
	.attribute	4, 16
	.attribute	5, "rv32i2p1"
	.file	"main.c"
	.globl	DrawMandelbrot                  # -- Begin function DrawMandelbrot
	.p2align	2
	.type	DrawMandelbrot,@function
DrawMandelbrot:                         # @DrawMandelbrot
# %bb.0:
	addi	sp, sp, -128
	sw	ra, 124(sp)                     # 4-byte Folded Spill
	sw	s0, 120(sp)                     # 4-byte Folded Spill
	addi	s0, sp, 128
	sw	a0, -12(s0)
	li	a0, 64
	sw	a0, -16(s0)
	lui	a0, 786432
	sw	a0, -20(s0)
	lui	a0, 260096
	sw	a0, -24(s0)
	lui	a1, 784384
	sw	a1, -28(s0)
	sw	a0, -32(s0)
	lw	a0, -24(s0)
	lw	a1, -20(s0)
	call	__subsf3
	sw	a0, -96(s0)                     # 4-byte Folded Spill
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	call	__floatsisf
	mv	a1, a0
	lw	a0, -96(s0)                     # 4-byte Folded Reload
	call	__divsf3
	sw	a0, -36(s0)
	lw	a0, -32(s0)
	lw	a1, -28(s0)
	call	__subsf3
	sw	a0, -92(s0)                     # 4-byte Folded Spill
	lw	a0, -12(s0)
	lw	a0, 4(a0)
	call	__floatsisf
	mv	a1, a0
	lw	a0, -92(s0)                     # 4-byte Folded Reload
	call	__divsf3
	sw	a0, -40(s0)
	li	a0, 0
	sw	a0, -44(s0)
	j	.LBB0_1
.LBB0_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB0_3 Depth 2
                                        #       Child Loop BB0_5 Depth 3
	lw	a0, -44(s0)
	lw	a1, -12(s0)
	lw	a1, 4(a1)
	bge	a0, a1, .LBB0_14
	j	.LBB0_2
.LBB0_2:                                #   in Loop: Header=BB0_1 Depth=1
	li	a0, 0
	sw	a0, -48(s0)
	j	.LBB0_3
.LBB0_3:                                #   Parent Loop BB0_1 Depth=1
                                        # =>  This Loop Header: Depth=2
                                        #       Child Loop BB0_5 Depth 3
	lw	a0, -48(s0)
	lw	a1, -12(s0)
	lw	a1, 0(a1)
	bge	a0, a1, .LBB0_12
	j	.LBB0_4
.LBB0_4:                                #   in Loop: Header=BB0_3 Depth=2
	lw	a0, -20(s0)
	sw	a0, -104(s0)                    # 4-byte Folded Spill
	lw	a0, -48(s0)
	call	__floatsisf
	lw	a1, -36(s0)
	call	__mulsf3
	lw	a1, -104(s0)                    # 4-byte Folded Reload
	call	__addsf3
	sw	a0, -52(s0)
	lw	a0, -28(s0)
	sw	a0, -100(s0)                    # 4-byte Folded Spill
	lw	a0, -44(s0)
	call	__floatsisf
	lw	a1, -40(s0)
	call	__mulsf3
	lw	a1, -100(s0)                    # 4-byte Folded Reload
	call	__addsf3
	sw	a0, -56(s0)
	li	a0, 0
	sw	a0, -60(s0)
	sw	a0, -64(s0)
	sw	a0, -68(s0)
	j	.LBB0_5
.LBB0_5:                                #   Parent Loop BB0_1 Depth=1
                                        #     Parent Loop BB0_3 Depth=2
                                        # =>    This Inner Loop Header: Depth=3
	lw	a0, -68(s0)
	lw	a1, -16(s0)
	bge	a0, a1, .LBB0_10
	j	.LBB0_6
.LBB0_6:                                #   in Loop: Header=BB0_5 Depth=3
	lw	a1, -60(s0)
	mv	a0, a1
	call	__mulsf3
	sw	a0, -72(s0)
	lw	a1, -64(s0)
	mv	a0, a1
	call	__mulsf3
	sw	a0, -76(s0)
	lw	a0, -72(s0)
	lw	a1, -76(s0)
	call	__addsf3
	lui	a1, 264192
	call	__gtsf2
	mv	a1, a0
	li	a0, 0
	bge	a0, a1, .LBB0_8
	j	.LBB0_7
.LBB0_7:                                #   in Loop: Header=BB0_3 Depth=2
	j	.LBB0_10
.LBB0_8:                                #   in Loop: Header=BB0_5 Depth=3
	lw	a0, -72(s0)
	lw	a1, -76(s0)
	call	__subsf3
	lw	a1, -52(s0)
	call	__addsf3
	sw	a0, -80(s0)
	lw	a1, -60(s0)
	mv	a0, a1
	call	__addsf3
	lw	a1, -64(s0)
	lw	a2, -56(s0)
	sw	a2, -108(s0)                    # 4-byte Folded Spill
	call	__mulsf3
	lw	a1, -108(s0)                    # 4-byte Folded Reload
	call	__addsf3
	sw	a0, -84(s0)
	lw	a0, -80(s0)
	sw	a0, -60(s0)
	lw	a0, -84(s0)
	sw	a0, -64(s0)
	j	.LBB0_9
.LBB0_9:                                #   in Loop: Header=BB0_5 Depth=3
	lw	a0, -68(s0)
	addi	a0, a0, 1
	sw	a0, -68(s0)
	j	.LBB0_5
.LBB0_10:                               #   in Loop: Header=BB0_3 Depth=2
	lw	a0, -68(s0)
	slli	a0, a0, 2
	lw	a1, -16(s0)
	call	__divsi3
	sb	a0, -85(s0)
	lbu	a0, -85(s0)
	sw	a0, -112(s0)                    # 4-byte Folded Spill
	lw	a1, -12(s0)
	lw	a0, 12(a1)
	sw	a0, -116(s0)                    # 4-byte Folded Spill
	lw	a0, -44(s0)
	lw	a1, 8(a1)
	call	__mulsi3
	lw	a1, -116(s0)                    # 4-byte Folded Reload
	mv	a2, a0
	lw	a0, -112(s0)                    # 4-byte Folded Reload
	lw	a3, -48(s0)
	add	a2, a2, a3
	add	a1, a1, a2
	sb	a0, 0(a1)
	j	.LBB0_11
.LBB0_11:                               #   in Loop: Header=BB0_3 Depth=2
	lw	a0, -48(s0)
	addi	a0, a0, 1
	sw	a0, -48(s0)
	j	.LBB0_3
.LBB0_12:                               #   in Loop: Header=BB0_1 Depth=1
	j	.LBB0_13
.LBB0_13:                               #   in Loop: Header=BB0_1 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 1
	sw	a0, -44(s0)
	j	.LBB0_1
.LBB0_14:
	lw	ra, 124(sp)                     # 4-byte Folded Reload
	lw	s0, 120(sp)                     # 4-byte Folded Reload
	addi	sp, sp, 128
	ret
.Lfunc_end0:
	.size	DrawMandelbrot, .Lfunc_end0-DrawMandelbrot
                                        # -- End function
	.globl	main                            # -- Begin function main
	.p2align	2
	.type	main,@function
main:                                   # @main
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	lui	a0, 32
	sw	a0, -12(s0)
	li	a0, 320
	sw	a0, -16(s0)
	li	a1, 240
	sw	a1, -20(s0)
	sw	a0, -24(s0)
	addi	a0, s0, -24
	sw	a0, -40(s0)
	li	a0, 255
	sb	a0, -36(s0)
	li	a0, 0
	sw	a0, -48(s0)                     # 4-byte Folded Spill
	sb	a0, -35(s0)
	sw	a0, -32(s0)
	sw	a0, -28(s0)
	addi	a0, s0, -40
	call	ClearConsole
	lw	a0, -48(s0)                     # 4-byte Folded Reload
	sw	a0, -44(s0)
	j	.LBB1_1
.LBB1_1:                                # =>This Inner Loop Header: Depth=1
	lw	a2, -44(s0)
	lui	a0, %hi(.L.str)
	addi	a1, a0, %lo(.L.str)
	addi	a0, s0, -40
	call	ConsoleWrite
	j	.LBB1_2
.LBB1_2:                                #   in Loop: Header=BB1_1 Depth=1
	lw	a0, -44(s0)
	addi	a0, a0, 1
	sw	a0, -44(s0)
	j	.LBB1_1
.Lfunc_end1:
	.size	main, .Lfunc_end1-main
                                        # -- End function
	.p2align	2                               # -- Begin function ClearConsole
	.type	ClearConsole,@function
ClearConsole:                           # @ClearConsole
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	lw	a1, -12(s0)
	lw	a0, 0(a1)
	lbu	a1, 5(a1)
	lw	a2, 12(a0)
	sw	a2, -16(s0)
	lw	a2, 8(a0)
	sw	a2, -20(s0)
	lw	a2, 4(a0)
	sw	a2, -24(s0)
	lw	a0, 0(a0)
	sw	a0, -28(s0)
	addi	a0, s0, -28
	call	ClearScreen
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end2:
	.size	ClearConsole, .Lfunc_end2-ClearConsole
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleWrite
	.type	ConsoleWrite,@function
ConsoleWrite:                           # @ConsoleWrite
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 20(sp)                      # 4-byte Folded Spill
	sw	s0, 16(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 24
	sw	a7, 20(s0)
	sw	a6, 16(s0)
	sw	a5, 12(s0)
	sw	a4, 8(s0)
	sw	a3, 4(s0)
	sw	a2, 0(s0)
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	mv	a0, s0
	sw	a0, -20(s0)
	j	.LBB3_1
.LBB3_1:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -16(s0)
	lbu	a0, 0(a0)
	beqz	a0, .LBB3_17
	j	.LBB3_2
.LBB3_2:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -16(s0)
	lbu	a0, 0(a0)
	li	a1, 37
	bne	a0, a1, .LBB3_15
	j	.LBB3_3
.LBB3_3:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -16(s0)
	addi	a0, a0, 1
	sw	a0, -16(s0)
	lw	a0, -16(s0)
	lbu	a0, 0(a0)
	sw	a0, -24(s0)                     # 4-byte Folded Spill
	beqz	a0, .LBB3_13
	j	.LBB3_4
.LBB3_4:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 99
	beq	a0, a1, .LBB3_12
	j	.LBB3_5
.LBB3_5:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 100
	beq	a0, a1, .LBB3_10
	j	.LBB3_6
.LBB3_6:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 105
	beq	a0, a1, .LBB3_10
	j	.LBB3_7
.LBB3_7:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 115
	beq	a0, a1, .LBB3_9
	j	.LBB3_8
.LBB3_8:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -24(s0)                     # 4-byte Folded Reload
	li	a1, 120
	beq	a0, a1, .LBB3_11
	j	.LBB3_14
.LBB3_9:                                #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	addi	a2, a1, 4
	sw	a2, -20(s0)
	lw	a1, 0(a1)
	call	ConsoleWriteString
	j	.LBB3_14
.LBB3_10:                               #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	addi	a2, a1, 4
	sw	a2, -20(s0)
	lw	a1, 0(a1)
	li	a2, 10
	call	ConsoleWriteInt
	j	.LBB3_14
.LBB3_11:                               #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	addi	a2, a1, 4
	sw	a2, -20(s0)
	lw	a1, 0(a1)
	li	a2, 16
	call	ConsoleWriteInt
	j	.LBB3_14
.LBB3_12:                               #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -20(s0)
	addi	a2, a1, 4
	sw	a2, -20(s0)
	lbu	a1, 0(a1)
	call	ConsoleWriteChar
	j	.LBB3_14
.LBB3_13:
	j	.LBB3_17
.LBB3_14:                               #   in Loop: Header=BB3_1 Depth=1
	j	.LBB3_16
.LBB3_15:                               #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lbu	a1, 0(a1)
	call	ConsoleWriteChar
	j	.LBB3_16
.LBB3_16:                               #   in Loop: Header=BB3_1 Depth=1
	lw	a0, -16(s0)
	addi	a0, a0, 1
	sw	a0, -16(s0)
	j	.LBB3_1
.LBB3_17:
	lw	ra, 20(sp)                      # 4-byte Folded Reload
	lw	s0, 16(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end3:
	.size	ConsoleWrite, .Lfunc_end3-ConsoleWrite
                                        # -- End function
	.p2align	2                               # -- Begin function ClearScreen
	.type	ClearScreen,@function
ClearScreen:                            # @ClearScreen
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -32(s0)                     # 4-byte Folded Spill
                                        # kill: def $x12 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	li	a0, 0
	sw	a0, -20(s0)
	sw	a0, -24(s0)
	j	.LBB4_1
.LBB4_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB4_3 Depth 2
	lw	a1, -32(s0)                     # 4-byte Folded Reload
	lw	a0, -24(s0)
	lw	a1, 4(a1)
	bge	a0, a1, .LBB4_8
	j	.LBB4_2
.LBB4_2:                                #   in Loop: Header=BB4_1 Depth=1
	li	a0, 0
	sw	a0, -28(s0)
	j	.LBB4_3
.LBB4_3:                                #   Parent Loop BB4_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a1, -32(s0)                     # 4-byte Folded Reload
	lw	a0, -28(s0)
	lw	a1, 0(a1)
	bge	a0, a1, .LBB4_6
	j	.LBB4_4
.LBB4_4:                                #   in Loop: Header=BB4_3 Depth=2
	lw	a1, -32(s0)                     # 4-byte Folded Reload
	lbu	a0, -13(s0)
	lw	a1, 12(a1)
	lw	a2, -20(s0)
	addi	a3, a2, 1
	sw	a3, -20(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	j	.LBB4_5
.LBB4_5:                                #   in Loop: Header=BB4_3 Depth=2
	lw	a0, -28(s0)
	addi	a0, a0, 1
	sw	a0, -28(s0)
	j	.LBB4_3
.LBB4_6:                                #   in Loop: Header=BB4_1 Depth=1
	j	.LBB4_7
.LBB4_7:                                #   in Loop: Header=BB4_1 Depth=1
	lw	a0, -24(s0)
	addi	a0, a0, 1
	sw	a0, -24(s0)
	j	.LBB4_1
.LBB4_8:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end4:
	.size	ClearScreen, .Lfunc_end4-ClearScreen
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleWriteString
	.type	ConsoleWriteString,@function
ConsoleWriteString:                     # @ConsoleWriteString
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	li	a0, 0
	sw	a0, -20(s0)
	j	.LBB5_1
.LBB5_1:                                # =>This Inner Loop Header: Depth=1
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	add	a0, a0, a1
	lbu	a0, 0(a0)
	beqz	a0, .LBB5_4
	j	.LBB5_2
.LBB5_2:                                #   in Loop: Header=BB5_1 Depth=1
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	call	ConsoleWriteChar
	j	.LBB5_3
.LBB5_3:                                #   in Loop: Header=BB5_1 Depth=1
	lw	a0, -20(s0)
	addi	a0, a0, 1
	sw	a0, -20(s0)
	j	.LBB5_1
.LBB5_4:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end5:
	.size	ConsoleWriteString, .Lfunc_end5-ConsoleWriteString
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleWriteInt
	.type	ConsoleWriteInt,@function
ConsoleWriteInt:                        # @ConsoleWriteInt
# %bb.0:
	addi	sp, sp, -32
	sw	ra, 28(sp)                      # 4-byte Folded Spill
	sw	s0, 24(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 32
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lw	a0, -16(s0)
	bnez	a0, .LBB6_2
	j	.LBB6_1
.LBB6_1:
	lw	a0, -12(s0)
	li	a1, 48
	call	ConsoleWriteChar
	j	.LBB6_3
.LBB6_2:
	lw	a0, -12(s0)
	lw	a1, -16(s0)
	lw	a2, -20(s0)
	call	ConsoleWriteIntInternal
	j	.LBB6_3
.LBB6_3:
	lw	ra, 28(sp)                      # 4-byte Folded Reload
	lw	s0, 24(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 32
	ret
.Lfunc_end6:
	.size	ConsoleWriteInt, .Lfunc_end6-ConsoleWriteInt
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleWriteChar
	.type	ConsoleWriteChar,@function
ConsoleWriteChar:                       # @ConsoleWriteChar
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
                                        # kill: def $x12 killed $x11
	sw	a0, -12(s0)
	sb	a1, -13(s0)
	lbu	a0, -13(s0)
	sw	a0, -36(s0)                     # 4-byte Folded Spill
	li	a1, 10
	beq	a0, a1, .LBB7_2
	j	.LBB7_1
.LBB7_1:
	lw	a0, -36(s0)                     # 4-byte Folded Reload
	li	a1, 13
	beq	a0, a1, .LBB7_5
	j	.LBB7_6
.LBB7_2:
	lw	a1, -12(s0)
	lw	a0, 12(a1)
	addi	a0, a0, 16
	sw	a0, 12(a1)
	lw	a1, -12(s0)
	li	a0, 0
	sw	a0, 8(a1)
	lw	a1, -12(s0)
	lw	a0, 12(a1)
	lw	a1, 0(a1)
	lw	a1, 4(a1)
	blt	a0, a1, .LBB7_4
	j	.LBB7_3
.LBB7_3:
	lw	a0, -12(s0)
	call	ConsoleScrollDown
	j	.LBB7_4
.LBB7_4:
	j	.LBB7_9
.LBB7_5:
	lw	a1, -12(s0)
	li	a0, 0
	sw	a0, 8(a1)
	j	.LBB7_9
.LBB7_6:
	lw	a3, -12(s0)
	lw	a0, 0(a3)
	lw	a1, 8(a3)
	lw	a2, 12(a3)
	lbu	a3, 4(a3)
	lbu	a4, -13(s0)
	lw	a5, 12(a0)
	sw	a5, -20(s0)
	lw	a5, 8(a0)
	sw	a5, -24(s0)
	lw	a5, 4(a0)
	sw	a5, -28(s0)
	lw	a0, 0(a0)
	sw	a0, -32(s0)
	addi	a0, s0, -32
	call	DrawChar
	lw	a1, -12(s0)
	lw	a0, 8(a1)
	addi	a0, a0, 8
	sw	a0, 8(a1)
	lw	a1, -12(s0)
	lw	a0, 8(a1)
	lw	a1, 0(a1)
	lw	a1, 0(a1)
	blt	a0, a1, .LBB7_8
	j	.LBB7_7
.LBB7_7:
	lw	a0, -12(s0)
	li	a1, 10
	call	ConsoleWriteChar
	j	.LBB7_8
.LBB7_8:
	j	.LBB7_9
.LBB7_9:
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end7:
	.size	ConsoleWriteChar, .Lfunc_end7-ConsoleWriteChar
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleWriteIntInternal
	.type	ConsoleWriteIntInternal,@function
ConsoleWriteIntInternal:                # @ConsoleWriteIntInternal
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	lui	a0, %hi(.L.str.1)
	addi	a0, a0, %lo(.L.str.1)
	sw	a0, -24(s0)
	lw	a0, -16(s0)
	beqz	a0, .LBB8_2
	j	.LBB8_1
.LBB8_1:
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	call	__modsi3
	sw	a0, -28(s0)
	lw	a0, -12(s0)
	sw	a0, -32(s0)                     # 4-byte Folded Spill
	lw	a0, -16(s0)
	lw	a1, -20(s0)
	sw	a1, -36(s0)                     # 4-byte Folded Spill
	call	__divsi3
	lw	a2, -36(s0)                     # 4-byte Folded Reload
	mv	a1, a0
	lw	a0, -32(s0)                     # 4-byte Folded Reload
	call	ConsoleWriteIntInternal
	lw	a0, -12(s0)
	lw	a1, -24(s0)
	lw	a2, -28(s0)
	add	a1, a1, a2
	lbu	a1, 0(a1)
	call	ConsoleWriteChar
	j	.LBB8_2
.LBB8_2:
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end8:
	.size	ConsoleWriteIntInternal, .Lfunc_end8-ConsoleWriteIntInternal
                                        # -- End function
	.p2align	2                               # -- Begin function ConsoleScrollDown
	.type	ConsoleScrollDown,@function
ConsoleScrollDown:                      # @ConsoleScrollDown
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a0, -12(s0)
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lw	a0, 4(a0)
	addi	a0, a0, -16
	sw	a0, -16(s0)
	lw	a0, -12(s0)
	lw	a1, 0(a0)
	lw	a0, 12(a1)
	lw	a1, 8(a1)
	slli	a1, a1, 4
	add	a0, a0, a1
	sw	a0, -20(s0)
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lw	a0, 12(a0)
	sw	a0, -24(s0)
	li	a0, 0
	sw	a0, -28(s0)
	j	.LBB9_1
.LBB9_1:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB9_3 Depth 2
	lw	a0, -28(s0)
	lw	a1, -16(s0)
	bge	a0, a1, .LBB9_8
	j	.LBB9_2
.LBB9_2:                                #   in Loop: Header=BB9_1 Depth=1
	li	a0, 0
	sw	a0, -32(s0)
	j	.LBB9_3
.LBB9_3:                                #   Parent Loop BB9_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a0, -32(s0)
	lw	a1, -12(s0)
	lw	a1, 0(a1)
	lw	a1, 0(a1)
	bge	a0, a1, .LBB9_6
	j	.LBB9_4
.LBB9_4:                                #   in Loop: Header=BB9_3 Depth=2
	lw	a0, -20(s0)
	lw	a2, -32(s0)
	add	a0, a0, a2
	lbu	a0, 0(a0)
	lw	a1, -24(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	j	.LBB9_5
.LBB9_5:                                #   in Loop: Header=BB9_3 Depth=2
	lw	a0, -32(s0)
	addi	a0, a0, 1
	sw	a0, -32(s0)
	j	.LBB9_3
.LBB9_6:                                #   in Loop: Header=BB9_1 Depth=1
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lw	a1, 8(a0)
	lw	a0, -20(s0)
	add	a0, a0, a1
	sw	a0, -20(s0)
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lw	a1, 8(a0)
	lw	a0, -24(s0)
	add	a0, a0, a1
	sw	a0, -24(s0)
	j	.LBB9_7
.LBB9_7:                                #   in Loop: Header=BB9_1 Depth=1
	lw	a0, -28(s0)
	addi	a0, a0, 1
	sw	a0, -28(s0)
	j	.LBB9_1
.LBB9_8:
	li	a0, 0
	sw	a0, -36(s0)
	j	.LBB9_9
.LBB9_9:                                # =>This Loop Header: Depth=1
                                        #     Child Loop BB9_11 Depth 2
	lw	a1, -36(s0)
	li	a0, 15
	blt	a0, a1, .LBB9_16
	j	.LBB9_10
.LBB9_10:                               #   in Loop: Header=BB9_9 Depth=1
	li	a0, 0
	sw	a0, -40(s0)
	j	.LBB9_11
.LBB9_11:                               #   Parent Loop BB9_9 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a0, -40(s0)
	lw	a1, -12(s0)
	lw	a1, 0(a1)
	lw	a1, 0(a1)
	bge	a0, a1, .LBB9_14
	j	.LBB9_12
.LBB9_12:                               #   in Loop: Header=BB9_11 Depth=2
	lw	a0, -12(s0)
	lbu	a0, 5(a0)
	lw	a1, -24(s0)
	lw	a2, -40(s0)
	add	a1, a1, a2
	sb	a0, 0(a1)
	j	.LBB9_13
.LBB9_13:                               #   in Loop: Header=BB9_11 Depth=2
	lw	a0, -40(s0)
	addi	a0, a0, 1
	sw	a0, -40(s0)
	j	.LBB9_11
.LBB9_14:                               #   in Loop: Header=BB9_9 Depth=1
	lw	a0, -12(s0)
	lw	a0, 0(a0)
	lw	a1, 8(a0)
	lw	a0, -24(s0)
	add	a0, a0, a1
	sw	a0, -24(s0)
	j	.LBB9_15
.LBB9_15:                               #   in Loop: Header=BB9_9 Depth=1
	lw	a0, -36(s0)
	addi	a0, a0, 1
	sw	a0, -36(s0)
	j	.LBB9_9
.LBB9_16:
	lw	a1, -12(s0)
	lw	a0, 12(a1)
	addi	a0, a0, -16
	sw	a0, 12(a1)
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end9:
	.size	ConsoleScrollDown, .Lfunc_end9-ConsoleScrollDown
                                        # -- End function
	.p2align	2                               # -- Begin function DrawChar
	.type	DrawChar,@function
DrawChar:                               # @DrawChar
# %bb.0:
	addi	sp, sp, -64
	sw	ra, 60(sp)                      # 4-byte Folded Spill
	sw	s0, 56(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 64
	sw	a0, -64(s0)                     # 4-byte Folded Spill
                                        # kill: def $x15 killed $x14
                                        # kill: def $x15 killed $x13
	sw	a0, -12(s0)
	sw	a1, -16(s0)
	sw	a2, -20(s0)
	sb	a3, -21(s0)
	sb	a4, -22(s0)
	lui	a0, %hi(VGAFontBytes)
	addi	a0, a0, %lo(VGAFontBytes)
	sw	a0, -28(s0)
	lw	a1, -28(s0)
	sw	a1, -60(s0)                     # 4-byte Folded Spill
	lbu	a0, -22(s0)
	lbu	a1, 3(a1)
	call	__mulsi3
	mv	a1, a0
	lw	a0, -60(s0)                     # 4-byte Folded Reload
	add	a0, a0, a1
	addi	a0, a0, 4
	sw	a0, -32(s0)
	li	a0, 0
	sw	a0, -36(s0)
	j	.LBB10_1
.LBB10_1:                               # =>This Loop Header: Depth=1
                                        #     Child Loop BB10_3 Depth 2
	lw	a0, -36(s0)
	lw	a1, -28(s0)
	lbu	a1, 3(a1)
	bge	a0, a1, .LBB10_10
	j	.LBB10_2
.LBB10_2:                               #   in Loop: Header=BB10_1 Depth=1
	li	a0, 0
	sw	a0, -40(s0)
	j	.LBB10_3
.LBB10_3:                               #   Parent Loop BB10_1 Depth=1
                                        # =>  This Inner Loop Header: Depth=2
	lw	a1, -40(s0)
	li	a0, 7
	blt	a0, a1, .LBB10_8
	j	.LBB10_4
.LBB10_4:                               #   in Loop: Header=BB10_3 Depth=2
	lw	a0, -32(s0)
	lbu	a0, 0(a0)
	lw	a1, -40(s0)
	sll	a0, a0, a1
	andi	a0, a0, 128
	beqz	a0, .LBB10_6
	j	.LBB10_5
.LBB10_5:                               #   in Loop: Header=BB10_3 Depth=2
	lw	a0, -64(s0)                     # 4-byte Folded Reload
	lw	a1, -16(s0)
	lw	a2, -40(s0)
	add	a1, a1, a2
	lw	a2, -20(s0)
	lw	a3, -36(s0)
	add	a2, a2, a3
	lbu	a3, -21(s0)
	lw	a4, 12(a0)
	sw	a4, -44(s0)
	lw	a4, 8(a0)
	sw	a4, -48(s0)
	lw	a4, 4(a0)
	sw	a4, -52(s0)
	lw	a0, 0(a0)
	sw	a0, -56(s0)
	addi	a0, s0, -56
	call	SetPixel
	j	.LBB10_6
.LBB10_6:                               #   in Loop: Header=BB10_3 Depth=2
	j	.LBB10_7
.LBB10_7:                               #   in Loop: Header=BB10_3 Depth=2
	lw	a0, -40(s0)
	addi	a0, a0, 1
	sw	a0, -40(s0)
	j	.LBB10_3
.LBB10_8:                               #   in Loop: Header=BB10_1 Depth=1
	lw	a0, -32(s0)
	addi	a0, a0, 1
	sw	a0, -32(s0)
	j	.LBB10_9
.LBB10_9:                               #   in Loop: Header=BB10_1 Depth=1
	lw	a0, -36(s0)
	addi	a0, a0, 1
	sw	a0, -36(s0)
	j	.LBB10_1
.LBB10_10:
	lw	ra, 60(sp)                      # 4-byte Folded Reload
	lw	s0, 56(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 64
	ret
.Lfunc_end10:
	.size	DrawChar, .Lfunc_end10-DrawChar
                                        # -- End function
	.p2align	2                               # -- Begin function SetPixel
	.type	SetPixel,@function
SetPixel:                               # @SetPixel
# %bb.0:
	addi	sp, sp, -48
	sw	ra, 44(sp)                      # 4-byte Folded Spill
	sw	s0, 40(sp)                      # 4-byte Folded Spill
	addi	s0, sp, 48
	sw	a1, -32(s0)                     # 4-byte Folded Spill
	mv	a1, a0
	lw	a0, -32(s0)                     # 4-byte Folded Reload
	sw	a1, -28(s0)                     # 4-byte Folded Spill
                                        # kill: def $x14 killed $x13
	sw	a1, -12(s0)
	sw	a0, -16(s0)
	sw	a2, -20(s0)
	sb	a3, -21(s0)
	lw	a0, -16(s0)
	lw	a1, 0(a1)
	bgeu	a0, a1, .LBB11_3
	j	.LBB11_1
.LBB11_1:
	lw	a1, -28(s0)                     # 4-byte Folded Reload
	lw	a0, -20(s0)
	lw	a1, 4(a1)
	bgeu	a0, a1, .LBB11_3
	j	.LBB11_2
.LBB11_2:
	lw	a1, -28(s0)                     # 4-byte Folded Reload
	lbu	a0, -21(s0)
	sw	a0, -36(s0)                     # 4-byte Folded Spill
	lw	a0, 12(a1)
	sw	a0, -40(s0)                     # 4-byte Folded Spill
	lw	a0, -20(s0)
	lw	a1, 8(a1)
	call	__mulsi3
	lw	a1, -40(s0)                     # 4-byte Folded Reload
	mv	a2, a0
	lw	a0, -36(s0)                     # 4-byte Folded Reload
	lw	a3, -16(s0)
	add	a2, a2, a3
	add	a1, a1, a2
	sb	a0, 0(a1)
	j	.LBB11_3
.LBB11_3:
	lw	ra, 44(sp)                      # 4-byte Folded Reload
	lw	s0, 40(sp)                      # 4-byte Folded Reload
	addi	sp, sp, 48
	ret
.Lfunc_end11:
	.size	SetPixel, .Lfunc_end11-SetPixel
                                        # -- End function
	.type	VGAFontBytes,@object            # @VGAFontBytes
	.data
	.globl	VGAFontBytes
	.p2align	2, 0x0
VGAFontBytes:
	.ascii	"6\004\002\020\000\000~\303\231\231\363\347\347\377\347\347~\000\000\000\000\000\000\000\000\177\346ffff\303\000\000\000\000\000\000\000\006\f\376\0300\376`\300\000\000\000\000\000\000\000\000\f\0300`0\030\f\000~\000\000\000\000\000\000\0000\030\f\006\f\0300\000~\000\000\000\000\000\000\000\000|||||||\000\000\000\000\000\000\000\000\000\0208|\376|8\020\000\000\000\000\000\000`\340bfl\0300f\316\226?\006\006\000\000\000`\340bfl\0300`\316\233\006\f\037\000\000\000\3400b6\354\0300f\316\226?\006\006\000\000\000\030\030\030\030\030\000\000\030\030\030\030\030\000\000\000\000ll\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\f\006|\000\000\000\016\033\030\030\030~\030\030\030\030\030\330p\000\000\000\030\030\030~\030\030\030\030\030\030\000\000\000\000\000\000\030\030\030~\030\030~\030\030\030\000\000\000\000\000\000\000\000\302\306\f\0300`\333\233\000\000\000\000\000\000\361[UQ\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\333\333\000\000\000\000\000\000\000\000\000\f\0300\030\f\000\000\000\000\000\000\000\000\000\000\0000\030\f\0300\000\000\000\000\000\000\000fff3\000\000\000\000\000\000\000\000\000\000\000\000fff\314\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000fff\314\000\000\000\000\000\000\000\000\000\000\000\000fff3\000\000\000\000\000\000\000\000\000\000\000\000\030\030\030\f\000\000l8\000<f\302\300\336\306\306f:\000\000\000\000\000\000l8\000v\314\314\314\314\314|\f\314x\000\000\030\030\000<\030\030\030\030\030\030<\000\000\000\000\000\000\000\000\0008\030\030\030\030\030<\000\000\000\000\000\000|\306\306`8\f\006\306\306|\f\006|\000\000\000\000\000\000|\306`8\f\306|\f\006|\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\030<<<\030\030\030\000\030\030\000\000\000\000\000fff$\000\000\000\000\000\000\000\000\000\000\000\000\000\000ll\376lll\376ll\000\000\000\000\000\020\020|\326\322\320|\026\226\326|\020\020\000\000\000\000\000\000\302\306\f\0300`\306\206\000\000\000\000\000\0008ll8v\334\314\314\314v\000\000\000\000\000\030\030\0300\000\000\000\000\000\000\000\000\000\000\000\000\000\f\030000000\030\f\000\000\000\000\000\0000\030\f\f\f\f\f\f\0300\000\000\000\000\000\000\000\000\000l8\3768l\000\000\000\000\000\000\000\000\000\000\000\030\030~\030\030\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\030\030\0300\000\000\000\000\000\000\000\000\000~\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\030\030\000\000\000\000\000\000\000\000\002\006\f\0300`\300\200\000\000\000\000\000\000|\306\306\306\326\326\306\306\306|\000\000\000\000\000\000\0308x\030\030\030\030\030\030~\000\000\000\000\000\000|\306\006\f\0300`\300\306\376\000\000\000\000\000\000|\306\006\006<\006\006\006\306|\000\000\000\000\000\000\f\034<l\314\376\f\f\f\036\000\000\000\000\000\000\376\300\300\300\374\006\006\006\306|\000\000\000\000\000\0008`\300\300\374\306\306\306\306|\000\000\000\000\000\000\376\306\006\006\f\0300000\000\000\000\000\000\000|\306\306\306|\306\306\306\306|\000\000\000\000\000\000|\306\306\306~\006\006\006\fx\000\000\000\000\000\000\000\000\000\030\030\000\000\000\030\030\000\000\000\000\000\000\000\000\000\030\030\000\000\000\030\030\0300\000\000\000\000\000\006\f\0300`0\030\f\006\000\000\000\000\000\000\000\000\000~\000\000~\000\000\000\000\000\000\000\000\000\000`0\030\f\006\f\0300`\000\000\000\000\000\000|\306\306\f\030\030\030\000\030\030\000\000\000\000\000\000|\306\306\306\336\336\336\334\300|\000\000\000\000\000\000\0208l\306\306\376\306\306\306\306\000\000\000\000\000\000\374fff|ffff\374\000\000\000\000\000\000<f\302\300\300\300\300\302f<\000\000\000\000\000\000\370lffffffl\370\000\000\000\000\000\000\376fbhxh`bf\376\000\000\000\000\000\000\376fbhxh```\360\000\000\000\000\000\000<f\302\300\300\336\306\306f:\000\000\000\000\000\000\306\306\306\306\376\306\306\306\306\306\000\000\000\000\000\000<\030\030\030\030\030\030\030\030<\000\000\000\000\000\000\036\f\f\f\f\f\314\314\314x\000\000\000\000\000\000\346fflxxlff\346\000\000\000\000\000\000\360``````bf\376\000\000\000\000\000\000\303\347\377\377\333\303\303\303\303\303\000\000\000\000\000\000\306\346\366\376\336\316\306\306\306\306\000\000\000\000\000\000|\306\306\306\306\306\306\306\306|\000\000\000\000\000\000\374fff|````\360\000\000\000\000\000\000|\306\306\306\306\306\306\326\336|\f\016\000\000\000\000\374fff|lfff\346\000\000\000\000\000\000|\306\306`8\f\006\306\306|\000\000\000\000\000\000\377\333\231\030\030\030\030\030\030<\000\000\000\000\000\000\306\306\306\306\306\306\306\306\306|\000\000\000\000\000\000\303\303\303\303\303\303\303f<\030\000\000\000\000\000\000\303\303\303\303\303\333\333\377ff\000\000\000\000\000\000\303\303f<\030\030<f\303\303\000\000\000\000\000\000\303\303\303f<\030\030\030\030<\000\000\000\000\000\000\377\303\206\f\0300`\301\303\377\000\000\000\000\000\000<00000000<\000\000\000\000\000\000\000\000\200\300`0\030\f\006\002\000\000\000\000\000\000<\f\f\f\f\f\f\f\f<\000\000\000\000\0208l\306\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\376\000\000\000\030\030\030\f\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000x\f|\314\314\314v\000\000\000\000\000\000\340``xlffff|\000\000\000\000\000\000\000\000\000|\306\300\300\300\306|\000\000\000\000\000\000\034\f\f<l\314\314\314\314v\000\000\000\000\000\000\000\000\000|\306\376\300\300\306|\000\000\000\000\000\0008ld`\360````\360\000\000\000\000\000\000\000\000\000v\314\314\314\314\314|\f\314x\000\000\000\340``lvffff\346\000\000\000\000\000\000\030\030\0008\030\030\030\030\030<\000\000\000\000\000\000\006\006\000\016\006\006\006\006\006\006ff<\000\000\000\340``flxxlf\346\000\000\000\000\000\0008\030\030\030\030\030\030\030\030<\000\000\000\000\000\000\000\000\000\346\377\333\333\333\333\333\000\000\000\000\000\000\000\000\000\334ffffff\000\000\000\000\000\000\000\000\000|\306\306\306\306\306|\000\000\000\000\000\000\000\000\000\334fffff|``\360\000\000\000\000\000\000v\314\314\314\314\314|\f\f\036\000\000\000\000\000\000\334vf```\360\000\000\000\000\000\000\000\000\000|\306`8\f\306|\000\000\000\000\000\000\02000\37400006\034\000\000\000\000\000\000\000\000\000\314\314\314\314\314\314v\000\000\000\000\000\000\000\000\000\303\303\303\303f<\030\000\000\000\000\000\000\000\000\000\303\303\303\333\333\377f\000\000\000\000\000\000\000\000\000\303f<\030<f\303\000\000\000\000\000\000\000\000\000\306\306\306\306\306\306~\006\f\370\000\000\000\000\000\000\376\314\0300`\306\376\000\000\000\000\000\000\016\030\030\030p\030\030\030\030\016\000\000\000\000\000\030\030\030\030\030\030\030\030\030\030\030\030\000\000\000\000\000p\030\030\030\016\030\030\030\030p\000\000\000\000\000\000v\334\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\030<<\030\000\000\000\000\000\000`0\030\0008l\306\306\376\306\306\306\000\000\000\000\f\0300\0008l\306\306\376\306\306\306\000\000\000\000\0208l\0008l\306\306\376\306\306\306\000\000\000\000\000v\334\0008l\306\306\376\306\306\306\000\000\000\000\000ll\0008l\306\306\376\306\306\306\000\000\000\0008l8\0208l\306\306\376\306\306\306\000\000\000\000\000\000?m\314\314\377\314\314\314\315\317\000\000\000\000\000\000<f\302\300\300\300\300\302f<\f\006|\000`0\030\000\376bhxh`b\376\000\000\000\000\f\0300\000\376bhxh`b\376\000\000\000\000\0208l\000\376bhxh`b\376\000\000\000\000\000ll\000\376bhxh`b\376\000\000\000\0000\030\f\000<\030\030\030\030\030\030<\000\000\000\000\f\0300\000<\030\030\030\030\030\030<\000\000\000\000\0208l\000<\030\030\030\030\030\030<\000\000\000\000\000ff\000<\030\030\030\030\030\030<\000\000\000\000\000\000\370lff\366fffl\370\000\000\000\000v\334\000\306\346\366\376\336\316\306\306\306\000\000\000\000`0\030\000|\306\306\306\306\306\306|\000\000\000\000\f\0300\000|\306\306\306\306\306\306|\000\000\000\000\0208l\000|\306\306\306\306\306\306|\000\000\000\000\000v\334\000|\306\306\306\306\306\306|\000\000\000\000\000ll\000|\306\306\306\306\306\306|\000\000\000\000\000\000\000\000\000\306l8l\306\000\000\000\000\000\000\000\000=gfn~vff\346\274\000\000\000\000`0\030\000\306\306\306\306\306\306\306|\000\000\000\000\f\0300\000\306\306\306\306\306\306\306|\000\000\000\000\0208l\000\306\306\306\306\306\306\306|\000\000\000\000\000ll\000\306\306\306\306\306\306\306|\000\000\000\000\f\0300\000\303\303f<\030\030\030<\000\000\000\000\000\000\360`|ffff|`\360\000\000\000\000\000\000x\314\314\314\330\314\306\306\306\314\000\000\000\000\252U\252U\252U\252U\252U\252U\252U\252U\000\000\030\030\000\030\030\030<<<\030\000\000\000\000\000\000\000\000\020|\326\320\320\320\326|\020\000\000\000\0008ld``\360```f\374\000\000\000\000\000\000\0363`\374`\370``3\036\000\000\000\000\000\000\303\303f<\030~\030~\030\030\000\000\000\000l8\020|\306\306`8\f\306\306|\000\000\000\000\000|\306`8l\306\306l8\f\306|\000\000\000\000l8\020\000|\306`8\f\306|\000\000\000\000\000\000<B\231\245\241\241\245\231B<\000\000\000\000\000<ll>\000~\000\000\000\000\000\000\000\000\000\000\000\000\000\0006l\330l6\000\000\000\000\000\000\000\000\000\000\000\000\376\006\006\006\000\000\000\000\000\000\000\000\000\000f<fff<f\000\000\000\000\000\000<B\271\245\271\245B<\000\000\000\000\000\000\000\000\000|\000\000\000\000\000\000\000\000\000\000\000\000\000\0008ll8\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\030\030~\030\030\000~\000\000\000\000\0008l\0300|\000\000\000\000\000\000\000\000\000\000\000x\f8\fx\000\000\000\000\000\000\000\000\000\000l8\020\377\303\206\f\0300a\303\377\000\000\000\000\000\000\000\000\000ffffff{``\300\000\000\000\177\333\333\333{\033\033\033\033\033\000\000\000\000\000\000\000\000\000\000\000\030\030\000\000\000\000\000\000\000\000l8\020\000\376\314\0300`\306\376\000\000\000\000\000\0308\030\030<\000\000\000\000\000\000\000\000\000\000\0008lll8\000|\000\000\000\000\000\000\000\000\000\000\000\000\000\330l6l\330\000\000\000\000\000\000\000\000\177\315\314\314\317\314\314\314\315\177\000\000\000\000\000\000\000\000\000~\333\333\337\330\333~\000\000\000\000\000ff\000\303\303f<\030\030\030<\000\000\000\000\000\00000\000000`\306\306|\000\000\000\000\000\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\030\030\030\030\030\030\030\030\030\030\030\030\030\030\030\030\000\000\000\000\000\000\000\037\030\030\030\030\030\030\030\030\000\000\000\000\000\000\000\370\030\030\030\030\030\030\030\030\030\030\030\030\030\030\030\037\000\000\000\000\000\000\000\000\030\030\030\030\030\030\030\370\000\000\000\000\000\000\000\000\030\030\030\030\030\030\030\037\030\030\030\030\030\030\030\030\030\030\030\030\030\030\030\370\030\030\030\030\030\030\030\030\000\000\000\000\000\000\000\377\030\030\030\030\030\030\030\030\030\030\030\030\030\030\030\377\000\000\000\000\000\000\000\000\030\030\030\030\030\030\030\377\030\030\030\030\030\030\030\030\210\"\210\"\210\"\210\"\210\"\210\"\210\"\210\"\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\377\000\000\000\000\000\000\000\377\000\377\000\000\000\000\000\000\0006666666666666666\000\000\000\000\000\000?076666666\000\000\000\000\000\000\376\006\366666666666666670?\000\000\000\000\000\000\000666666\366\006\376\000\000\000\000\000\000\0006666667076666666666666\366\006\3666666666\000\000\000\000\000\000\377\000\3676666666666666\367\000\377\000\000\000\000\000\000\000666666\367\000\3676666666\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\377\000\000\030<~\030\030\030\030\030\030\030\000\000\000\000\000\000\030\030\030\030\030\030\030~<\030\000\000\000\000\000\000\000\000\000\0300\1770\030\000\000\000\000\000\000\000\000\000\000\000\030\f\376\f\030\000\000\000\000\000\000\000`0\030\000x\f|\314\314\314v\000\000\000\000\000\f\0300\000x\f|\314\314\314v\000\000\000\000\000\0208l\000x\f|\314\314\314v\000\000\000\000\000\000v\334\000x\f|\314\314\314v\000\000\000\000\000\000ll\000x\f|\314\314\314v\000\000\000\000\0008l8\000x\f|\314\314\314v\000\000\000\000\000\000\000\000\000v\033{\337\330\333n\000\000\000\000\000\000\000\000\000|\306\300\300\300\306|\f\006|\000\000`0\030\000|\306\376\300\300\306|\000\000\000\000\000\f\0300\000|\306\376\300\300\306|\000\000\000\000\000\0208l\000|\306\376\300\300\306|\000\000\000\000\000\000ll\000|\306\376\300\300\306|\000\000\000\000\000`0\030\0008\030\030\030\030\030<\000\000\000\000\000\f\0300\0008\030\030\030\030\030<\000\000\000\000\000\0208l\0008\030\030\030\030\030<\000\000\000\000\000\000ll\0008\030\030\030\030\030<\000\000\000\000\000\0004\030,\006>ffff<\000\000\000\000\000\000v\334\000\334ffffff\000\000\000\000\000`0\030\000|\306\306\306\306\306|\000\000\000\000\000\f\0300\000|\306\306\306\306\306|\000\000\000\000\000\0208l\000|\306\306\306\306\306|\000\000\000\000\000\000v\334\000|\306\306\306\306\306|\000\000\000\000\000\000ll\000|\306\306\306\306\306|\000\000\000\000\000\000\000\000\030\030\000~\000\030\030\000\000\000\000\000\000\000\000\000\000=gn~v\346\274\000\000\000\000\000`0\030\000\314\314\314\314\314\314v\000\000\000\000\000\f\0300\000\314\314\314\314\314\314v\000\000\000\000\000\0208l\000\314\314\314\314\314\314v\000\000\000\000\000\000ll\000\314\314\314\314\314\314v\000\000\000\000\000\f\0300\000\306\306\306\306\306\306~\006\f\370\000\000\000\340``|fffff|``\360\000\000\000ll\000\306\306\306\306\306\306~\006\f\370\000\375\377\377\377\300\003\377\377`\"\377\377d\"\377\377e\"\377\377\240%\254%\256%\374%\376%\033+\016\"\377\377\306%f&%+'+\377\377\274\000\377\377\275\000\377\377\276\000\377\377\246\000\377\377\250\000\377\377\270\000\377\377\222\001\377\377  \377\377! \377\3770 \377\377\"!\377\377& \377\3779 \377\377: \377\377\034 \037 6 \377\377\035 \272\002\335\002\356\0023 \377\377\036 \377\377B.\377\377A.\316\002\377\377\036\001\377\377\037\001\377\3770\001\377\3771\001\377\377^\001\377\377_\001\377\377 \000\240\000\000 \001 \002 \003 \004 \005 \006 \007 \b \t \n / _ \377\377!\000\377\377\"\000\377\377#\000\377\377$\000\377\377%\000\377\377&\000\377\377'\000\264\000\271\002\274\002\312\002\031 2 \377\377(\000\377\377)\000\377\377*\000N \027\"\377\377+\000\377\377,\000\317\002\032 \377\377-\000\255\000\020 \021 \022 \023 C \022\"\377\377.\000$ \377\377/\000D \025\"\377\3770\000\377\3771\000\377\3772\000\377\3773\000\377\3774\000\377\3775\000\377\3776\000\377\3777\000\377\3778\000\377\3779\000\377\377:\0006\"\377\377;\000\377\377<\000\377\377=\000@.\377\377>\000\377\377?\000\377\377@\000\377\377A\000\377\377B\000\377\377C\000\377\377D\000\377\377E\000\377\377F\000\377\377G\000\377\377H\000\377\377I\000\377\377J\000\377\377K\000*!\377\377L\000\377\377M\000\377\377N\000\377\377O\000\377\377P\000\377\377Q\000\377\377R\000\377\377S\000\377\377T\000\377\377U\000\377\377V\000\377\377W\000\377\377X\000\377\377Y\000\377\377Z\000\377\377[\000\377\377\\\000\365)\377\377]\000\377\377^\000\304\002\306\002\003#\377\377_\000\377\377`\000\273\002\275\002\313\002\030 \033 5 \377\377a\000\377\377b\000\377\377c\000\377\377d\000\377\377e\000\377\377f\000\377\377g\000\377\377h\000\377\377i\000\377\377j\000\377\377k\000\377\377l\000\377\377m\000\377\377n\000\377\377o\000\377\377p\000\377\377q\000\377\377r\000\377\377s\000\377\377t\000\377\377u\000\377\377v\000\377\377w\000\377\377x\000\377\377y\000\377\377z\000\377\377{\000\377\377|\000#\"\377\377}\000\377\377~\000\334\002\377\377\" \031\"\317%\377\377\300\000\377\377\301\000\377\377\302\000\377\377\303\000\377\377\304\000\377\377\305\000+!\377\377\306\000\377\377\307\000\377\377\310\000\377\377\311\000\377\377\312\000\377\377\313\000\377\377\314\000\377\377\315\000\377\377\316\000\377\377\317\000\377\377\320\000\020\001\377\377\321\000\377\377\322\000\377\377\323\000\377\377\324\000\377\377\325\000\377\377\326\000\377\377\327\000\377\377\330\000\377\377\331\000\377\377\332\000\377\377\333\000\377\377\334\000\377\377\335\000\377\377\336\000\377\377\337\000\377\377\222%\377\377\241\000\377\377\242\000\377\377\243\000\377\377\254 \377\377\245\000\377\377`\001\377\377\247\000\377\377a\001\377\377\251\000\377\377\252\000\377\377\253\000\377\377\254\000\377\377\244\000\377\377\256\000\377\377\257\000\311\002\377\377\260\000\332\002\377\377\261\000\377\377\262\000\377\377\263\000\377\377}\001\377\377\265\000\274\003\377\377\266\000\377\377\267\000' \305\"1.\377\377~\001\377\377\271\000\377\377\272\000\377\377\273\000\377\377R\001\377\377S\001\377\377x\001\377\377\277\000\377\377\000%\024 \025 \257#\377\377\002%\377\377\f%m%\377\377\020%n%\377\377\024%p%\377\377\030%o%\377\377\034%\377\377$%\377\377,%\377\3774%\377\377<%\377\377\221%\377\377\272#> \377\377\273#\377\377\274#\377\377\275#\377\377P%\001%\377\377Q%\003%\377\377T%\017%\377\377W%\023%\377\377Z%\027%\377\377]%\033%\377\377`%#%\377\377c%+%\377\377f%3%\377\377i%;%\377\377l%K%\377\377\210%\377\377\221!\377\377\223!\377\377\220!\377\377\222!\377\377\340\000\377\377\341\000\377\377\342\000\377\377\343\000\377\377\344\000\377\377\345\000\377\377\346\000\377\377\347\000\377\377\350\000\377\377\351\000\377\377\352\000\377\377\353\000\377\377\354\000\377\377\355\000\377\377\356\000\377\377\357\000\377\377\360\000\377\377\361\000\377\377\362\000\377\377\363\000\377\377\364\000\377\377\365\000\377\377\366\000\377\377\367\000\377\377\370\000\377\377\371\000\377\377\372\000\377\377\373\000\377\377\374\000\377\377\375\000\377\377\376\000\377\377\377\000\377\377"
	.size	VGAFontBytes, 5312

	.type	.L__const.main.Screen,@object   # @__const.main.Screen
	.section	.rodata.cst16,"aM",@progbits,16
	.p2align	2, 0x0
.L__const.main.Screen:
	.word	320                             # 0x140
	.word	240                             # 0xf0
	.word	320                             # 0x140
	.word	131072
	.size	.L__const.main.Screen, 16

	.type	.L.str,@object                  # @.str
	.section	.rodata.str1.1,"aMS",@progbits,1
.L.str:
	.asciz	"Hello %d\n"
	.size	.L.str, 10

	.type	.L.str.1,@object                # @.str.1
.L.str.1:
	.asciz	"0123456789ABCDEF"
	.size	.L.str.1, 17

	.ident	"clang version 18.1.6"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym ClearConsole
	.addrsig_sym ConsoleWrite
	.addrsig_sym ClearScreen
	.addrsig_sym ConsoleWriteString
	.addrsig_sym ConsoleWriteInt
	.addrsig_sym ConsoleWriteChar
	.addrsig_sym ConsoleWriteIntInternal
	.addrsig_sym ConsoleScrollDown
	.addrsig_sym DrawChar
	.addrsig_sym SetPixel
	.addrsig_sym VGAFontBytes
