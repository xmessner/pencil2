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
        defb "DEV!** SPRITE ANIMATION **!2019"

        defs 25,0

ramtop:         equ $7050
VBlankFlag:     equ     $7320           ; VBlank flag
spriteX:	equ	$7400

include "../../common/tms.asm"

start:
	ld	($7000),sp
	ld      sp, ramtop
	call    tmsbitmap

; bc : taille des sprites
; de : adresse vdp pour le patron
; hl : adresse du sprite
	ld      bc, spritelen
	ld      de, $1800
	ld      hl, sprite
	call    tmswrite

	call    tmsintenable            ; enable interrupts on TMS
	call    drawSprite               ; draw next frame, if it's time


mainloop:
	ld a,(spriteX)
	inc a
	ld (spriteX),a
	call	waitVbl
	; Change les coordonnées
	ld	de,$3b00
	ld	bc,1
	ld	hl,spriteX
	call	tmswrite
	jr      mainloop                ; busy wait and let interrupts do their thing

waitVbl:
        ld      a,(VBlankFlag)
        or      a
        jr      z,waitVbl
        xor     a
        ld      (VBlankFlag),a
        ret

inthandler:
	push	af
	in      a, (tmsreg)             ; clear interrupt flag
        ld      a,1                     ; the only interrupt enabled is VBlank so...
        ld      (VBlankFlag),a	
	pop	af
	ei
	reti

; hl : adresse des attributs de sprites
; bc : 4 données / sprites * nb sprites. MAX 128 (32*4)
; de : vdp adress en fonction du mode graphique
drawSprite:
	ld      bc, 4
	ld      de, $3b00
	ld      hl, SprAttrib
	call    tmswrite
	ret

SprAttrib:
	db 52, 0,0,11 ; Y=82, X= 24, Pattern#0, Color=13
	
sprite:
        db %00000110
        db %00101001
        db %00000000
        db %01001000
        db %00010001
        db %00000001
        db %00000111
	db %00001111

	db %00001110
	db %00011111
	db %00011111
	db %00001111
	db %00001111
	db %00000111
	db %00000011
	db %00000000

	db %00000000
	db %00000000
	db %10000000
	db %01000000
	db %11110000
	db %11110000
	db %11111100
	db %11111110

	db %11111110
	db %11111111
	db %11111111
	db %11101110
	db %11101110
	db %11011100
	db %11111000
	db %11100000

spritelen: equ $-sprite
