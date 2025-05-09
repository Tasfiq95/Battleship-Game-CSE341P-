.MODEL SMALL
 
.STACK 100H

.DATA

; declare variables here
frontend db 64 dup('')      ; 8x8 grid initialized with '' 
score db 0
missiles db 5

; Predefined ship positions (1 = ship)
backend db 0,0,0,1,0,1,0,0
        db 0,0,0,1,1,0,0,0
        db 8 dup(0)
        db 0,0,0,0,1,0,0,0
        db 0,1,1,0,1,0,0,0
        db 0,1,0,0,1,0,0,0
        db 8 dup(0)
        db 0,0,0,1,0,0,0,0

prompt_row db 13,10,'Enter row (1-8): $'
prompt_col db 13,10,'Enter column (1-8): $'
hit_msg db 13,10,'Hit!$'
miss_msg db 13,10,'Miss!$'
score_msg db 13,10,'Score: $'
remaining_msg db 13,10,'Missiles left: $'
final_msg db 13,10,'Final $'
newline db 13,10,'$'


.CODE
MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
 
; enter your code here

start:
    game_loop:
        ; Display board
        mov cx, 8
        mov si, 0
        print_board:
            push cx
            mov cx, 8
            print_row:
                mov dl, [frontend+si]
                mov ah, 2
                int 21h
                mov dl, ' '
                int 21h
                inc si
                loop print_row
            lea dx, newline
            mov ah, 9
            int 21h
            pop cx
            loop print_board
            
        ; Get coordinates
        lea dx, prompt_row
        mov ah, 9
        int 21h
        call get_number
        mov bl, al
        
        lea dx, prompt_col
        mov ah, 9
        int 21h
        call get_number
        mov bh, al
        
        ; Calculate index
        dec bx             ; Convert to 0-based index
        mov ax, bx
        and ax, 00FFh
        mov cl, 8
        mul cl
        add al, bh
        mov di, ax
        
        ; Check hit/miss
        cmp backend[di], 1
        je hit
        
        miss:
            mov frontend[di], '-'
            dec score
            lea dx, miss_msg
            jmp update
        hit:
            mov frontend[di], '+'
            inc score
           lea dx, hit_msg
        update:
        mov ah, 9
        int 21h
        
        ; Update missiles
        dec [missiles]
        jz end_game
        
        ; Show status
        lea dx, score_msg
        mov ah, 09h
        int 21h
        mov al, [score]
        call print_number
        
        lea dx, remaining_msg
        mov ah, 9
        int 21h
        mov al, [missiles]
        call print_number
        jmp game_loop

end_game:
    lea dx, final_msg
    mov ah, 9
    int 21h
    lea dx, score_msg
    int 21h
    mov al, [score]
    call print_number
    
    ; Exit to DOS
    mov ah, 4ch
    int 21h

; Helper procedures
get_number:
    mov ah, 1
    int 21h
    sub al, '0'
    ret

print_number:
    aam
    add ax, 3030h
    push ax
    mov dl, ah
    mov ah, 02h
    int 21h
    pop ax
    mov dl, al
    int 21h
    ret        


 
hlt
;exit to DOS
               
MOV AX,4C00H
INT 21H

MAIN ENDP
    END MAIN
    