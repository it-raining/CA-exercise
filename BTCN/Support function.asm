.globl int_to_ascii
int_to_ascii:
    # Save the return address
    sw $ra, 0($sp)
    addiu $sp, $sp, -4

    # Reverse the integer
    li $t0, 0
reverse_loop:
    remu $t1, $a0, 10
    divu $a0, $a0, 10
    mul $t0, $t0, 10
    add $t0, $t0, $t1
    bnez $a0, reverse_loop

    # Convert each digit to ASCII and store in buffer
convert_loop:
    remu $t1, $t0, 10
    addiu $t1, $t1, 48
    sb $t1, 0($a1)
    addiu $a1, $a1, 1
    divu $t0, $t0, 10
    bnez $t0, convert_loop

    # Restore the return address and return
    addiu $sp, $sp, 4
    lw $ra, 0($sp)
    jr $ra
