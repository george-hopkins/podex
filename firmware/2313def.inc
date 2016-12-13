;***************************************************************************
;* A P P L I C A T I O N   N O T E   F O R   T H E   A V R   F A M I L Y
;* 
;* Number		:AVR000
;* File Name		:"2313def.inc"
;* Title		:Register/Bit Definitions for the AT90S2313
;* Date	 		:97.12.11
;* Version		:1.20
;* Support telephone	:+47 72 88 87 20 (ATMEL Norway)
;* Support fax		:+47 72 88 87 18 (ATMEL Norway)
;* Support E-Mail	:avr@atmel.com
;* Target MCU		:AT90S2313
;*
;* DESCRIPTION
;* When including this file in the assembly program file, all I/O register
;* names and I/O register bit names appearing in the data book can be used.
;* 
;* The Register names are represented by their hexadecimal addresses.
;* 
;* The Register Bit names are represented by their bit number (0-7).
;* 
;* Please observe the difference in using the bit names with instructions
;* such as "sbr"/"cbr" (set/clear bit in register) and "sbrs"/"sbrc" 
;* (skip if bit in register set/cleared). The following example illustrates
;* this:
;* 
;* in	r16,PORTB		;read PORTB latch
;* sbr	r16,(1<<PB6)+(1<<PB5)	;set PB6 and PB5 (use masks, not bit#)
;* out  PORTB,r16		;output to PORTB
;*
;* in	r16,TIFR		;read the Timer Interrupt Flag Register
;* sbrc	r16,TOV0		;test the overflow flag (use bit#)
;* rjmp	TOV0_is_set		;jump if set
;* ...				;otherwise do something else
;***************************************************************************


;***** I/O Register Definitions
.equ	SREG,	0x3f
.equ	SPL,	0x3d
.equ	GIMSK,	0x3b
.equ	GIFR,	0x3a
.equ	TIMSK,	0x39
.equ	TIFR,	0x38
.equ	MCUCR,	0x35
.equ	MCUSR,	0x34
.equ	TCCR0,	0x33
.equ	TCNT0,	0x32
.equ	TCCR1A,	0x2f
.equ	TCCR1B,	0x2e
.equ	TCNT1H,	0x2d
.equ	TCNT1L,	0x2c
.equ	OCR1AH,	0x2b
.equ	OCR1AL,	0x2a
.equ	ICR1H,	0x25
.equ	ICR1L,	0x24
.equ	WDTCR,	0x21
.equ	EEAR,	0x1e
.equ	EEARL,	0x1e
.equ	EEDR,	0x1d
.equ	EECR,	0x1c
.equ	PORTB,	0x18
.equ	DDRB,	0x17
.equ	PINB,	0x16
.equ	PORTD,	0x12
.equ	DDRD,	0x11
.equ	PIND,	0x10
.equ	UDR,	0x0c
.equ	USR,	0x0b
.equ	UCR,	0x0a
.equ	UBRR,	0x09
.equ	ACSR,	0x08


;***** Bit Definitions
.equ	SP7,	7
.equ	SP6,	6
.equ	SP5,	5
.equ	SP4,	4
.equ	SP3,	3
.equ	SP2,	2
.equ	SP1,	1
.equ	SP0,	0

.equ	INT1,	7
.equ	INT0,	6

.equ	INTF1,	7
.equ	INTF0,	6

.equ	TOIE1,	7
.equ	OCIE1A,	6
.equ	TICIE,	3
.equ	TOIE0,	1

.equ	TOV1,	7
.equ	OCF1A,	6
.equ	ICF1,	3
.equ	TOV0,	1

.equ	SE,	5
.equ	SM,	4
.equ	ISC11,	3
.equ	ISC10,	2
.equ	ISC01,	1
.equ	ISC00,	0

.equ	EXTRF,	1
.equ	PORF,	0

.equ	CS02,	2
.equ	CS01,	1
.equ	CS00,	0

.equ	COM1A1,	7
.equ	COM1A0,	6
.equ	PWM11,	1
.equ	PWM10,	0

.equ	ICNC1,	7
.equ	ICES1,	6
.equ	CTC1,	3
.equ	CS12,	2
.equ	CS11,	1
.equ	CS10,	0

.equ	WDTOE,	4
.equ	WDE,	3
.equ	WDP2,	2
.equ	WDP1,	1
.equ	WDP0,	0

.equ	EEMWE,	2
.equ	EEWE,	1
.equ	EERE,	0

.equ	PB7,	7
.equ	PB6,	6
.equ	PB5,	5
.equ	PB4,	4
.equ	PB3,	3
.equ	PB2,	2
.equ	PB1,	1
.equ	PB0,	0

.equ	DDB7,	7
.equ	DDB6,	6
.equ	DDB5,	5
.equ	DDB4,	4
.equ	DDB3,	3
.equ	DDB2,	2
.equ	DDB1,	1
.equ	DDB0,	0

.equ	PINB7,	7
.equ	PINB6,	6
.equ	PINB5,	5
.equ	PINB4,	4
.equ	PINB3,	3
.equ	PINB2,	2
.equ	PINB1,	1
.equ	PINB0,	0

.equ	PD6,	6
.equ	PD5,	5
.equ	PD4,	4
.equ	PD3,	3
.equ	PD2,	2
.equ	PD1,	1
.equ	PD0,	0

.equ	DDD6,	6
.equ	DDD5,	5
.equ	DDD4,	4
.equ	DDD3,	3
.equ	DDD2,	2
.equ	DDD1,	1
.equ	DDD0,	0

.equ	PIND6,	6
.equ	PIND5,	5
.equ	PIND4,	4
.equ	PIND3,	3
.equ	PIND2,	2
.equ	PIND1,	1
.equ	PIND0,	0

.equ	RXC,	7
.equ	TXC,	6
.equ	UDRE,	5
.equ	FE,	4
.equ	OR,	3

.equ	RXCIE,	7
.equ	TXCIE,	6
.equ	UDRIE,	5
.equ	RXEN,	4
.equ	TXEN,	3
.equ	CHR9,	2
.equ	RXB8,	1
.equ	TXB8,	0

.equ	ACD,	7
.equ	ACO,	5
.equ	ACI,	4
.equ	ACIE,	3
.equ	ACIC,	2
.equ	ACIS1,	1
.equ	ACIS0,	0

.equ	XL,	r26
.equ	XH,	r27
.equ	YL,	r28
.equ	YH,	r29
.equ	ZL,	r30
.equ	ZH,	r31

.equ	RAMEND,	0xdf

.equ	INT0addr,	0x001
.equ	INT1addr,	0x002
.equ	ICP1addr,	0x003
.equ	OC1addr,	0x004
.equ	OVF1addr,	0x005
.equ	OVF0addr,	0x006
.equ	URXCaddr,	0x007
.equ	UDREaddr,	0x008
.equ	UTXCaddr,	0x009
.equ	ACIaddr,	0x00a

