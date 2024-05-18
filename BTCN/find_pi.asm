.include "find_pi.mac"
.data
	FD: .word 0
	total: .word 50000
	counter: .word 0
	pi: .float 0

	buffer: .space 4
	decimal_part: .space 4
	fraction_part: .space 6
	
	filename: .asciiz "BTCN\\Pi.txt"
	cannot_open_file: .asciiz "Error handle: Can not open file"
	label_1: .ascii "So diem nam trong hinh tron:  "		#30 char
	label_2: .ascii "/50000\nSo PI tinh duoc:  "			#26 char
.text
.globl main
main:
	li		$v0, 30			#Set seed
	syscall
	sw		$a0, 0($sp)		#id of pseudorandom num generator
	li		$v0, 40			
	syscall
		
	lw 		$t1, total  			# number of points
	li		$t0, 1			# Set 1 (int)
	mtc1	$t0, $f17
	cvt.s.w	$f17, $f17		# Convert 1 into single prec
loop:
	addiu 	$t1, $t1, -1  		# decrement counter
	li 		$v0, 43  			# syscall for random float
	syscall
    	mov.s 	$f12, $f0  		# x-coordinate
    	syscall
    	mov.s 	$f13, $f0  		# y-coordinate
    	
	mul.s 	$f14, $f12, $f12  	# x^2
	mul.s 	$f15, $f13, $f13 	# y^2
	add.s 	$f16, $f14, $f15 	# x^2 + y^2

    	c.lt.s 	$f17, $f16  		# if x^2 + y^2 > 1
    	bc1t 	out_of_circle
	addiu 	$t0, $t0, 1		
out_of_circle:
	bne	 	$t1, $zero, loop	# if counter is not zero, continue loop
	
done:
	sw		$t0, counter
	lwc1		$f18, counter
	cvt.s.w	$f18, $f18		#convert word into single prec
	lwc1		$f19, total	
	cvt.s.w	$f19, $f19		#as the above guy
	div.s 	$f20, $f18, $f19  	# count / total
	
	li		$t0, 4			# Set 4 (int)
	mtc1	$t0, $f21
	cvt.s.w	$f21, $f21		# Convert 4 into single prec
	mul.s 	$f22, $f20, $f21	#4.0 * (count / total)
	swc1	$f22, pi
	
write_file:
	li		$v0, 13
	la		$a0, filename		#Open file
	li		$a1, 1
	li		$a2, 1
	syscall
	slt		$t0, $v0, $zero	#v0 < zero?1:0
	bne		$t0, $zero, error_openfile_handle
	sw		$v0, FD
	
	#Write label 1
	lw		$a0, FD			
	la		$a1, label_1
	li		$a2, 30
	li		$v0, 15
	syscall
	
	#Write count / 50.000
	lw		$a0, counter			# convert counter into ascii string
	la		$a1, buffer
	jal		int_to_ascii
	
	lw		$a0, FD				# print the number
	la		$a1, buffer
	li		$a2, 5
	li		$v0, 15
	syscall

	#Write label 2
	lw		$a0, FD
	la		$a1, label_2
	li		$a2, 26
	li		$v0, 15
	syscall
	
	#Convert pi into IEEE binary32
	lwc1		$f0, pi
	la		$a1, decimal_part
	la		$a2, fraction_part
	jal		float_to_ascii
	
	#Write pi_decimal value
	lw		$a0, FD			
	la		$a1, decimal_part
	li		$a2, 1
	li		$v0, 15
	syscall
	
	# Print dot
	li		$t0, 46
	sw		$t0, buffer
	lw		$a0, FD			
	la		$a1, buffer
	li		$a2, 1
	li		$v0, 15
	syscall
	
	#Write pi_fraction value
	lw		$a0, FD			
	la		$a1, fraction_part
	li		$a2, 6
	li		$v0, 15
	syscall

close_file:
	lw		$a0, FD
	li		$v0, 16
	syscall
	li		$v0, 10
	syscall
error_openfile_handle:
	print_text(cannot_open_file)
	li	$v0, 10
	syscall
.include "Support function.asm"
