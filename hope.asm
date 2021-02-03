.data
my_array:
 	.align 2
	.space 800
space:
 	.asciiz " "
newline:
	.asciiz "\n"
message:
	.asciiz "please enter the size of the board"
message_tree:
	.asciiz "do you want to enter a tree? if yes press 1 if no press 0"
message_tree_coordinates:
	.asciiz " please enter the coordinates of your tree the row first and then the column"
solution_not:
	.asciiz "the solution is not found throught this method"

.text
la $a0, message        			 # load the message about the size
li $v0, 4
syscall					 # print the message

li $v0, 5                      		 # enter your size
syscall
add $t0, $v0, $zero			 # store the size of the array
li $t9, 1
pow:
	mul $t9, $t9, 2
	addi $t2, $t2, 1
	blt $t2, $t0, pow		 # this function will give use 1111 if our board is size four and eight ones if size 8 for example
minus1:
	li $t2, 0			 # set $t2 to zero because we will use it again
	subi $v1, $t9, 1		 # this $v1 will always be constant that we use in bitwise operators to take only
					 # the amount of bits that suits out size

					 # a function that takes the size of the board and puts the trees where they are supposed to be
jal enter_trees

la $t4, my_array			 # t4 is used for array address has to point to index zero in main
li $t2, 0				 # we have to set the number of columns to 0 when we start this function
jal lizards





li $v0, 10
syscall
 
 
enter_trees:


la $a0, message_tree			 # load the message you whether or not one wants to enter a tree
li $v0, 4
syscall

li $v0,5				 # enter whether you want to enter trees or not				
syscall
beq $v0, 1, enter_array			 # if he wants to enter trees at all go in
beq $v0, $zero, exit_enter_tree 	 # if he doesn't want to add trees at all exit
bne $v0, $zero, enter_trees		 # if it is none of the two values he has to enter one of them

enter_array:
la $t4, my_array			 # the address of the tree is inside $t4


la $a0, message_tree_coordinates	 # ask for the coordinates of the tree you want entered in the array
li $v0, 4				 # print the message
syscall

li $v0, 5 				 # enter row coordinate
syscall
add $t1, $v0, $zero			 # the row coordinate is now in $t1

li $v0, 5 				 # enter column coordinate
syscall
add $t2, $v0, $zero			 # the y column is now in $t1

# now we calulate the place of the tree inside the 2-D array
mul $t8, $t1, $t0 			 # multiply size by row to get at the beginnig of row you want
add $t8, $t8, $t2			 # add the number of columns to get at the element you want in that row
mul $t8, $t8, 4				 # multiply by 4 since every int is stored in 4 bytes 

add $t8, $t4, $t8			 # add the number of bytes to the reference address to get the address value to store in in $t8

li $v0, 2

sw $v0, ($t8)                            # store the integer in memory

again_choose_tree:

li $v0, 4 # print a message asking if there is more
la $a0, message_tree 
syscall

li $v0,5
syscall

beq $v0, 1, enter_array			 # if he wants to enter another tree
beq $v0, $zero, exit_enter_tree 	 # if he doesn't want to add anymore trees
bne $v0, $zero, again_choose_tree	 # if it is none of the two values he has to enter one of them


exit_enter_tree:
jr $ra


print_board:
add $t1, $t0, $zero			 # get the number of rows in $t1
add $t2, $t0, $zero			 # get the number of columns in $t2
li $t3, 0			  	 # get a counter for the row loop
la $t4, my_array			 # get the address of the 2-D array

loop_row:

li $t5, 0				 # get a counter for the col loop

loop_col:
lw $a0, ($t4)				 # get the value of the element in this coordinates
li $v0, 1				 # print this value as integer
syscall

la $a0, space				 # leave some space between the elements of the same row
li $v0, 4				 # print the space
syscall 

addi $t4, $t4, 4			 # add the address to get the next element
addi $t5, $t5, 1			 # increment the counter to act as a stopping criteria for the loop

blt  $t5, $t2, loop_col			 # if the number of all columns in row isn't covered yet

la $a0, newline
li $v0, 4				 # print a newline after every row
syscall
addi $t3, $t3, 1			 # increment the counter for the row loop
blt $t3, $t1, loop_row			 # if number of all rows are finished get out of the row loop too

jr $ra 

lizards:				 # t0 is used to get size of the array
					 # t1 is used for row
					 # t2 is used for col
					 # t5 is used for ld
					 # t6 is used for rd
					 # t7 is used for col
					 # t8 is used for getting suitable amount of bits
addi $sp, $sp, -4			 # get more stack room
sw  $ra, ($sp) 				 # store $ra for the first main function or in other words  for lizard functions
beq $v0, $t0, enditall			 # if the number of lizards equal the size of the board then you killed it 
beq $t2, $t0, no_solution
li $v0, 0				 # set the number of lizards to zero at each trial
li $t1, 0				 # each trial we will start at row 0
li $a0, 0				 # for each trial we should set the flag that row has 1 to zero
li $t5, 0				 # for each trial the ld is initialized
li $t6, 0  				 # for each trial the rd is initialized
li $t7, 0				 # for each trial the col is initialized
						
addi $sp, $sp, -4
sw $ra, ($sp)
jal clean_board				 # if the trial failed we need to delete all the foken lizards to start the next trial fresh
addi $sp, $sp, 4
lw $ra, ($sp)
		 

addi $sp, $sp, -4			 # get more stack room
sw  $t4, ($sp) 				 # store the address of array entered	
addi $sp, $sp, -4			 # get more stack room	
sw  $t2, ($sp) 				 # store the number of column		
jal for_this_cell
addi $sp, $sp, 4			 # get more stack room	
lw  $t2, ($sp) 				 # restore the number of column
addi $sp, $sp, 4			 # get more stack room
lw  $t4, ($sp) 				 # restore the address of array entered
addi $sp, $sp, 4
lw $ra,($sp)

add $t2, $t2, 1				 # in case one of the cells in the first row fails we need to start the second time with column next
add $t4, $t4, 4				 # if one of the cells in the first row didn't succeed we start all over by the next one

				
jal lizards
addi $sp, $sp, 4
lw $ra,($sp)
jr $ra

enditall:

jr $ra

no_solution:
li $v0, 4
la $a0, solution_not
syscall
jr $ra

for_this_cell:
addi $sp, $sp, -4
sw $ra,($sp)

lw $t9, ($t4)				 # we get the value stored in the board to know if it is a tree or not

beq $t9, 2, recurse_tree		 # checking if it is a tree we will recurse on different conditions	 

					 # now we will recurse assumung it is not a tree
					 
	 

check_cell_is_safe:

beq $a0, 1, not_safe           		 # if the row has a lizard that is not masked


or $a3, $t5, $t6			 # the values of rd and ld for this row are considered
or $a3, $a3, $t7			 # also the lizards in columns are considered



sub $a1, $t0, 1			         # get the maximum allowed column index in $a1
sub $a1, $a1, $t2			 # subtract the max value from the actual value of the column, to get in reverse
li $a2, 1
sllv $a2, $a2, $a1			 # we are going to shift logical by $a1 and the value of $a2 will be the bin of current column
and $a3, $a3, $a2			 # the current col in bin will be used in two ways to decide whether or not a 1 will be 
					 # placed and if that one is placed it will update its effect to the col, ld, rd

beq $a3, $a2, not_safe			 # note after anding the col we want in bin with all the conditions, if they are still
					 # equal this means the column was marked originally be a3 to not be safe	
																		
li $a0, 1				 # this will  also be used as an indication that there is a  lizard in the column
sw $a0, ($t4)				 # put 1 in that empty_safe cell and proceed 
add $v0, $v0, 1				 # this will act as a counter for the number of lizards we have 
					 # placed so far, when we return to lizards function it will compare them to size if they
					 # are less than the size of the board we get in this function again
												
					 # update the data_structure

or $t7, $a2, $t7			 # we are going to or the current column and all the previous column to get a binary for all 
			 		 # columns that contain lizards 1000 says column one has a lizard
or $t5, $a2, $t5			 # we are going to store the left diagonal effect of this one on next rows
or $t6, $a2, $t6 			 # we are going to store the right diagonal effect of this one on next rows

not_safe:				 # if cell is not safe we will start from here to recurse on next cell and escape the last
					 # part dealing with the a lizard being placed and its effect on data_structures
					 
sub $t0, $t0, 1
beq $t1, $t0, check_return		 # check each cell of the last row if it is the end of 2D array
not_yet:
add $t0, $t0, 1	

sub $a1, $t0, 1				 # get the maximum allowed column index in $a1
beq $t2, $a1, recurse_next_row 		 # we need this to be in sparate label because we we go to next row we need to update data_structure

addi $t4,$t4, 4				 # we will recurse on the next cell in the row
addi $t2, $t2, 1			 # add the column number as well 

addi $sp, $sp, -4			 # get more stack room
sw  $t4, ($sp) 				 # store the address of array entered				
jal for_this_cell
addi $sp, $sp, 4			 # get more stack room
lw  $t4, ($sp) 				 # restore the address of array entered
addi $sp, $sp, 4
lw $ra,($sp)

jr $ra

recurse_next_row:
srl $t5, $t5, 1				 # to update the effect of a diagonal on the next row, you must shift it to right by one
and $t5, $t5, $v1			 # this will ensure the data has info only for places inculded in the board
sll $t6, $t6, 1				 # to update the effect of a right diagonal on the next row, shift it to left by one
and $t6, $t6, $v1			 # this will ensure the data has info only for places inculded in the board
addi $t1, $t1, 1			 # we increment the index of rows for the 2-D array
li $t2, 0				 # the first index of column for every row is zero
li $a0, 0				 # when we first enter a row there are no lizards in that row
add $a0, $s5, $zero			 # unless there was a jump from a tree that put a one in there
xor $s5, $s5, $s5                        # set the value of the marker to zero after usage once
addi $t4, $t4, 4			 # increase to get the next index in the row


addi $sp, $sp, -4			 # get more stack room
sw  $t4, ($sp) 				 # store the address of array entered	
addi $sp, $sp, -4
sw $t5, ($sp)
addi $sp, $sp, -4
sw $t6, ($sp)	
addi $sp, $sp, -4
sw $t7, ($sp)
addi $sp, $sp, -4
sw $t2, ($sp)
addi $sp, $sp, -4
sw $t1, ($sp)			
jal for_this_cell
addi $sp, $sp, 4
lw $t1, ($sp)	
addi $sp, $sp, 4
lw $t2, ($sp)
addi $sp, $sp, 4
lw $t7, ($sp)
addi $sp, $sp, 4
lw $t6, ($sp)	
addi $sp, $sp, 4
lw $t5, ($sp)
addi $sp, $sp, 4			 # get more stack room
lw  $t4, ($sp) 				 # restore the address of array entered
addi $sp, $sp, 4
lw $ra,($sp)

addi $sp, $sp, -4
sw $t4, ($sp)
addi $sp, $sp, -4
sw $ra, ($sp)
jal delete_rows_under
addi $sp, $sp, 4
lw $ra, ($sp)
addi $sp, $sp, 4
lw $t4, ($sp)

addi $t4, $t4,4
addi $t2, $t2, 1

addi $sp, $sp, 4
sw $t4, ($sp)
jal for_this_cell			 # recurse to find all other possible combinations
jr $ra

recurse_tree:
					 # before we do any checking we need to apply the masking of the tree
sub $a1, $t0, 1			         # get the maximum allowed column index in $a1
sub $a1, $a1, $t2			 # subtract the max value from the actual value of the column, to get in reverse
li $a2, 1
sllv $a2, $a2, $a1			 # we are going to shift logical by $a1 and the value of $a2 will be the bin of current column
					 # this column is the column containing the tree hence is where we do the masking
not $a2, $a2
and $a2, $a2, $v1
and $t5, $t5, $a2			 # mask the effect of the left diagonal by the tree
and $t6, $t6, $a2			 # mask the effect of the right diagnoal by the tree
and $t7, $t7, $a2			 # mask the effect of the column by the tree

					 # we first check below the tree if we can place a lizard we do and continue horizontal 
					 # movement from there

mul $t0, $t0, 4	         		 # get the number of bytes required to get to the next row
add $t4, $t4, $t0			 # add to the current index the size of the 2-D array in bytes which will get it to the next element in column	
div $t0, $t0, 4  			 # get the size back without the bytes 
lw $t9, ($t4)				 # get the value in that index in case we have another foken tree	 
add $t1, $t1, 1				 # since we will be checking below we increment the row because we will work from that row from now on

					 # note the column will be the same so we don't need to change that
					 # updating data_structures to see if the element below tree is safe to place the lizard
					 # taking into consideration the masking of the tree

add $t3, $t5, $zero			 # since we can sometimes move two rows at once and then get back if the element below
                 			 # the tree is unsafe we have to restore the truncated $t5 diagonal restrictions
					 # note this will never happen to $t6 since we don't do two jumps up
li $a0, 0				 # since this is a new row there are no lizards placed yet	
add $a0, $s5, $zero			 # unless there is a 1 put by another tree earlier
xor $s5, $s5, $s5			 # disable marker				 
srl $t5, $t5, 1				 # to update the effect of a diagonal on the next row, you must shift it to right by one
and $t5, $t5, $v1			 # this will ensure the data has info only for places inculded in the board
sll $t6, $t6, 1				 # to update the effect of a right diagonal on the next row, shift it to left by one
and $t6, $t6, $v1			 # this will ensure the data has info only for places inculded in the board

beq $t9, 2, check_next_cell		 # if the cell_below tree is another tree, check the cell next to the upper tree
					  

or $a3, $t5, $t6			 # only the values of the diagonals may affect since the tree already masked col
or $a3, $a3, $t7			 # we also need to update col num
and $a2, $a3, $a2
bne $a3, $a2, check_next_cell		 # if both $a3 and $a2 are not equal this means that column under tree is not safe because of diagonal so check cell next to tree
					 # # in case all conditions are met we do indeed put 1 under the tree
beq $a0, 1, check_next_cell

li $a0, 1				 # this will  also be used as an indication that there is a  lizard in the column
sw $a0, ($t4)				 # put 1 in that empty_safe cell and proceed 
add $v0, $v0, 1				 # this will act as a counter for the number of lizards we have 
add $s5, $s5, 1          		 # since we jump under the tree put one and return one row the effect of the one
					 # under the tree has to be preseved since a0 need to be set to zero to highlight
					 # the mask of the tree for the previous row
					 # placed so far, when we return to lizards function it will compare them to size if they
					 # are less than the size of the board we get in this function again
												
sub $a1, $t0, 1			         # get the maximum allowed column index in $a1
sub $a1, $a1, $t2			 # subtract the max value from the actual value of the column, to get in reverse
li $a2, 1
sllv $a2, $a2, $a1			 # we are going to shift logical by $a1 and the value of $a2 will be the bin of current column
                			 # update the data_structure

or $t7, $a2, $t7			 # we are going to or the current column and all the previous column to get a binary for all 
			 		 # columns that contain lizards 1000 says column one has a lizard
or $t5, $a2, $t5			 # we are going to store the left diagonal effect of this one on next rows
or $t6, $a2, $t6 			 # we are going to store the right diagonal effect of this one on next rows

					 # we start of by getting back to the upper row and shifting all the values of ld and rd
					 # of course we will keep the masking since the tree is not going anywhere 
mul $t0, $t0, 4			         # get the number of bytes required to get to the next row
sub $t4, $t4, $t0
div $t0, $t0, 4  			 # get the size back withouth bytes
sub $t1, $t1, 1
sll $t5, $t5, 1				 # since we got back one row we restore the ld of that row
or $t5, $t5, $t3			 # restore truncated errors due to double jump and get back
srl $t6, $t6, 1				 # since we got back one row we restore the rd of that row

sub $a1, $t0, 1				 # get the maximum allowed column index in $a1
beq $t2, $a1, recurse_next_row 		 # we need this to be in sparate label because we we go to next row we need to update data_structure

li $a0, 0				 # since we will always jump back  the tree will shield any lizard in the column
addi $t4, $t4, 4			 # increase to get the next index of next column to the tree
addi $t2, $t2, 1			 # increase the column since we are going to store next to the tree
					 
addi $sp, $sp, -4			 # get more stack room
sw  $t4, ($sp) 				 # store the address of array entered				
jal for_this_cell
addi $sp, $sp, 4			 # get more stack room
lw  $t4, ($sp) 				 # restore the address of array entered
addi $sp, $sp, 4
lw $ra,($sp)

jr $ra


check_next_cell:
					 # we start of by getting back to the upper row and shifting all the values of ld and rd
					 # of course we will keep the masking since the tree is not going anywhere 
mul $t0, $t0, 4			         # get the number of bytes required to get to the next row
sub $t4, $t4, $t0
div $t0, $t0, 4  			 # get the size back withouth bytes
sub $t1, $t1, 1
sll $t5, $t5, 1				 # since we got back one row we restore the ld of that row
or $t5, $t5, $t3			 # restore truncated errors due to double jump and get back
srl $t6, $t6, 1				 # since we got bacl one row we restore the rd of that row
li $a0, 0				 # since this is the row that contains the tree it masks any affect if any of a previous
					 # lizard in the row
sub $a1, $t0, 1				 # get the maximum allowed column index in $a1
beq $t2, $a1, recurse_next_row 		 # we need this to be in sparate label because we we go to next row we need to update data_structure

addi $t4, $t4, 4			 # increase to get the next index of next column to the tree
addi $t2, $t2, 1
addi $sp, $sp, -4			 # get more stack room
sw  $t4, ($sp) 				 # store the address of array entered				
jal for_this_cell
addi $sp, $sp, 4			 # get more stack room
lw  $t4, ($sp) 				 # restore the address of array entered
addi $sp, $sp, 4
lw $ra,($sp)
jr $ra

clean_board:
la $s0, my_array			 
li $s1,0 				  # counter
clean_loop:
lw $s2, ($s0)
beq $s2, 1, clear_to_zero
continue_cleaning:
addi $s1, $s1, 1			  # increment counter 
add $t3, $t0,$zero
mul $t0, $t0, $t0			  # get the number of elements in the 2D array
beq $s1, $t0, cleaned
div $t0, $t0, $t3
add $s0, $s0, 4
j clean_loop

clear_to_zero:
li $s2, 0
sw $s2, ($s0)
j continue_cleaning

cleaned:
div $t0, $t0, $t3
jr $ra

check_return:
beq $t2, $t0, return
j not_yet

return:
add $t0,$t0, 1
jr $ra

delete_rows_under:
la $s0, my_array			# get the address of first array
mul $t0, $t0, $t0			# get number of elements in 2D array
mul $t0, $t0, 4				# get number of bytes required to finish
add $s0, $s0, $t0			# last address in array
div $t0, $t0, 4
div $t0, $t0, $t0			#restore size
li $s1, 0
continue_rows_cleaning:
lw $s2, ($t4)
beq $s2, 1, make_row_zero
add $t4, $t4, 4
add $s1, $s1, 1
beq $t4, $s0,cleaned_rows
j continue_rows_cleaning
make_row_zero:
li $s2, 0
sw $s2, ($t4)
j continue_rows_cleaning

cleaned_rows:
jr $ra

addi $sp, $sp, -4
sw $a0 ($sp)
addi $sp, $sp, -4
sw $a1, ($sp)

addi $sp, $sp, 4
lw $a1, ($sp)
addi $sp, $sp, 4			 # get more stack room	
lw  $t2, ($sp) 				 # restore the number of column