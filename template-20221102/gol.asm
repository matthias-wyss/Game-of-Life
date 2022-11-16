    ;;    game state memory location
    .equ CURR_STATE, 0x1000              ; current game state
    .equ GSA_ID, 0x1004                  ; gsa currently in use for drawing
    .equ PAUSE, 0x1008                   ; is the game paused or running
    .equ SPEED, 0x100C                   ; game speed
    .equ CURR_STEP,  0x1010              ; game current step
    .equ SEED, 0x1014                    ; game seed
    .equ GSA0, 0x1018                    ; GSA0 starting address
    .equ GSA1, 0x1038                    ; GSA1 starting address
    .equ SEVEN_SEGS, 0x1198              ; 7-segment display addresses
    .equ CUSTOM_VAR_START, 0x1200        ; Free range of addresses for custom variable definition
    .equ CUSTOM_VAR_END, 0x1300
    .equ LEDS, 0x2000                    ; LED address
    .equ RANDOM_NUM, 0x2010              ; Random number generator address
    .equ BUTTONS, 0x2030                 ; Buttons addresses

    ;; states
    .equ INIT, 0
    .equ RAND, 1
    .equ RUN, 2

    ;; constants
    .equ N_SEEDS, 4
    .equ N_GSA_LINES, 8
    .equ N_GSA_COLUMNS, 12
    .equ MAX_SPEED, 10
    .equ MIN_SPEED, 1
    .equ PAUSED, 0x00
    .equ RUNNING, 0x01

main:

	call random_gsa 

; BEGIN:clears_leds
clears_leds:
    stw zero, LEDS(zero)
    stw zero, LEDS+4(zero)
    stw zero, LEDS+8(zero)
	ret
; END:clear_leds
    

; BEGIN:set_pixel
set_pixel:
	cmpltui t0, a0, 4    ; if LEDS[0]
    cmpltui t1, a0, 8    ; if LEDS[1]
    nor t2, t0, t0
    and t1, t1, t2
    cmpltui t3, a0, 12   ; if LEDS[2]
    nor t4, t1, t1
    and t3, t3, t4

    bne t0, zero, CASE1
    bne t1, zero, CASE2
    bne t3, zero, CASE3

    CASE1: 
        slli a0, a0, 3
        add t5, a0, a1
        addi t6, zero, 1
        sll t6, t6, t5         ; shift left the 1 by t5
        stw t7, LEDS(zero)
        or t6, t6, t7  ; mask t5 or existing leds
        stw t6, LEDS(zero)

    CASE2: 
        addi a0, a0, -4
        slli a0, a0, 3
        add t5, a0, a1 
        addi t6, zero, 1
        sll t6, t6, t5
        stw t7, LEDS+4(zero)
        or t6, t6, t7
        stw t6, LEDS+4(zero)

    CASE3: 
        addi a0, a0, -8
        slli a0, a0, 3
        add t5, a0, a1 
        addi t6, zero, 1
        sll t6, t6, t5
        stw t7, LEDS+8(zero)
        or t6, t6, t7
        stw t6, LEDS+8(zero)

	ret
; END:set_pixel


; BEGIN:wait
wait:
    addi t0, zero, 1
    slli t0, t0, 19
    ldw t1, SPEED(zero)

    loop:
        sub t0, t0, t1
        bge t0, zero, loop
	ret
; END:wait


; BEGIN:get_gsa
get_gsa :
	addi t2, zero, GSA_ID
    beq t2, zero, STATE0
    bne t2, zero, STATE1


    STATE0 : 
    ldw v0, GSA0(a0) 
    ret

    STATE1 : 
    ldw v0, GSA1(a0) 
    ret
; END:get_gsa

; BEGIN:set_gsa 
set_gsa : 
   	addi t2, zero, GSA_ID
    beq t2, zero, STATE00
    bne t2, zero, STATE11

    STATE00 : 
    stw a0, GSA0(a1)
    ret

    STATE11 : 
    stw a0, GSA1(a1)
    ret

; END:set_gsa

; BEGIN draw_gsa 
draw_gsa : 

    addi t0, zero, 0
    addi t1, zero, 8

    bne t0, t1, ITERX

    ITERX : 
        addi t2, zero, 0 
        addi t3, zero, 12

        bne t2, t3, DRAW

        DRAW :
            add a0, t2, zero
            add a1, t0, zero
            call set_pixel
            addi t2, t2, 1
            addi t0, t0, 1 


; END:draw_gsa

; BEGIN:random_gsa 
random_gsa : 
	add t1, zero, zero ;;0 
    addi t2, zero, 11   ;; 11
    add t5, zero, zero ;; GSA 
    addi t0, zero, GSA_ID
    beq t0, zero, RANDOM_ZERO
    bne t0, zero, RANDOM_UN 
    


    RANDOM_ZERO : 
        bne t1, t2, ITER 
		ret

    RANDOM_UN : 
        bne t1, t2, ITER
		ret

    ITER :
        ldw t3, RANDOM_NUM(zero) ;; On prend un random num 
        andi t4, t3, 1 ;; On recupere le LSB de random_num 
        sll t4, t4, t1 ;; on le shift auquel on veut le mettre dans le gsa 
        or t5, t5, t4 ;; on OR pour introduire dans gsa 
        addi t1, t1, 1
		bne t1, t2, ITER
		beq t1, t2, end 

	end : 
		ret
		 
    

; END:random_gsa 

        

font_data:
    .word 0xFC ; 0
    .word 0x60 ; 1
    .word 0xDA ; 2
    .word 0xF2 ; 3
    .word 0x66 ; 4
    .word 0xB6 ; 5
    .word 0xBE ; 6
    .word 0xE0 ; 7
    .word 0xFE ; 8
    .word 0xF6 ; 9
    .word 0xEE ; A
    .word 0x3E ; B
    .word 0x9C ; C
    .word 0x7A ; D
    .word 0x9E ; E
    .word 0x8E ; F

seed0:
    .word 0xC00
    .word 0xC00
    .word 0x000
    .word 0x060
    .word 0x0A0
    .word 0x0C6
    .word 0x006
    .word 0x000

seed1:
    .word 0x000
    .word 0x000
    .word 0x05C
    .word 0x040
    .word 0x240
    .word 0x200
    .word 0x20E
    .word 0x000

seed2:
    .word 0x000
    .word 0x010
    .word 0x020
    .word 0x038
    .word 0x000
    .word 0x000
    .word 0x000
    .word 0x000

seed3:
    .word 0x000
    .word 0x000
    .word 0x090
    .word 0x008
    .word 0x088
    .word 0x078
    .word 0x000
    .word 0x000

    ;; Predefined seeds
SEEDS:
    .word seed0
    .word seed1
    .word seed2
    .word seed3

mask0:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF

mask1:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x1FF
	.word 0x1FF
	.word 0x1FF

mask2:
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF
	.word 0x7FF

mask3:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

mask4:
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0xFFF
	.word 0x000

MASKS:
    .word mask0
    .word mask1
    .word mask2
    .word mask3
    .word mask4

