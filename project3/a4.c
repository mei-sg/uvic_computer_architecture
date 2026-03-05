/* a4.c
 * CSC Fall 2022
 * 
 * Student name: Mei Stoesz-Gouthro
 * Student UVic ID: V01004629
 * Date of completed work: November 30th, 2025
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2022-Nov-22)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define __DELAY_BACKWARD_COMPATIBLE__ 1
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

// method turns an turns a LED on
void led_state(uint8_t LED, uint8_t state) {

	uint8_t bitmask = 0;

	// turn the input led number on or off
	switch (LED) {

		case 0: // LED 0, bit 7
			bitmask = 0b10000000;
			break;

		case 1: // LED 1, bit 5
			bitmask = 0b00100000;
			break;

		case 2: // LED 2, bit 3
			bitmask = 0b00001000;
			break;

		case 3: // LED 3, bit 1
			bitmask = 0b00000010;
			break;
	}
	
	// turn the bit on
	if (state) {
			PORTL |= bitmask;
	// turn off the bit
	} else {
			PORTL &= ~ bitmask;
	}
}


// display sos pattern
void SOS() {
	uint8_t light[] = {
		0x1, 0, 0x1, 0, 0x1, 0,
		0xf, 0, 0xf, 0, 0xf, 0,
		0x1, 0, 0x1, 0, 0x1, 0,
	0x0};

	int duration[] = {
		100, 250, 100, 250, 100, 500,
		250, 250, 250, 250, 250, 500,
		100, 250, 100, 250, 100, 250,
	250};

	int length = 19;

	// display sos pattern with led_state()
	for (int i = 0; i < length; i++) {
		// determine pattern
		uint8_t pattern = light[i];

		// loop through led 0 though 4
		for (int led_number = 0; led_number < 4; led_number++) {
			// determine if the light is turned on or off
			uint8_t on_or_off = (pattern >> led_number) & 0x1;
			// call led_state() with the correct info for each light
			led_state(led_number, on_or_off);
		}
		// call the appropriate delay
		_delay_ms(duration[i]);
	}
}

// display an led with a given brightness
void glow(uint8_t LED, float brightness) {

	float threshold = PWM_PERIOD * brightness;
	// check if the light is on
	int led_on = 0;

	// infinite loop to turn on the given light at the given intensity
	for (;;) {

		

		// if count < threshold and LED is not already on, then turn the LED on
		if (count < threshold && !led_on) {
			led_state(LED, 1);
			led_on = 1;

			// if count < PWM_PERIOD and LED is not already off, then turn the LED off
			} else if (count >= threshold && count < PWM_PERIOD && led_on) {
			led_state(LED, 0);
			led_on = 0;

			// else (count must be greater than PWM_PERIOD), then count = 0 and turn the LED on
			} else {
			count = 0;
			led_state(LED, 1);
			led_on = 1;
		}
	}
}

// pulse the brightness of a light
void pulse_glow(uint8_t LED) {

	float brightness = 0.0f;
	long int slow = slow_count;
	float up_down = 1.00f;
	count = 0;

	// infinite loop to turn on the given light at the given intensity
	while (1) {
		
        int led_on = 0;
        float threshold = PWM_PERIOD * brightness;

        // run until the end of the period
		while (count < PWM_PERIOD) {

			if (count < threshold && !led_on) { // if count < threshold and LED is not already on, then turn the LED on
				led_state(LED, 1);
				led_on = 1;

			} else if (count >= threshold && led_on) { // if count < PWM_PERIOD and LED is not already off, then turn the LED off
				led_state(LED, 0);
				led_on = 0;
			}
		}
		
        // reset count
		count = 0;

        // has slow_count changed?
		if (slow_count != slow) {

			slow = slow_count;
			brightness += up_down * 0.01f;

            // increase or decrease brightness at the high and low bounds 
			if (brightness >= 0.99) {
				up_down = -1;

			} else if (brightness <= 0.0f) {
				brightness = 0.0f;
				up_down = 1;
			}
		}
	}
}


void light_show() {

}


/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a pre-scaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a pre-scaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */
	DDRL = 0xFF;
	PORTL = 0x00;

 /* This code could be used to test your work for part A.

	led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);
*/

/* This code could be used to test your work for part B.

	SOS();
*/

/* This code could be used to test your work for part C.

	glow(2, .01);
*/



//This code could be used to test your work for part D.

	pulse_glow(3);



/* This code could be used to test your work for the bonus part.

	light_show();
 */

/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}
