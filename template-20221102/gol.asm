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
  ; FINAL : 
  ; call reset_game 
  ; call get_input
  ; add t0, zero, v0 ; edgecapture 
  ; add t1, zero, zero 
  ; bne t1, zero, SUITE

   ;SUITE : 
   ;add a0, t0, zero 
   ;addi sp, sp, -4
   ;stw t0, CUSTOM_VAR_END(sp)
   ;call select_action
   ;ldw t0, CUSTOM_VAR_END(sp)
   ;addi sp, sp, 4
   ;add a0, zero, t0
   ;call update_state
   ;call update_gsa 
   ;call mask 
   ;call draw_gsa
   ;call wait 
   ;call decrement_step
   ;add t1, zero, v0
   ;call get_input
   ;add t0, v0, zero 
   ;beq t1, zero, SUITE
   ;beq zero, zero, FINAL

end: 
	break 

; BEGIN:clear_leds
clear_leds:
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
        ldw t7, LEDS(zero)
        or t6, t6, t7  ; mask t5 or existing leds
        stw t6, LEDS(zero)
        ret

    CASE2: 
        addi a0, a0, -4
        slli a0, a0, 3
        add t5, a0, a1 
        addi t6, zero, 1
        sll t6, t6, t5
        ldw t7, LEDS+4(zero)
        or t6, t6, t7
        stw t6, LEDS+4(zero)
        ret

    CASE3: 
        addi a0, a0, -8
        slli a0, a0, 3
        add t5, a0, a1 
        addi t6, zero, 1
        sll t6, t6, t5
        ldw t7, LEDS+8(zero)
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
get_gsa:
	ldw t2, GSA_ID(zero)
	slli t6, a0, 2
    beq t2, zero, STATE0
    bne t2, zero, STATE1


    STATE0 : 
    ldw v0, GSA0(t6) 
    ret

    STATE1 : 
    ldw v0, GSA1(t6) 
    ret
ret
; END:get_gsa

; BEGIN:set_gsa 
set_gsa: 
   	ldw t7, GSA_ID(zero) ; to know which gsa is used 
    slli t6, a1, 2
    beq t7, zero, STATE00 ; state GSa0 
    bne t7, zero, STATE11 ; state GSa 1 

    STATE00 : 
    stw a0, GSA0(t6)
    ret

    STATE11 : 
    stw a0, GSA1(t6)
    ret
ret
; END:set_gsa


; BEGIN:draw_gsa 
draw_gsa: 
addi t0, zero, -1 ; iter sur y de 0 a 7
addi t3, zero, N_GSA_LINES
    ITER_Y : 
    addi t7, zero, 3 ; nm max de x dans un LED 
    addi t4, zero, -1 ; iterateur sur toute la ligne x 
    addi t0, t0, 1
    addi a0, t0, 0 ; pour recup call gsa (numero de la ligne)
   ; add s3, ra, zero

    addi sp, sp, -4 
    stw ra, CUSTOM_VAR_END(sp)
    addi sp, sp, -4  
    stw t3, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw t7, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw t4, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw t0, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw a0, CUSTOM_VAR_END(sp)

    call get_gsa

    ldw a0, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw t0, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw t4, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw t7, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw t3, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw ra, CUSTOM_VAR_END(sp)
    addi sp, sp, 4

    bne t0, t3, ITER_LINE
    ret
    
    ITER_LINE : 
        addi t1, zero, -1 ; iterateur entre 0 et 3
        br ITER_LED0
        ret
        
        ITER_LED0 : 
        addi t5, zero, 1 ; masl
        addi t4, t4, 1
        sll t5, t5, t4 ; mask le bit qu'on veut recuperer  
        addi t1, t1, 1 
        and t5, v0, t5 ; on applique le mask sur t5 
        srl t5, t5, t4
        slli s5, t1, 3 ; fois 8
        add s5, s5, t0 ; + y 
        add s4, zero, t5
        sll s4, s4, s5
        ldw s6, LEDS(zero) ; on recup la valeur de la LED precedente 
        or s4, s6, s4 ; on concatene le tout 
        stw s4, LEDS(zero)  ; on le met dans LED0 
        bne t1, t7, ITER_LED0 
        beq t1, t7, ITER_LED1
        ret

        ITER_LED1 : 
            addi t5, zero, 1 
            addi t4, t4, 1
            sll t5, t5, t4
            addi t1, t4, 0
            addi t1, t1, -4
            and t5, v0, t5
            srl t5, t5, t4
            slli s5, t1, 3
            add s5, s5, t0
            add s4, zero, t5
            sll s4, s4, s5
            ldw s6, LEDS+4(zero)
            or s4, s6, s4 
            stw s4, LEDS+4(zero)
            bne t1, t7, ITER_LED1 
            beq t1, t7, ITER_LED2
            ret


        ITER_LED2 : 
            addi t5, zero, 1 
            addi t4, t4, 1
            sll t5, t5, t4
            addi t1, t4, 0
            addi t1, t1, -8
            and t5, v0, t5
            srl t5, t5, t4
            slli s5, t1, 3
            add s5, s5, t0
            add s4, zero, t5
            sll s4, s4, s5
            ldw s6, LEDS+8(zero)
            or s4, s6, s4 
            stw s4, LEDS+8(zero)
            bne t1, t7, ITER_LED2
            addi s7, t0, 1 
            bne s7, t3, ITER_Y
            ret
    ret
; END:draw_gsa

; BEGIN:random_gsa 
random_gsa: 
		addi t6, zero, 7
        add s1, zero, zero ; iterateur sur Y
		br OKLM 
	OKLM : 
	add t1, zero, zero ;;0  
    addi t2, zero, 12   ;; 11 MAX
    add t5, zero, zero ;; GSA 
    ;ldw t0, GSA_ID(zero)
    addi t0, zero, 8
	br ITER 
   ; addi s1, zero, 12 
    ITER :
        ldw t3, RANDOM_NUM(zero) ; On prend un random num 
        andi t4, t3, 1 ; On recupere le LSB de random_num 
        sll t4, t4, t1 ; on le shift auquel on veut le mettre dans le gsa 
        or t5, t5, t4 ;on OR pour introduire dans gsa 
        addi t1, t1, 1 ; + 1 a l'iteration 
		bne t1, t2, ITER
		beq t1, t2, SET_G

    SET_G : 
        add a0, t5, zero 
        add a1, s1, zero
		;add s1, zero, ra

        addi sp, sp, -4 
        stw ra, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t0, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw s1, CUSTOM_VAR_END(sp) 

        call set_gsa
        ldw s1, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t0, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw ra, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
		;add ra, s1, zero
        addi s1, s1, 1
        bne s1, t0, OKLM 
		ret   
ret		 
; END:random_gsa 

; BEGIN:change_speed 
change_speed: 
        ldw t1, SPEED(zero)
        addi t2, zero, MAX_SPEED
        addi t3, zero, MIN_SPEED

        beq a0, zero, INCREMENT
        bne a0, zero, DECREMENT

            INCREMENT : 
            bne t1, t2, ADD1

                ADD1 : 
                addi t1, t1, 1
                stw t1, SPEED(zero)            
            ret 
            DECREMENT : 
            bne t1, t3, SUB1

                SUB1 : 
                addi t1, t1, -1
                stw t1, SPEED(zero)
            ret
    ret
; END:change_speed

; BEGIN:pause_game 
pause_game: 
        ldw t1, PAUSE(zero)
        addi t2, zero, PAUSED
        addi t3, zero,  RUNNING
        beq t1, t2, ISPAUSED
        beq t1, t3, ISRUNNING 


        ISPAUSED : 
        stw t3, PAUSE(zero)
        ret

        ISRUNNING : 
        stw t2, PAUSE(zero) 
        ret
    ret
; END:pause_game 

; BEGIN:change_steps
change_steps:
    ldw t0, CURR_STEP(zero) 
    bne a0, zero, UNITS
    bne a1, zero, TENS 
    bne a2, zero, HUNDREDS

    UNITS :
        addi t0, t0, 1
        stw t0, CURR_STEP(zero)
        ret

    TENS :
        addi t0, t0, 10
        stw t0, CURR_STEP(zero)
        ret

    HUNDREDS :
        addi t0, t0, 256
        stw t0, CURR_STEP(zero)
        ret
ret
; END:change_steps

; BEGIN:increment_seed
increment_seed: 
 addi sp, sp, -4
 stw ra, CUSTOM_VAR_END(sp)


    ldw t1, CURR_STATE(zero) ; current state 
    addi t0, zero, INIT ; state INIT 
    addi t3, zero, RAND ; state RAND
 add t4, zero, zero
    add t6, zero, zero
 add s5, zero, zero
    addi t7, zero, N_SEEDS
    addi s0, zero, N_GSA_LINES
 add a1, zero, zero
    beq t0, t1, INIT_STATE   ; case currenstate equals INIT state 
    beq t3, t1, RAND_STATE

        INIT_STATE :
            ldw t2, SEED(zero) ; game seed
            addi t2, t2, 1 ; increment by one 
            stw t2, SEED(zero)
            beq t2, t7, RAND_STATE
            jmpi SET_G2
            ret

        SET_G2 :
   slli t6, t2, 2
   ldw t5, SEEDS(t6)
   add t5, t5, s5
   ldw a0, 0(t5)
   addi sp, sp, -4
   ;stw ra, CUSTOM_VAR_END(sp)
   ;addi sp, sp, -4
   stw t2, CUSTOM_VAR_END(sp)
   addi sp, sp, -4
   stw t5, CUSTOM_VAR_END(sp)
   addi sp, sp, -4
   stw s0, CUSTOM_VAR_END(sp)
   call set_gsa
   ldw s0, CUSTOM_VAR_END(sp)
   addi sp, sp, 4
   ldw t5, CUSTOM_VAR_END(sp)
   addi sp, sp, 4
   ldw t2, CUSTOM_VAR_END(sp)
   addi sp, sp, 4


   addi s5, s5, 4 ; next word
   addi a1, a1, 1
   bne a1, s0, SET_G2
   ldw ra, CUSTOM_VAR_END(sp)
   addi sp, sp, 4
   ret

        RAND_STATE :
			;addi sp, sp, -4
            ;stw ra, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t2, CUSTOM_VAR_END(sp)
            call random_gsa
            ldw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw ra, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            addi t2, zero, 4
            stw t2, SEED(zero)
            ret
 ret
; END:increment_seed


; BEGIN:update_state
update_state:
    ldw t0, CURR_STATE(zero) ; current state
    ldw s0, SEED(zero)
    addi t1, zero, INIT ; state INIT
    addi t2, zero, RAND ; state RAND
    addi t3, zero, RUN ; state RUN
    add t6, a0, zero ; edgecapture input
    ;slli t6, t6, 27 ; on garde que les 5 buttons
    addi t7, zero, N_SEEDS
    beq t0, t1, CASE_INIT
    beq t0, t2, CASE_RAND
    beq t0, t3, CASE_RUN
    ret

        CASE_INIT: 
            addi t4, zero, 1 ; mask for b0
            ;slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, CHECK_EQUAL
        return_init_1:
            addi t4, zero, 2 ; mask for b1
            ;slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, SET_RUN_1
        return_init_2:
            addi t4, zero, 29 ; mask for 11101
            ;slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, CHECK_LOWER
        return_init_3:
            ret
            
            CHECK_EQUAL:
                beq s0, t7, SET_RANDOM_1
            return_check_equal:
                jmpi return_init_1

                SET_RANDOM_1:
                    stw t2, CURR_STATE(zero)
                    jmpi return_check_equal

            SET_RUN_1:
                stw t3, CURR_STATE(zero)
                jmpi return_init_2

            CHECK_LOWER:
                blt s0, t7, SET_INIT
            return_check_lower:
                jmpi return_init_3

                SET_INIT:
                    stw t1, CURR_STATE(zero)
                    jmpi return_check_lower

        CASE_RAND:
            addi t4, zero, 2 ; mask for b1
            slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, SET_RUN_2
        return_rand_1:
            addi t4, zero, 29 ; mask for 11101
            slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, SET_RANDOM_2
        return_rand_2:
            ret

            SET_RUN_2:
                stw t3, CURR_STATE(zero)
                jmpi return_rand_1

            SET_RANDOM_2:
                stw t2, CURR_STATE(zero)
                jmpi return_rand_2

        CASE_RUN:
            addi t4, zero, 8 ; mask for b3
            slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, SET_INIT_AND_RESET
        return_run_1:
            addi t4, zero, 23 ; mask for 10111
            slli t4, t4, 27 ; on garde que pour les 5 buttons
            and t5, t4, t6 ; apply mask
            beq t5, t4, SET_RUN_3
        return_run_2:
            ret

            SET_INIT_AND_RESET:
                stw t1, CURR_STATE(zero)
                ;call reset_game
                jmpi return_run_1

            SET_RUN_3:
                stw t3, CURR_STATE(zero)
                jmpi return_run_2 
    ret    
; END:update_state


; BEGIN:select_action 
select_action:
    addi sp, sp, -4
    stw ra, CUSTOM_VAR_END(sp)
    ldw t0, CURR_STATE(zero)
    addi t2, zero, 3 ; SEED maximal 
    addi s0, zero, 1; 00001
    slli s1, s0, 1 ; 00010
    slli s2, s1, 1 ; 00100
    slli s3, s2, 1 ; 01000
    slli s4, s3, 1 ; 10000
    addi s5, zero, INIT ; value of init state 
    addi s6, zero, RAND ; value of rand state 
    addi s7, zero, RUN ; value of run state 

    beq t0, s7, RUN_S  ;state run 
    beq t0, s6, RAND_S ; state rand
    beq t0, s5, INIT_S  ; state init 



    INIT_S : 
    ldw t3, SEED(zero)
    and t4, s0, a0 ; to see if button 0 is pressed 
    beq t4, s0, BUTTON0 ; if button 0 is pressed we go to state button0 
    and t5, s2, a0 ; to see if button 2 is pressed 
    and t6, s3, a0 ; to see if button 3 is pressed 
    and t7, s4, a0 ; to see if button 4 is pressed 
    cmpeq t5, t5, s2  ; 
    cmpeq t6, t6, s3
    cmpeq t7, t7, s4 
    or t1, t5, t6
    or t1, t1, t7
    beq t1, s0, BUTTON234
    ldw ra, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ret

        
        BUTTON0 : 
            bne t2, t3, REGISTER 

            REGISTER : 
                addi sp, sp, -4
                stw a0, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t0, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t1, CUSTOM_VAR_END(sp)
                addi sp, sp, -4 
                stw t2, CUSTOM_VAR_END(sp)
                addi sp, sp, -4 
                stw t3, CUSTOM_VAR_END(sp)
                addi sp, sp, -4 
                stw t4, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw s0, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t5, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t6, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t7, CUSTOM_VAR_END(sp)
                
                call increment_seed

                ldw t7, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t6, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t5, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw s0, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t4, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t3, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t2, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t1, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw t0, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw a0, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                jmpi INIT_S+12

        BUTTON234 : 
                addi sp, sp, -4
                stw a0, CUSTOM_VAR_END(sp)
                addi sp, sp, -4
                stw t0, CUSTOM_VAR_END(sp)
                add a0, zero, t7
                add a1, zero, t6
                add a2, zero, t5
                call change_steps
                ldw t0, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                ldw a0, CUSTOM_VAR_END(sp)
                addi sp, sp, 4
                jmpi INIT_S+48

    RAND_S : 
        and t4, s0, a0 ; to see if button 0 is pressed 
        beq t4, s0, BUTTON0_R
        and t5, s2, a0 ; to see if button 2 is pressed 
        and t6, s3, a0 ; to see if button 3 is pressed 
        and t7, s4, a0 ; to see if button 4 is pressed 
        cmpeq t5, t5, s2  ; 
        cmpeq t6, t6, s3
        cmpeq t7, t7, s4 
        or t1, t5, t6
        or t1, t1, t7
        beq t1, s0, BUTTON234_R
        ldw ra, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ret

        BUTTON0_R : 
            addi sp, sp, -4
            stw t0, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t4, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t5, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t6, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t7, CUSTOM_VAR_END(sp)

            call random_gsa
            
            ldw t7, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t6, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t5, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t4, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t0, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            jmpi RAND_S+8

         BUTTON234_R : 
            addi sp, sp, -4
            stw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t0, CUSTOM_VAR_END(sp)
            add a0, zero, t7
            add a1, zero, t6
            add a2, zero, t5
            call change_steps
            ldw t0, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            jmpi RAND_S+44 


    RUN_S : 
        and t4, s0, a0 ; to see if button 0 is pressed 
        beq t4, s0, BUTTON0_RUN
        and t1, s1, a0
        beq t1, s1, BUTTON1_RUN
        and t5, s2, a0 ; to see if button 2 is pressed 
        beq t5, s2, BUTTON2_RUN
        and t7, s4, a0 ; to see if button 4 is pressed 
        beq t7, s4, BUTTON4_RUN
        ldw ra, CUSTOM_VAR_END(sp)
        addi sp, sp, -4
        ret
        
        BUTTON0_RUN : 
            addi sp, sp, -4
            stw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, -4

            call pause_game

            ldw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            jmpi RUN_S+8
        
        BUTTON1_RUN : 
            addi sp, sp, -4
            stw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, -4

            addi a0, zero, 0
            call change_speed

            ldw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            jmpi RUN_S+16

        BUTTON2_RUN : 
            addi sp, sp, -4
            stw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, -4
            stw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, -4

            addi a0, zero, 1
            call change_speed

            ldw a0, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t3, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t2, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            ldw t1, CUSTOM_VAR_END(sp)
            addi sp, sp, 4
            jmpi RUN_S+24
        

        BUTTON4_RUN : 
            call random_gsa
            jmpi RUN_S+32 
    ret
; END:select_action 

; BEGIN:cell_fate 
cell_fate : 
    addi t0, zero, 1
    addi t1, zero, 2
    addi t2, zero, 4
    addi t3, zero, 3
    beq a1, t0, LIVING ;living cell 
    beq a1, zero, DIED ; the cell is initially at 0 

    LIVING: 
        bltu a0, t1, DIE
        bgeu a0, t2, DIE
        beq a0, t1, STAY
        beq a0, t3, STAY


        DIE: 
            add v1, zero, zero
            ret 
        LIVE: 
            addi v1, zero, 1
            ret
        STAY: 
            addi v1, zero, 1
            ret

    DIED : 
        beq a0, t3, BECOME_ALIVE
        ret
        

        BECOME_ALIVE:
            addi v1, zero, 1
            ret
    ret
; END:cell_fate 
         
; BEGIN:find_neighbours
find_neighbours:
    ; state of the cell (v1 part)
    add t0, a0, zero ; switch a0 and a1 for get_gsa (we need a0 : y)
    add a0, a1, zero ; a0 : y coordinate
    add a1, t0, zero ; a1 : x coordinate
    addi sp, sp, -4 
    stw ra, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw t0, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw a0, CUSTOM_VAR_END(sp)
    addi sp, sp, -4 
    stw a1, CUSTOM_VAR_END(sp)
    call get_gsa ; gsa of y coord in v0
    ldw a1, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw a0, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ldw t0, CUSTOM_VAR_END(sp)
    addi sp, sp, 4 

    addi t0, zero, 1 ; create mask
    sll t0, t0, a1 ; shift mask
    and t0, t0, v0 ; apply mask 
    srl v1, t0, a1 ; reshift and store in v1

    ; number of living neighbours (v0 part)
    addi s2, zero, N_GSA_COLUMNS ; max x
    addi t3, zero, N_GSA_LINES ; max y
    add t4, zero, zero ; neighbours counter

    add s0, zero, a1 ; x1
    add s1, zero, a0 ; x2
    addi s0, s0, 1
    addi s1, s1, 1
    call MOD
    addi s1, s1, -1
    call MOD
    addi s0, s0, -1
    addi s1, s1, 1
    call MOD
    addi s0, s0, -1
    addi s1, s1, -2
    call MOD
    addi s1, s1, 1
    call MOD
    addi s0, s0, 1
    addi s1, s1, -1
    call MOD
    addi s0, s0, -1
    addi s1, s1, 2
    call MOD
    addi s0, s0, 2
    addi s1, s1, -2
    call MOD
    add v0, t4, zero 
    ldw ra, CUSTOM_VAR_END(sp)
    addi sp, sp, 4
    ret
    

        MOD:
            blt s0, zero, LOWER ; si inferieur 0 on ajoute 12
            return_mod_1:
            bge s0, s2, GREATER ; si superieur 12 on enleve 12
            return_mod_2:
            slli s1, s1, 29
            srli s1, s1, 29 ; on prend les 3 LSB = mod 8
            add a0, zero, s1
            add t5, zero, ra

			addi sp, sp, -4
			stw t4, CUSTOM_VAR_END(sp)
			addi sp, sp, -4
			stw t5, CUSTOM_VAR_END(sp)
			addi sp, sp, -4
			stw t0, CUSTOM_VAR_END(sp)
			addi sp, sp, -4
			stw s0, CUSTOM_VAR_END(sp)

            call get_gsa

			ldw s0, CUSTOM_VAR_END(sp)
			addi sp, sp, 4
			ldw t0, CUSTOM_VAR_END(sp)
			addi sp, sp, 4
			ldw t5, CUSTOM_VAR_END(sp)
			addi sp, sp, 4
			ldw t4, CUSTOM_VAR_END(sp)
			addi sp, sp, 4 
            add ra, zero, t5
            addi t0, zero, 1 ; create mask
            sll t0, t0, s0 ; shift mask
            and t0, t0, v0 ; apply mask 
            srl t0, t0, s0 ; reshift and store in t0
            addi t5, zero, 1
            beq t0, t5, INCREMENT_NEIGHBOURS
        return_mod_3:
            ret
            
        LOWER:
            add s0, s0, s2
            jmpi return_mod_1

        GREATER:
            sub s0, s0, s2
            jmpi return_mod_2

        INCREMENT_NEIGHBOURS:
            addi t4, t4, 1
            jmpi return_mod_3
    ret    
; END:find_neighbours

; BEGIN:update_gsa 
update_gsa: 
addi sp, sp, -4
stw ra, CUSTOM_VAR_END(sp)
ldw t0, PAUSE(zero)
addi t3, zero, 12 ; MX  x
addi t4, zero, 8 ; max y
addi t5, zero, 11
addi t7, zero, 0 ; gsa 
add t1, zero, zero ; iter ligne
bne t0, zero, ITERY

ITERY : 
	addi t2, zero, 0 ; col

   ITERX :
	    addi sp, sp, -4
        stw t0, CUSTOM_VAR_END(sp)
	 	addi sp, sp, -4
       stw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, -4
        stw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, -4
        stw t3, CUSTOM_VAR_END(sp)
       addi sp, sp, -4 
        stw t4, CUSTOM_VAR_END(sp)
       addi sp, sp, -4  
        stw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t7, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw s0, CUSTOM_VAR_END(sp)

        add a0, zero, t2
        add a1, zero, t1
        call find_neighbours

       add a0, v0, zero ; donne le nb de live neighbours  
       add a1, v1, zero ;donne le state de la cell 
       call cell_fate
        ldw s0, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t7, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t4, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t3, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
       ldw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t0, CUSTOM_VAR_END(sp)
        addi sp, sp, 4

   	    sll t6, v0, t5
        or t7, t7, t6 
        addi t5, t5, -1 
        addi t2, t2, 1 
        bne t2, t3, ITERX

		addi sp, sp, -4
        stw t6, CUSTOM_VAR_END(sp)
		addi sp, sp, -4
        stw t7, CUSTOM_VAR_END(sp)
        add a0, t7, zero
        add a1, zero, t1
        call set_gsa
        ldw t7, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
        ldw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        addi t1, t1, 1
        bne t1, t4, ITERY
        stw s0, GSA_ID(zero)
        addi s1, zero, 1
        beq s0, zero, ID0 
        bne s0, s1, ID1 
            ID0 :
                stw s1, GSA_ID(zero) ; next ID 
                ldw ra, CUSTOM_VAR_END(sp)
				addi sp, sp, 4 
                ret
            
            ID1 : 
                stw zero, GSA_ID(zero) ; next ID 
                ldw ra, CUSTOM_VAR_END(sp)
				addi sp, sp, 4
                ret
ret
; END:update_gsa 


; BEGIN:mask
mask:
    ldw t4, SEED(zero)
    addi t1, zero, -1 ; index line
    addi t2, zero, N_GSA_LINES
    slli t4, t4, 2 ; fois 4
    ldw t3, MASKS(t4) ; mask
 	add t7, zero, zero

    LOOP_LINE: 
        addi t1, t1, 1
        ldw t6, 0(t3)
  		addi t3, t3, 4
        add a0, zero, t1
        add t5, ra, zero
        addi sp, sp, -4 
        stw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t3, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t4, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
  		stw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, -4
        stw a0, CUSTOM_VAR_END(sp)
        call get_gsa
        ldw a0, CUSTOM_VAR_END(sp)
        addi sp, sp, 4
  		ldw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t4, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t3, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 

        and t6, t6, v0 ; masked
        add a1, zero, a0
        add a0, zero, t6

       addi sp, sp, -4 
        stw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t3, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t4, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
        stw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, -4 
  		stw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, -4
  		stw t7, CUSTOM_VAR_END(sp)
        call set_gsa
        ldw t7, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
  		ldw t6, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t5, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t4, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t3, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t2, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        ldw t1, CUSTOM_VAR_END(sp)
        addi sp, sp, 4 
        add ra, zero, t5
        bne t1, t2, LOOP_LINE
 ret
; END:mask


    
; BEGIN:get_input
get_input : 
    ldw v0, BUTTONS+4(zero)
    stw zero, BUTTONS+4(zero)
    ret
; END:get_input


; BEGIN:decrement_step
decrement_step: 
    addi sp, sp, -4
    stw ra, CUSTOM_VAR_END(sp)
    ldw t0, CURR_STATE(zero) 
    ldw s0, PAUSE(zero)
    ldw t2, CURR_STEP(zero)
    cmpeqi t3, t0, RUN ; check if current state equals 2 (state run)
    cmpeqi t4, s0, RUNNING ; check if pause is in state running
    cmpeqi t5, t2, 0  ; check if current step equals 0 
    and t6, t3, t4 ; current state is RUN and state running
    bne t6, zero, RUN_CASE
    beq t3, zero, INIT_OR_RAND_CASE

        RUN_CASE:
            and t6, t6, t5 ; and current step equals 0
            beq t6, zero, RUN_0_CASE ; if current step equals 0
            bne t6, zero, RUN_1_CASE ; else

        RUN_0_CASE:
            addi v0, zero, 0 ; return 0
            ret
            
        RUN_1_CASE:
   addi t2, t2, -1 ; decrement number of steps
            stw t2, CURR_STEP(zero) ; store it
            addi v0, zero, 0 ; return 0
   jmpi WRITE_SEG
            ret

        INIT_OR_RAND_CASE:
   addi v0, zero, 1 ; return 0
            jmpi WRITE_SEG
            ret   

  WRITE_SEG:
   ldw t1, CURR_STEP(zero) ; first digit
   addi s3, zero, 15 ; mask 000F
   and t1, t1, s3 ; apply mask
            slli t1, t1, 2 ; multiply by 4
            ldw t7, font_data(t1) ; t7 = the char to display
            addi s2, zero, 12
            stw t7, SEVEN_SEGS(s2) ; store it in segs3
            ldw t1, CURR_STEP(zero) ; second digit
   slli s3, s3, 4 ; mask 00F0
   and t1, t1, s3 ; apply mask
   srli t1, t1, 4
            slli t1, t1, 2 ; multiply by 4
            ldw t7, font_data(t1) ; t7 = the char to display
            addi s2, zero, 8
            stw t7, SEVEN_SEGS(s2) ; store it in segs2
            ldw t1, CURR_STEP(zero) ; third digit
   slli s3, s3, 4 ; mask 0F00
   and t1, t1, s3 ; apply mask
   srli t1, t1, 8
            slli t1, t1, 2 ; multiply by 4
            ldw t7, font_data(t1) ; t7 = the char to display
            addi s2, zero, 4
            stw t7, SEVEN_SEGS(s2) ; store it in segs1
            ldw t1, CURR_STEP(zero) ; fourth digit
   slli s3, s3, 4 ; mask F000
   and t1, t1, s3 ; apply mask
   srli t1, t1, 12
            slli t1, t1, 2 ; multiply by 4
            ldw t7, font_data(t1) ; t7 = the char to display
            stw t7, SEVEN_SEGS(zero) ; store it in segs0
   ret  
 
    ret
; END:decrement_step



; BEGIN:reset_game 
reset_game: 
addi sp, sp, -4
stw ra, CUSTOM_VAR_END(sp)
addi t1, zero, 1
stw t1, CURR_STEP(zero)
addi t0, zero, 0 ; iterateur 
addi t2, zero, N_SEEDS ; MAX SEED 
addi t4, zero, N_GSA_LINES ; LIGNE MX GS 
ldw t3, font_data(zero) ; on prend la valeure 0 
addi t5, zero, seed0 ; iterateur sur les seeds 

iter : 
addi sp, sp, -4
stw t0, CUSTOM_VAR_END(sp)
addi sp, sp, -4
stw t1, CUSTOM_VAR_END(sp)
addi sp, sp, -4
stw t5, CUSTOM_VAR_END(sp)
addi sp, sp, -4
stw t4, CUSTOM_VAR_END(sp)

add a1, zero, t0
ldw a0, 0(t5)

call set_gsa

ldw t4, CUSTOM_VAR_END(sp)
addi sp, sp, 4
ldw t5, CUSTOM_VAR_END(sp)
addi sp, sp, 4 
ldw t1, CUSTOM_VAR_END(sp)
addi sp, sp, 4
ldw t0, CUSTOM_VAR_END(sp)
addi sp, sp, 4

addi t0, t0, 1
addi t5, t5, 4
bne t0, t4, iter

stw t1, SPEED(zero)
stw zero, SEED(zero) 
stw zero, CURR_STATE(zero) ; INIT ST
stw zero, GSA_ID(zero) 
stw zero, PAUSE(zero)
ldw ra, CUSTOM_VAR_END(sp)
addi sp, sp, 4
ret
; END:reset_game 


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

