; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section
ldi r16, 0xFF ;set bits to 1 
sts DDRL, r16 ;use port L as output
ldi r16, 0x00 ;turn off lights to start
sts PORTL, r16
		

; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_c
	; Test code


test_part_a:
	;ldi r16, 0b11111111
	;rcall set_leds
	;ldi r16, 0b00000000
	;rcall set_leds
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	clr r16
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop

	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end






; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:
	;ldi r18, 0xFF ;set r18 to 255
	;sts DDRL, r18 ;data direction register L
	sts PORTL, r16 ;port L out
	ret

slow_leds:
	push r16 ;push leds binary encoding number to the stack
	mov r16, r17 ;copy the value in r17 to r16
	rcall set_leds ;set the leds
	rcall delay_long ;call long delay
	ldi r16, 0b0 ;clear
	rcall set_leds ;reset
	pop r16 ;remove the leds binary value from the stack
	ret

fast_leds:
	push r16 ;push leds binary encoding number to the stack
	mov r16, r17 ;copy the value in r17 to r16
	rcall set_leds ;set the leds
	rcall delay_short ;call short delay
	ldi r16, 0x00 ;turn off lights
	rcall set_leds ;reset
	pop r16 ;remove the leds binary value from the stack
	ret

leds_with_speed: ;push, call, pop
    push r16 ;push values to the stack to retain
    push r17
    push r18
    mov r18, r16 ;copy r16 value to r18 to mask
    andi r18, 0b11000000 ;mask bits
    cpi r18, 0b11000000 ;compare r18 value with configuration bits value, 1 
    breq set_slow_lights ; if the configuration bits are 1, use slow_leds
    mov r17, r16 ;else, call fast_leds
    rcall fast_leds
    rjmp end_leds_with_speed ;finish and restore stack

set_slow_lights:
    mov r17, r16 ;copy r16 value to r17
    rcall slow_leds
    rjmp end_leds_with_speed ;finsih and restore stack
    

end_leds_with_speed:
    pop r18 ;restore stored values in the stack
    pop r17
    pop r16
    ret
	
; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	;give alias names for registers for readability 
	.def temp = r18
	.def counter = r22
	.def return_reg = r25
	.def test_input = r21

	push temp ;push onto stack
	push counter 
	ldi counter, 6
	ldi ZH, high(PATTERNS<<1) ;high Z reg (program mem)
	ldi ZL, low(PATTERNS<<1) ;low Z reg (program mem)

loop_through:
	lpm temp, Z+ ;load letter to program mem
	cp temp, test_input ;compare the letter with the input
	breq found_letter ;go to found_letter if they are equal
	adiw ZL, 7 ;skip the un-needed bits
	rjmp loop_through

found_letter:
	clr return_reg ;clear return reg

set_led_code:
	lpm temp, Z+ ;load one bit of letter to program mem
	cpi temp, 'o' ;compare with the on symbol
	brne next
	ori return_reg, 0b01 ;set bit to on

next:
	lsl return_reg ;go to the next bit
	dec counter ;decrement the counter
	brne set_led_code ;load a new bit into program mem

read_configuration:
	lpm temp, Z+ ;read the configuration bit
	cpi temp, 1 ;compare with the value for slow_leds
	brne end_encode_letters
	ori return_reg, 0b11000000 ;set configuration bits to 1 for slow


end_encode_letters:
	pop counter ;clear stack
	pop temp
	ret
	
display_message:
	ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "X", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

