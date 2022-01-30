.SET SCREEN_HEIGHT, 25
.set SCREEN_WIDTH, 80
.set ROW_LENGTH, 160
.set VIDEO_MEMORY, 0xB800
#.set BACKGROUND, 0xFF00
.set BACKGROUND, 0x0000
.set DRAW_PATTERN, 0xF000
.set PADDLE_HEIGHT, 5

.data
    p1_y:
        .short 4
    p2_y:
        .short 18
    ball_y:
        .word 10
    ball_x:
        .word 40
    ball_y_move:
        .word -1
    ball_x_move:
        .word 1
    game_started:
        .short 0

.code16
.text
.global _boot
_boot:
    #clear data, this may be required for real hw
    xor %ax, %ax
    mov %ax, %dx
    mov %ax, %es
    #video mode 80x25, 16 color
    mov $0x03, %al #0d
    mov $0x00, %ah
    int $0x10
    # disable cursor
    inc %ah
    mov $25, %ch
    int $0x10
main_loop:
#keyboard handling
    mov $0x01, %ah
    int $0x16
    jz draw_world
    mov $0x00, %ah
    int $0x16
    cmp $0x5000, %ax
    je down_p2
    cmp $0x4800, %ax
    je up_p2
    cmp $0x1F73, %ax #s
    je down_p1
    cmp $0x1177, %ax #w
    je up_p1
    jmp draw_world
    down_p1:
        movw $1, game_started
        incw p1_y
        cmp $20, p1_y
        jne draw_world
        decw p1_y
        jmp draw_world
    up_p1:
        movw $1, game_started
        decw p1_y
        jnz draw_world
        incw p1_y
        jmp draw_world
     down_p2:
         movw $1, game_started
         incw p2_y
         cmp $20, p2_y
         jne draw_world
         decw p2_y
         jmp draw_world
     up_p2:
         movw $1, game_started
         decw p2_y
         jnz draw_world
         incw p2_y
         jmp draw_world

draw_world:
    mov $VIDEO_MEMORY, %ax
	mov %ax, %es     #B000:0000
	xor %di, %di
    mov $BACKGROUND, %ax
    mov $(SCREEN_WIDTH*SCREEN_HEIGHT), %cx
    rep stosw

    mov $DRAW_PATTERN, %ax

    imul $ROW_LENGTH, p1_y, %bx
    mov %bx, %di
    mov $PADDLE_HEIGHT, %cx
    draw_paddle_p1:
        stosw
        add $(ROW_LENGTH-2), %di
        loop draw_paddle_p1

    imul $ROW_LENGTH, p2_y, %bx
    mov %bx, %di
    mov $PADDLE_HEIGHT, %cx
    add $(ROW_LENGTH-2), %di
    draw_paddle_p2:
        stosw
        add $(ROW_LENGTH-2), %di
        loop draw_paddle_p2

    imul $ROW_LENGTH, ball_y, %bx
    mov %bx, %di
    imul $2, ball_x, %bx
    add %bx, %di
    stosw

    cmp $1, game_started
    jne delay

#act
#is it p1=0 or p2=1
    cmp $(SCREEN_WIDTH/2), ball_x
    jb it_is_p1
    mov $1, %dx
    jmp move_ball
it_is_p1:
    mov $0, %dx

move_ball:
    mov ball_x_move, %ax
    add %ax, ball_x

    mov ball_y_move, %ax
    add %ax, ball_y

    cmp $79, ball_x
    jb collision_detection_y

    cmp $0, %dx
    je p1_collision
    #p2 collision detection
    mov ball_y, %ax
    sub p2_y, %ax
    cmp $PADDLE_HEIGHT, %ax
    jbe collision_x
    jmp end

    p1_collision:
    mov ball_y, %ax
    sub p1_y, %ax
    cmp $PADDLE_HEIGHT, %ax
    jbe collision_x
    jmp end
collision_x:
    mov ball_x_move, %ax
    neg %ax
    mov %ax, ball_x_move

collision_detection_y:
    cmp $24,ball_y
    jb delay
    mov ball_y_move, %ax
    neg %ax
    mov %ax, ball_y_move

delay:
    xor %dx, %dx
    mov $1, %cx
    mov $0x86, %ah
    int $0x15

   jmp main_loop
end:
    #reload boot sector
    int $0x19


