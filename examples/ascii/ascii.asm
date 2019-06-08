	; Header d'une cartouche Pencil II
	org $8000
	; COPYRIGHT SOUNDIC
	defb "COPYRIGHT SOUNDIC"
	; Point d'entrée du lancement du programme sur la cartouche
	jp start

	; Remplissage du vide, trouver à quoi cela correspond
	; Sur la cartouche SD Basic, plusieurs JP à certaines adresses
	defs 32,0

	; VERSION!TITRE!DATE (C)
	defb "BETA!** ASCII **!2019"

	; Remplissage du vide, trouver à quoi cela correspond
	defs 10,0
;start:

dataVDP: EQU $BE ; VDP Data port
cmdVDP: EQU $BF ; VDP Command port
ramtop:         equ $7050
bdos:           equ $5
linelen:        equ 32
dblhorizontal:  equ 205
dblvertical:    equ 186
dbltopleft:     equ 201
dbltopright:    equ 187
dblbottomleft:  equ 200
dblbottomright: equ 188
        
	jp start

oldstack:
        defw    0

tmsfont:
        include "../../common/tmsfont.asm"
        include "../../common/tms.asm"

start:
	ld	($7000),sp			;ld	(oldstack),sp                   ; save old stack poitner
        ld      sp, ramtop                      ; set up stack
        ld      hl, tmsfont                     ; pointer to font
        call    tmstextmode                     ; initialize text mode
        ld      a, tmswhite                  ; set blue background
        call    tmsbackground
	ld	a, tmsmagenta
	call	tmstextcolor
        call    textborder
        ld      a, 11                           ; put title at 11, 1
        ld      e, 2
        call    tmstextpos
        ld      hl, msg                         ; output title
        call    tmsstrout
        ld      a, 0                            ; start at character 0
        ld      b, linelen                      ; 32 chars per line
        ld      c, 6                            ; start at line 6
        push    af                              ; save current character
nextline:
        ld      a, 0+(40-linelen)/2             ; center text
        ld      e, c                            ; on current line
        call    tmstextpos
        pop     af                              ; get current character
nextchar:
        out     (tmsram), a                     ; output current character
        cp      255                             ; see if we have output everything
        jp      z, done
        inc     a                               ; next character
        cp      b                               ; time for a new line?
        jp      nz, nextchar                    ; if not, output the next character
        push    af                              ; if so, save the next character
        add     a, linelen                      ; 32 characters on the next line
        ld      b, a
        inc     c                               ; skip two lines
        inc     c
        jp      nextline                        ; do the next line
done:
        ld	sp,(oldstack)	                ; put stack back to how we found it
        ld	c,$0			        ; this is the CP/M proper exit call
        halt 					;jp	bdos

textborder:
        ld      a, 0                            ; start at upper left
        ld      e, 0
        call    tmstextpos
        ld      a, dbltopleft                   ; output corner
        call    tmschrout
        ld      b, 38                           ; output top border
        ld      a, dblhorizontal
        call    tmschrrpt
        ld      a, dbltopright                  ; output corner
        call    tmschrout
        ld      c, 22                           ; output left/right borders for 22 lines
next:
        ld      a, dblvertical                  ; vertical border
        call    tmschrout
        ld      a, ' '                          ; space
        ld      b, 38
        call    tmschrrpt
        ld      a, dblvertical                  ; vertical border
        call    tmschrout
        dec     c
        jr      nz, next
        ld      a, dblbottomleft               ; bottom right
        call    tmschrout
        ld      a, dblhorizontal
        ld      b, 38
        call    tmschrrpt
        ld      a, dblbottomright
        call    tmschrout
        ret

msg:    
        defb "ASCII Character Set", 0
