	;Matris 1
m_one_row	EQU		0x7
m_one_col	EQU		0x7
	
	;Matris 2
;Row has to be same with 'm_one_col'
m_two_col	EQU		0x1
	

M_s_1		EQU 0x20000800	; Matris one
M_s_2		EQU 0x20000A00	; Matris two
M_f			EQU 0x20000C00	; Matris product
M_sorted	EQU 0x20000E00	; Sorted values
	
	
c_col		EQU	0x20000004	; Column Counter
c_row		EQU 0x20000000	; Row Counter and Base address, "800, A000, C00, E00" can be added.




	AREA MYCODE, CODE
MATRIX_1 DCD 2,8,6,5,1,8,7,2,2,8,6,5,1,8,7,2,2,8,6,5,1,8,7,2,2,8,6,5,1,8,7,2,2,8,6,5,1,8,7,2,2,8,6,5,1,8,7,2,5
MATRIX_2 DCD 5,7,2,1,4,3,7
    ALIGN
    ENTRY
    
    EXPORT __main
	
	
	
__main

str_memory_1

	LDR R0, =M_s_1		;Address of first matrix at memory
	LDR R1, =MATRIX_1	;Temporary address of first matrix
	
	LDR R3, =m_one_row	;row number
	LDR R4, =m_one_col	;column number
	MUL R5, R3, R4	  	;First matrix element number
loop_m1
	SUBS R5, #1			;subs 1 until all the elements of
	LDR	 R2, [R1], #4	;first matrix loaded
	STR  R2, [R0], #4	;then stored to memory
	BNE  loop_m1
	
str_memory_2

	LDR R0, =M_s_2		;Address of second matrix at memory
	LDR R1, =MATRIX_2   ;Temporary address of second matrix
	
	LDR R3, =m_one_col	;row number of second matrix
	LDR R4, =m_two_col  ;column number of second matrix
	MUL R5, R3, R4	  	;First matrix element number
loop_m2
	SUBS R5, #1			;subs 1 until all the elements of
	LDR	 R2, [R1], #4   ;second matrix loaded
	STR  R2, [R0], #4   ;then stored to memory
	BNE  loop_m2


	
TO_MUL

	LDR R0, =m_one_row	; row number of first matrix
	LDR R1, =m_one_col	; column number of first matrix and row number of second matrix
	LDR R2, =m_two_col	; column number of second matrix
	
	MUL R3, R0, R1  ; First matris element number
	MUL R4, R1, R2	; Second matris element number
	
	 
		
	;IMPORTANT ADDRESS FOR Counters
	LDR R5, =c_row	; FOR ROW COUNTER
	LDR R6, =0x0
	STR R6, [R5]	; 0 value stored
	
	
	LDR R5, =c_row		;FOR COLUMN COUNTER
	ADD R5, #4			;to reach column address 4 added
	LDR R6, =0x0		; the program gives error when I do it differently
	STR R6, [R5]		; 0 value stored
	
	LDR R11, =M_s_1		; Address of first matrix
	LDR R12, =M_s_2		; Adress of second matrix
	LDR R10, =M_f		; Address of result matrix

	
	
loop_line_step  ; this loop works when all the column are used

	LDR R5, =c_row		;FOR COLUMN COUNTER
	ADD R5, #4			; to reach address
	LDR R6, =0x0		; its because the code only branches here when all the columns are multiplied
	STR R6, [R5]		; it reset column counter and stores again.

	LDR R0, =m_one_row  ; row number of first matrix
	LDR R1, =m_one_col  ; column number of first matrix and row number of second matrix
	LDR R2, =m_two_col  ; column number of second matrix

	LDR R11, =M_s_1
	LDR R12, =M_s_2

	LDR R5, =c_row		;FOR ROW COUNTER
	LDR R6, [R5]		; loads the which row it used last time
	
	MUL R1, R6		; because skip the next row we need to increase the address by column number times 4
					; so that this MUL calculates how far the next row's start address from start address of first matrix.
					; as an example at matrix of 1 2 3 , 4 is 12 byte far from 1 which equal to 3(colum)*4
					;                            4 5 6
	ADD R11, R1, LSL #2	; its add the the value to start address of first matrix
	
	CMP R6, R0 ; if the  counter equal to row number od first matrix
	BEQ final  ; its mean all the row used, so its branches to final
	
	ADD R6, #1	 ; if not it add 1 to row counter
	STR R6, [R5] ; and stores for next usage

loop_col_step ; this loop checks if the all the column used
			  ; *if used, branches to loop below for next row
			  ; *if not, uses next column

	LDR R0, =m_one_row ; row number of first matrix
	LDR R1, =m_one_col ; column number of first matrix and row number of second matrix
	LDR R2, =m_two_col ; column number of second matrix
	
	
	LDR R5, =c_row		;FOR COLUMN COUNTER
	ADD R5, #4			; to reach address
	LDR R6, [R5]		; loads the which column it last used

	LDR R12, =M_s_2		; second matrix start address
	ADD R12, R6, LSL #2	; it adds 4*column counter to start address of second matrix because
						;as an example at matrix of 1 2 3 , third column is 8 byte far from 1 which equal to 2(counter value)*4
						;						    4 5 6
	
	CMP R6, R2		; compares the counter with column number to check if the all the columns are used
	
	ADD R6, #1		; if not it add 1 to row counter
	STR R6, [R5]    ; and stores for next usage
	
	BEQ	loop_line_step	; if used, branches to pass the next row
	PUSH{R11}			; because all the columns multiplies with same row for each row
						; it stores to row's start address
	

loop_answer
	
	SUBS R1, #1	;the number of multiplications is equal to the number of colons of the first matrix

	PUSH{R1} ; we store that value

	LDR R6 ,[R11], #4 ; next element of row
	LDR R7 ,[R12]	  ; element of column
	
	LDR R1, =m_two_col  ; to reach second element of column 
	ADD R12, R1, LSL #2 ; it adds 4*column number of second matrix
					 	;as an example at matrix of 1 2 3 , 4 is 12 byte far from 1 which equal to 3(colum)*4
						;						    4 5 6 , and 7 is 12 bytes far from 4, which again equal to 3(colum)*4
						;							7 8 9
	
	LDR R9, [R10]		; loads the answer matrix
	MUL R8, R7, R6		; multiplies the row and column element
	ADD R8, R9			; adds the value to the value came from memory
	STR R8, [R10]		; and stores
						; by doing this, the product of the row and the column is stored into a single element 
	
	POP{R1}				; loads the counter again
	BNE loop_answer		; does this progres for all element in the row and column
	
	ADD R10, #4			; when it end it pass to next address for next row and column product
	POP{R11}			; reset the row's start address
	
	BEQ	loop_col_step  ; if it end goes for the next column
	

	
final ; loads some values

	LDR R1, =c_row	; to load sorted array address it uses c_row as a base address
	ADD R1, #0xE00	; 

	LDR R2, =m_one_row
	LDR R3, =m_two_col
	MUL R8, R2, R3		;R8 equal to number of element of answer matrix
	
sorting	; loads a value to compare

	MUL R7, R2, R3		; max term will be R2 LSL #2
						; R7 equal to number of element of answer matrix
						; and it will uses as counter
						
	LDR R0, =c_row	; to load answer array address it uses c_row as a base address
	ADD R0, #0xC00


	LDR R4, [R0], #4 ; loads first element of answer matrix
	MOV R10, R0		 ; stores the address to R10

	
try_again	; compares the value with other elements

	SUBS R7, #1 ; the number of comparision equal to R7
	BEQ s_save  ; if all the comparision are done, it branches to save 

	LDR R5, [R0], #4 ; loads next element to compare
	
	CMP R4, R5	; you will not believe but it compares
	
	BLS swap		; if second value is bigger than first, it goes to swap
	BHI try_again	; if not, it branches itself to load another element
	
swap
	MOV R10, R0	; saves the address of bigger value
	MOV R4, R5	; swaps
	B	try_again ; branches to comparision until finding to highest element
	
	
s_save

	SUBS R8, #1 ; since sorted matrix element number equal to R8
				; for each time we store a value to sorted matrix , it subs 1 from R8

	STR	R4, [R1], #4	; it stores the biggest value to sorted array address
	SUB	R10, #4			; beacuse each time we load a new value from answer array, we increase the address by 4
						; so to go back to value address we sub 4.
	STR	R7, [R10]	; and we store 0 to that address

	BEQ	last_wish	; if all the values are saved, it branches last step
	B	sorting		; if not it go back to sorting
	

last_wish
	;son 2 ve ilk 2 deper kayit edilir

	LDR R0, =c_row
	ADD R0, #0xE00
	
	LDR R1, =m_one_row
	LDR R2, =m_two_col
	MUL R3, R1, R2
	SUB R3, #2

	LDR R5, [R0]	; biggest value
	LDR R6, [R0, #4]; second biggest value
	
	ADD R0, R3, LSL #2	; 
	
	LDR R7, [R0]	; second smallest value
	LDR R8, [R0, #4]; smallest value
	
	
endd B endd

	
	
	
	
	END
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		