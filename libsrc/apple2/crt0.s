;
; Startup code for cc65 (Apple2 version)
;
; This must be the *first* file on the linker command line
;

	.export		_exit
	.import	   	initlib, donelib
	.import	   	zerobss, push0
       	.import	       	__STARTUP_LOAD__, __BSS_LOAD__	; Linker generated
	.import		callmain

        .include        "zeropage.inc"
	.include	"apple2.inc"

; ------------------------------------------------------------------------
; The executable header

.segment	"EXEHDR"

       	.word  	__STARTUP_LOAD__                ; Start address
       	.word  	__BSS_LOAD__ - __STARTUP_LOAD__	; Size

; ------------------------------------------------------------------------
; Create an empty LOWCODE segment to avoid linker warnings

.segment        "LOWCODE"

; ------------------------------------------------------------------------
; Place the startup code in a special segment.

.segment       	"STARTUP"

       	ldx	#zpspace-1
L1:	lda	sp,x
   	sta	zpsave,x    	; Save the zero page locations we need
	dex
       	bpl	L1

; Clear the BSS data

	jsr	zerobss

; Save system stuff and setup the stack

       	tsx
       	stx    	spsave 	    	; Save the system stack ptr

	lda    	MEMSIZE
	sta	sp
	lda	MEMSIZE+1
       	sta	sp+1   	    	; Set argument stack ptr

; Call module constructors

	jsr	initlib

; Initialize conio stuff

	lda	#$ff
	sta	TEXTTYP

; Set up to use Apple ROM $C000-$CFFF

	;; 	sta    	USEROM

; Push arguments and call main()

	jsr	callmain

; Call module destructors. This is also the _exit entry.

_exit:	jsr	donelib

; Restore system stuff

	lda	#$ff  	    	; Reset text mode
	sta	TEXTTYP

	ldx	spsave
	txs	       		; Restore stack pointer

; Copy back the zero page stuff

	ldx	#zpspace-1
L2:	lda	zpsave,x
	sta	sp,x
	dex
       	bpl	L2

; Reset changed vectors, back to basic

	jmp	RESTOR

; ------------------------------------------------------------------------
; Data

.data

zpsave:	.res	zpspace

.bss

spsave:	.res	1
