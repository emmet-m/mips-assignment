# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Emmet Murray, z5059840 August 2017

   .data
main_ret_save: .space 4

   .text
   .globl main
main:
   sw   $ra, main_ret_save

 #Your main program code goes here

end_main:
   lw   $ra, main_ret_save
   jr   $ra


# The other functions go here

