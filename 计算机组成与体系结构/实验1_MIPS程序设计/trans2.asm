        .globl main
        .globl sumn

        .data                   
A:      .word   9, 7, 15, 19, 20, 30, 11, 18
msg1:   .asciiz "The result is: " 


        .text 

sumn:
Loop:   beq     $a1, $t0, Exit
        add     $t1, $t0, $t0
        add     $t1, $t1, $t1
        add     $t1, $t1, $a0

        lw      $t2, 0($t1)
        add     $v1, $v1, $t2
        addi    $t0, $t0, 1
        j       Loop
Exit:   jr      $ra

main:
        la      $a0, A          # Register $a0 gets address of A
        li      $a1, 8
 
        jal     sumn            # call sumn

        la      $a0, msg1       
        li      $v0, 4
        syscall                 # print msg

        move    $a0, $v1
	    li      $v0, 1
        syscall                 # print interger

        ori	    $v0, $0, 10
	    syscall                 # Exit