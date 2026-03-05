; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
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
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000. 
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========

	ldi R16, 0b01011100
	;ldi R16, 0b10110110
	;ldi R16, 0b11111111
	;ldi R16, 0b00000000
	;ldi R16, 0b00000010


	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 
; research sources used
; https://stackoverflow.com/questions/62579414/avr-assembly-bit-number-to-mask
; https://electronics.stackexchange.com/questions/39311/assembly-language-program-design
; both these resources were used for the idea of my counter in r18, where it goes up by 1, if shifted right, and goes down by 1, if shifted left. 
; the idea to track carry flag values was also used

ldi r25, 0
ldi r18, 0 ;counts down the number of times shifted to the right
ldi r19, 8 ;compare to number

find_one:
	lsr r16 ;shift one to the right 
	inc r18 ;increment by 1 bc we have shifted once
	brcs is_one ;goes to is_one loop if a 1 is carried
	cp r18, r19 ;see if the counter is at 8
	breq end_program ;stop if it is 8 0s
	brcc find_one ;loop around again

is_one:
	lsr r16 ;shifts to the right again
	inc r18 ;increments the counter 
	brcs is_one ;if it is still a 1 that is shifted, then loop back to is_one
	brcc shift_left ;if we have now carried a 0, we shift back to the left to end 

shift_left:
	lsl r16 ;shift left r16 until 
	dec r18 ;decrement r18 by 1, to signify a shift left
	brne shift_left ;shifts left until the counter is back at 0
	mov r25, r16

end_program:
	mov r25, r16

; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop
; ==== END OF "DO NOT TOUCH" SECTION ==========
