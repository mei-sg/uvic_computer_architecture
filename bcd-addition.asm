; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;   *  0x94 in R16
;   *  0x09 in R17
; with the result of the addition being:
;   * 0x03 in R25
;   * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If 
; the digits are encoded as BCD, we would have
;   * 0x35 in R16
;   * 0x49 in R17
; with the result of the addition being:
;   * 0x84 in R25
;   * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

;https://www.youtube.com/watch?v=boLrmr8K94g
;https://www.youtube.com/watch?v=-kQdswrlQFE
;the bcd addition process was explained to me by these videos, specifically the carry over process


.cseg
.org 0

; Some test cases below for you to try. And as usual
; your solution is expected to work with values other
; than those provided here.
;
; Your code will always be tested with legal BCD
; values in r16 and r17 (i.e. no need for error checking).

; 94 + 9 = 03, carry = 1 
ldi r16, 0x94
ldi r17, 0x09

; 86 + 79 = 65, carry = 1 
;ldi r16, 0x86
;ldi r17, 0x79

; 35 + 49 = 84, carry = 0 yes
;ldi r16, 0x35
;ldi r17, 0x49

; 32 + 41 = 73, carry = 0 yes
;ldi r16, 0x32
;ldi r17, 0x41

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

;name the registers and initialize values   	
.def num1 = r16
.def num2 = r17
.def n1_hi = r18
.def n1_lo = r19
.def n2_hi = r20
.def n2_lo = r21
.def fix = r22
.def temp = r23
.def carry = r24
.def right = r25


ldi n1_hi, 0
ldi n1_lo, 0
ldi n2_hi, 0
ldi n2_lo, 0
ldi fix, 0x06 ;add 6 (decimal) to fix
ldi temp, 1
ldi carry, 0
ldi right, 0


;split up num1 into high and low nibbles
mov n1_lo, num1 ;copy num1 to n1_lo
andi n1_lo, 0x0F ;keep the low nibble
 
mov n1_hi, num1 ;copy num1 to n1_hi
swap n1_hi ;swap high and low nibble around
andi n1_hi, 0x0F ;keep the low nibble (originally the high nibble)
 
;split up num2 into high and low nibbles
mov n2_lo, num2;copy num2 to n2_lo
andi n2_lo, 0x0F ;keep the low nibble
 
mov n2_hi, num2 ;copy num2 to n2_hi
swap n2_hi ;swap high and low nibble around
andi n2_hi, 0x0F ;keep the low nibble (originally the high nibble)

;perform addition on the low nibbles
add n1_lo, n2_lo ;add the low nibbles and store the value in n1_lo
cpi n1_lo, 10 ;check if the number in n1_lo is greater than or equal to 10
brge to_fix_lo
rjmp add_hi

to_fix_lo:
	add n1_lo, fix ;add a 6 to fix 
	;mov right, n1_lo
	andi n1_lo, 0x0F ;keep the last 4 digits of n1_lo
	add n1_hi, temp
	rjmp add_hi

;perform addition on the high nibbles
add_hi:
	add n1_hi , n2_hi ;add the high nibbles and store the value in n1_hi
	cpi n1_hi, 10 ;check if the number in n1_lo is greater than 10
	brge to_fix_hi
	andi n1_hi, 0x0F ;keep only 4 bits
	swap n1_hi ;make it the high nibble
	or n1_hi, n1_lo
	mov right, n1_hi
	rjmp bcd_addition_end

to_fix_hi:
	add n1_hi, fix ;add a 6 to fix 
	ldi carry, 1
	andi n1_hi, 0x0F ;keep only 4 bits
	swap n1_hi ;make it the high nibble
	or n1_hi, n1_lo
	mov right, n1_hi
	rjmp bcd_addition_end

; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
