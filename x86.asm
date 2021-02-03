section .data
space db " "
newline db "\n"
message db "please enter the size of the board"
message_tree db "do you want to enter a tree? if yes press 1 if no press 0"
message_tree_coordinates db " please enter the coordinates of your tree the row first and then the column"
no_solution db "No solution has been found"
break_point db "BREAK POINT", 10, 13
;----------------------------------------------------------
section .bss
my_array resb 800
print_integer_space resb 2
;-------------------------------------------------------------
section .text
global  _start
%macro print_string 2
	push r11
    push rax
    push rdi
    push rsi
    push rdx
    ;(%1) address string
    ;(%2) length of the string
    mov rax, 1
    mov rdi, 1
    mov rsi, %1
    mov rdx, %2
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
	pop r11
%endmacro

%macro print_integer 1
    push rax
    push rdi
    push rsi
    push rdx
    ;(%1) --- number in register)  ;give it in its 8-bit format in character format
    mov rax, 1
    mov rdi, 1
    add rsi, 48
    mov byte[print_integer_space], %1
    mov rsi, print_integer_space
    mov rdx, 1
    syscall
    pop rdx
    pop rsi
    pop rdi
    pop rax
%endmacro

%macro input_integer 1  
    ;save all the registers included here before using this macro
    ;(1) register to store in the number (it takes one byte) (numbers represented in only one bit)
    ;please pass the register as 8-bit format and don't enter one of the register used in the macro
	push r11
	push rdx
    push rsi
    push rdi
    push rax
    mov rax, 0
    mov rdi, 0
    mov rsi, print_integer_space
    mov rdx, 2 ;to account for the (/n) included in the input
    syscall
    mov %1, byte[print_integer_space]
    sub %1, 48
    pop rdx
    pop rsi
    pop rdi
    pop rax
	pop r11
%endmacro

%macro exit 0  
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro
_start:
print_string message, 34			  ; print the message

xor r8, r8
xor rdi, rdi
input_integer r8b
;(r8) stores the size of the array
;(rax) r15
;add r8, r14, 0			  ; store the size of the array
mov rax, 1 ;rax instead of $t9
;(r8) ize of the array
;(r9) r9
;(r10) r10
pow:
    mov r14, 2
    mul r14 ;multply the rax $t9 by 2
	add r10, 1
    cmp r10, r8
    jl pow		  ; this function will give use 1111 if our board is size four and eight ones if size 8 for example
minus1:
	mov r10, 0			  ; set r10 to zero because we will use it again
	mov rsi, rax
    sub rsi, 1		  ; this rsi will always be constant that we use in bitwise operators to take only
					  ; the amount of bits that suits out size
					  ; a function that takes the size of the board and puts the trees where they are supposed to be

call enter_trees

mov r11, my_array			  ; t4 is used for array address has to point to index zero in main
mov r10, 0				  ; we have to set the number of columns to 0 when we start this function
call lizards
print_string break_point, 13

 ; at the start of this function we have the size at r8 then the function will print the board GIVEN the board is square of course
call print_board
exit
 
 
enter_trees:

print_string message_tree, 57

input_integer r12b
cmp r12b, 1
je enter_array			  ; if he wants to enter trees at all go in
cmp r12b, 0
je exit_enter_tree 	  ; if he doesn't want to add trees at all exit
cmp r12b, 0
jne enter_trees		  ; if it is none of the two values he has to enter one of them

enter_array:
mov r11, my_array			  ; the address of the tree is inside r11

print_string message_tree_coordinates, 76	  ; ask for the coordinates of the tree you want entered in the array


xor r12, r12
input_integer r12b

mov r9, r12	
             	  ; the row coordinate is now in r9
xor r12, r12
input_integer r12b

mov r10, r12			  ; the y column is now in r9

push rdi
push rdx
; now we calulate the place of the tree inside the 2-D array
; multiply size by row to get at the beginnig of row you wan

push rdx
mov rax, r9
mul r8
mov rdi, rax
pop rdx
add rdi, r10
mov rax, rdi
push rbx
mov rbx, 8
mul rbx
pop rbx
add rax, r11
mov rdi, rax
			  ; add the number of columns to get at the element you want in that row			  ; multiply by 4 since every int is stored in 4 bytes 
		  ; add the number of bytes to the reference address to get the address value to store in in rdi
mov r12, 2
mov [rdi], r12

                             ; store the integer in memory
pop rdx
pop rdi

again_choose_tree:

; print a message asking if there is more
print_string message_tree, 57 


input_integer r12b

cmp r12b, 1
je enter_array			  ; if he wants to enter another tree
cmp r12b, 0
je exit_enter_tree 	  ; if he doesn't want to add anymore trees
cmp r12b, 0
jne again_choose_tree	  ; if it is none of the two values he has to enter one of them


exit_enter_tree:
ret


print_board:
mov r9, r8			  ; get the number of rows in r9
mov r10, r8			  ; get the number of columns in r10
mov r12, 0			  	  ; get a counter for the row loop
mov r11, my_array			  ; get the address of the 2-D array

loop_row:
mov r13, 0				  ; get a counter for the col loop

loop_col:
mov r15, [r11]
				  ; get the value of the element in this coordinates
print_integer r15b ;specifiy it as 8-bit register

print_string space, 1				  ; leave some space between the elements of the same row

add r11, 8			  ; add the address to get the next element
add r13, 1			  ; increment the counter to act as a stopping criteria for the loop

cmp r13, r10
jl loop_col			  ; if the number of all columns in row isn't covered yet

print_string newline, 1

add r12, 1			  ; increment the counter for the row loop
cmp r12, r9
jl loop_row			  ; if number of all rows are finished get out of the row loop too

ret 

lizards:				  ; t0 is used to get size of the array
					  ; t1 is used for row
					  ; t2 is used for col
					  ; t5 is used for ld
					  ; t6 is used for rd
					  ; t7 is used for col
					  ; t8 is used for getting suitable amount of bits
			  ; get more stack room
cmp r14, r8
je enditall			  ; if the number of lizards equal the size of the board then you killed it 
mov r14, 0				  ; set the number of lizards to zero at each trial
mov r9, 0				  ; each trial we will start at row 0
mov r15, 0				  ; for each trial we should set the flag that row has 1 to zero
mov r13, 0				  ; for each trial the ld is initialized
mov rdi, 0  				  ; for each trial the rd is initialized
mov rdx, 0				  ; for each trial the col is initialized

call clean_board				  ; if the trial failed we need to delete all the foken lizards to start the next trial fresh
push  r11				  ; store the address of array entered	
push r10				  ; store the number of column		
call for_this_cell
pop  r10				  ; restore the number of column
pop  r11				  ; restore the address of array entered

add r10, 1				  ; in case one of the cells in the first row fails we need to start the second time with column next
add r11, 4				  ; if one of the cells in the first row didn't succeed we start all over by the next one
				
call lizards
ret

enditall:
ret

for_this_cell:

mov r15, [r11]				  ; we get the value stored in the board to know if it is a tree or not

cmp r15, 2
je recurse_tree		  ; checking if it is a tree we will recurse on different conditions	 

					  ; now we will recurse assumung it is not a tree
					 
	 

check_cell_is_safe:

cmp r15, 1
je not_safe           		  ; if the row has a lizard that is not masked

push rax
push rbx
push rcx

mov rax, r13
or rax, rdi
			  ; the values of rd and ld for this row are considered
or rax, rdx			  ; also the lizards in columns are considered


mov rcx, r8
sub rcx, 1			          ; get the maximum allowed column index in $a1
sub rcx, r10			  ; subtract the max value from the actual value of the column, to get in reverse
mov rbx, 1

shld rbx, rbx, cl			  ; we are going to shift logical by $a1 and the value of rbx will be the bin of current column
and rax, rbx			  ; the current col in bin will be used in two ways to decide whether or not a 1 will be 
					  ; placed and if that one is placed it will update its effect to the col, ld, rd
cmp rax, rbx


je not_safe			  ; note after anding the col we want in bin with all the conditions, if they are still
					  ; equal this means the column was marked originally be a3 to not be safe	
																		
mov r15, 1				  ; this will  also be used as an indication that there is a  lizard in the column
mov [r11], r15 				  ; put 1 in that empty_safe cell and proceed 
add r14, 1				  ; this will act as a counter for the number of lizards we have 
					  ; placed so far, when we return to lizards function it will compare them to size if they
					  ; are less than the size of the board we get in this function again
												
					  ; update the data_structure

or rdx, rbx			  ; we are going to or the current column and all the previous column to get a binary for all 
			 		  ; columns that contain lizards 1000 says column one has a lizard

or r13, rbx			  ; we are going to store the left diagonal effect of this one on next rows
or rdi, rbx			  ; we are going to store the right diagonal effect of this one on next rows

not_safe:				  ; if cell is not safe we will start from here to recurse on next cell and escape the last
					  ; part dealing with the a lizard being placed and its effect on data_structures
	 
sub r8, 1
cmp r9, r8
je check_return		  ; check each cell of the last row if it is the end of 2D array
not_yet:

add r8, 1	

mov rcx, r8
sub rcx, 1				  ; get the maximum allowed column index in $a1
cmp r10, rcx
pop rcx
pop rbx	
pop rax
push rcx
je recurse_next_row 		  ; we need this to be in sparate label because we we go to next row we need to update data_structure
pop rcx
add r11,8				  ; we will recurse on the next cell in the row
add r10, 1			  ; add the column number as well 

push  r11			  ; store the address of array entered				
call for_this_cell
pop  r11			  ; restore the address of array entered
ret

recurse_next_row:
shrd r13, r13, 1				  ; to update the effect of a diagonal on the next row, you must shift it to right by one
and r13, rsi			  ; this will ensure the data has info only for places inculded in the board
shld rdi, rdi, 1				  ; to update the effect of a right diagonal on the next row, shift it to left by one
and rdi, rsi			  ; this will ensure the data has info only for places inculded in the board
add r9, 1			  ; we increment the index of rows for the 2-D array
mov r10, 0				  ; the first index of column for every row is zero
mov r15, 0				  ; when we first enter a row there are no lizards in that row
mov r15, rcx		  ; unless there was a jmpump from a tree that put a one in there
xor rcx, rcx                        ; set the value of the marker to zero after usage once
add r11, 8			  ; increase to get the next index in the row
push  r11 				  ; store the address of array entered				
call for_this_cell
pop  r11 				  ; restore the address of array entered
ret

recurse_tree:
					  ; before we do any checking we need to apply the masking of the tree
push rax
push rbx

mov rax, r8
sub rax, 1			          ; get the maximum allowed column index in $a1
sub rax, r10			  ; subtract the max value from the actual value of the column, to get in reverse
mov rbx, 1
push rcx
mov cl, al
shld rbx, rbx, cl			  ; we are going to shift logical by rax and the value of $a2 will be the bin of current column
pop rcx
					  ; this column is the column containing the tree hence is where we do the masking
not rbx

and rbx, rsi
and r13, rbx			  ; mask the effect of the left diagonal by the tree
and rdi, rbx			  ; mask the effect of the right diagnoal by the tree
and rdx, rbx			  ; mask the effect of the column by the tree

					  ; we first check below the tree if we can place a lizard we do and continue horizontal 
					  ; movement from there


push rax
push rdx
push r12
mov rax, r8
mov r12, 8
mul r12
mov r8, rax
push r12
push rdx
push rax
         		  ; get the number of bytes required to get to the next row
add r11, r8			  ; add to the current index the size of the 2-D array in bytes which will get it to the next element in column	
push rax
push rdx
push r12
mov rax, r8
mov r12, 8
div r12
mov r8, rax
push r12
push rdx
push rax

 			  ; get the size back without the bytes 
mov r15, [r11]				  ; get the value in that index in case we have another foken tree	 
add r9, 1				  ; since we will be checking below we increment the row because we will work from that row from now on

					  ; note the column will be the same so we don't need to change that
					  ; updating data_structures to see if the element below tree is safe to place the lizard
					  ; taking into consideration the masking of the tree

mov r12, r13		  ; since we can sometimes move two rows at once and then get back if the element below
                 			  ; the tree is unsafe we have to restore the truncated r13 diagonal restrictions
					  ; note this will never happen to rdi since we don't do two jmpumps up
mov r15, 0				  ; since this is a new row there are no lizards placed yet	
mov r15, rcx		  ; unless there is a 1 put by another tree earlier
xor rcx, rcx			  ; disable marker				 
shrd r13, r13, 1				  ; to update the effect of a diagonal on the next row, you must shift it to right by one
and r13, rsi			  ; this will ensure the data has info only for places inculded in the board
shld rdi, rdi, 1				  ; to update the effect of a right diagonal on the next row, shift it to left by one
and rdi, rsi			  ; this will ensure the data has info only for places inculded in the board

cmp r15, 2
je check_next_cell		  ; if the cell_below tree is another tree, check the cell next to the upper tree

mov rax, r13
or rax, rdi			  ; only the values of the diagonals may affect since the tree already masked col
or rax, rdx			  ; we also need to update col num
and rbx, rax
cmp rax, rbx

jne check_next_cell		  ; if both rax and $a2 are not equal this means that column under tree is not safe because of diagonal so check cell next to tree
					  ;  ; in case all conditions are met we do indeed put 1 under the tree
cmp r15, 1
je check_next_cell

mov r15, 1				  ; this will  also be used as an indication that there is a  lizard in the column
mov [r11], r15 				  ; put 1 in that empty_safe cell and proceed 
add r14, 1				  ; this will act as a counter for the number of lizards we have 
add rcx, 1          		  ; since we jmpump under the tree put one and return one row the effect of the one

				  ; under the tree has to be preseved since a0 need to be set to zero to highlight
					  ; the mask of the tree for the previous row
					  ; placed so far, when we return to lizards function it will compare them to size if they
					  ; are less than the size of the board we get in this function again
												
mov rbx, r8
sub rbx, 1			          ; get the maximum allowed column index in $a1
sub rax, r10			  ; subtract the max value from the actual value of the column, to get in reverse
mov rbx, 1
push rcx
mov cl, al
shld rbx, rbx, cl			  ; we are going to shift logical by $a1 and the value of $a2 will be the bin of current column
pop rcx
                			  ; update the data_structure

or rdx, rbx		  ; we are going to or the current column and all the previous column to get a binary for all 
			 		  ; columns that contain lizards 1000 says column one has a lizard
or r13, rbx		  ; we are going to store the left diagonal effect of this one on next rows
or rdi, rbx			  ; we are going to store the right diagonal effect of this one on next rows

					  ; we start of by getting back to the upper row and shifting all the values of ld and rd
					  ; of course we will keep the masking since the tree is not going anywhere 
push rax
push rdx
push r12
mov rax, r8
mov r12, 8
mul r12
mov r8, rax
pop r12
pop rdx
pop rax	
		          ; get the number of bytes required to get to the next row
sub r11, 8

push rax
push rdx
push r12
mov rax, r8
mov r12, 8
div r12
mov r8, rax
pop r12
pop rdx
pop rax 			  ; get the size back withouth bytes
sub r9, 1
shld r13, r13, 1				  ; since we got back one row we restore the ld of that row
or r13, r12			  ; restore truncated errors due to double jmpump and get back
shrd rdi, rdi, 1				  ; since we got back one row we restore the rd of that row

mov rax, r8
sub rax, 1				  ; get the maximum allowed column index in $a1
cmp r10, rax
pop rbx
pop rax	
je recurse_next_row 		  ; we need this to be in sparate label because we we go to next row we need to update data_structure

mov r15, 0				  ; since we will always jmpump back  the tree will shield any lizard in the column
add r11, 8			  ; increase to get the next index of next column to the tree
add r10, 1			  ; increase the column since we are going to store next to the tree
					 
push r11 				  ; store the address of array entered				
call for_this_cell
pop r11 				  ; restore the address of array entered
ret


check_next_cell:
					  ; we start of by getting back to the upper row and shifting all the values of ld and rd
					  ; of course we will keep the masking since the tree is not going anywhere 
pop rbx
pop rax

push rax
push rdx
push r12
mov rax, r8
mov r12, 8
mul r12
mov r8, rax
pop r12
pop rdx
pop rax

			          ; get the number of bytes required to get to the next row
sub r11, r8
push rax
push rdx
push r12
mov rax, r8
mov r12, 8
div r12
mov r8, rax
pop r12
pop rdx
pop rax
 			  ; get the size back withouth bytes
sub r9, 1
shld r13, r13, 1				  ; since we got back one row we restore the ld of that row
or r13, r12			  ; restore truncated errors due to double jmpump and get back
shrd rdi, rdi, 1				  ; since we got bacl one row we restore the rd of that row
mov r15, 0				  ; since this is the row that contains the tree it masks any affect if any of a previous
					  ; lizard in the row
push rax
mov rax, r8
sub rax, 1
			  ; get the maximum allowed column index in $a1
cmp r10, rax
je recurse_next_row 		  ; we need this to be in sparate label because we we go to next row we need to update data_structure
pop rax
add r11, 8			  ; increase to get the next index of next column to the tree
add r10, 1
push  r11 				  ; store the address of array entered				
call for_this_cell
pop  r11 				  ; restore the address of array entered
ret

clean_board:
;-------------PUSH------------
push rax
push rbx
push rcx;---------------------

mov rax, my_array			 
mov rbx,0 				   ; counter
clean_loop:
push rbx
mov rbx, [rax]
cmp rbx, 1
pop rbx
je clear_to_zero
continue_cleaning:
add rbx, 1			   ; increment counter 
;-------------PUSH-------------
push rdi
push rdx
push rax;----------------------

mov rdi, r8
mov rax, r8
mul r8
mov r8, rax

		   ; get the number of elements in the 2D array
cmp rbx, r8
jge cleaned
mov rax, r8
div rdi
mov r8, rax

pop rax;---------------------------
pop rdx
pop rdi
;----------------POP---------------

;pop rcx;---------------------------
;pop rbx
;pop rax
add rax, 8
;---------------POP----------------

jmp clean_loop

clear_to_zero:
mov rcx, 0
mov [rax], rcx
jmp continue_cleaning

cleaned:
push rax
push rdx
mov rax, r8
div rdi
mov r8, rax
pop rdx
pop rax

pop rax;---------------------------------
pop rdx
pop rdi
pop rcx
pop rbx
pop rax
;-------------ALL POP---------------------
ret

check_return:
pop rcx
pop rbx	
pop rax
cmp r10, r8
je return
jmp not_yet

return:
add r8, 1
ret

