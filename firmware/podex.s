	;;
	;; :::::::::::::::::
	;; :::           :::
	;; ::  p o d e x  ::
	;; :::           :::
	;; :::::::::::::::::
	;;
	;; Copyright (C) 2004 Marek Peca <mp@duch.cz>
	;;
	;; This file is part of podex.
	;;
	;; podex is free software: you can redistribute it and/or modify
	;; it under the terms of the GNU General Public License as published by
	;; the Free Software Foundation, either version 3 of the License, or
	;; (at your option) any later version.
	;;
	;; podex is distributed in the hope that it will be useful,
	;; but WITHOUT ANY WARRANTY; without even the implied warranty of
	;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	;; GNU General Public License for more details.
	;;
	;; You should have received a copy of the GNU General Public License
	;; along with podex.  If not, see <http://www.gnu.org/licenses/>.
	;;
	;; -*- http://duch.cz/podex/ -*-
	;;
	;; RS232 <--> Motorola 68HC12 BDM
	;; Background Debug Mode interface
	;; Kevin Ross' BDM12 v4.7 compatible protocol
	;;

	.file	"podex.s"
	.arch	at90s2313
	.include "2313def.inc"

	;;
	;; timing constants
	;;
	;; +------------------------+
	;; |    XTAL |    A |     B |
	;; |---------+------+-------|
	;; | 11.0592 |   54 |  3125 |
	;; |  9.2160 |    9 |   625 |
	;; |  7.3728 |   36 |  3125 |
	;; +------------------------+
	;;
.equ	POD_XTAL640_A,	9	; POD_XTAL640_A/POD_XTAL640_B = f_pod/(640MHz)
.equ	POD_XTAL640_B,	625	; (for precise computation of ExtendedSpeed spec. in v.4.7)
	;;
.equ	BAUD_RATE,	115200
.equ	UBRR_DENOM,	POD_XTAL640_B*BAUD_RATE
.equ	UBRR_VALUE,	(40000000*POD_XTAL640_A - UBRR_DENOM/2)/UBRR_DENOM
	;;
.equ	WAIT_1MS,	160000*POD_XTAL640_A/POD_XTAL640_B - 15	; 1ms = (4*N+15)T

	;;
	;; port/pin definition
	;;
	;; HC12 -- BKGND & RESET
.equ	BDM_P,	PORTB
.equ	RST_P,	PORTB
.equ	BDM_B,	PB0
.equ	RST_B,	PB1
.equ	BDM_I,	PINB
.equ	RST_I,	PINB
.equ	BDM_DD,	DDRB
.equ	RST_DD,	DDRB
	;; RS232
.equ	RTS_P,	PORTD
.equ	CTS_I,	PIND
.equ	RTS_B,	PD2		; CTS of PC
.equ	CTS_B,	PD3		; RTS of PC
.equ	RTS_DD,	DDRD
.equ	CTS_DD,	DDRD
	;; etc.
.equ	IO_PORT_P,	PORTB
.equ	IO_PORT_D,	DDRB
.equ	LED_RED,	PB2
.equ	LED_GREEN,	PB3
	;;
	;; global vars & buffer start
	;;
.equ	RAM_BEGIN,	0x60
.equ	REG_BASE_HI,	RAM_BEGIN+0	; high byte of HC12 register base
.equ	PACE_COUNT,	RAM_BEGIN+1	; delay between TraceTo in ms
.equ	RESET_COUNT,	RAM_BEGIN+2	; delay between RESET and BDM in ms
	;;
.equ	WAIT_150E_LO,	RAM_BEGIN+3
.equ	WAIT_150E_HI,	RAM_BEGIN+4
.equ	WAIT_64E_LO,	RAM_BEGIN+5
.equ	WAIT_64E_HI,	RAM_BEGIN+6
.equ	WAIT_32E_LO,	RAM_BEGIN+7
.equ	WAIT_32E_HI,	RAM_BEGIN+8
	;;
.equ	WAIT_BDMRX_4E1,	RAM_BEGIN+9
.equ	WAIT_BDMRX_6E2,	RAM_BEGIN+10
.equ	WAIT_BDMRX_6E3,	RAM_BEGIN+11
.equ	WAIT_BDMTX_4E1,	RAM_BEGIN+12
.equ	WAIT_BDMTX_9E2,	RAM_BEGIN+13
.equ	WAIT_BDMTX_3E3,	RAM_BEGIN+14
	;;
.equ	SPEED,		RAM_BEGIN+15
.equ	XSPEED_LO,	RAM_BEGIN+16
.equ	XSPEED_HI,	RAM_BEGIN+17
	;;
	;; BDM opcodes
	;;
.equ	READ_BYTE,	0xe0
.equ	READ_BD_BYTE,	0xe4
.equ	READ_WORD,	0xe8
.equ	READ_BD_WORD,	0xec
.equ	WRITE_BYTE,	0xc0
.equ	WRITE_BD_BYTE,	0xc4
.equ	WRITE_WORD,	0xc8
.equ	WRITE_BD_WORD,	0xcc
.equ	BACKGROUND,	0x90
	;;
.equ	READ_NEXT,	0x62
.equ	READ_PC,	0x63
.equ	READ_D,		0x64
.equ	READ_X,		0x65
.equ	READ_Y,		0x66
.equ	READ_SP,	0x67
.equ	WRITE_NEXT,	0x42
.equ	WRITE_PC,	0x43
.equ	WRITE_D,	0x44
.equ	WRITE_X,	0x45
.equ	WRITE_Y,	0x46
.equ	WRITE_SP,	0x47
.equ	GO_GO_GO,	0x08
.equ	TRACE1,		0x10
.equ	TAGGO,		0x18
	;;
.equ	BDM12_SYNC,	0x00
.equ	BDM12_RESET,	0x01
.equ	BDM12_RESET_LO, 0x02
.equ	BDM12_RESET_HI,	0x03
.equ	BDM12_EXT,	0x04
.equ	BDM12_EE_WRITE,	0x05
.equ	BDM12_REGBASE,	0x06
.equ	BDM12_EE_ERASE,	0x07
	;;
.equ	BDM12X_VERSION,	0x00
.equ	BDM12X_REGDUMP,	0x01
.equ	BDM12X_TRACETO,	0x02
.equ	BDM12X_MEMDUMP,	0x03
.equ	BDM12X_PARAM,	0x04
.equ	BDM12X_IOCTL,	0x05
.equ	BDM12X_MEMPUT,	0x06
.equ	BDM12X_XSPEED,	0x07
	;;
.equ	BDM12SPEED_1,	0x00
.equ	BDM12SPEED_2,	0x01
.equ	BDM12SPEED_4,	0x02
.equ	BDM12SPEED_8,	0x03
.equ	BDM12SPEED_X,	0x04
	;;
.equ	EEPROG,	0xf3		; EEPROM ctrl register (68HC12B*, 68HC12D*,..)
	;;
	;;


	.text
	.org	0

vector_table:
	rjmp	start
	reti			; dummy IRQ entries
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	reti
	;;

	.string	"podex 68HC12 BDM <mp@duch.cz>"

start:
init:
	;;
	;; Initialization
	;;
	cli			; No IRQ
	ldi	r24,RAMEND	; RAMEND->SP
	out	SPL,r24
	;;
	;; BDM pin & RESET, LED
	;;
	ldi	r24,(1<<LED_GREEN)|(1<<LED_RED)
	out	IO_PORT_D,r24	; LED output, other bits high-Z
	ser	r24
	out	IO_PORT_P,r24	; high
	;;
	;; RS232
	;;
	sbi	RTS_P,RTS_B	; RTS initially OFF
	sbi	RTS_DD,RTS_B	; RTS=output
	cbi	CTS_DD,CTS_B	; CTS=input
	ldi	r24,UBRR_VALUE
	out	UBRR,r24
	ldi	r24,0x18	; TXEN, RXEN
	out	UCR,r24
	;;
	;; parameters
	;;
	ldi	r24,BDM12SPEED_8 ; (8MHz EClock as default)
	sts	SPEED,r24
	clr	r21
	ldi	r20,(1280/8-14)/8 ; 8MHz
	rcall	set_speed
	;;
	ldi	r24,1		; 1ms -- minimum
	sts	RESET_COUNT,r24
	ldi	r24,0
	sts	PACE_COUNT,r24
	;;

main:
	;;
	;; main loop -- process command from PC
	;;
command:
	sbi	IO_PORT_P,LED_RED	; turn red LED off (no error)
command_u:
	cbi	IO_PORT_P,LED_GREEN	; green LED on (waiting)
	rcall	pod_rx		; get a command
	sbi	IO_PORT_P,LED_GREEN	; green LED off (busy)
	;;
	cpi	r17,0x08	; BDM command?
	brlo	pod_command	; no, --> pod command
	;;
	;; BDM commands (translator)
	;;
bdm_command:
	mov	r16,r17
	sbrc	r17,6		; one-byte command?
	rjmp	bdm_cmd_select
bdm_single:
	sbrc	r17,7		; HW or firmware cmd?
	rjmp	bdm_single_fw
bdm_single_hw:
	rcall	bdm_tx		; 0B in, 0B out
	rcall	wait_150E	; HW cmd
	rjmp	command		; %
	;;
bdm_single_fw:
	rcall	bdm_tx		; 0B in, 0B out
	rcall	wait_64E	; FW TRACE or GO cmd
	rjmp	command		; %
	;;
bdm_cmd_select:
	andi	r17,0xe0	; (opcode also in r16)
bdm_cmd_e0:
	cpi	r17,0xe0	; HW read command
	brne	bdm_cmd_c0
	rcall	pod_rx_word
	rcall	hw_read_cmd
	rcall	pod_tx_word
	rjmp	command		; %
	;;
bdm_cmd_c0:
	cpi	r17,0xc0	; HW write command
	brne	bdm_cmd_60
	rcall	pod_rx_word	; get address
	rcall	pod_rx		; get data
	mov	r22,r17
	rcall	pod_rx
	mov	r23,r17
	rcall	hw_write_cmd
	rjmp	command		; %
	;;
bdm_cmd_60:
	cpi	r17,0x60	; FW read command
	brne	bdm_cmd_40
	rcall	fw_read_cmd
	rcall	pod_tx_word
	rjmp	command		; %
	;;
bdm_cmd_40:
	cpi	r17,0x40	; FW write command
	brne	bdm_unknown_cmd
	rcall	pod_rx_word
	rcall	fw_write_cmd
	rjmp	command		; %
bdm_unknown_cmd:
	rjmp	unknown_cmd	; -
	;;
	;; bdm12 (pod) commands
	;;
pod_command:
pod_cmd_01:
	cpi	r17,BDM12_RESET
	brne	pod_cmd_02
	cbi	RST_P,RST_B	; /RESET low
	sbi	RST_DD,RST_B	; drive
	cbi	BDM_P,BDM_B	; BKGD low
	sbi	BDM_DD,BDM_B	; drive
      	ldi	r19,10		; wait 10ms
      	rcall	wait_n_ms
	cbi	RST_DD,RST_B	; high-Z (should be pulled up)
	lds	r19,RESET_COUNT ; wait RESET_COUNT ms
	tst	r19
	brne	pod_cmd_01_1	;; this delay must be at least 1ms
	inc	r19		;; -- with <<1ms delay some HC12's
pod_cmd_01_1:			;; haven't initialized properly
	rcall	wait_n_ms
	;;
pod_cmd_01_2:
	sbis	RST_I,RST_B	; [!] wait, if RESET pin is still low
	rjmp	pod_cmd_01_2	; [!]
	;;
	sbi	BDM_P,BDM_B	; BKGD high (!)
	cbi	BDM_DD,BDM_B	; BKGD high-Z
	rjmp	command		; %
	;;
pod_cmd_02:
	cpi	r17,BDM12_RESET_LO
	brne	pod_cmd_03
	cbi	RST_P,RST_B	; /RESET low
	sbi	RST_DD,RST_B	; drive
	rjmp	command		; %
	;;
pod_cmd_03:
	cpi	r17,BDM12_RESET_HI
	brne	pod_cmd_04
	cbi	RST_DD,RST_B	; high-Z (should be pulled up!)
	rjmp	command		; %
	;;
pod_cmd_04:
	cpi	r17,BDM12_EXT
	breq	pod_ext
pod_cmd_05:
	cpi	r17,BDM12_EE_WRITE
	brne	pod_cmd_06
	rcall	pod_rx		; wAddress
	mov	r10,r17
	rcall	pod_rx
	mov	r11,r17
	rcall	pod_rx		; wData
	mov	r12,r17
	rcall	pod_rx
	mov	r13,r17
	ldi	r16,READ_WORD	; read current content at addr.
	rcall	hw_read_cmd
	mov	r14,r22
	mov	r15,r23
	and	r22,r12		; do not erase, if new&old==new
	cp	r12,r22
	brne	pod_cmd_05_1
	and	r23,r13
	cp	r13,r23
	brne	pod_cmd_05_1	; not equal -> erase word
	eor	r12,r14		; new=~(new^old)
	com	r12
	eor	r13,r15
	com	r13
pod_cmd_05_1:
	ldi	r17,0x14	; EEPROG: BYTE,ERASE=1
	rcall	eeprom_write	; erase word in EEPROM
pod_cmd_05_2:
	ldi	r17,0x00	; EEPROG: programming
	rcall	eeprom_write	; program word from r12,r13
	rjmp	command		; %
	;;
pod_cmd_06:
	cpi	r17,BDM12_REGBASE
	brne	pod_cmd_07
	rcall	pod_rx		; get arg -- high part of addr
	sts	REG_BASE_HI,r17	; to variable
	rjmp	command		; %
	;;
pod_cmd_07:
	cpi	r17,BDM12_EE_ERASE
	brne	pod_cmd_00
	rcall	pod_rx		; wAddress
	mov	r10,r17
	rcall	pod_rx
	mov	r11,r17
	ldi	r17,0x04	; EEPROG: ERASE=1
	rcall	eeprom_write
	rjmp	command		; %
	;;
pod_cmd_00:
	cpi	r17,BDM12_SYNC
	brne	unknown_cmd
	;; sync -- do nothing :-)
	rjmp	command		; %
unknown_cmd:
	cbi	IO_PORT_P,LED_RED ; error
	rjmp	command_u	; %
	;;
	;; bdm12 extended commands
	;;
pod_ext:
	rcall	pod_rx		; get Extended command opcode
	cpi	r17,BDM12X_VERSION
	brne	pod_ext_01
	ldi	r17,0xc7	; version 4.7 with MODA/MODB lines
	rcall	pod_tx
	rjmp	command		; %
	;;
pod_ext_01:
	cpi	r17,BDM12X_REGDUMP
	brne	pod_ext_02
	ldi	r17,0x83	; packet: STATUS_BYTE | REGISTERS | PACKET_DONE
	rcall	pod_tx
	ldi	r16,READ_BD_BYTE ; read status
	ldi	r20,0xff	; STATUS address
	ldi	r21,0x01
	rcall	hw_read_cmd
	mov	r17,r23		; STATUS byte --> PC
	rcall	pod_tx
	rcall	reg_dump	; register dump --> PC
	rjmp	command		; %
	;;
pod_ext_02:
	;; ?!?!?!?!?!?!?!?!?!?!?
	;; I don't know, what does this output in original K.R.'s pod
	;; documentation is very ambiguous here
	;; ?!?!?!?!?!?!?!?!?!?!?
	cpi	r17,BDM12X_TRACETO
	brne	pod_ext_03_
	rcall	pod_rx		; bFlags
	mov	r15,r17		; ->r15
	rcall	pod_rx_word	; get address (or count)
	mov	r18,r20
	mov	r19,r21
	clr	r0		; clear counter (r3,r2,r1,r0)
	clr	r1
	clr	r2
	clr	r3
pod_ext_02_lp:
	ldi	r16,TRACE1	; TRACE1 FW cmd.
	rcall	bdm_tx
	rcall	wait_64E
	ldi	r16,1
	add	r0,r16		; ++(r3,r2,r1,r0)
	clr	r16
	adc	r1,r16
	adc	r2,r16
	adc	r3,r16
	ldi	r16,READ_PC	; READ_PC FW cmd.
	rcall	fw_read_cmd
	mov	r12,r22		; PC->(r12,r13)
	mov	r13,r23
	sbis	CTS_I,CTS_B	; CTS high = break
	rjmp	pod_ext_02_end
	mov	r16,r15
	andi	r16,0x04	; wait for count instead of addr.?
	brne	pod_ext_02_1
	cp	r13,r19		; PC == wAddr?
	cpc	r12,r18
	breq	pod_ext_02_end
	rjmp	pod_ext_02_2
	;; /* jump over...
pod_ext_03_:
	rjmp	pod_ext_03
	;; ... */
pod_ext_02_1:
	cp	r0,r19		; lo16(count) == wCount?
	cpc	r1,r18
	breq	pod_ext_02_end
pod_ext_02_2:
	ldi	r17,0x02	; prepare packet type REGDUMP, not final
	mov	r16,r15
	andi	r16,0x01	; reg.dump after each insn?
	brne	pod_ext_02_3
	mov	r16,r15
	andi	r16,0x08	; output PC after each insn?
	breq	pod_ext_02_lp
	ldi	r17,0x04	; packet: PC
	rcall	pod_tx
	mov	r17,r12
	rcall	pod_tx		; send PC
	mov	r17,r13
	rcall	pod_tx
	rjmp	pod_ext_02_lp
pod_ext_02_end:
	ldi	r17,0x82	; packet type REGDUMP, final
	mov	r16,r15
	andi	r16,0x02	; output insn count at the end?
	breq	pod_ext_02_3
	ori	r17,0x40	; add DWORD_VALUE to packet type
pod_ext_02_3:
	mov	r14,r17
	rcall	pod_tx		; send packet type
	rcall	reg_dump	; send reg.dump
	mov	r16,r14
	andi	r16,0x40	; output count?
	breq	pod_ext_02_4
	mov	r17,r0		; send count -- 32bit in little endian
	rcall	pod_tx
	mov	r17,r1
	rcall	pod_tx
	mov	r17,r2
	rcall	pod_tx
	mov	r17,r3
	rcall	pod_tx
pod_ext_02_4:
	mov	r16,r14
	andi	r16,0x80	; end of trace?
	breq	pod_ext_02_lp
	;; ?!? -----------------
	rjmp	command		; %
	;;
pod_ext_03:
	cpi	r17,BDM12X_MEMDUMP
	brne	pod_ext_04
	rcall	pod_rx_addrcount
	brlo	pod_ext_03_0	; wCount was 0 (should not happen)
pod_ext_03_lp:
	ldi	r16,READ_WORD
	rcall	hw_read_cmd	; read mem(wAddress)
	rcall	pod_tx_word	; send to PC
	ldi	r25,2
	ldi	r24,0
	add	r21,r25		; wAddress += 2
	adc	r20,r24
	subi	r19,1
	brsh	pod_ext_03_lp
	subi	r18,1
	brsh	pod_ext_03_lp
pod_ext_03_0:
	rjmp	command		; %
	;;
pod_ext_04:
	cpi	r17,BDM12X_PARAM
	brne	pod_ext_05
	rcall	pod_rx		; bECLOCK
	sts	SPEED,r17
	cpi	r17,BDM12SPEED_X
	breq	pod_ext_04_x	; ExtendedSpeed
	clr	r21
pod_ext_04_1:
	cpi	r17,BDM12SPEED_1
	brne	pod_ext_04_2
	ldi	r20,(1280/1-14)/8 ; 1MHz
	rjmp	pod_ext_04_s
pod_ext_04_2:
	cpi	r17,BDM12SPEED_2
	brne	pod_ext_04_4
	ldi	r20,(1280/2-14)/8 ; 2MHz
	rjmp	pod_ext_04_s
pod_ext_04_4:
	cpi	r17,BDM12SPEED_4
	brne	pod_ext_04_8
	ldi	r20,(1280/4-14)/8 ; 4MHz
	rjmp	pod_ext_04_s
pod_ext_04_8:
	cpi	r17,BDM12SPEED_8
	brne	pod_ext_04_x	; [!] (error)
	ldi	r20,(1280/8-14)/8 ; 8MHz
	rjmp	pod_ext_04_s
pod_ext_04_x:
	lds	r20,XSPEED_LO
	lds	r21,XSPEED_HI
pod_ext_04_s:
	rcall	set_speed	; set delay consts.
	rcall	pod_rx		; bPaceCount
	sts	PACE_COUNT,r17
	rcall	pod_rx		; bResetCount
	sts	RESET_COUNT,r17
	rjmp	command		; %
	;;
pod_ext_05:
	cpi	r17,BDM12X_IOCTL
	brne	pod_ext_06
	rcall	pod_rx		; bLineControl
	out	IO_PORT_P,r17
	ser	r17
	out	IO_PORT_D,r17	; all bits as output
	rjmp	command		; %
	;;
pod_ext_06:
	cpi	r17,BDM12X_MEMPUT
	brne	pod_ext_07
	rcall	pod_rx_addrcount
	brlo	pod_ext_06_0	; wCount was 0 (should not happen)
pod_ext_06_lp:
	ldi	r16,WRITE_WORD
	rcall	pod_rx
	mov	r22,r17
	rcall	pod_rx
	mov	r23,r17		; get word to r22:r23
	rcall	hw_write_cmd	; write to mem(wAddress)
	ldi	r25,2
	ldi	r24,0
	add	r21,r25		; wAddress += 2
	adc	r20,r24
	subi	r19,1		; decrement wCount-er
	brsh	pod_ext_06_lp
	subi	r18,1
	brsh	pod_ext_06_lp	; cycle...
pod_ext_06_0:
	rjmp	command		; %
	;;
pod_ext_07:
	cpi	r17,BDM12X_XSPEED
	brne	ext_unknown_cmd
	rcall	pod_rx		; bEClockScalar -- ignore, compute everything from w128EClocks
	rcall	pod_rx_word	; w128EClocks
	sts	XSPEED_LO,r21	; big endian
	sts	XSPEED_HI,r20	; but not really sure
	lds	r17,SPEED	; is ExtendedSpeed currently in use?
	cp	r17,BDM12SPEED_X
	brne	pod_ext_07_0
	rcall	set_speed	; yes -> set parameters
pod_ext_07_0:
	rjmp	command		; %
	;;
ext_unknown_cmd:
	rjmp	unknown_cmd	; -
	;;


	;;
	;; register dump BDM-->PC
	;; assumes firmware enabled
	;;
reg_dump:
	ldi	r20,READ_PC	; first FW read opcode
reg_dump_lp:
	mov	r16,r20		; opcode
	rcall	fw_read_cmd
	rcall	pod_tx_word
	inc	r20		; next register opcode
	cpi	r20,(READ_SP+1)
	brlo	reg_dump_lp
	;;
	ldi	r16,READ_BD_BYTE
	ldi	r20,0xff	; from 0xff06 -- CCR save
	ldi	r21,0x06
	rcall	hw_read_cmd
	mov	r17,r22		; 1st byte is CCR
	rcall	pod_tx
	ret


	;;
	;; read wAddress, wCount from PC
	;; wAddress-->r20:r21, (wCount-1)-->r18:r19
	;;
pod_rx_addrcount:
	rcall	pod_rx_word	; wAddress-->r20:r21
	rcall	pod_rx
	mov	r18,r17
	rcall	pod_rx
	mov	r19,r17		; wCount-->r18:r19
	subi	r19,1		; wCount--
	sbci	r18,0
	ret


	;;
	;; EEPROM erase/program
	;;
	;; r17:	initial EEPROG value (EELAT,EEPGM=0)
	;; r10,r11: address, r12,r13: data
	;;
eeprom_write:
	mov	r22,r17
	ori	r22,0x02	; EELAT=1
	rcall	set_eeprog
	ldi	r16,WRITE_WORD
	mov	r20,r10		; addr.
	mov	r21,r11
	mov	r22,r12		; data
	mov	r23,r13
	rcall	hw_write_cmd
	mov	r22,r17
	ori	r22,0x03	; EEPGM=1
	rcall	set_eeprog
	ldi	r19,10		; wait t_ERAS=10ms
	rcall	wait_n_ms
	mov	r22,r17
	ori	r22,0x02	; EEPGM=0
	rcall	set_eeprog
	mov	r22,r17		; EELAT=0
	rcall	set_eeprog
	ret


	;;
	;; set value from r22 to EEPROG HC12 register
	;;
set_eeprog:
	ldi	r16,WRITE_BYTE
	lds	r20,REG_BASE_HI
	ldi	r21,EEPROG
	mov	r23,r22
	rcall	hw_write_cmd
	ret


	;;
	;; set timing constants for given EClock rate
	;;
	;; r21:r20 = w128EClocks
	;;
set_speed:
	mov	r10,r20
	mov	r11,r21
	clr	r12
	lsl	r10
	rol	r11
	rol	r12
	lsl	r10
	rol	r11
	rol	r12		; (r12,r11,r10) = 4*w128EClocks
	clr	r0
	ldi	r19,7
	add	r10,r19
	adc	r11,r0
	adc	r12,r0		; (r12,r11,r10) = 4*w128EClocks+7
	ldi	r19,POD_XTAL640_A
	mov	r9,r19
	rcall	mul24u8
	mov	r10,r0
	mov	r11,r1
	mov	r12,r2		; (r12,r11,r10) = K = A*(4*w128EClocks+7)
	;;
	;; 8bit constants
	;;
	ldi	r16,(3*POD_XTAL640_B)%0x100
	mov	r3,r16
	ldi	r17,((3*POD_XTAL640_B)/0x100)%0x100
	mov	r4,r17
	ldi	r18,(3*POD_XTAL640_B)/0x10000 ; (r18,r17,r16) = D = 3*POD_XTAL640_B
	mov	r5,r18		; (r5,r4,r3) = B = 3*POD_XTAL640_B
	;; 6E ~ 3*n + 3
	ldi	r19,6
	rcall	comp_delay
	sts	WAIT_BDMRX_6E3,r6
	;; 6E ~ 3*n - 1 (!) ~ 3*n' + 2
	ldi	r16,(2*POD_XTAL640_B)%0x100
	ldi	r17,(2*POD_XTAL640_B)/0x100 ; (r18,r17,r16) = D = 2*POD_XTAL640_B
	ldi	r19,6
	rcall	comp_delay
	inc	r6		; n = n' + 1
	sts	WAIT_BDMRX_6E2,r6
	;;
	ldi	r16,POD_XTAL640_B%0x100
	ldi	r17,POD_XTAL640_B/0x100
	clr	r18		; (r18,r17,r16) = D = 1*POD_XTAL640_B
	;; 4E ~ 3*n + 1
	ldi	r19,4
	rcall	comp_delay
	sts	WAIT_BDMRX_4E1,r6
	sts	WAIT_BDMTX_4E1,r6
	;; 9E ~ 3*n + 1
	ldi	r19,9
	rcall	comp_delay
	sts	WAIT_BDMTX_9E2,r6
	;; 3E ~ 3*n + 1
	ldi	r19,3
	rcall	comp_delay
	sts	WAIT_BDMTX_3E3,r6
	;;
	;; 16bit constants
	;;
	add	r3,r16		; B += D
	adc	r4,r17
	adc	r5,r18		; (r5,r4,r3) = B = 4*POD_XTAL640_B
	ldi	r16,(16*POD_XTAL640_B)%0x100
	ldi	r17,((16*POD_XTAL640_B)/0x100)%0x100
	ldi	r18,(16*POD_XTAL640_B)/0x10000 ; (r18,r17,r16) = D = 16*POD_XTAL640_B
	;; 150E ~ 4*n + 16
	ldi	r19,150
	rcall	comp_delay
	sts	WAIT_150E_LO,r6
	sts	WAIT_150E_HI,r7
	;; 64E ~ 4*n + 16
	ldi	r19,64
	rcall	comp_delay
	sts	WAIT_64E_LO,r6
	sts	WAIT_64E_HI,r7
	;; 32E ~ 4*n + 16
	ldi	r19,32
	rcall	comp_delay
	sts	WAIT_32E_LO,r6
	sts	WAIT_32E_HI,r7
	ret
	;;
	;; compute delay loop length
	;;
	;; (r12,r11,r10) = K = A*(4*w128EClocks+7)
	;; (r18,r17,r16) = D, r19 = E, (r5,r4,r3) = B
	;;
	;; (r8,r7,r6) = round((K*E - D)/B)
	;;
	;; (affects ...)
	;;
comp_delay:
	mov	r9,r19
	rcall	mul24u8		; (r2,r1,r0) = K*E
	sub	r0,r16
	sbc	r1,r17
	sbc	r2,r18		; (r2,r1,r0) = K*E - D
	mov	r6,r3
	mov	r7,r4
	mov	r8,r5
	lsr	r8
	ror	r7
	ror	r6		; (r8,r7,r6) = B>>1
	add	r0,r6
	adc	r1,r7
	adc	r2,r8		; (r2,r1,r0) = K*E - D + B/2
	rcall	div24u		; (r8,r7,r6) = round((K*E - D)/B)
	ret

	;; ---------------------

	;;
	;; HW read cmd (r17 ~ 0xe4, 0xec, 0xe0, 0xe8)
	;; 2B in (r20:r21), 150E w8, 2B out (r22:r23)
	;;
hw_read_cmd:
	rcall	bdm_tx		; opcode (r16)
	mov	r16,r20		; write address
	rcall	bdm_tx
	mov	r16,r21
	rcall	bdm_tx
	rcall	wait_150E
	rcall	bdm_rx
	mov	r22,r16		; read data
	rcall	bdm_rx
	mov	r23,r16
	ret


	;;
	;; HW write cmd (r17 ~ 0xc4, 0xcc, 0xc0, 0xc8)
	;; 4B in (r20:r21:r22:r23), 150E w8, 0B out
	;;
hw_write_cmd:
	rcall	bdm_tx		; opcode (r16)
	mov	r16,r20		; write address
	rcall	bdm_tx
	mov	r16,r21
	rcall	bdm_tx
	mov	r16,r22		; write data
	rcall	bdm_tx
	mov	r16,r23
	rcall	bdm_tx
	rcall	wait_150E
	ret


	;;
	;; FW read cmd (r17 ~ 0x62..0x67)
	;; 0B in, 32E w8, 2B out (r22:r23)
	;;
fw_read_cmd:
	rcall	bdm_tx		; opcode (r16)
	rcall	wait_32E
	rcall	bdm_rx
	mov	r22,r16		; read data
	rcall	bdm_rx
	mov	r23,r16
	ret


	;;
	;; FW write cmd (r17 ~ 0x42..0x47)
	;; 2B in (r20:r21), 32E w8, 0B out
	;;
fw_write_cmd:
	rcall	bdm_tx		; opcode (r16)
	mov	r16,r20		; write data
	rcall	bdm_tx
	mov	r16,r21
	rcall	bdm_tx
	rcall	wait_32E
	ret

	;; ---------------------

	;;
	;; receive word from PC to r20:r21
	;;
pod_rx_word:
	rcall	pod_rx
	mov	r20,r17
	rcall	pod_rx
	mov	r21,r17
	ret

	;;
	;; send word from r22:r23 to PC
	;;
pod_tx_word:
	mov	r17,r22
	rcall	pod_tx
	mov	r17,r23
	rcall	pod_tx
	ret

	;; DEBUG
.equ	pod_rx,	pod_rx__
;  .equ	pod_rx,	pod_rx_dbg

	;;
pod_rx_abort:
	sbi	RTS_P,RTS_B	; lower RTS and wait for input again
	;;
	;; receive a byte from RS232 with RTS/CTS handshaking
	;; according to Kevin Ross' protocol
	;;
pod_rx__:
pod_rx_cts_1:
	sbic	CTS_I,CTS_B	; wait for CTS (PC RTS) high
	rjmp	pod_rx_cts_1
	cbi	RTS_P,RTS_B	; raise RTS (PC CTS)
pod_rx_rxc:
	sbic	CTS_I,CTS_B
	rjmp	pod_rx_abort	; if CTS went low, abort waiting for char
	sbis	USR,RXC		; wait for char from UART
	rjmp	pod_rx_rxc
	in	r17,UDR		; received char->r17
	sbi	RTS_P,RTS_B	; lower RTS (PC CTS)
pod_rx_cts_0:
	sbis	CTS_I,CTS_B	; wait for CTS (PC RTS) low
	rjmp	pod_rx_cts_0	; for PC to acknowlegde
	ret


	;;
	;; receive a byte from UART to r17
	;;
pod_rx_dbg:
p_r_d_wait_rxc:
	sbis	USR,RXC		; wait for received char
	rjmp	p_r_d_wait_rxc
	in	r17,UDR		; received char->r17
	ret


	;;
	;; send a byte from r17 to UART
	;;
pod_tx:
pod_tx_udre:
	sbis	USR,UDRE	; wait for not busy
	rjmp	pod_tx_udre
	out	UDR,r17		; transmit r17
	ret


	;;
	;; send a byte from R16 to BDM
	;;
bdm_tx:
	ldi	r24,8		; 8 bits
bdm_tx_loop:
	rol	r16		; highest bit->C
	rcall	bdm_tx_bit	; send C
	dec	r24
	brne	bdm_tx_loop
	ret


	;;
	;; receive a byte from BDM to R16
	;;
bdm_rx:
	ldi	r24,8		; 8 bits
bdm_rx_loop:
	rcall	bdm_rx_bit	; read bit->C
	rol	r16		; C->lowest bit
	dec	r24
	brne	bdm_rx_loop
	ret


	;;
	;; send a bit from C flag to BDM
	;;
bdm_tx_bit:
	lds	r13,WAIT_BDMTX_4E1
	lds	r14,WAIT_BDMTX_9E2
	lds	r15,WAIT_BDMTX_3E3
	sbi	BDM_DD,BDM_B	; drive
	brcs	bdm_tx_bit_1
bdm_tx_bit_0:
	cbi	BDM_P,BDM_B	; BDM=0
bdm_tx_bit_0lp1:
	dec	r13
	brne	bdm_tx_bit_0lp1
	rjmp	bdm_tx_bit_2
bdm_tx_bit_1:
	cbi	BDM_P,BDM_B	; BDM=0
bdm_tx_bit_1lp1:
	dec	r13
	brne	bdm_tx_bit_1lp1
	sbi	BDM_P,BDM_B	; BDM=1
	;; 4E ~ (r13*3 + 1)T
bdm_tx_bit_2:
bdm_tx_bit_lp2:
	dec	r14
	brne	bdm_tx_bit_lp2
	sbi	BDM_P,BDM_B	; (BDM=1)
	;; 9E ~ (r14*3 + 1)T
bdm_tx_bit_lp3:
	dec	r15
	brne	bdm_tx_bit_lp3
	cbi	BDM_DD,BDM_B	; ?!?!
	;; 3E ~ (r15*3 + 1)T
	ret


	;;
	;; receive a bit from BDM to C flag
	;;
bdm_rx_bit:
	lds	r13,WAIT_BDMRX_4E1
	lds	r14,WAIT_BDMRX_6E2
	lds	r15,WAIT_BDMRX_6E3
	clc
	sbi	BDM_DD,BDM_B	; drive
	cbi	BDM_P,BDM_B	; BDM=0
bdm_rx_bit_lp1:
	dec	r13
	brne	bdm_rx_bit_lp1
	cbi	BDM_DD,BDM_B	; high-Z
	;; 4E ~ (r13*3 + 1)T
bdm_rx_bit_lp2:
	dec	r14
	brne	bdm_rx_bit_lp2
	;; 6E ~ (r14*3 - 1)T
	sbic	BDM_I,BDM_B	; read bit
	sec
bdm_rx_bit_lp3:
	dec	r15
	brne	bdm_rx_bit_lp3
	sbi	BDM_P,BDM_B	; (BDM=1)
	;; 6E ~ (r15*3 + 3)T
	ret


	;;
	;; command execution delays
	;;
	;; rcall+2xlds+rjmp+wait_loop ~ (N*4+16)T
	;;
wait_150E:
	lds	r24,WAIT_150E_LO
	lds	r25,WAIT_150E_HI
	rjmp	wait_loop
wait_64E:
	lds	r24,WAIT_64E_LO
	lds	r25,WAIT_64E_HI
	rjmp	wait_loop
wait_32E:
	lds	r24,WAIT_32E_LO
	lds	r25,WAIT_32E_HI
	rjmp	wait_loop
	;;
	;; r19*1ms delay
	;;
wait_n_ms_loop:			; !!!!prepocitat cykly WAIT_1MS
	rcall	wait_1ms
wait_n_ms:
	subi	r19,1
	brsh	wait_n_ms_loop
	ret
	;;
	;; 1ms delay
	;;
wait_1ms:
	ldi	r24,WAIT_1MS%0x100
	ldi	r25,WAIT_1MS/0x100
	;;
	;; 16bit wait loop
	;; ((256*r25+r24)*4+7)T
	;;
wait_loop:
	subi	r24,1
	sbci	r25,0
	brsh	wait_loop
	ret


	;;
	;; 24bit*8bit unsigned multiplication
	;;
	;;     C      =      A       * B
	;; (r2,r1,r0) = (r12,r11,r10)*r9
	;;
	;; (clears r9, r19)
	;;
mul24u8:
	clr	r0		; C=0
	clr	r1
	clr	r2
	ldi	r19,8		; N=8
mul24u8_1:
	lsl	r9		; B<<1
	brcc	mul24u8_2
	add	r0,r10		; C+=A
	adc	r1,r11
	adc	r2,r12
mul24u8_2:
	dec	r19		; --N
	breq	mul24u8_3
	lsl	r0		; C<<1
	rol	r1
	rol	r2
	rjmp	mul24u8_1
mul24u8_3:
	ret


	;;
	;; 24bit/24bit unsigned division
	;;
	;;     C      =      A    /    B
	;; (r8,r7,r6) = (r2,r1,r0)/(r5,r4,r3),
	;; (r2,r1,r0) = (r2,r1,r0)%(r5,r4,r3)
	;;
	;; (clears r15)
	;;
div24u:
	clr	r6		; C=0
	clr	r7
	clr	r8
	clr	r15		; N=0
div24u_1:
	inc	r15		; ++N
	lsl	r3		; B<<1
	rol	r4
	rol	r5
	brcs	div24u_2
	cp	r0,r3		; A>=B?
	cpc	r1,r4
	cpc	r2,r5
	brsh	div24u_1
	clc
div24u_2:
	ror	r5		; B>>1
	ror	r4
	ror	r3
	cp	r0,r3		; A<B?
	cpc	r1,r4
	cpc	r2,r5
	brlo	div24u_3
	sub	r0,r3		; A-=B
	sbc	r1,r4
	sbc	r2,r5
	inc	r6		; (!) C|=1
div24u_3:
	dec	r15		; --N
	breq	div24u_4
	lsl	r6		; C<<1
	rol	r7
	rol	r8
	rjmp	div24u_2
div24u_4:
	ret


	.end

;; ***********
;; * KOHE||, *
;; ***********
