    /*
    This file is part of gamelib-x64.

    Copyright (C) 2014 Tim Hegeman

    gamelib-x64 is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    gamelib-x64 is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with gamelib-x64. If not, see <http://www.gnu.org/licenses/>.
    */

    .file "src/game/game.s"

    .global gameInit
    .global gameLoop

    .section .game.data

    enemy_list_base:.word 0x0012, 0x0414, 0x0804, 0x0c18, 0x1005, 0x1413, 0x1815, 0x1c16, 0x2002, 0x2405, 0x2808,  0x2c11, 0x300c, 0x340f, 0x3815, 0x3c0a, 0x4001, 0x4417, 0x4809, 0x4c0d 
    movment: .byte 0x2d, 0x5c, 0x7c, 0x2f 
    game_state: .byte 0

    //game menu:
    game_title: .asciz "SPINNING BLADES"
    play_button: .asciz "play"
    leaderboards_button: .asciz "leaderboards"
    exit_button: .asciz "exit"
    button_pointer: .byte 0
    current_key: .byte 0
    //leaderboard
    leaderboard_string: .asciz "Leaderboard"
    //gameover
    gameover_string: .asciz "GAMEOVER"
    press_any_button: .asciz "Press any button to continue"
    you_placed: .asciz "you placed  ' on the leaderboard!"

    delta_clock: .word 1000

    first: .quad 0
    second: .quad 0
    third: .quad 0
    fourth: .quad 0
    fifth: .quad 0


    .section .game.bss
    enemy_list: .skip 40
    player_coordinates: .skip 2

    number_converter: .skip 24
    .section .game.text

    //scrren 80-25 characters
    gameInit:
    	// call clear_screen

    	movq $10, %rdi
    	call setTimer
    	// leaq interval(%rip), %r13
    	// movb $0, (%r13)
    	xorq %r13, %r13
    	movq $10, %r12




    	leaq current_key(%rip), %r15
    	movb $0, (%r15)
    	ret


    clear_screen:
    	movq $79, %rdi
    	movq $24, %rsi
    	xorq %rdx, %rdx
    	movb $0x00, %cl

    loop_clear_screen:
    	pushq %rdi
    	pushq %rsi
    	call putChar
    	popq %rsi
    	popq %rdi
    	decq %rsi
    	jge loop_clear_screen
    	decq %rdi
    	movq $24, %rsi
    	jge loop_clear_screen
    	ret


    gameLoop:
    	# Check if a key has been pressed
    // call readKeyCode
    // cmpb $0, %al
    // je skip
    // movb %al, %dl
    // movb $40, %dil
    // movb $10, %sil
    // movb $0x0a, %cl
    // call putChar
    // skip:
    	leaq game_state(%rip), %r15
    	cmpb $1, (%r15)
    	jl display_menu
    	je get_input_menu
    	cmpb $3, (%r15)
    	jl gameplay
    	je get_input_leaderboard
    	jg get_input_gameover

    	// decq %r12
    	// jnz skip_speed_increment
    	// decb (%r15)
    	// movq $10, %r12

    	ret


    get_input_menu:
    	call readKeyCode
    	leaq  current_key(%rip), %r15
    	cmpb $0, %al
    	jne update_key
    	cmpb $0, (%r15)
    	jne key_release
    	ret 
    key_release:
    	movb (%r15), %al
    	movb $0, (%r15)
    	leaq button_pointer(%rip), %r15
    	cmpb $80, %al
    	jne skip_down_arrow
    	cmpb $2, (%r15)
    	je skip_enter
    	movb (%r15), %dil
    	incb %dil
    	call display_arrow
    	ret
    skip_down_arrow:
    	cmpb $72, %al
    	jne skip_arrow
    	leaq button_pointer(%rip), %r15
    	cmpb $0,(%r15)
    	je skip_enter
    	movb (%r15), %dil
    	decb %dil
    	call display_arrow 
    	ret
    skip_arrow:
    	cmpb $28, %al
    	jne skip_enter
    	call enter_press
    skip_enter:
    	ret
    update_key:
    	movb %al, (%r15)
    	ret


    get_input_gameover:
    	decq %r11
    	jg return
    	leaq current_key(%rip), %r15
    	call readKeyCode
    	cmpb $0, %al
    	jne update_key
    	cmpb $0, (%r15)
    	je return
    	xorq %r12, %r12
    	movb $0, (%r15)
    	leaq game_state(%rip), %r15
    	movb $0, (%r15)
    return:
    	ret
    // Enter press
    enter_press:
    	leaq button_pointer(%rip), %r15
    	cmpb $1, (%r15)
    	jl to_play
    	je to_leaderboard
    // movq $60, %rax
    // syscall //htf do I exit

    to_play:
    	leaq game_state(%rip), %r15
    	movb $2, (%r15)

    	call clear_screen
    	leaq player_coordinates(%rip), %r15
    	movw $0x010c, (%r15)
    	movb $1, %dil
    	movb $12, %sil
    	movb $62, %dl
    	movb $0x07, %cl
    	call putChar

    	leaq enemy_list_base(%rip), %r15
    	leaq enemy_list(%rip), %r14
    	movb $4, %bl
    loop_initialize_enemy_list:
    	movq (%r15, %rbx, 8), %rax
    	movq %rax, (%r14, %rbx, 8)
    	decb %bl
    	jge loop_initialize_enemy_list

    	movq $80, %rdi
    	call setTimer
    	//implement
    	xorq %r12, %r12
    	leaq delta_clock(%rip), %r15
    	movw $1000, (%r15)
    	xorq %r13, %r13
    	ret

    //to leaderboard screen
    to_leaderboard:
    	leaq game_state(%rip), %r15
    	movb $3, (%r15)
    	call clear_screen

    	leaq leaderboard_string(%rip), %rdx
    	movb $34, %dil
    	movb $4, %sil
    	movb $0x03, %cl
    	call display_string

    	leaq first(%rip), %rdi
    	cmpq $0, (%rdi)
    	je skip_first
    	movq $1, %rsi
    	call display_score
    skip_first:
    	leaq second(%rip), %rdi
    	cmpq $0, (%rdi)
    	je skip_second
    	movq $2, %rsi
    	call display_score
    skip_second:
    	leaq third(%rip), %rdi
    	cmpq $0, (%rdi)
    	je skip_third
    	movq $3, %rsi
    	call display_score
    skip_third:
    	leaq fourth(%rip), %rdi
    	cmpq $0, (%rdi)
    	je skip_fourth
    	movq $4, %rsi
    	call display_score
    skip_fourth:
    	leaq fifth(%rip), %rdi
    	cmpq $0, (%rdi)
    	je skip_fifth
    	movq $5, %rsi
    	call display_score
    skip_fifth:
    	movb $28, %dil
    	movb $23, %sil
    	movb $0x0f, %cl
    	leaq press_any_button(%rip), %rdx
    	call display_string
    	ret


    // rdi:addressToScore, rsi:place
    display_score: 
    	movq (%rdi), %rdi
    	call number_converter_function
    	movq %rax, %rdx
    	cmpq $2, %rsi
    	jl print_1
    	je print_2
    	cmpq $4, %rsi
    	jl print_3
    	je print_4
    	jg print_5
    	//implement
    	ret

    print_1:
    	movb $33, %dil
    	movb $7, %sil
    	movb $0x0f, %cl
    	movb $49, %r8b
    	call reverse_print
    	ret
    print_2:
    	movb $33, %dil
    	movb $9, %sil
    	movb $0x0f, %cl
    	movb $50, %r8b
    	call reverse_print
    	ret
    print_3:
    	movb $33, %dil
    	movb $11, %sil
    	movb $0x0f, %cl
    	movb $51, %r8b
    	call reverse_print
    	ret
    print_4:
    	movb $33, %dil
    	movb $13, %sil
    	movb $0x0f, %cl
    	movb $52, %r8b
    	call reverse_print
    	ret
    print_5:
    	movb $33, %dil
    	movb $15, %sil
    	movb $0x0f, %cl
    	movb $53, %r8b
    	call reverse_print
    	ret
    // dil:startX, sil:y, %rdx:index, cl:colour, r8b:place
    reverse_print:
    	movq %rdx, %rbx
    	pushq %rcx
    	pushq %rdi
    	pushq %rsi
    	movb %r8b, %dl
    	movb $0x0c, %cl
    	call putChar
    	popq %rsi
    	popq %rdi
    	popq %rcx
    	movb $58, %dl
    	incb %dil
    	pushq %rcx
    	pushq %rdi
    	pushq %rsi
    	call putChar
    	popq %rsi
    	popq %rdi
    	popq %rcx
    	inc %dil

    	leaq number_converter(%rip), %r8
    loop_reverse_print:
    	movb (%r8, %rbx, 1), %dl
    	pushq %rdi
    	pushq %rsi
    	call putChar
    	popq %rsi
    	popq %rdi
    	incb %dil
    	decq %rbx
    	jge loop_reverse_print

    	ret

    	
    	



    get_input_leaderboard:
    	leaq current_key(%rip), %r15
    	call readKeyCode
    	cmpb $0, %al
    	jne update_key
    	cmpb $0, (%r15)
    	jne to_menu
    	//implement
    	ret
    to_menu:
    	movb $0, (%r15) 
    	leaq game_state(%rip), %r15
    	movb $0, (%r15)
    	ret




    // rdi: 0->play, 1->leaderboards, 2->exit
    display_arrow:
    	pushq %rdi
    	leaq button_pointer(%rip), %r15
    	movb (%r15), %r14b
    	cmpb $1, %r14b 
    	jl cancel_arrow_0
    	je cancel_arrow_1
    	jg cancel_arrow_2
    skip_cancel_arrow:
    	popq %rdi
    	cmpb $1, %dil
    	jl display_arrow_0
    	je display_arrow_1
    	jg display_arrow_2
    	// ret
    cancel_arrow_0:
    	movb $36, %dil
    	movb $8, %sil
    	xorq %rdx, %rdx
    	call putChar
    	jmp skip_cancel_arrow

    cancel_arrow_1:
    	movb $32, %dil
    	movb $10, %sil
    	xorq %rdx, %rdx
    	call putChar
    	jmp skip_cancel_arrow

    cancel_arrow_2:
    	movb $36, %dil
    	movb $12, %sil
    	xorq %rdx, %rdx
    	call putChar
    	jmp skip_cancel_arrow

    display_arrow_0:
    	movb $36, %dil
    	movb $8, %sil
    	movb $62, %dl
    	movb $0x0b, %cl
    	call putChar
    	leaq button_pointer(%rip), %r15
    	movb $0, (%r15)
    	ret 

    display_arrow_1:
    	movb $32, %dil
    	movb $10, %sil
    	movb $62, %dl
    	movb $0x0b, %cl
    	call putChar
    	leaq button_pointer(%rip), %r15
    	movb $1, (%r15)
    // loop_no_input:
    // 	call readKeyCode
    // 	cmpb $0, %al
    // 	jne loop_no_input
    	ret

    display_arrow_2:
    	movb $36, %dil
    	movb $12, %sil
    	movb $62, %dl
    	movb $0x0b, %cl
    	call putChar
    	leaq button_pointer(%rip), %r15
    	movb $2, (%r15)
    	ret

    display_menu:
    	movb $1, (%r15)
    	call clear_screen

    	leaq game_title(%rip), %rdx
    	movb $32, %dil
    	movb $5, %sil
    	movb $0x06, %cl
    	call display_string

    	leaq play_button(%rip), %rdx
    	movb $38, %dil
    	movb $8, %sil
    	movb $0x02, %cl
    	call display_string

    	leaq leaderboards_button(%rip), %rdx
    	movb $34, %dil
    	movb $10, %sil
    	movb $0x03, %cl
    	call display_string

    	leaq exit_button(%rip), %rdx
    	movb $38, %dil
    	movb $12, %sil
    	movb $0x04, %cl
    	call display_string

    	jmp display_arrow_0

    //dil:starting x, sil:y, rdx:starting character addrees, cl:color 
    display_string:
    	movq %rdx, %r8
    	movb (%r8), %dl
    loop_display_string:
    	pushq %rdi
    	pushq %rsi
    	call putChar
    	popq %rsi
    	popq %rdi
    	incb %dil
    	incq %r8
    	movb (%r8), %dl
    	cmpb $0, %dl
    	jne loop_display_string
    	ret





    gameplay:
    	leaq current_key(%rip), %r15
    	call readKeyCode
    	cmpb $0, %al
    	jne update_key
    	cmpb $0, (%r15)
    	je skip_update_player_position
    	
    	movb (%r15), %al
    	movb $0, (%r15)
    	leaq player_coordinates(%rip), %r15
    	cmpb $72, %al
    	jne skip_move_up
    	cmpb $0, (%r15)
    	jle skip_update_player_position
    	call delete_old_position
    	decb (%r15)
    	jmp skip_all_moves
    skip_move_up:
    	cmpb $80, %al
    	jne skip_move_down
    	cmpb $24,(%r15)
    	jge skip_update_player_position
    	call delete_old_position
    	incb (%r15)
    	jmp skip_all_moves
    skip_move_down:
    	cmpb $75, %al
    	jne skip_move_left
    	cmpb $1, 1(%r15)
    	jle skip_update_player_position
    	call delete_old_position
    	decb 1(%r15)
    	jmp skip_all_moves
    skip_move_left:
    	cmpb $77, %al
    	jne skip_move_right
    	cmpb $79, 1(%r15)
    	jge skip_update_player_position
    	call delete_old_position
    	incb 1(%r15)
    	jmp skip_all_moves
    skip_move_right:
    	// cmpb $?, %al
    	// skip ?      implement Esc
    skip_all_moves:
    	movb 1(%r15), %dil
    	movb (%r15), %sil
    	movb $0x07, %cl
    	movb $62, %dl
    	call putChar

    skip_update_player_position:
    	leaq delta_clock(%rip), %r15
    	cmpw %r13w, (%r15)
    	jne skip_cycle_enemy
    	xorq %r13, %r13
    	incq %r12
    	cmpb $0xf0, %r12b
    	jl skip_speed_increment
    	cmpw $200, (%r15)
    	jle skip_speed_increment
    	decw (%r15)
    skip_speed_increment:
    	movq %r12, %rdi
    	call display_current_score     

    update_enemy_positions:
    	movq $19, %rbx
    	leaq enemy_list(%rip), %r8
    	leaq movment(%rip), %r9
    	leaq player_coordinates(%rip), %r10
    	movw (%r10), %r10w
    	movq $0x0c, %rcx
    	xorq %r15, %r15
    update_enemy_loop:
    	movb 1(%r8, %rbx, 2), %r15b
    	// cmpb $79, %r15b
    	// jg skip_all_mid
    	xorq %rdx, %rdx
    	movb (%r8, %rbx, 2), %sil
    	movb %r15b, %dil
    	call putChar
    	movw (%r8, %rbx, 2), %r14w
    	cmpw %r14w, %r10w
    	je gameover
    	addw $0x100, %r14w
    	cmpw %r14w, %r10w
    	je gameover	
    	addw $0x100, %r14w
    	cmpw %r14w, %r10w
    	je gameover
    skip_cancel:
    	decb 1(%r8, %rbx, 2)
    	decb %r15b
    	cmpb $0, %r15b
    	je pacman
    	andb $0x3, %r15b
    	movb (%r9, %r15, 1), %dl
    	movb 1(%r8, %rbx, 2), %dil
    	movb (%r8, %rbx, 2), %sil
    	call putChar
    skip_all:
    	cmpw (%r8, %rbx, 2), %r10w
    	je gameover
    	decq %rbx
    	cmpq $0, %rbx
    	jge update_enemy_loop
    skip_cycle_enemy:
    	incw %r13w 
    	ret

    pacman:
    	movb $79, 1(%r8, %rbx, 2)
    	movb %r12b, %al
    	andb $0xf, %al
    	cmpb $14, %al
    	jne skip_randomizer
    	leaq player_coordinates(%rip), %r15
    	movb (%r15), %al
    	movb %al, (%r8, %rbx, 2)
    skip_randomizer:
    	jmp update_enemy_loop

    skip_all_mid:
    	decb %r15b
    	movb %r15b, 1(%r8, %rbx, 2)
    	jmp skip_all

    delete_old_position:
    	movb (%r15), %sil
    	movb 1(%r15), %dil
    	movb $0, %dl
    	call putChar
    	ret

    gameover:
    	//implement
    	leaq game_state(%rip), %r15
    	movb $4, (%r15)
    	leaq gameover_string(%rip), %rdx
    	movb $36, %dil
    	movb $10, %sil
    	movb $0x0c, %cl
    	call display_string

    	leaq press_any_button(%rip), %rdx
    	movb $12, %sil
    	movb $28, %dil
    	movb $0x0f, %cl
    	call display_string
    	movq $1000, %r11

    	// movb $38, %dil
    	// movb $14, %sil
    	// movb $0x0e, %cl
    	// movq %r12, %rdi
    	// call number_converter
    	// call display_current_score

    	movb $14, %sil
    	movb $26, %dil
    	movb $0x0f, %cl
    	leaq you_placed(%rip), %rdx
    	movb $0, %r9b

    	leaq first(%rip), %r15
    	cmpq (%r15), %r12
    	jle skip_first_place
    	movb $49, 11(%rdx)
    	call display_string
    	movb $1, %r9b
    	movq (%r15), %rax
    	movq %r12, (%r15)
    	movq %rax, %r12
    skip_first_place:
    	addq $8, %r15
    	cmpq (%r15), %r12
    	jle skip_second_place
    	movq (%r15), %rax
    	movq %r12, (%r15)
    	movq %rax, %r12
    	cmpb $1, %r9b
    	je skip_second_place
    	movb $50, 11(%rdx)
    	call display_string
    	movb $1, %r9b
    skip_second_place:
    	addq $8, %r15
    	cmpq (%r15), %r12
    	jle skip_third_place
    	movq (%r15), %rax
    	movq %r12, (%r15)
    	movq %rax, %r12
    	cmpb $1, %r9b
    	je skip_third_place
    	movb $51, 11(%rdx)
    	call display_string
    skip_third_place:
    	addq $8, %r15
    	cmpq (%r15), %r12
    	jle skip_fourth_place
    	movq (%r15), %rax
    	movq %r12, (%r15)
    	movq %rax, %r12
    	cmpb $1, %r9b
    	je skip_fourth_place
    	movb $52, 11(%rdx)
    	call display_string
    skip_fourth_place:
    	addq $8, %r15
    	cmpq (%r15), %r12
    	jle skip_fifth_place
    	movq %r12, (%r15)
    	cmpb $1, %r9b
    	je skip_fifth_place
    	movb $53, 11(%rdx)
    	call display_string
    skip_fifth_place:
    	movq $7, %rdi
    	call setTimer


    	ret

    display_current_score:
    	call number_converter_function
    // 	leaq number_converter(%rip), %r8 
    // 	movq %rdi, %rax
    // 	xorq %rdx, %rdx
    // 	movq $10, %r10
    // 	xorq %rbx, %rbx
    // loop_display_current_score:
    // 	divq %r10
    // 	addb $48, %dl
    // 	movb %dl, (%r8, %rbx, 1)
    // 	incq %rbx
    // 	xorq %rdx, %rdx
    // 	cmpq $0, %rax
    // 	jne loop_display_current_score
    	leaq number_converter(%rip), %r15
    	movb $0, %sil
    	movb $75, %dil
    	movb $0x0f, %cl
    loop_print_score:
    	movb (%r15, %rbx, 1), %dl
    	pushq %rdi
    	pushq %rsi
    	call putChar
    	popq %rsi
    	popq %rdi
    	incq %rdi
    	decq %rbx
    	jge loop_print_score

    	ret		

    // rdi:number, ret: index
    number_converter_function:
    	movq %rdi, %rax
    	xorq %rdx, %rdx
    	leaq number_converter(%rip), %r15
    	movq $10, %r8
    	xorq %rbx, %rbx
    loop_number_converter:
    	divq %r8
    	addb $48, %dl
    	movb %dl, (%r15, %rbx, 1)
    	cmpq $0, %rax
    	je end_number_converter
    	incq %rbx
    	xorq %rdx, %rdx
    	jmp loop_number_converter
    end_number_converter:
    	movq %rbx, %rax
    	ret



