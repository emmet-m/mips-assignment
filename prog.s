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
num_user_iterations: .space 4
Nsquare: .space 4
hash: .asciiz "#"
dot: .asciiz "."
iternum: .asciiz "# Iterations: "
afterIter1: .asciiz "=== After iteration "
afterIter2: .asciiz " ===\n"
newline: .asciiz "\n"
	.text
	.globl main
main:
	sw $ra, main_ret_save # DO NOT COMMENT THIS OUT

	# Get the number of iterations
	li $v0, 4
	la $a0 iternum
	syscall
	# Read the user input into $v0
	li $v0 5
	syscall

	sw $v0 num_user_iterations # Save the user iterations into a constant

	# Calculate N^2 - 1
	lw $t0 N
	mul $t0, $t0, $t0
	addi $t0, $t0, -1
	sw $t0 Nsquare # save it back

	# Set our iterations counter to 1
	li $s0 1
	
	# Now we begin our cycling loop
	iterations_loop:
		lw $t0 num_user_iterations # Load temporarily the number of iterations into $t0
		bgt $s0, $t0, end_iterations_loop # Jump to the loop end if num_iters > specified_iters

		# Loop: loop from (0) to (N^2 -1), 
		# $s1 is our counter
		li $s1 0
		logic_loop:
			lw $t0 Nsquare # get our exit status
			bgt $s1 $t0 logic_end #Exit if counter > N^2 - 1

			# Get neighbours
			move $a0 $s1 #a0 has current index
			jal neighbours
			nop
			# Now $v0 has the amount of neighbours, copy to $s3
			move $s3 $v0
			# If current cell is alive, jump to alive logic:
			lb $s2 board($s1)
			bgtz $s2 if_cell_alive # If cell is > 0 (i.e. 1), jump to alive secion
				#Else, cell is dead
				li $t0 3
				# If Neighbours is 3, keep cell alive
				bne $s3 $t0 cell_stays_dead
					# Cell becomes alive as neighbours = 3
					li $t0 1
					sb $t0 newBoard($s1)
					j end_incr_j #end loop iteration
				cell_stays_dead: #Else, cell stays dead
					sb $zero newBoard($s1) # Write 0 to newBoard
					j end_incr_j # end loop iteration
			if_cell_alive:
				# Check 3 possibilities
				li $t0 2
				li $t1 3
				blt $s3 $t0 cell_dies # If number of neighbours is less than 2
				bgt $s3 $t1 cell_dies # If number of neighbours is greater than 3 
					# At this stage, the cell lives, as neighbours is 2 or 3
					li $t0 1
					sb $t0 newBoard($s1)
					j end_incr_j #end loop iteration
					
				cell_dies:
					sb $zero newBoard($s1) # Write 0 to newBoard
					j end_incr_j # end loop iteration
				
				
		end_incr_j: #end inner loop, increment and jump
			addi $s1 1
			j logic_loop

		logic_end:
		# Print iteration number
		li $v0 4
		la $a0 afterIter1
		syscall # prints "=== After iteration "
		li $v0 1
		move $a0 $s0
		syscall # print the iteration number
		li $v0 4
		la $a0 afterIter2
		syscall # prints " ===\n"
		
		# Print the board and copy into new board
		jal copyBackAndShow 
		nop
		# Increment and save back
		addi $s0 1
		# Next iteration
		j iterations_loop
		
	end_iterations_loop:

 #Your main program code goes here

end_main:
	lw $ra, main_ret_save
	jr $ra

# The other functions go here

#Takes two int coordinates, returns the amount of neighbours in $v0
neighbours: 
	# index is in $a0
	# Save our result in $v0, load our constant N
	li $v0, 0
	lw $t9, N

	# We need our cartesian coordinates: $t0 = $t5*N + $t6
	# $t5 = integerDivision $t0/N
	div $t5, $a0, $t9
	# $t6 = mod  $t0 % N
	rem $t6, $a0, $t9

	# Get our two loop counters
	li $t1, -1
	li $t2, -1
	# Load our branching constant into $t8
	li $t8, 1
	outerNeighbours:
		# If counter greater than 1, jump to the end
		bgt $t1, $t8, outerNeighboursEnd
		# Reset our counter
		li $t2, -1
		innerNeighbours:
			# If counter greater than 1, jump to the end
			bgt $t2, $t8, innerNeighboursEnd

 			# See if we've gone too far above the board or below the board
			add  $t7, $t1, $t5
			bltz $t7, caseFail # If less than 0, above board
			bge  $t7, $t9 caseFail # If greater than N-1, below board

			# See if we've gone too far left and right
			add  $t3, $t2, $t6 
			bltz $t3, caseFail # If less than 0, above board
			bge  $t3, $t9 caseFail # If greater than N-1, below board

			# Passed edge tests... Now onto calculating offset	
			# Recalculate offset into $t7
			mul $t7, $t7, $t9 # +(-N || 0 || N)
			add $t7, $t7, $t3
			beq  $t7, $a0 caseFail # If index is current index (we don't count ourself)
			
			# Now add the board index $t3 into $t4
			lb  $t4, board($t7) # 1 or 0
			add $v0, $v0, $t4
		caseFail: # If a test for safety fails, jumps here
			#incement and jump 
			addi $t2, $t2, 1
			j innerNeighbours
		# Increment outer counter and jump to start of loop
		innerNeighboursEnd:
			addi $t1, $t1, 1
			j outerNeighbours
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
			# Copy newBoard to board
			lb $t5, newBoard($t3)
			sb $t5, board($t3)
		
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
