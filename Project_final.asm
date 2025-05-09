; Simple Battleship Game for EMU 8086
; 8x8 grid with randomized ship locations
; 10 missiles, +1 for hit, 0 for miss

.model small
.stack 100h
.data
    ; Game messages
    welcome_msg  db 'BATTLESHIP GAME - 8x8 GRID$'
    level_msg    db 'LEVEL: $'
    hit_msg      db 'HIT! (+1)$'
    miss_msg     db 'MISS! (0)$'
    missiles_msg db 'Missiles: $'
    score_msg    db 'Score: $'
    accuracy_msg db 'Accuracy: $'
    percent_msg  db '%$'
    row_prompt   db 'Row (1-8): $'
    col_prompt   db 'Col (1-8): $'
    game_over    db 'GAME OVER!$'
    level_up     db 'Advanced to Level 2!$'
    play_again   db 'Play again? (Y/N): $'
    reveal_msg   db 'SHIP LOCATIONS:$'
    
    ; Game variables
    board       db 64 dup(0)  ; 8x8 board (0=empty, 1=ship)
    vis_board   db 64 dup('*'); Visible board
    missiles    db 10         ; Number of missiles
    score       db 0          ; Player's score
    hits        db 0          ; Number of hits
    shots       db 0          ; Total shots taken
    level       db 1          ; Current game level
    row         db 0          ; Selected row
    col         db 0          ; Selected column
    seed        dw 0          ; Random seed
    
.code
main proc
    mov ax, @data
    mov ds, ax
    
    ; Get system time for random seed
    mov ah, 2Ch
    int 21h
    mov seed, dx
    
start_game:
    call clear_screen
    call init_board
    
    ; Show welcome message
    mov ah, 9
    lea dx, welcome_msg
    int 21h
    call new_line
    
    ; Show level
    lea dx, level_msg
    int 21h
    mov dl, level
    add dl, '0'
    mov ah, 2
    int 21h
    call new_line
    
game_loop:
    ; Display board and status
    call show_board
    
    ; Check if game over
    mov al, missiles
    cmp al, 0
    je end_game
    
    ; Get player's move
    call get_move
    
    ; Process move
    call process_move
    
    ; Continue game loop
    jmp game_loop
    
end_game:
    ; Show final board
    call show_board
    
    ; Show game over message
    mov ah, 9
    lea dx, game_over
    int 21h
    call new_line
    
    ; Show accuracy
    call show_accuracy
    
    ; Reveal ship locations
    call reveal_ships
    
    ; Check if player advances to level 2
    mov al, hits
    mov bl, 10
    mul bl
    cmp ax, 50
    jl no_level_up
    
    ; If level 1, advance to level 2
    cmp level, 1
    jne no_level_up
    
    mov level, 2
    
    ; Show level up message
    mov ah, 9
    lea dx, level_up
    int 21h
    call new_line
    
no_level_up:
    ; Ask to play again
    mov ah, 9
    lea dx, play_again
    int 21h
    
    mov ah, 1
    int 21h
    
    cmp al, 'Y'
    je start_game
    cmp al, 'y'
    je start_game
    
    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

; Initialize the game board
init_board proc
    ; Clear the board
    mov cx, 64
    mov bx, 0
clear_loop:
    mov board[bx], 0
    mov vis_board[bx], '*'
    inc bx
    loop clear_loop
    
    ; Determine ship count by level
    mov cx, 15        ; Level 1: 15 ships
    cmp level, 1
    je place_ships
    
    mov cx, 5         ; Level 2: 5 ships
    
place_ships:
    ; Get random position
    mov ax, seed
    mov bx, 8405h
    mul bx
    add ax, 1
    mov seed, ax
    and ax, 3Fh       ; Modulo 64 (0-63)
    
    ; Check if position is free
    mov bx, ax
    cmp board[bx], 1
    je place_ships
    
    ; Place ship
    mov board[bx], 1
    
    loop place_ships
    
    ; Reset game stats
    mov missiles, 10
    mov score, 0
    mov hits, 0
    mov shots, 0
    
    ret
init_board endp

; Display the board
show_board proc
    ; Display column numbers
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    
    mov cx, 8
    mov dl, '1'
col_nums:
    int 21h
    mov dl, ' '
    int 21h
    inc dl
    loop col_nums
    
    call new_line
    
    ; Display board
    mov cx, 8
    mov bx, 0
    mov dl, '1'
row_loop:
    push cx
    
    ; Row number
    mov ah, 2
    int 21h
    mov dl, ' '
    int 21h
    
    ; Row cells
    mov cx, 8
col_loop:
    mov ah, 2
    mov dl, vis_board[bx]
    int 21h
    mov dl, ' '
    int 21h
    
    inc bx
    loop col_loop
    
    call new_line
    
    pop cx
    mov dl, '1'
    add dl, 8
    sub dl, cl
    loop row_loop
    
    call new_line
    
    ; Display status
    mov ah, 9
    lea dx, missiles_msg
    int 21h
    
    mov ah, 2
    mov dl, missiles
    add dl, '0'
    int 21h
    call new_line
    
    mov ah, 9
    lea dx, score_msg
    int 21h
    
    mov ah, 2
    mov dl, score
    add dl, '0'
    int 21h
    call new_line
    
    ret
show_board endp

; Get player's move
get_move proc
    ; Get row
    mov ah, 9
    lea dx, row_prompt
    int 21h
    
    mov ah, 1
    int 21h
    sub al, '1'
    mov row, al
    call new_line
    
    ; Get column
    mov ah, 9
    lea dx, col_prompt
    int 21h
    
    mov ah, 1
    int 21h
    sub al, '1'
    mov col, al
    call new_line
    
    ret
get_move endp

; Process the player's move
process_move proc
    ; Calculate board index: row*8 + col
    mov al, row
    mov bl, 8
    mul bl
    add al, col
    mov bx, ax
    
    ; Check if already selected
    cmp vis_board[bx], '*'
    jne skip_move
    
    ; Decrease missiles and count shot
    dec missiles
    inc shots
    
    ; Check if hit or miss
    cmp board[bx], 1
    jne miss
    
    ; Hit
    mov vis_board[bx], 'H'
    inc score
    inc hits
    
    mov ah, 9
    lea dx, hit_msg
    int 21h
    call new_line
    jmp move_done
    
miss:
    mov vis_board[bx], 'M'
    
    mov ah, 9
    lea dx, miss_msg
    int 21h
    call new_line
    
    jmp move_done
    
skip_move:
    ; Invalid move, restore missile
    inc missiles
    
move_done:
    ret
process_move endp

; Show accuracy percentage
show_accuracy proc
    ; Check for division by zero
    cmp shots, 0
    je zero_acc
    
    ; Calculate accuracy: (hits * 100) / shots
    mov al, hits
    mov ah, 0
    mov cx, 100
    mul cx
    
    mov cx, ax
    
    mov al, shots
    mov ah, 0
    
    mov bx, ax
    mov ax, cx
    
    mov dx, 0
    div bx
    
    ; Display accuracy
    mov cx, ax
    
    mov ah, 9
    lea dx, accuracy_msg
    int 21h
    
    ; Convert to digits
    mov ax, cx
    mov bl, 10
    div bl
    
    mov cl, ah
    
    mov ah, 2
    mov dl, al
    add dl, '0'
    int 21h
    
    mov dl, cl
    add dl, '0'
    int 21h
    
    mov ah, 9
    lea dx, percent_msg
    int 21h
    call new_line
    
    ret
    
zero_acc:
    mov ah, 9
    lea dx, accuracy_msg
    int 21h
    
    mov ah, 2
    mov dl, '0'
    int 21h
    
    mov ah, 9
    lea dx, percent_msg
    int 21h
    call new_line
    
    ret
show_accuracy endp

; Reveal ship locations
reveal_ships proc
    mov ah, 9
    lea dx, reveal_msg
    int 21h
    call new_line
    
    ; Display column numbers
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, ' '
    int 21h
    
    mov cx, 8
    mov dl, '1'
r_col_nums:
    int 21h
    mov dl, ' '
    int 21h
    inc dl
    loop r_col_nums
    
    call new_line
    
    ; Display board with ships
    mov cx, 8
    mov bx, 0
    mov dl, '1'
r_row_loop:
    push cx
    
    ; Row number
    mov ah, 2
    int 21h
    mov dl, ' '
    int 21h
    
    ; Row cells
    mov cx, 8
r_col_loop:
    mov ah, 2
    
    cmp board[bx], 1
    jne r_empty
    
    mov dl, 'S'
    jmp r_display
    
r_empty:
    mov dl, '-'
    
r_display:
    int 21h
    mov dl, ' '
    int 21h
    
    inc bx
    loop r_col_loop
    
    call new_line
    
    pop cx
    mov dl, '1'
    add dl, 8
    sub dl, cl
    loop r_row_loop
    
    call new_line
    ret
reveal_ships endp

; Clear screen
clear_screen proc
    mov ah, 0
    mov al, 3
    int 10h
    ret
clear_screen endp

; Print new line
new_line proc
    mov ah, 2
    mov dl, 13
    int 21h
    mov dl, 10
    int 21h
    ret
new_line endp

end main
