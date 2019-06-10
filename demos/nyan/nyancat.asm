;
; code:			Adapted for the Hanimex Pencil II Computer by MESSNER Xavier.
; nyan gfx & code:	J.B Langston (https://github.com/jblang/TMS9918A)
; vdp code:		J.B Langston (https://github.com/jblang/TMS9918A)
; psg code: psglib:	sverx (https://github.com/sverx/PSGlib.git)
; VGM SN76489 Music:	MESSNER Xavier using Deflemask (Nyan Cat c64 version / Remix bu littlelamp100)
; tools:
;   vgm2psg / psgcomp
;   z80asm

        ;Header d'une cartouche Pencil II
        org $8000
        ; COPYRIGHT SOUNDIC
        defb "COPYRIGHT SOUNDIC"        ;8000 - 8010
        ; Point d'entrée du lancement du programme sur la cartouche
        jp start                        ;8011 - 8013

        ; $66 -> 8014 NMI               ;8014
        jp inthandler                   ;3 8014 - 8016
        ; Remplissage du vide, trouver à quoi cela correspond
        ; Sur la cartouche SD Basic, plusieurs JP à certaines adresses
        ;defs 32,0
        ; 8017
        defs 29,0 

        ; 8034 - 804C
        ; VERSION!TITRE!DATE (C)
        defb "1.0!** NYAN CAT **!2019"

        defs 25,0


frameticks:	equ	3		; number of interrupts per animation frame
framecount:	equ	12		; number of frames in animation
tickcounter:	equ	$7100
currframe:	equ	$7400

ramtop:		equ	$7050
ptrvgm:		equ	$7200
count:		equ	$7205
toplay:		equ	$7203

VBlankFlag:	equ	$7320		; VBlank flag
MaxVCount:	equ	$7321

include "tms.asm"
include "psgmin.asm"

inthandler:
	push	af
	in	a,(tmsreg)		; read port to satisfy interrupt
	ld	a,1			; the only interrupt enabled is VBlank so...
	ld	(VBlankFlag),a		;   ... write down that it actually happened
	pop	af
	ei				; enable interrupt (that were disabled by the IRQ call)
	reti				; return from interrupt

waitForVBlank:
	ld	a,(VBlankFlag)
	or	a
	jr	z,waitForVBlank
	xor	a
	ld	(VBlankFlag),a
	ret


start:
	ld	($7000),sp		; save old stack poitner
	ld	sp, ramtop		; set up stack

	call	$505			; TURN_OFF_SOUND

	call	tmsmulticolor		; initialize tms for multicolor mode
	ld	a, tmsdarkblue		; set background color
	call	tmsbackground

	ld	a, frameticks		; initialize interrupt counter to frame length
	ld	(tickcounter), a

	call	PSGInit			; better do that before activating interrupts ;)
	call	tmsintenable

	ld	hl,theMusic
	call	PSGPlay

_loopVBL:
;	ld	a, tmsdarkred		; set background color
;	call	tmsbackground
	call	PSGFrame		; process next music frame

;	ld	a, tmsdarkred		; set background color
;	call	tmsbackground
	call	drawframe 

;	ld	a, tmsgray		; set background color
;	call	tmsbackground
	call	waitForVBlank		; wait for vertical blanking

	jp	_loopVBL

drawframe:
	ld	a, (tickcounter)	; check if we've been called frameticks times
	or	a
	jr	nz, framewait		; if not, wait to draw next animation frame
	ld	hl, animation		; draw the current frame
	ld	a, (currframe)		; calculate offset for current frame
	ld	d, a			; x 1
	add	a, d			; x 2
	add	a, d			; x 3
	add	a, a			; x 6
	ld	d, a			; offset = frame x 600h
	ld	e, 0
	add	hl, de			; add offset to base address
	ld	de, $0000		; pattern table address in vram
	ld	bc, $0500		; $500 is the max for one VBL. More slow down the music
	;ld	bc, $0600		; length of one frame (original)
	call	tmswrite		; copy frame to pattern table
	ld	a, (currframe)		; next animation frame
	inc	a
	cp	framecount		; have we displayed all frames yet?
	jr	nz, skipreset		; if not, display the next frame
	ld	a, 0			; if so, start over at the first frame
skipreset:
	ld	(currframe), a		; save next frame in memory
	ld	a, frameticks		; reset interrupt down counter
	ld	(tickcounter), a
	ret
framewait:
	ld	hl, tickcounter		; not time to switch animation frames yet
	dec	(hl)			; decrement down counter
	ret

theMusic:
	incbin	"nyan.psgc"
animation:
	incbin	"nyan/nyan.bin"
