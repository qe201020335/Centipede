#####################################################################
#
# CSC258H Winter 2021 Assembly Final Project # University of Toronto, St. George
#
# Student: Tianhe Zhang, 1004962533
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the project handout for descriptions of the milestones)
# - Milestone 1
#
# Which approved additional features have been implemented?
# (See the project handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
    displayAddress:	.word 0x10008000
    bugLocation: .word 814  # initial position of the bug
    centipedLocation: .word 0, 1, 2, 3, 4, 5, 6, 7, 8, 9
    centipedDirection: .word 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
    mushroomLocation: .word 69, 115, 180, 234, 317, 428, 451, 537, 646, 760  # some random initial location of mashroom


    bgColor: .word 0x00000000  # black
    centipedColor: .word 0x00ff0000  # red
    bugColor: .word 0x00ffffff  # white
    mushroomColor: .word 0x00f600ff  # pink
    dartColor: .word 0x00afafaf  # grey

    sleep: .word 200  # delay for each game loop iteration

.text 
Loop:
    jal clear_screen

    jal disp_centiped
    jal disp_mashroom
    jal disp_bug

    jal move_centipede

    jal check_keystroke



    jal delay
    j Loop	

Exit:
    li $v0, 10		# terminate the program gracefully
    syscall





# function to clear the screen for a new iteration of the game
clear_screen:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $a3, $zero, 1024	 # load a3 with the loop count (10)
    la $a1, mushroomLocation # load the address of the array into $a1

    clear_screen_loop:  # loop over the whole screen and draw every pixel with bgColor
        blt $a3, $zero, clear_screen_loop_end
        la $t1, bgColor  # store the address of the bgColor
        lw $t1, ($t1)   # now $t1 is the bgColor

        lw $t2, displayAddress  # $t2 stores the base address for display

        sll $t4, $a3, 2		# $t4 is arrdress offset of the current pixel at $a3
        add $t4, $t2, $t4	# now $t4 is the address of the current pixel
        sw $t1, 0($t4)		# paint this pixel with bgColor
        addi $a3, $a3, -1	 # decrement $a3 by 1
        j clear_screen_loop
    clear_screen_loop_end:
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra





# function to display a static centiped	
disp_centiped:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $a3, $zero, 10	 # load a3 with the loop count (10)
    la $a1, centipedLocation # load the address of the array into $a1

    disp_centiped_loop:	#iterate over the loops elements to draw each body in the centiped
        lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1

        lw $t2, displayAddress  # $t2 stores the base address for display
        li $t3, 0xff0000	# $t3 stores the red colour code
        
        sll $t4,$t1, 2		# $t4 is the bias of the old body location in memory (offset*4)
        add $t4, $t2, $t4	# $t4 is the address of the old bug location
        sw $t3, 0($t4)		# paint the body with red
        
        
        addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
        addi $a3, $a3, -1	 # decrement $a3 by 1
        bne $a3, $zero, disp_centiped_loop
        
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra





# display mushrooms
disp_mashroom:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $a3, $zero, 10	 # load a3 with the loop count (10)
    la $a1, mushroomLocation # load the address of the array into $a1

    mashroom_loop:	#iterate over the loops elements to draw each body in the centiped
        lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1

        lw $t2, displayAddress  # $t2 stores the base address for display
        la $t3, mushroomColor	
        lw $t3, ($t3)    # $t3 stores the mushroom colour code
        
        sll $t4, $t1, 2		# $t4 is the offset mushroom location in memory (offset*4)
        add $t4, $t2, $t4	# $t4 is the address of the mushroom pixel
        sw $t3, 0($t4)		# paint the pixel with mushroom color
        
        
        addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
        addi $a2, $a2, 4
        addi $a3, $a3, -1	 # decrement $a3 by 1
        bne $a3, $zero, mashroom_loop
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra





# display Bug Blaster
disp_bug:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    la $t1, bugLocation
    lw $t1, ($t1)  # load the bug blaster location in $t1

    la $t2, bugColor
    lw $t2, ($t2)  # load bug blaster color

    lw $t3, displayAddress

    sll $t4, $t1, 2		# calculate the offset amount in $t4
    add $t4, $t3, $t4	# $t4 is the address of the bug blaster pixel
    sw $t2, 0($t4)		# paint the pixel with bug blaster color


    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra




# move each section of the centipede
move_centipede:
     # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    addi $a3, $zero, 10	 # load a3 with the loop count (10)
    la $a1, centipedLocation # load the address of the array into $a1
    la $a2, centipedDirection # load the address of the array into $a2

    move_centiped_loop:	#iterate over the loops elements to update location of each body in the centiped
        lw $t1, 0($a1)		 # load a word from the centipedLocation array into $t1
        lw $t2, 0($a2)		 # load a word from the centipedDirection array into $t2
        
        add $t1, $t1, $t2    # update the location by it's direction
        
        # check whether the new position is a mushroom
        lw $t3, displayAddress
        sll $t4, $t1, 2		# calculate the offset amount
        add $t4, $t3, $t4	# $t4 is the address of the desired pixel 

        lw $t4, ($t4)       # color of this pixel
        
        la $t5, mushroomColor
        lw $t5, ($t5)       # color of a mushroom
        
        bne $t5, $t4, save_new_pos_n_dir  # brach if it is not a mushroom
            # hit a mushroom, reposition to move down
            lw $t1, 0($a1)          # reload the original position
            addi $t1, $t1, 32       # move down
            addi $t6, $zero, -1     # stores -1 in $t6
            mult	$t2, $t6			# reverse the direction of this centipede
            mflo	$t2					# copy Lo to $t2
        
        
        
        save_new_pos_n_dir:
            sw $t1, 0($a1)       # store the new location
            sw $t2, 0($a2)       # store the new direction
                
        addi $a1, $a1, 4	 # increment $a1 by one, to point to the next element in the array
        addi $a2, $a2, 4
        addi $a3, $a3, -1	 # decrement $a3 by 1
        bne $a3, $zero, move_centiped_loop

    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra





# function to detect any keystroke
check_keystroke:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t8, 0xffff0000
    beq $t8, 1, get_keyboard_input # if key is pressed, jump to get this key
    addi $t8, $zero, 0
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# function to get the input key
get_keyboard_input:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    lw $t2, 0xffff0004
    addi $v0, $zero, 0	#default case
    beq $t2, 0x6A, respond_to_j
    beq $t2, 0x6B, respond_to_k
    beq $t2, 0x78, respond_to_x
    beq $t2, 0x73, respond_to_s
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
# Call back function of j key
respond_to_j:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, bugLocation	# load the address of buglocation from memory
    lw $t1, 0($t0)		# load the bug location itself in t1
    
    lw $t2, displayAddress  # $t2 stores the base address for display
    li $t3, 0x000000	# $t3 stores the black colour code
    
    sll $t4,$t1, 2		# $t4 the bias of the old buglocation
    add $t4, $t2, $t4	# $t4 is the address of the old bug location
    sw $t3, 0($t4)		# paint the first (top-left) unit white.
    
    beq $t1, 800, skip_movement_j # prevent the bug from getting out of the canvas
    addi $t1, $t1, -1	# move the bug one location to the right
skip_movement_j:
    sw $t1, 0($t0)		# save the bug location

    li $t3, 0xffffff	# $t3 stores the white colour code
    
    sll $t4,$t1, 2
    add $t4, $t2, $t4
    sw $t3, 0($t4)		# paint the first (top-left) unit white.
    
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

# Call back function of k key
respond_to_k:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t0, bugLocation	# load the address of buglocation from memory
    lw $t1, 0($t0)		# load the bug location itself in t1
    
    lw $t2, displayAddress  # $t2 stores the base address for display
    li $t3, 0x000000	# $t3 stores the black colour code
    
    sll $t4,$t1, 2		# $t4 the bias of the old buglocation
    add $t4, $t2, $t4	# $t4 is the address of the old bug location
    sw $t3, 0($t4)		# paint the block with black
    
    beq $t1, 831, skip_movement_k #prevent the bug from getting out of the canvas
    addi $t1, $t1, 1	# move the bug one location to the right
skip_movement_k:
    sw $t1, 0($t0)		# save the bug location

    li $t3, 0xffffff	# $t3 stores the white colour code
    
    sll $t4,$t1, 2
    add $t4, $t2, $t4
    sw $t3, 0($t4)		# paint the block with white
    
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
respond_to_x:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $v0, $zero, 3
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
    
respond_to_s:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    addi $v0, $zero, 4
    
    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra

delay:
    # move stack pointer a work and push ra onto it
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    la $t7, sleep
    lw $a0, ($t7)
    li $v0, 32
    syscall

    # pop a word off the stack and move the stack pointer
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    
    jr $ra
