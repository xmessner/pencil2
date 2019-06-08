; Colecovision - Sprite Tests, by F-Cycles

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
        defb "DEV!** 48 SPRITES **!2019"

        defs 25,0

ramtop:         equ $7050
sprAttr:	equ $3b00
sprPat:		equ $1800

SPRITE_GEN_RAM_ADR: equ $7300

include "../../common/tms.asm"

inthandler:
	; --- NMI ROUTINE ---
	ld de,sprAttr	; --- copy to 3000 sprite attribute ---
	ld hl,SpriteAttrib
	ld bc,128
	call tmswrite

; Attente
	ld c, $00
lp_b:
	ld a, c
	inc c
	ld a, $15
lp_a:
	dec a
	jp nz, lp_a
	nop	
	nop
	add a, 1
	add a, 1
	add a, 1
	ld a, c
	sub a, $50
	jp nz, lp_b
; fin de l'attente

	
	ld de,sprAttr	; --- copy to 3000 sprite attribute ---
	ld hl,SpriteAttribEx
	ld bc,64
	call tmswrite

	in a,($bf)

	ei
	reti

start:
	ld ($7000),sp
	ld sp,ramtop

	call tmsbitmap
	call $505 ; TURN_OFF_SOUND
	call tmsintenable
	

	; Clear VRAM
	;ld hl,0
	;ld de,$4000
	;xor a
	;call $1f82 ; FILL_VRAM

	ld c, $01
	ld de,sprPat	; --- copy to 3800 generated sprite

; gen sprites
        ld      bc, 32
        ld      de, $1800
        ld      hl, SpriteBackground
        call    tmswrite

	ld de,sprAttr	; --- copy to 3000 sprite attribute ---
	ld hl,SpriteAttrib
	ld bc,128
	call tmswrite ;$1fdf ; WRITE_VRAM
	
	ld de,sprAttr	; --- copy to 3000 sprite attribute ---
	ld hl,SpriteAttribEx
	ld bc,64
	call tmswrite	;$1fdf ; WRITE_VRAM
	
TheEnd:
	halt
	jp TheEnd

SpriteAttrib:
		db 00, $20, $0, $0f ; y=0, x =0x40, sprite data=0, color = 6
		db 00, $40, $0, $0f ; y=0, x =0x40, sprite data=0, color = 6
		db 00, $60, $0, $0f ; y=0, x =0x40, sprite data=0, color = 6
		db 00, $80, $0, $0f ; y=0, x =0x40, sprite data=0, color = 6

		db 16, $20, $0, $0e ; y=0, x =0x40, sprite data=0, color = 6
		db 16, $40, $0, $0d ; y=0, x =0x40, sprite data=0, color = 6
		db 16, $60, $0, $0c ; y=0, x =0x40, sprite data=0, color = 6
		db 16, $80, $0, $0b ; y=0, x =0x40, sprite data=0, color = 6

		db 32, $20, $0, $0d ; y=0, x =0x40, sprite data=0, color = 6
		db 32, $40, $0, $0c ; y=0, x =0x40, sprite data=0, color = 6
		db 32, $60, $0, $0b ; y=0, x =0x40, sprite data=0, color = 6
		db 32, $80, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6

		db 48, $20, $0, $0c ; y=0, x =0x40, sprite data=0, color = 6
		db 48, $40, $0, $0b ; y=0, x =0x40, sprite data=0, color = 6
		db 48, $60, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6
		db 48, $80, $0, $09 ; y=0, x =0x40, sprite data=0, color = 6

		db 64, $20, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6
		db 64, $40, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6
		db 64, $60, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6
		db 64, $80, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6

		db 80, $20, $0, $0a ; y=0, x =0x40, sprite data=0, color = 6
		db 80, $40, $0, $09 ; y=0, x =0x40, sprite data=0, color = 6
		db 80, $60, $0, $08 ; y=0, x =0x40, sprite data=0, color = 6
		db 80, $80, $0, $07 ; y=0, x =0x40, sprite data=0, color = 6

		db 96, $20, $0, $09 ; y=0, x =0x40, sprite data=0, color = 6
		db 96, $40, $0, $08 ; y=0, x =0x40, sprite data=0, color = 6
		db 96, $60, $0, $07 ; y=0, x =0x40, sprite data=0, color = 6
		db 96, $80, $0, $06 ; y=0, x =0x40, sprite data=0, color = 6

		db 112, $20, $0, $08 ; y=0, x =0x40, sprite data=0, color = 6
		db 112, $40, $0, $07 ; y=0, x =0x40, sprite data=0, color = 6
		db 112, $60, $0, $06 ; y=0, x =0x40, sprite data=0, color = 6
		db 112, $80, $0, $05 ; y=0, x =0x40, sprite data=0, color = 6

SpriteAttribEx:
		db 128, $20, $0, $07 ; y=0, x =0x40, sprite data=0, color = 6
		db 128, $40, $0, $06 ; y=0, x =0x40, sprite data=0, color = 6
		db 128, $60, $0, $05 ; y=0, x =0x40, sprite data=0, color = 6
		db 128, $80, $0, $04 ; y=0, x =0x40, sprite data=0, color = 6

		db 144, $20, $0, $06 ; y=0, x =0x40, sprite data=0, color = 6
		db 144, $40, $0, $05 ; y=0, x =0x40, sprite data=0, color = 6
		db 144, $60, $0, $04 ; y=0, x =0x40, sprite data=0, color = 6
		db 144, $80, $0, $03 ; y=0, x =0x40, sprite data=0, color = 6
	
		db 160, $20, $0, $05 ; y=0, x =0x40, sprite data=0, color = 6
		db 160, $40, $0, $04 ; y=0, x =0x40, sprite data=0, color = 6
		db 160, $60, $0, $03 ; y=0, x =0x40, sprite data=0, color = 6
		db 160, $80, $0, $02 ; y=0, x =0x40, sprite data=0, color = 6
		
		db 176, $20, $0, $04 ; y=0, x =0x40, sprite data=0, color = 6
		db 176, $40, $0, $03 ; y=0, x =0x40, sprite data=0, color = 6
		db 176, $60, $0, $02 ; y=0, x =0x40, sprite data=0, color = 6
		db 176, $80, $0, $0f ; y=0, x =0x40, sprite data=0, color = 6
		
SpriteBackground:
    db %00000111
    db %00011111
    db %00111111
    db %01111111
    db %01111111
    db %11111111
    db %11111111
    db %11111111

    db %11111111
    db %11111111
    db %11111111
    db %01111111
    db %01111111
    db %00111111
    db %00011111
    db %00000111

    db %11100000
    db %11111000
    db %11111100
    db %11111110
    db %11111110
    db %11111111
    db %11111111
    db %11111111

    db %11111111
    db %11111111
    db %11111111
    db %11111110
    db %11111110
    db %11111100
    db %11111000
    db %11100000
