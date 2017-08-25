# board.s ... Game of Life on a 10x10 grid

   .data

N: .word 10  # gives board dimensions

board:
   .byte 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 1, 1, 0, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 0, 0, 0, 0, 0
   .byte 0, 0, 0, 0, 1, 1, 1, 0, 0, 0
   .byte 0, 0, 0, 1, 0, 0, 1, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
   .byte 0, 0, 1, 0, 0, 0, 0, 0, 0, 0

newBoard: .space 100
# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Emmet Murray, z5059840 August 2017

	.data
main_ret_save: .space 4
hash: .asciiz "h"
dot: .asciiz "."
	.text
	.globl main
main:
	sw $ra, main_ret_save

 #Your main program code goes here

end_main:
	lw $ra, main_ret_save
	jr $ra

# The other functions go here
#
#
#

neighbours: #Takes two int coordinates, returns the amount of neighbours in $a0
	jr $ra

copyBackAndShow: # Copies the new board over to the old, and prints it at the same time
	# Load our board size constant into $t0 for use
	li $t0 N
	# Define our loop counters
	li $t1 0
	li $t2 0
	#Incrementation rate
	li $t7 1
	outerCopy:
		# if our outer counter is done, we exit
		beq $t1 $t0 endOuterCopy
		innerCopy:
			# Jump to end if we are done
			beq $t2 $t0 endInnerCopy
			# Get offset into $t3: offset = $t1*N + $t2
			mul $t3 $t1 $t0
			addu $t3 $t3 $t2
			# Now $t3 has the byte we need. We can access it by doing board[$t3]
			beqz newboard+$t3 caseDot
			#print hash
			la $a0 hash
			li $v0 1
			syscall
			# Increment and jump to the start of the loop
			addu $t2 $t2 $t7
			j innerCopy
			# We print a dot
		caseDot:
			#print dot
			la $a0 dot
			li $v0 1
			syscall
			# Increment and jump to the start of the loop
			addu $t2 $t2 $t7
			j innerCopy
					
		endInnerCopy:
			#increment row counter and continue
			addu $t1 $t1 $t7 
			j outerCopy

			#Jump here when done
endOuterCopy:	
	jr $ra

