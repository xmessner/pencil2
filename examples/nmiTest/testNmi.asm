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
        defb "BETA!** NMI TEST **!2019"

        defs 25,0

        include "../../common/tms.asm"

; VARIABLES

dataVDP:	EQU $BE ; VDP Data port
cmdVDP:		EQU $BF ; VDP Command port
ramtop:         equ $7050
        
; Change bg color
inthandler:
	out ($bf), a
	ld a, $87
	out ($bf), a 

        in      a, (tmsreg)             ; clear interrupt flag
        ei
        reti

start:
	ld	($7000),sp			;ld	(oldstack),sp                   ; save old stack poitner
        ld      sp, ramtop                      ; set up stack

	call    tmsbitmap
        call $505 ; TURN_OFF_SOUND
	call tmsintenable

main:
	add a,1
	jr main

