org 100h
.model small
.stack 100h
.data 
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
msg db 'Game Over$'
msg1 db 'Press space to restart$'
nl db 10, 13, '$' 

.code

main proc
   
    mov ax,@data
    mov ds,ax 
    
    mov ah, 0
    mov al, 13h
    int 10h 
     
    call baskt
    
   
endp main 

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
    lea dx,msg 
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

end main