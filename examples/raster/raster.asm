       ; Header d'une cartouche Pencil II
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
        defb "BETA!** RASTER **!2019"

        defs 25,0

; VARIABLES

dataVDP:	EQU $BE ; VDP Data port
cmdVDP:		EQU $BF ; VDP Command port
ramtop:         equ $7050
        include "../../common/tms.asm"

inthandler:
        in      a, (tmsreg)             ; clear interrupt flag
        call    rasters 
        ei
        reti
        
rasters:
	; Register 7 = $2 => 0000 0010 (BGC)
	ld c, $02
lp_b:
	ld a, c
	out ($bf), a
	ld a, $87
	out ($bf), a

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

	xor a, a
	out ($bf), a
	ld a, $87
	out ($bf), a

	ret


start:
	ld	($7000),sp			;ld	(oldstack),sp                   ; save old stack poitner
        ld      sp, ramtop                      ; set up stack

	call    tmsbitmap
        call	$505 ; TURN_OFF_SOUND
	call	tmsintenable


        ; Clear VRAM
;clearVram:
;        LD B,$0         ; Fill with some patern to see what happen
;        LD HL,$3FFF
;        LD C,dataVDP
;
;CLEAR:
;        OUT (C),B
;        DEC HL
;        LD A,H
;        OR L
;        NOP             ; Let's wait 8 clock cycles just in case VDP is not quick enough.
;        NOP
;        JR NZ,CLEAR
;
;	ld a, $01
;	out ($bf), a
;	ld a, $80
;	out ($bf), a ; set register 0 to $1, enable NMI
;	in a,($bf) ; required to re-init to data.
	;ei
mainLoop:
	jr mainLoop

