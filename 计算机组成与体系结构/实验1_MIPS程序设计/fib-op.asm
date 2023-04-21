
.globl main

.text


fib:
        bgt     $a0, 1, fib_recurse
		li      $v1, 1
		jr      $ra

fib_recurse:
        li		$t0, 1
		li		$t1, 1
		li      $t3, 1
Loop:   beq     $a0, $t3, Exit
        add     $v1, $t0, $t1
		move    $t1, $t0
		move    $t0, $v1
		addi    $t3, $t3, 1
        j       Loop
Exit:   jr      $ra
	

main:
        li      $a0, 20
		jal     fib             

		move    $a0, $v1
	    li      $v0, 1
        syscall                 # print interger

		li	    $v0, 10
	    syscall                 # Exit