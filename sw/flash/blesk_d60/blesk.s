	;;
	;; programovani interni FLASH pro 68HC912D60A
	;; blok 32KB
	;; 

.equ	FEECTL,	0xf7		; FEECTL32

	;;
	.data
	.org	0x800

start:	
	;;
	;; promenne bdm12_eraseflash.h a bdm12_programflash.h
	;; 
BDM12_ERASEFLASH_FLASHSTART:
BDM12_PROGRAMFLASH_FLASHSTART:	
DEST_ADDR:	.word	0x8000

BDM12_PROGRAMFLASH_FLASHEND:
END_ADDR:	.word	0x8002

BDM12_PROGRAMFLASH_DATASTART:
BUFFER_ADDR:	.word	0x900

BDM12_ERASEFLASH_ERRORFLAG:
ERROR_FLAG:
		.byte	1

BDM12_PROGRAMFLASH_NUMWRITTEN:
NUM_WRITTEN:
		.word	0

BDM12_ERASEFLASH_REGSTART:
BDM12_PROGRAMFLASH_REGSTART:
REG_START:	.word	0	; !!!#!#ZATIM IGNORUJI#!#
	;;
	;; 
COUNT:		.word	0
FLASH_LEN:	.word	0x8000
COUNT_B:	.word	0

T_SHRT:		.word	-8
T_NVH:		.word	-80
T_FPGM:		.word	-24

TMP:		.word	0
	;;
	;; 

	.text

	;; 
BDM12_ERASEFLASH_PROGSTART:
	;; DBG
	;; 
	;; *
	;; * mazani FLASH
	;; *
	;; 
erase_flash:
	movb	#0x2, FEECTL	; ERAS=1
	movw	#0xffff, 0x8000	; zapsat cokoli do prostoru programovane FLASH
	;;
	;; pockat t_NVS
	;; 
	ldd	T_SHRT
wait_nvs0:
	addd	#0x1
	bne	wait_nvs0
	;; 
	movb	#0xa, FEECTL	; HVEN=1, ERAS=1
	;;
	;; pockat t_ERAS
	;; 
	movb	0x50, TMP
wait_eras1:	
	ldd	T_NVH
wait_eras2:	
	addd	#0x1
	bne	wait_eras2
	dec	TMP
	bne	wait_eras1
	;; 
	movb	#0x8, FEECTL	; ERAS=0, HVEN=1
	;;
	;; pockat t_NVHL
	;; 
	ldd	T_NVH
wait_nvhl:	
	addd	#0x1
	bne	wait_nvhl
	;; 
	movb	#0, FEECTL	; HVEN=0
	;;
	;; pockat t_RCV
	;; 
	ldd	T_SHRT
wait_rcv0:	
	addd	#0x1
	bne	wait_rcv0
	;; 
	;; kontrola smazani
	;;
	ldy	#0x8000
erase_verify:
    	ldd	#0xffff
    	cpd	2,Y+
    	beq	erase_verify_next
    	movb	#3, ERROR_FLAG		; chyba :-(
    	bgnd
erase_verify_next:
  	ldd	FLASH_LEN
  	subd	#0x2
  	std	FLASH_LEN
  	bne	erase_verify
	movb	#0, ERROR_FLAG		; povedlo se :-)
  	bgnd

	
	;; 
BDM12_PROGRAMFLASH_PROGSTART:
	;;
	ldd	END_ADDR
	subd	DEST_ADDR	; D=(FLASHEND-FLASHSTART)
	;; #!#PRASARNA-OSETRIT!
	addd	#1
	andb	#0xfe
	;; #!#----------------!
	std	COUNT
	std	COUNT_B
	ldx	BUFFER_ADDR
	ldy	DEST_ADDR
	;; 
	;; *
	;; * zapis do FLASH
	;; *
	;; arg: COUNT..pocet bajtu, Y..cilova adresa, X..zdrojova adresa
	;; ((vraci: D..0=OK, -1=KO))
	;; 
pgm_row:
	movb	#0x1, FEECTL	; PGM=1
	movw	#0xffff, 0,Y	; vyber prave programovaneho radku
	;;
	;; pockat t_NVS
	;; 
	ldd	T_SHRT
wait_nvs1:	
	addd	#0x1
	bne	wait_nvs1
	;; 
	movb	#0x9, FEECTL	; HVEN=1, PGM=1
	;;
	;; pockat t_PGS
	;; 
	ldd	T_SHRT
wait_pgs:	
	addd	#0x1
	bne	wait_pgs
	;;
pgm_word:	
	ldd	2,X+		; precti slovo z bufferu
	std	2,Y+		; zapis do FLASH
	;;
	;; pockat t_FPGM
	;; 
	ldd	T_FPGM
wait_fpgm:	
	addd	#0x1
	bne	wait_fpgm
	;; 
	ldd	COUNT
	subd	#0x2		; pocet zbyvajicich bajtu -= 2
	std	COUNT
	beq	end_of_pgm	; == 0 ?
	;; 
	tfr	Y,D
	andb	#0x3f		; konec radku?
	bne	pgm_word
end_of_pgm:	
	movb	#0x8, FEECTL	; PGM=0, HVEN=1
	;;
	;; pockat t_NVH
	;; 
	ldd	T_SHRT
wait_nvh:	
	addd	#0x1
	bne	wait_nvh
	;; 
	movb	#0x0, FEECTL	; HVEN=0
	;;
	;; pockat t_RCV
	;; 
	ldd	T_SHRT
wait_rcv1:	
	addd	#0x1
	bne	wait_rcv1
	;; 
	ldd	COUNT		; pocet nezapsanych bajtu
	bne	pgm_row		; != 0 --> pokracuj dalsim radkem
	;; 
	ldx	BUFFER_ADDR
	ldy	DEST_ADDR
	movw	COUNT_B, COUNT
verify:	
	ldd	2,X+		; precti slovo z bufferu
	cpd	2,Y+		; porovnej se slovem ve FLASHi
;  	bne	verify_error
	ldd	COUNT
	subd	#0x2		; pocet bajtu -= 2
	std	COUNT
	beq	pgm_quit	; == 0? --> konec, vrat 0
	bra	verify
verify_error:
pgm_quit:
	ldd	COUNT_B
  	subd	COUNT
	std	NUM_WRITTEN
	bgnd
	;;
	;;


initialize:
;  	movb	#0x19, 0x000b	; Special Single Chip Mode
;  	movb	#0x00, 0x0016	; Turn off watchdog (COPCTL)
	movb	#0x00, FEECTL	; Turn off feectl
	movb	#0x00, 0x00f4	; Turn off lock bit in feelck
	movb	#0x00, 0x00f5	; Allow writes in protected block, feemcr
	;; #!#
	;; vypocet casovych konstant pro 8MHz CPU
	;; #!#
	ldx	#8		; neco
	;; 
	;; *
	;; * vypocet casovych konstant
	;; *
	;; arg:	X..neco
	;; zapisuje T_FPGM, T_SHRT, T_NVH
	;; 
calc_delay:
	tfr	X,D
	std	TMP
	asld
	addd	TMP		; D=3*X
	bsr	neg_d
	std	T_FPGM		; uloz -3*X
	tfr	X,D
	bsr	neg_d
	std	T_SHRT		; uloz -X
	tfr	X,D
	asld
	std	TMP		; 2*X
	asld
	asld
	addd	TMP		; D=10*X
	bsr	neg_d
	std	T_NVH		; uloz -10*X
	clr	FEECTL
	ldd	#0x0
	rts
	;; 

	;;
	;; NEG D
	;; 
neg_d:				; D = -D
	comb
	coma
	addd	#0x1
	rts

end:	
	;; 
	;; KONEC
	;; 

	.end
