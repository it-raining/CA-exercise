# brief: Convert integer into ascii
# param: a0: value of integer register
#		a1: address of buffer
# retvl: None
int_to_ascii:
    # Save the return address
    sw $ra, 0($sp)
    addiu $sp, $sp, -4

    # Reverse the integer
    li 		$t0, 0
reverse_loop:
    remu 	$t1, $a0, 10
    divu 	$a0, $a0, 10
    mul 	$t0, $t0, 10
    add 	$t0, $t0, $t1
    bnez 	$a0, reverse_loop

    # Convert each digit to ASCII and store in buffer
convert_loop:
    remu 	$t1, $t0, 10
    addiu 	$t1, $t1, 48
    sb 	$t1, 0($a1)
    addiu 	$a1, $a1, 1
    divu 	$t0, $t0, 10
    bnez 	$t0, convert_loop

    # Restore the return address and return
    addiu $sp, $sp, 4
    lw $ra, 0($sp)
    jr $ra
    
# brief: Convert registor contain pi into ascii, support at max 7 digit
# param: f0: value of floating point
#		a1: address of decimal part
#		a2: address of fraction part
# Tempotary Reg: $f11: value of 1 and 10^6
#				$f12, value of 10
# retvl: None
float_to_ascii:
    # Save the return address
    	sw 		$ra, -4($sp)
	sw		$a0, 0($sp)
	addiu 	$sp, $sp, -8
decimal:
	floor.w.s	$f11, $f0
	mfc1	$a0, $f11
	jal		int_to_ascii
fraction:
	cvt.s.w	$f11, $f11
	sub.s	$f0, $f0, $f11 	#Remove decimal part
		
	li		$t0, 1
	mtc1	$t0, $f11
	cvt.s.w	$f11, $f11	# Set f11 = 1
	li		$t0, 10
	mtc1	$t0, $f12
	cvt.s.w	$f12, $f12	# Set f12 = 10
	
	convert_fraction:
	lui		$t0, 0xF
	ori		$t0, 0x4240
	mtc1	$t0, $f11
	cvt.s.w	$f11, $f11	# Set f11 = 10^6
	mul.s	$f0, $f0, $f11
	floor.w.s	$f11, $f0
	mfc1	$a0, $f11
	addu	$a1, $zero, $a2
	jal		int_to_ascii
    # Restore the return address and return
        addiu	$sp, $sp, 8
       	lw		$a0, 0($sp)
    	lw 		$ra, -4($sp)
    	jr 		$ra
