*-----------------------------------------------------------
* Title      : handle Player Inputs
* Written by : Enzo Sorano
* Date       : 08/10/23
* Description: This subroutine handles the players input
*-----------------------------------------------------------
*--------------------------CONSTANTS------------------------
KEYCODE_A     EQU 'A'
KEYCODE_D     EQU 'D'
KEYCODE_W     EQU 'W'
*-----------------------------------------------------------

*<summary>
*set all the flags for the player to determine how the player should
*be moving
*<summary>
handlePlayerInput
    *check if the player is moving up
    cmp.b #1, playerMovingUp
    BEQ HANDLEPLAYERMOVINGUP              
   
    *check if the player is moving down
    cmp.b #1, playerMovingDown
    BEQ HANDLEPLAYERMOVINGDOWN

    *check if the player needs to start moving up
    move.l #TRAP_KEY_INPUT, d0
    move.l #KEYCODE_W, d1
    trap #15
    
    andi.l #$FF, d1
    BEQ HANDLEPLAYERONGROUND            ;if the key was not pressed 
    
    move.b #1, playerMovingUp           ;player pressed w so change flag
    
HANDLEPLAYERMOVINGUP:
    *check if we are at the max height
    cmp #PLAYER_JUMP_HEIGHT, d6
    ble PLAYERMOVINGDOWNS
    
    *move the player up
    jsr movePlayerUp
    jsr checkAPressed
    jsr checkDPressed
    
    rts
    
PLAYERMOVINGDOWNS:
    move.b #1, playerMovingDown         ;set the player moving down flag to true
    move.b #0, playerMovingUp           ;set the player moving down flag to false 
   
HANDLEPLAYERMOVINGDOWN: 
    *check if we are at the min height
    cmpi.l #PLAYER_MIN_HEIGHT, d6
    BGE PLAYERONGROUND
    
    jsr movePlayerDown
    jsr checkAPressed
    jsr checkDPressed
    
    rts
    
PLAYERONGROUND:
    move.b #0, playerMovingUp
    move.b #0, playerMovingDown
    
HANDLEPLAYERONGROUND:
    jsr checkAPressed
    jsr checkDPressed
    
EXITPLAYERINPUTS:
    rts
    
*<summary>
*checks if A was pressed, and if it was redraws the player to the left
*<summary>
checkAPressed
    *check if a was pressed
    move.l #TRAP_KEY_INPUT, d0
    move.l #KEYCODE_A, d1
    trap #15                    
    
    andi.l #$FF, d1
    beq EXITAPRESSED
 
    jsr coverPlayerImage
    *consider delta time when moving player
    move.l DELTA_TIME_PLAYER(sp), d1   ;get the delta time (2 frational bits)
    mulu #PLAYER_VELOCITY, d1          ;multiply the player velocity by the delta time(4 fractional bits)
    asr.l #4, d1                       ;shift the fractinoal bits out
    sub.l d1, d5                       ;subtract it to move the player up
    
    cmpi.l #PLAYER_MAX_LEFT, d5
    bge SKIPMAXLEFT
    move.l #PLAYER_MAX_LEFT, d5
    
SKIPMAXLEFT:
    jsr drawPlayerImage
EXITAPRESSED
    rts
    
*<summary>
*checks if D was pressed, and if it was redraws the player to the right
*<summary> 
   
checkDPressed:
    move.l #TRAP_KEY_INPUT, d0
    move.l #KEYCODE_D, d1
    trap #15
    
    andi.l #$FF, d1
    beq EXITDPRESSED
    
    jsr coverPlayerImage
    
    *consider delta time when moving player
    move.l DELTA_TIME_PLAYER(sp), d1   ;get the delta time (2 frational bits)
    mulu #PLAYER_VELOCITY, d1          ;multiply the player velocity by the delta time(4 fractional bits)
    asr.l #4, d1                       ;shift the fractinoal bits out
    add.l d1, d5                       ;add it to move the player to the right
    
    cmpi.l #PLAYER_MAX_RIGHT, d5
    ble SKIPMAXRIGHT
    move.l #PLAYER_MAX_RIGHT, d5
SKIPMAXRIGHT:
    jsr drawPlayerImage
    
EXITDPRESSED: 
    rts
*<summary>
*re-draw the player up
*<summary>      
movePlayerUp:
    jsr coverPlayerImage
    
    *consider delta time when moving player
    move.l DELTA_TIME_PLAYER(sp), d1   ;get the delta time (2 frational bits)
    mulu #PLAYER_VELOCITY, d1          ;multiply the player velocity by the delta time(4 fractional bits)
    asr.l #4, d1                       ;shift the fractinoal bits out
    sub.l d1, d6                       ;subtract it to move the player up
    
    jsr drawPlayerImage
    
    rts
    
*<summary>
*re-draw the player down
*<summary>      
movePlayerDown:
    jsr coverPlayerImage
    
    *consider delta time when moving player
    move.l DELTA_TIME_PLAYER(sp), d1   ;get the delta time (2 frational bits)
    mulu #PLAYER_VELOCITY, d1          ;multiply the player velocity by the delta time(4 fractional bits)
    asr.l #4, d1                       ;shift the fractinoal bits out
    add.l d1, d6                       ;subtract it to move the player up

 
    jsr drawPlayerImage
    
    rts

    








*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
