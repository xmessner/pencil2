    PSG_STOPPED: equ         0
    PSG_PLAYING: equ         1

    PSGDataPort: equ         $ff

    PSGLatch: equ            $80
    PSGData: equ             $40

    PSGChannel0: equ         %00000000
    PSGChannel1: equ         %00100000
    PSGChannel2: equ         %01000000
    PSGChannel3: equ         %01100000
    PSGVolumeData: equ %00010000

    PSGWait: equ        $38
    PSGSubString: equ        $08
    PSGLoop: equ             $01
    PSGEnd: equ              $00

PSGInit:
  xor a                           ; ld a,PSG_STOPPED
  ld (PSGMusicStatus),a           ; set music status to PSG_STOPPED
  ret

; ************************************************************************************
; receives in HL the address of the PSG to start playing
; destroys AF
PSGPlayNoRepeat:
  xor a                           ; We don't want the song to loop
  jp next
PSGPlay:
  ld a,$1                         ; the song can loop when finished
next:
  ld (PSGLoopFlag),a
  call PSGStop                    ; if there's a tune already playing, we should stop it!
  ld (PSGMusicStart),hl           ; store the begin point of music
  ld (PSGMusicPointer),hl         ; set music pointer to begin of music
  ld (PSGMusicLoopPoint),hl       ; looppointer points to begin too
  xor a
  ld (PSGMusicSkipFrames),a       ; reset the skip frames
  ld (PSGMusicSubstringLen),a     ; reset the substring len (for compression)
  ld a,PSG_PLAYING
  ld (PSGMusicStatus),a           ; set status to PSG_PLAYING
  ret

; ************************************************************************************
; stops the music (leaving the SFX on, if it's playing)
; destroys AF
PSGStop:
  ld a,(PSGMusicStatus)                         ; if it's already stopped, leave
  or a
  ret z
  ld a,PSGLatch|PSGChannel0|PSGVolumeData|$0F   ; latch channel 0, volume=0xF (silent)
  out (PSGDataPort),a
  ld a,PSGLatch|PSGChannel1|PSGVolumeData|$0F   ; latch channel 1, volume=0xF (silent)
  out (PSGDataPort),a
  ld a,PSGLatch|PSGChannel2|PSGVolumeData|$0F   ; latch channel 2, volume=0xF (silent)
  out (PSGDataPort),a
  ld a,PSGLatch|PSGChannel3|PSGVolumeData|$0F   ; latch channel 3, volume=0xF (silent)
  xor a                                         ; ld a,PSG_STOPPED
  ld (PSGMusicStatus),a                         ; set status to PSG_STOPPED
  ret

; ************************************************************************************
; sets the currently looping music to no more loops after the current
; destroys AF
PSGCancelLoop:
  xor a
  ld (PSGLoopFlag),a
  ret

; ************************************************************************************
; gets the current status of music into register A
PSGGetStatus:
  ld a,(PSGMusicStatus)
  ret

; ************************************************************************************
; processes a music frame
; destroys AF,HL,BC
PSGFrame:
  ld a,(PSGMusicStatus)          ; check if we have got to play a tune
  or a
  ret z

  ld a,(PSGMusicSkipFrames)      ; check if we havve got to skip frames
  or a
  jp z,readMusicPointer
  dec a                          ; skip this frame and ret
  ld (PSGMusicSkipFrames),a
  ret

readMusicPointer:
  ld hl,(PSGMusicPointer)        ; read current address

_intLoop:
  ld b,(hl)                      ; load PSG byte (in B)
  inc hl                         ; point to next byte
  ld a,(PSGMusicSubstringLen)    ; read substring len
  or a
  jr z,_continue                 ; check if it is 0 (we are not in a substring)
  dec a                          ; decrease len
  ld (PSGMusicSubstringLen),a    ; save len
  jr nz,_continue
  ld hl,(PSGMusicSubstringRetAddr)  ; substring is over, retrieve return address

_continue:
  ld a,b                         ; copy PSG byte into A
;+:cp PSGData                     ; is it a command (<$40)??
  cp PSGData                     ; is it a command (<$40)??
  jr c,cont                         ; it is not, output it!
  out (PSGDataPort),a
  jr _intLoop

cont:
  cp PSGWait
  jr z,_done                     ; no additional frames
  jr c,_otherCommands            ; other commands?
  and $07                        ; take only the last 3 bits for skip frames
  ld (PSGMusicSkipFrames),a      ; we got additional frames
_done:
  ld (PSGMusicPointer),hl        ; save current address
  ret                            ; frame done

_otherCommands:
  cp PSGSubString
  jr nc,_substring
  cp PSGEnd
  jr z,_musicLoop
  cp PSGLoop
  jr z,_setLoopPoint

  ; ***************************************************************************
  ; we should never get here!
  ; if we do, it means the PSG file is probably corrupted, so we just RET
  ; ***************************************************************************

  ret

_setLoopPoint:
  ld (PSGMusicLoopPoint),hl
  jp _intLoop

_musicLoop:
  ld a,(PSGLoopFlag)               ; looping requested?
  or a
  jp z,PSGStop                     ; No:stop it! (tail call optimization)
  ld hl,(PSGMusicLoopPoint)
  jp _intLoop

_substring:
  sub PSGSubString-4                  ; len is value - $08 + 4
  ld (PSGMusicSubstringLen),a         ; save len
  ld c,(hl)                           ; load substring address (offset)
  inc hl
  ld b,(hl)
  inc hl
  ld (PSGMusicSubstringRetAddr),hl    ; save return address
  ld hl,(PSGMusicStart)
  add hl,bc                           ; make substring current
  jp _intLoop

  ; fundamental vars
  PSGMusicStatus: equ $7300  ; are we playing a background music?
  PSGMusicStart:  equ $7301  ;          dw    ; the pointer to the beginning of music
  PSGMusicPointer: equ $7303 ;          dw    ; the pointer to the current
  PSGMusicLoopPoint: equ $7305 ;          dw    ; the pointer to the loop begin
  PSGMusicSkipFrames: equ $7307 ;         db    ; the frames we need to skip
  PSGLoopFlag: equ $7308 ;               db    ; the tune should loop or not (flag)

  ; decompression vars
  PSGMusicSubstringLen: equ $7309 ;       db    ; lenght of the substring we are playing
  PSGMusicSubstringRetAddr: equ $730A ;   dw    ; return to this address when substring is over
