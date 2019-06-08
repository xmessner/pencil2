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
        defb "DEV!** SPRITES BOUNCE **!2019"

        defs 25,0

ramtop:         equ $7050
frameticks:     equ 6                   ; number of interrupts per animation frame
framecount:     equ 8                   ; number of frames in animation

tickcounter:	equ $7200	      	;1 interrupt down counter
currframe:	equ $7202              	;1 current frame of animation
VBlankFlag:	equ $7204
sprite1Attr:	equ $7600
sprite2Attr:	equ $7604
sprite1X:	equ sprite1Attr+1
sprite1Y:	equ sprite1Attr
sprite1Name:	equ sprite1Attr+2
sprite1Color:	equ sprite1Attr+3
sprite1PosX:	equ 0
sprite2X:	equ sprite2Attr+1
sprite2Y:	equ sprite2Attr
sprite2Name:	equ sprite2Attr+2
sprite2Color:	equ sprite2Attr+3
sprite2PosX:	equ 0

xdelta:		equ $7608                       	; direction of x axis motion
ydelta:		equ $7609                       	; directino of y axis motion


sprite1color:	defb	tmsdarkblue
sprite2color:	defb	tmslightgreen

include "../../common/tms.asm"

waitForVBlank:
        ld a,(VBlankFlag)
        or a
        jr z,waitForVBlank
        xor a
        ld (VBlankFlag),a
        ret

start:
        ld      ($7000),sp                      ;ld     (oldstack),sp                   ; save old stack poitner
        ld      sp, ramtop                      ; set up stack

        call    tmsbitmap
        call    $505 ; TURN_OFF_SOUND

	; Lecture des sprites et stockage en VRAM
	ld      bc, spritelen
	ld      de, $1800
	ld      hl, sprite
	call    tmswrite

	; Ecriture des attributs des sprites
	ld	a,tmsdarkblue
	ld	(sprite1Color),a
	ld	a,tmslightgreen
	ld	(sprite2Color),a

	ld	a,sprite1PosX
	ld	(sprite1X),a
	ld	a,sprite2PosX
	ld	(sprite2X),a

	ld	a,1
	ld	(xdelta),a
	ld	(ydelta),a

	; Envoit les attributs des 2 sprites	
	ld      bc, 8
	ld      de, $3b00
	ld      hl, sprite1Attr
	call    tmswrite

	ld      a, frameticks           ; initialize interrupt counter to frame length
	ld      (tickcounter), a

        call    tmsintenable

mainloop:
	call    drawframe               ; draw next frame, if it's time
	call	waitForVBlank
	jr      mainloop                ; busy wait and let interrupts do their thing

; interrupt handler: rotate animation frames
inthandler:
	push	af
	in	a, (tmsreg)             ; clear interrupt flag
        ld	a,1                          ; the only interrupt enabled is VBlank so...
        ld	(VBlankFlag),a
	pop	af
	ei
	reti


; change direction of motion
;       HL = pointer to direction variable
changedir:
	push    af
	ld      a, (hl)
	neg
	ld      (hl), a
	pop     af
	ret

; draw a single animation frame
;       HL = animation data base address
;       A = current animation frame number
drawframe:
	; Position X
	ld      hl, xdelta              ; move x position
	ld      a, (sprite1X)
	add     a, (hl)
	ld      (sprite1X), a
	ld      (sprite2X), a
	cp      240                     ; bounce off the edge
	call    z, changedir
	cp      0
	call    z, changedir

	; Position Y
	ld      hl, ydelta              ; move y position
	ld      a, (sprite1Y)
	add     a, (hl)
	ld      (sprite1Y), a
	ld      (sprite2Y), a
	cp      176                     ; bounce off the edge
	call    z, changedir
	cp      0
	call    z, changedir

	; prochain sprite
	ld      a, (tickcounter)        ; check if we've been called frameticks times
	or      a
	jr      nz, framewait           ; if not, wait to draw next animation frame
	ld      a, (currframe)          ; next animation frame
	add     a, a                    ; multiply current frame x 8
	add     a, a
	add     a, a
	ld      (sprite1Name), a        ; set name for first sprite
	add     a, 4                    ; add 4
	ld      (sprite2Name), a        ; set name for second sprite

	ld      a, (currframe)          ; next animation frame
	inc     a
	cp      framecount              ; have we displayed all frames yet?
	jr      nz, skipreset           ; if not, display the next frame
	ld      a, 0                    ; if so, start over at the first frame
skipreset:
	ld      (currframe), a          ; save next frame in memory
	ld      a, frameticks           ; reset interrupt down counter
	ld      (tickcounter), a
	ret
framewait:
	ld      bc, 8                   ; send updated sprite attribute table
	ld      de, $3b00
	ld      hl, sprite1Attr
	call    tmswrite
	
	ld      hl, tickcounter         ; not time to switch animation frames yet
	dec     (hl)                    ; decrement down counter
	ret


; planet sprites from TI VDP Programmer's guide
sprite:
	; Sprite world0 pattern 1
	defb  $07,$1C,$38,$70,$78,$5C,$0E,$0F
	defb  $0F,$1F,$7F,$63,$73,$3D,$1F,$07
	defb  $E0,$F8,$7C,$66,$F2,$BE,$DC,$FC
	defb  $F8,$A0,$C0,$C0,$E2,$F4,$F8,$E0
	; Sprite world0 pattern 2
	defb  $00,$03,$07,$0F,$07,$A3,$F1,$F0
	defb  $F0,$E0,$80,$1C,$0C,$02,$00,$00
	defb  $00,$00,$80,$98,$0C,$41,$23,$03
	defb  $07,$5F,$3F,$3E,$1C,$08,$00,$00
	; Sprite world1 pattern 1
	defb  $03,$1F,$3E,$7C,$7E,$97,$03,$03
	defb  $03,$07,$1F,$78,$7C,$3F,$1F,$07
	defb  $E0,$38,$1C,$18,$3C,$2F,$B7,$FF
	defb  $FE,$E8,$F0,$F0,$F8,$7C,$F8,$E0
	; Sprite world1 pattern 2
	defb  $00,$00,$01,$03,$01,$68,$FC,$FC
	defb  $FC,$F8,$E0,$07,$03,$00,$00,$00
	defb  $00,$C0,$E0,$E6,$C2,$D0,$48,$00
	defb  $01,$17,$0F,$0E,$06,$80,$00,$00
	; Sprite world2 pattern 1
	defb  $07,$1F,$3F,$7F,$3F,$E5,$C0,$C0
	defb  $80,$01,$07,$1E,$3F,$3F,$1F,$07
	defb  $E0,$C8,$84,$06,$8E,$CB,$ED,$FF
	defb  $FF,$FA,$FC,$3C,$3E,$DC,$F8,$E0
	; Sprite world2 pattern 2
	defb  $00,$00,$00,$00,$40,$1A,$3F,$3F
	defb  $7F,$FE,$F8,$61,$40,$00,$00,$00
	defb  $00,$30,$78,$F8,$70,$34,$12,$00
	defb  $00,$05,$03,$C2,$C0,$20,$00,$00
	; Sprite world3 pattern 1
	defb  $07,$1F,$3F,$1F,$4F,$F9,$70,$F0
	defb  $E0,$80,$01,$07,$0F,$1F,$1F,$07
	defb  $E0,$F0,$E0,$C2,$E2,$72,$3B,$3F
	defb  $3F,$7E,$FF,$8E,$CE,$F4,$F8,$E0
	; Sprite world3 pattern 2
	defb  $00,$00,$00,$60,$30,$06,$8F,$0F
	defb  $1F,$7F,$FE,$78,$70,$20,$00,$00
	defb  $00,$08,$1C,$3C,$1C,$8D,$C4,$C0
	defb  $C0,$81,$00,$70,$30,$08,$00,$00
	; Sprite world4 pattern 1
	defb  $07,$1F,$3F,$67,$73,$BE,$DC,$FC
	defb  $F8,$A0,$C0,$41,$63,$37,$1F,$07
	defb  $E0,$F8,$F8,$F0,$F8,$5C,$0E,$0F
	defb  $0F,$1F,$7F,$E2,$F2,$FC,$F8,$E0
	; Sprite world4 pattern 2
	defb  $00,$00,$00,$18,$0C,$41,$23,$03
	defb  $07,$5F,$3F,$3E,$1C,$08,$00,$00
	defb  $00,$00,$04,$0E,$06,$A3,$F1,$F0
	defb  $F0,$E0,$80,$1C,$0C,$00,$00,$00
	; Sprite world5 pattern 1
	defb  $07,$1F,$1F,$19,$3C,$2F,$B7,$FF
	defb  $FE,$E8,$F0,$70,$78,$3D,$1F,$07
	defb  $E0,$F8,$FC,$FC,$FE,$97,$03,$03
	defb  $03,$07,$1F,$78,$FC,$FC,$F8,$E0
	; Sprite world5 pattern 2
	defb  $00,$00,$20,$66,$43,$D0,$48,$00
	defb  $01,$17,$0F,$0F,$07,$02,$00,$00
	defb  $00,$00,$00,$02,$00,$68,$FC,$FC
	defb  $FC,$F8,$E0,$86,$02,$00,$00,$00
	; Sprite world6 pattern 1
	defb  $07,$0F,$07,$06,$0F,$CB,$ED,$FF
	defb  $FF,$FA,$FC,$3C,$3E,$1F,$1F,$07
	defb  $E0,$F8,$FC,$7E,$3E,$E5,$C0,$C0
	defb  $80,$01,$07,$1E,$3E,$7C,$F8,$E0
	; Sprite world6 pattern 2
	defb  $00,$10,$38,$79,$70,$34,$12,$00
	defb  $00,$05,$03,$43,$41,$20,$00,$00
	defb  $00,$00,$00,$80,$C0,$1A,$3F,$3F
	defb  $7F,$FE,$F8,$E0,$C0,$80,$00,$00
	; Sprite world7 pattern 1
	defb  $07,$13,$21,$41,$63,$72,$3B,$3F
	defb  $3F,$7E,$FF,$0F,$4F,$37,$1F,$07
	defb  $E0,$F8,$FC,$9E,$CE,$F9,$70,$F0
	defb  $E0,$80,$01,$06,$8E,$DC,$F8,$E0
	; Sprite world7 pattern 2
	defb  $00,$0C,$1E,$3E,$1C,$8D,$C4,$C0
	defb  $C0,$81,$00,$70,$30,$08,$00,$00
	defb  $00,$00,$00,$60,$30,$06,$8F,$0F
	defb  $1F,$7F,$FE,$F8,$70,$20,$00,$00
spritelen: equ $-sprite
