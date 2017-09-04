# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Emmet Murray, z5059840 August 2017

	.data
	.align 4
main_ret_save: .space 4
hash: .asciiz "#"
dot: .asciiz "."
newline: .asciiz "\n"
	.text
	.globl main
main:
	sw $ra, main_ret_save

	jal copyBackAndShow
 #Your main program code goes here

end_main:
	lw $ra, main_ret_save
	jr $ra

# The other functions go here

#Takes two int coordinates, returns the amount of neighbours in $a0
neighbours: 
	li $t0, 0
	outerNeighbours:
		innerNeighbours:
		innerNeighboursEnd:
	outerNeighboursEnd:

	jr $ra

# Copies the new board over to the old, and prints it at the same time
copyBackAndShow: 
	# Load our board size constant into $t0, for use
	lw $t0, N
	# Define our loop counters
	li $t1, 0
	li $t2, 0
	#Incrementation rate
	outerCopy:
		# if our outer counter is done (= N), we exit
		beq $t1, $t0, endOuterCopy
		# We need to reset out inner counter before continuing
		li $t2, 0

		innerCopy:
			# Jump to end if we are done
			beq $t2, $t0, endInnerCopy
			# Get offset into $t3,: offset = $t1*N + $t2
			mul $t3, $t1, $t0
			addu $t3, $t3, $t2
			# The following is commented out. Comment it again when most of MAIN is done:
			# Copy newboard to board TODO
			#lb board($t3), newboard($t3)
		
			lb $t4, board($t3)
			# if the byte in slot $t3 is a 0, jump to a dot print
			beqz $t4, caseDot
				#print hash
				la $a0, hash
				li $v0, 4
				syscall
				# Increment and jump to the start of the loop
				addi $t2, $t2, 1
				j innerCopy
				# We print a dot
			caseDot:
				#print dot
				la $a0, dot
				li $v0, 4 
				syscall
				# Increment and jump to the start of the loop
				addu $t2, $t2, 1
				j innerCopy
			
		endInnerCopy:
			#print newline
			li $v0, 4
			la $a0, newline
			syscall
			#increment row counter and continue
			addu $t1, $t1, 1
			j outerCopy
	
		#Jump here when done
	endOuterCopy:	
		jr $ra
