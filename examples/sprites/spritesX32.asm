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
        defb "DEV!** 32 SPRITES **!2019"

        defs 25,0

ramtop:         equ $7050

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

;	call    tmsintenable            ; enable interrupts on TMS
mainloop:
	call    drawSprite               ; draw next frame, if it's time
	jr      mainloop                ; busy wait and let interrupts do their thing

inthandler:
	in      a, (tmsreg)             ; clear interrupt flag
	ei
	reti

; hl : adresse des attributs de sprites
; bc : 4 données / sprites * nb sprites. MAX 128 (32*4)
; de : vdp adress en fonction du mode graphique
drawSprite:
	ld      bc, 128
	ld      de, $3b00
	ld      hl, SprAttrib
	call    tmswrite
	ret

SprAttrib:
	db 0, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 0, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 0, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 0, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 16, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 16, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 16, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 16, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 32, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 32, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 32, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 32, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 48, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 48, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 48, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 48, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 64, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 64, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 64, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 64, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 80, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 80, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 80, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 80, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 96, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 96, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 96, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 96, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 112, 0,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 112, 16,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 112, 32,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 112, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	db 128, 48,0,13 ; Y=82, X= 24, Pattern#0, Color=13
	
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
