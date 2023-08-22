*-----------------------------------------------------------
* Title      : Enemy Movement
* Written by : Enzo Sorano
* Date       : 07/13/2023
* Description: this file is meant to handle all enemy movement. It will use a random number to move the
* enemys to the left or the right
*-----------------------------------------------------------
*------------------------CONSTANTS--------------------------
*d3 = enemyOne_x
*d4 = enemyVelocity

*<summary>
*this function handls all of the enemy movement
*<summary>
handleEnemyMovement
    cmp.b #0, enemyDirection
    BEQ moveEnemyRight
    BNE moveEnemyLeft
    
moveEnemyLeft
    *check for collision
    
    jsr coverEnemyImage
    *move the enemy considering delta time
    move.l d4, d0               ;save off the enemies current velocity
    move.l DELTA_TIME(sp), d1   ;get the delta time into d1(2 decimal bits)
    mulu d1, d4                 ;multiply the velocity by delta time (4 decimal bits)
    asr.l #4, d4                ;shift out the decimal bits    
    sub.l d4, d3                ;subtract it to move the enemy right
    move.l d0, d4               ;make the enemies velocity its original again
    
    cmpi.l #EMEMY_MAX_LEFT, d3
    bge ENEMYSKIPMAXLEFT
    
    move.l #EMEMY_MAX_LEFT, d3
    move.b #0, enemyDirection
    
    
ENEMYSKIPMAXLEFT:
    jsr drawEnemyImage
    
    rts
    
moveEnemyRight
    jsr coverEnemyImage
    
    *move the enemy considering delta time
    move.l d4, d0               ;save off the enemies current velocity
    move.l DELTA_TIME(sp), d1   ;get the delta time into d1(2 fractional bits)
    mulu d1, d4                 ;multiply the velocity by delta time (4 fractional bits)
    asr.l #4, d4                ;shift out the decimal places    
    add.l d4, d3                ;subtract it to move the enemy right
    move.l d0, d4               ;make the enemies velocity its original again

    
    cmpi.l #ENEMY_MAX_RIGHT, d3
    ble ENEMYSKIPMAXRIGHT
    
    move.l #ENEMY_MAX_RIGHT, d3
    move.b #1, enemyDirection
    
ENEMYSKIPMAXRIGHT:
    jsr drawEnemyImage
    
    rts
    
    
*<summary>
*this function detects and handles collisions between the player and the enemy
*<summary>  
handleEnemyCollision
    
    *save off d1 because it will be a temp register
    movem.l d1, -(sp)
    
    *check if the player is falling
    cmp.b #0, playerMovingDown
    BEQ CHECKFORPLAYERKILLED
    
    *check if the player is able to hit the target by checking its height
    cmp #ENEMY_KILLED_HITBOX_UY, d6         
    BGE CHECKFORENEMYKILLED
    BLE EXITHANDLEENEMYCOLLISION  ;if we can't collide dont check collision
    
CHECKFORENEMYKILLED:
    *check that the player is in the right y zone to kill the enemy
    cmp #ENEMY_KILLED_HITBOX_LY, d6
    BGE CHECKFORPLAYERKILLED
    
    *if they are, check the left x
    move.l d5, d1
    sub.l #PLAYER_RADIUS, d1     
    sub.l #ENEMY_OVERLAP, d1     
    cmp.l d1, d3
    BGE ENEMYKILLRIGHTX         ;if the center of the player is greater than the center of the enemy
    
    movem.l (sp)+, d1           ;restore d1 because about to exit
    rts                         ;otherwise exit because there can't be a collision
    
ENEMYKILLRIGHTX:
    move.l d5, d1
    add.l #PLAYER_RADIUS, d1
    add.l #ENEMY_OVERLAP, d1     ;get the right x
    cmp.l d1, d3
    BLE ENEMYWASKILLED         ;if player x is less than the right x
    
    movem.l (sp)+, d1          ;restore d1 because we are about to exit
    rts

ENEMYWASKILLED:
    *then cover the enemy
    jsr coverEnemyImage
    *change the enemys velocity
    jsr getRandomNumber         ;get random number between 1 and 20     
    move.l randomValue, d4
    
    *then put the enemy back in its starting spot
    move.l #ENEMY_STARTING_X, d3
    
    *put the player back in his
    jsr coverPlayerImage
    
    move.l #PLAYER_STARTING_X, d5 
    move.l #PLAYER_STARTING_Y, d6
    
    move.b #0, playerMovingDown 
    
    *increment ths score
    jsr addScore            
    
    movem.l (sp)+, d1       ;restore d1 because we are about to exit
    rts
    
    
CHECKFORPLAYERKILLED:
    *check if the player is low enough to be killed
    cmp #ENEMY_KILLED_HITBOX_LY, d6
    BLE EXITHANDLEENEMYCOLLISION        ;if not exit
    
    *check if the player's x is greater than the enemy left x
    move.l d5, d1
    sub.l #PLAYER_RADIUS, d1     
    sub.l #ENEMY_OVERLAP, d1
    cmp.l d1, d3
    BGE PLAYERKILLRIGHTX        ;if player x is greater than the left x
    
    movem.l (sp)+, d1           ;restore d1 because about to exit
    rts                         ;otherwise exit because there can't be a collision

    
PLAYERKILLRIGHTX:
    *check if the player's x is less than the enemy right x
    move.l d5, d1
    add.l #PLAYER_RADIUS, d1
    add.l #ENEMY_OVERLAP, d1     ;get the right x
    cmp.l d1, d3
    BLE PLAYERWASKILLED        ;if player x is less than the right x
    
    
    movem.l (sp)+, d1          ;restore d1 because we are about to exit
    rts
    
    *if so then the player has been killed
PLAYERWASKILLED:
    jsr coverPlayerImage
    *display "game over" "you lose"
    
    movem.l (sp)+, d1
    simhalt
    *-------------------------------------------
    *-----------display game over here----------
    *-------------------------------------------
    
    rts  
    
EXITHANDLEENEMYCOLLISION:
    movem.l (sp)+, d1 
    rts



















*~Font name~Courier New~
*~Font size~14~
*~Tab type~1~
*~Tab size~4~
