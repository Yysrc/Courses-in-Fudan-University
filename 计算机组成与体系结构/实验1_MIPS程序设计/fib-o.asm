## fib-- (hacked-up caller-save method)
## Registers used:
## $a0 - initially n.
## $t0 - parameter n.
## $t1 - fib (n - 1).
## $t2 - fib (n - 2).

.globl main

.text
fib:
	bgt		 $a0, 1, fib_recurse        # if n < 2, then just return a 1,
	li		 $v1, 1						# don¡¯t bother to build a stack frame.
	jr		 $ra
										# otherwise, set things up to handle
fib_recurse:							# the recursive case:
	subu	 $sp, $sp, 32				# frame size = 32, just because...
	sw		 $ra, 28($sp)				# preserve the Return Address.
	sw		 $fp, 24($sp)				# preserve the Frame Pointer.
	addu	 $fp, $sp, 32				# move Frame Pointer to base of frame.
	move	 $t0, $a0		 			# get n from caller.

										# compute fib (n - 1):
	sw		 $t0, 20($sp)				# preserve n.
	sub		 $a0, $t0, 1				# compute fib (n - 1)
	jal		 fib
	move	 $t1, $v1					# t1 = fib (n - 1)
	lw		 $t0, 20($sp)				# restore n.
										# compute fib (n - 2):
	sw		 $t1, 16($sp)				# preserve $t1.
	sub		 $a0, $t0, 2				# compute fib (n - 2)
	jal		 fib
	move     $t2, $v1					# t2 = fib (n - 2)
	lw		 $t1, 16($sp)				# restore $t1.
	add		 $v1, $t1, $t2				# $v0 = fib (n - 1) + fib (n - 2)

	lw		 $ra, 28($sp)				# restore Return Address.
	lw		 $fp, 24($sp)				# restore Frame Pointer.
	addu	 $sp, $sp, 32				# restore Stack Pointer.
	jr		 $ra					    # return.

main:
        li      $a0, 20
		jal     fib             

		move    $a0, $v1
	    li      $v0, 1
        syscall                 # print interger

		ori	    $v0, $zero, 10
	    syscall                 # Exit