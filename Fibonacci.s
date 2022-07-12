sequence_address EQU 0x20001000   ;Addrees of sequence
iterataion       EQU 0x7          ; sequence number

	AREA MYCODE, CODE
    ALIGN
    ENTRY 
    EXPORT __main
	
__main
	LDR R0, =sequence_address
	LDR R1, =0x1                ; First element of sequence
	LDR R2, =0x1                ; Second element of sequence
	
	STM R0, {R1,R2}             ; First 2 terms stored in memory
	
	LDR R10, =iterataion        ;
	SUB R10, #2                 ; First 2 iteratson are 1 so 2 subtracted from iteration number
	LDR R5, =0x0                ; going to be used as a 'division answer'
	LDR R4, =0x2                ; going to be used as a 'total value counter'
                                ;and because we defined fisrt 2 term, we started R4 with 2

loop1
	SUBS R10, #1                ; used as loop counter	
	
	LDR R1, [R0], #4            ; loaded the 2nd previous value
	LDR R2, [R0], #4            ; loaded the 1st previous value and R0 has empty memory address value

	ADD R3, R1, R2              ; added two previous term to get present term
	ADD R4, R3                  ; added to R4 as 'total value counter'
	STR R3, [R0]                ; stored the present term to mememory

	SUB R0, #4                  ; subtracted 4 to go back 1 term back

	BNE	loop1                   ; will branch until all values are obtained


	LDR R10, =iterataion        ; loaded iteration number for mean_loop
mean
	
	SUB R4, R10                 ; to make division iteration number subtracted
	ADD R5, #1                  ; after every subtraction 1 added to 'division answer'
	
	CMP R4, R10                 ; 'total value counter'compared for is it possible to do more subtraction
	BHS	mean                    ; if possible branched to mean again
	
	
	LDR R0, =sequence_address   ; Sequence start address loaded
	LDR R10, =iterataion        ; iteration number loaded
squared_difference
	SUBS R10, #1                ; to find veriance we need to sum of all the values subtracted from mean and squared.
	
	LDR R6, [R0], #4	; Loads values
	SUB R6, R6, R5		; Substract them to division answer
	MUL R6, R6, R6		; multiplies with itself to take square

	ADD R7, R6          ; Add them to R7

	BNE	squared_difference

	LDR R10, =iterataion ; loads iteration number for veriance_loop
	SUB R10, #1          ; for veriance we need to divide with n-1, so we substracted 1
veriance

	SUB R7, R10          ; to make division iteration number subtracted
	ADD R8, #1           ; after every subtraction 1 added to 'division answer'
	
	CMP R7, R10          ; R7 compared for is it possible to do more subtraction
	BHS	veriance         ; if higher than R10, go to loop again

endd B endd
	END