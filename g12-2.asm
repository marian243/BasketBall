.MODEL small
.STACK 100h
.DATA
;================================
 MSG DB 'PRESS ENTER TO PLAY $'

filename db 'Ball.bmp',0

filehandle dw ?

Header db 54 dup (0)

Palette db 256*4 dup (0)

ScrLine db 320 dup (0)

ErrorMsg db 'Error', 13, 10,'$'

x dw 0
y dw 100
b_pos dw 0  
l dw 20
bl_pos dw 0
TIK dw ? 
Row db 14
column db 22 
Sense dw -1
player_pos dw 6158d 
life dw 3 
msg2 db 'Game Over$'
msg1 db 'Press space to restart$'
nl db 10, 13, '$'
;================================
.code
;================================
 OpenFile proc

    ; Open file

    mov ah, 3Dh
    xor al, al
    mov dx, offset filename
    int 21h

    jc openerror
    mov [filehandle], ax
    ret

    openerror:
    mov dx, offset ErrorMsg
    mov ah, 9h
    int 21h
    ret
endp OpenFile


ReadHeader  proc

    ; Read BMP file header, 54 bytes

    mov ah,3fh
    mov bx, [filehandle]
    mov cx,54
    mov dx,offset Header
    int 21h
    ret
    endp ReadHeader


ReadPalette   proc

    ; Read BMP file color palette, 256 colors * 4 bytes (400h)

    mov ah,3fh
    mov cx,400h
    mov dx,offset Palette
    int 21h
    ret
endp ReadPalette



CopyPal proc

    ; Copy the colors palette to the video memory
    ; The number of the first color should be sent to port 3C8h
    ; The palette is sent to port 3C9h

    mov si,offset Palette
    mov cx,256
    mov dx,3C8h
    mov al,0

    ; Copy starting color to port 3C8h

    out dx,al

    ; Copy palette itself to port 3C9h

    inc dx
    PalLoop:   
        ; Note: Colors in a BMP file are saved as BGR values rather than RGB.
    
        mov al,[si+2] ; Get red value.
        shr al,2 ; Max. is 255, but video palette maximal
    
        ; value is 63. Therefore dividing by 4.
    
        out dx,al ; Send it.
        mov al,[si+1] ; Get green value.
        shr al,2
        out dx,al ; Send it.
        mov al,[si] ; Get blue value.
        shr al,2
        out dx,al ; Send it.
        add si,4 ; Point to next color.
    
        ; (There is a null chr. after every color.)
    
        loop PalLoop
    ret
endp CopyPal

 CopyBitmap   proc

    ; BMP graphics are saved upside-down.
    ; Read the graphic line by line (200 lines in VGA format),
    ; displaying the lines from bottom to top.

    mov ax, 0A000h
    mov es, ax
    mov cx,200
    PrintBMPLoop:
        push cx
    
        ; di = cx*320, point to the correct screen line
    
        mov di,cx
        shl cx,6
        shl di,8
        add di,cx
    
        ; Read one line
    
        mov ah,3fh
        mov cx,320
        mov dx,offset ScrLine
        int 21h
    
        ; Copy one line into video memory
    
        cld 
    
        ; Clear direction flag, for movsb
    
        mov cx,320
        mov si,offset ScrLine
        rep movsb 
        pop cx
        loop PrintBMPLoop
    ret
 endp CopyBitmap           
 
 
;================================
start:
mov ax, @data
mov ds, ax
;================================

    ; Graphic mode
    mov ax, 13h
    int 10h

    ; Process BMP file
    call OpenFile
    call ReadHeader
    call ReadPalette
    call CopyPal
    call CopyBitmap 
    
    mov ax,@data  ; initialization data segment 
    mov ds,ax     
      
    mov ah,13h
    mov bl, 06h 
    mov dl,70
    mov dh,18   
    int 10h  
   
     
    lea dx,MSG ; initialize data segment 2
    mov ah,9
    int 21h
    
    mov ah,2
    mov dl,0dh    ; new line
    int 21h
    mov dl,0ah
    int 21 
     
     
    ; Wait for key press
    mov ah,1
    int 21h
    CALL clear
    
 clear:
  clearscreen proc near
        mov ah,0
        mov al,3
        int 10h        
        ret
  clearscreen endp
   jne clear 
    
    ; Back to text mode
    mov ah, 0
    mov al, 13h
    int 10h  
    
    
      
L4:
     mov ah,0ch                  
     mov dx,348 
     mov cx,258                        
     mov al,14 
     int 10h      
     jle L4
          
L5:
     mov ah,0ch                  
     mov dx,348 
     mov cx,250                        
     mov al,14 
     int 10h      
     jle L5  
     
L27:
     mov ah,0ch                  
     mov dx,348
     mov cx,264                     
     mov al,14 
     int 10h      
     jle L27  
     mov ah,0ch
     mov al,15 ;color
     mov cx,200
     mov dx,0   
 L28:
                   
    int 10h
    inc dx
    cmp dx,100
    jne L28   
                   
                    
    mov ah,0ch
    mov al,15 ;color
    mov cx,400
    mov dx,0 
                 
                   
 L29:
                   
    int 10h
    inc dx
    cmp dx,100
    jne L29  
                              
                   
    mov ah,0ch
    mov al,15;color
    mov cx,200
    mov dx,100 
                 
L30:
                   
   int 10h
   inc cx
   cmp cx,400
   jne L30                                       
   mov ah,4ch
   int 21h     
;================================
exit:
    mov ax, 4c00h
    int 21h
    END start
    
    
    
    mov ax, @data
    mov ds, ax

 mov ax, @data
    mov ds, ax

input2:
        mov ah,1
        int 21h
        cmp al,13d
        jne input2
        call clear_screen
    
        mov ah,2
        mov dl, 13d
        int 21h
        
        cmp al,13d
        call baskt
        
        
baskt proc
    
    mov ah, 0
    mov al, 13h
    int 10h 
    
    player1:
            
           mov  dx, player_pos
           mov  bh, 0
           mov  ah, 02h    ;SetCursor
           int  10h

           mov  cx, 1
           mov  bh, 0         ;draw a player
           mov  al, 94d
           mov  ah, 09h
           mov  bl, 14     ;DrawCharacter
           int  10h       
           
 
 l1:      
    mov ah,1h
    int 16h                                ;go if pressed
    jnz key_pressed
    ;jz basket    
    
    
key_pressed:                              ;input hanaling section
    mov ah,0
    int 16h

    cmp al,32                            ;go spaceKey if space button is pressed
    je spaceKey
        
                                          ;if no key is pressed go to inside of loop
    jmp basket 
    
    
  basket:
      
    mov bx, l
      
      l2:
      mov ah, 0ch
      mov al, 4
      mov bh, 0 
      mov cx, x               ;draw basket which is just a line
      mov dx, y
      int 10h 
      inc x 
      cmp x,bx 
      jl l2
       
    mov b_pos, 1
      
    MOV AX,00H
    INT 1AH

    MOV TIK,DX
    ADD TIK, 8H

    DELAY1:
    MOV AX,00H
    INT 1AH
    CMP TIK, DX
    JGE DELAY1 
    
    cld                    ; Set forward direction for STOSD
    mov ax, 13h
    int 10h               ; Set video mode 0x13 (320x200x256 colors)

    mov ax, 0a000h
    mov es, ax             ; Beginning of VGA memory in segment 0xA000
    xor di, di           ; Destination address set to 0
    mov cx, (320*200)/2   ; We are doing 4 bytes at a time so count = (320*200)/4 DWORDS
    stosw              ; Clear video memory
      
      mov b_pos, 0 
      
      mov x, bx
      add bx,20
      cmp x,200 
      jl l2
      
      call baskt  
      
spaceKey:
   jmp ball
   
   
 ball:
       player:
            
           mov  dx, player_pos
           mov  bh, 0
           mov  ah, 02h    ;SetCursor
           int  10h

           mov  cx, 1
           mov  bh, 0                            ;draw ball which is basically just an O
           mov  al, 94d
           mov  ah, 09h
           mov  bl, 14     ;DrawCharacter
           int  10h
 ;mov column, 27
 mov  dh, column
 mov  dl, row
 mov  bh, 0
 mov  ah, 02h    ;SetCursor
 int  10h
 
 mov bl_pos, 1
 
 mov  cx, 1
 mov  bh, 0
 mov  al, 79d
 mov  ah, 09h
 mov  bl, 6    ;DrawCharacter
 int  10h   

 mov  dx, 0      ;Approximately 1/8 second
 mov  cx, 2
 mov  ah, 86h    ;Delay
 int  15h

 cld                    ; Set forward direction for STOSD
 mov ax, 13h
 int 10h 
 
 mov bl_pos,0 
 
 mov  ax, Sense  ;Is +1 to go right, is -1 to go left
 test ax, ax
 js   GoUp 
 
GoUp:
  
 dec  column
 jns  ball  
 dec life   
 
 cmp life, 0
 je gameover 
 
 mov  column, 22
 jmp basket         
       
gameover:
    mov ah,09h
    lea dx,msg2 
    int 21h 
    
    mov ah, 9
    lea dx, nl
    int 21h
           
    mov ah,09h
    lea dx, msg1
    int 21h 
    
    mov ah,1h
    int 16h                                ;go if pressed
    jnz entry
    
    entry:
     
      mov ah,0
      int 16h

      cmp al,32                            ;go spaceKey1 if space button is pressed
      je spaceKey1
      
spaceKey1:
  call baskt        
            
           
mov ah, 4ch
int 21h
    
endp    