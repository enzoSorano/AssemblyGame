
*-----------------------------------------------------------
* Title      : Ball Smash 
* Written by : Enzo Sorano
* Date       : 08/09/2023
* Description: This is a game that I created. It Contains a functional 7-Segment display, collision detection system, Random Number Generator,
* loading screen, and makes use of fracitonal bits. It also uses a custom bit map reader to display the background and cover the players and enemy.
* The objective of the game is for the player(the ball) to fall on top of the enemy(rectangle). If you fall ontop you are rewarded a point,
* and the enemy is respawned with a random speed. Your objective for the game is to get 10 pts! but be carefull, if you are hit by either side of
* the enemy(rectangle) you will be eliminated and the game will be over! Good luck out there.

*-------------------------------------------------------------
    ORG 1000     

*-----------------------trap codes----------------------------
TRAP_GET_TIME                       EQU     8
TRAP_CLEAR_SCREEN                   EQU     11
TRAP_PRINT_STRING                   EQU     13
TRAP_DOUBLE_BUFFER                  EQU     17
TRAP_KEY_INPUT                      EQU     19
TRAP_SET_OUTPUT_WINDOW              EQU     33
TRAP_PEN_COLOR                      EQU     80
TRAP_SET_FILL_COLOR                 EQU     81
TRAP_DRAW_PIXEL                     EQU     82
TRAP_DRAW_LINE                      EQU     85
TRAP_MOVE_X_Y                       EQU     86
TRAP_DRAW_RECTANGLE                 EQU     87
TRAP_DRAW_ELIPSE                    EQU     88
TRAP_DRAWING_MODE                   EQU     92
TRAP_SET_PEN_WIDTH                  EQU     93 
TRAP_REPAINT_SCREEN                 EQU     94
*-------------------------CONSTANTS----------------------------
SCREEN_WIDTH                        EQU     800
SCREEN_HEIGHT                       EQU     600
RANDOM_NUMBER_INTERVAL              EQU     20
DELTA_TIME                          EQU     4
DELTA_TIME_PLAYER                   EQU     8
FRACTIONAL_BITS                     EQU     2
*-------------------------player------------------------------
PLAYER_VELOCITY                     EQU     2<<FRACTIONAL_BITS      ; .5 * 2^fractional bits = 2
PLAYER_MAX_LEFT                     EQU     20
PLAYER_MAX_RIGHT                    EQU     760
PLAYER_MAX_HEIGHT                   EQU     20
PLAYER_RADIUS                       EQU     20
PLAYER_HEIGHT                       EQU     40
PLAYER_WIDTH                        EQU     40
PLAYER_STARTING_X                   EQU     400     
PLAYER_STARTING_Y                   EQU     400
PLAYER_JUMP_HEIGHT                  EQU     400
PLAYER_MIN_HEIGHT                   EQU     500
*----------------------------enemy---------------------------
ENEMY_STARTING_VELOCITY             EQU     4<<FRACTIONAL_BITS      ;make the velocity have two fractional bits(this will be a velocity of 1)
ENEMY_WIDTH                         EQU     40
ENEMY_HEIGHT                        EQU     40
EMEMY_MAX_LEFT                      EQU     20
ENEMY_MAX_RIGHT                     EQU     760
ENEMY_STARTING_X                    EQU     400
ENEMY_HALF_WIDTH                    EQU     20

ENEMY_OVERLAP                       EQU     15
ENEMY_UY                            EQU     480
ENEMY_LY                            EQU     520
ENEMY_KILLED_HITBOX_UY              EQU     460
ENEMY_KILLED_HITBOX_LY              EQU     480
*----------------------------LED----------------------------
LED_X                               EQU     400
LED_Y                               EQU     100
LED_OFFSET                          EQU     4
LED_SIZE                            EQU     16
SEGMENT7                            EQU     7
DIGIT_PEN_WIDTH                     EQU     3
DEFAULT_PEN_WIDTH                   EQU     1
DIGIT_WIDTH                         EQU     LED_SIZE+LED_OFFSET+4   
BLACK_COLOR                         EQU     $00000000
WHITE_COLOR                         EQU     $00FFFFFF
BACKGROUND_COLOR                    EQU     $0060A0C0

*------------------------REGISTERS----------------------------
REGISTERS_DRAW_BITMAP               REG     D0-D7/A0-A4
REGISTERS_DRAW_PLAYER               REG     D0-D6
REGISTERS_DRAW_7SEGMENT             REG     D3-D7/A6
ALL_REGISTERS                       REG     D0-D7
REGISTERS_USED_TO_COVER             REG     D3-d7  
    
*-----------------------------DATA REGISTERS-----------------
    
    *d3 = enemyOne x
    *d4 = enemeyOne Velocity
    *d5 = player center x
    *d6 = player center y
    *d7 = last frame time
    
        
    
START:                 
    jsr intalizeGame
game:
    jsr getDeltaTime    ;get the change in time between frames
    movem.l d1,-(sp)    ;put the delta time on the stack
    
    jsr drawPlayerImage
    jsr handlePlayerInput
    jsr handleEnemyMovement
    jsr handleEnemyCollision
    
    movem.l (sp)+, d1
    jsr repaint
   
    bra game

    
    SIMHALT             ; halt simulator
    
addScore
    
    *increment the score
    lea score, a6
    addi.l #1, (a6)
    
    *---------------------------------
    *Draw the score
    movem.l REGISTERS_DRAW_7SEGMENT, -(sp)
    move.l (a6), d6
    
    move.l #LED_X,numberPositionX
    move.l #LED_Y, numberPositionY
    jsr Display7Segment
    
    movem.l (sp)+, REGISTERS_DRAW_7SEGMENT
    
    rts
    
repaint
    move.b  #TRAP_REPAINT_SCREEN ,d0
    trap #15
    rts
    
enableDoubleBuffering
    move.l #TRAP_DRAWING_MODE, d0
    move.l #TRAP_DOUBLE_BUFFER, d1
    trap #15
    rts
    
drawLoadingScreen
    move.l #TRAP_PRINT_STRING, d0
    lea    loadingScreenText, a1
    trap   #15
    
    jsr repaint
    
    rts
    
setOutputWindow
    move.l #TRAP_SET_OUTPUT_WINDOW, d0
    move.w #SCREEN_WIDTH, d1
    swap d1
    move.w #SCREEN_HEIGHT, d1
    trap #15
    
    rts
clearScreen
    move.l #TRAP_CLEAR_SCREEN, d0
    trap #15
    
    rts
    
coverPlayerImage
   
   movem.l REGISTERS_DRAW_BITMAP, -(sp)    ;save registers
   
   *local variables
   move.l #PLAYER_RADIUS, d7

   *calculate top left corner
   sub.l d7, d5
   sub.l d7, d6
 
   lea BackgroundImageData, a5
   lea BackgroundImage, a0
    
   *pass the arguments using the stack
   
   move.l #PLAYER_HEIGHT, -(sp)             ;height
   move.l #PLAYER_WIDTH,  -(sp)             ;width
   move.l d5, -(sp)                         ;x offset of the image, which is the same as x co-ordinate
   move.l d6, -(sp)                         ;y offset of the image
   move.l d5, -(sp)                         ;x coordinate
   move.l d6, -(sp)                         ;y coordinate
    
   jsr DisplayImage
    
   add.l #SIZE_OF_DISPLAYING_IMAGE, sp     ;fix the stack
   movem.l (sp)+, REGISTERS_DRAW_BITMAP    ;put registers back on the stack
   
   ;jsr repaint
   rts
   
coverEnemyImage
   movem.l REGISTERS_DRAW_BITMAP, -(sp)    ;save registers
   
   *get the top left x
   move.l #ENEMY_HALF_WIDTH, d7
   sub.l d7, d3
   
   lea BackgroundImageData, a5
   lea BackgroundImage, a0
    
   *pass the arguments using the stack
   move.l #ENEMY_HEIGHT, -(sp)              ;height
   move.l #ENEMY_WIDTH,  -(sp)              ;width
   move.l d3, -(sp)                         ;x offset of the image, which is the same as x co-ordinate
   move.l #ENEMY_UY, -(sp)                  ;y offset of the image
   move.l d3, -(sp)                         ;x coordinate
   move.l #ENEMY_UY, -(sp)                  ;y coordinate
    
   jsr DisplayImage
    
   add.l #SIZE_OF_DISPLAYING_IMAGE, sp     ;fix the stack
   movem.l (sp)+, REGISTERS_DRAW_BITMAP    ;put registers back on the stack
coverLed
    movem.l REGISTERS_DRAW_BITMAP, -(sp)    ;save registers
   
   *get the top left x
   move.l #ENEMY_HALF_WIDTH, d7
   sub.l d7, d3
   
   lea BackgroundImageData, a5
   lea BackgroundImage, a0
    
   *pass the arguments using the stack
   move.l #ENEMY_HEIGHT, -(sp)              ;height
   move.l #ENEMY_WIDTH,  -(sp)              ;width
   move.l d3, -(sp)                         ;x offset of the image, which is the same as x co-ordinate
   move.l #ENEMY_UY, -(sp)                  ;y offset of the image
   move.l d3, -(sp)                         ;x coordinate
   move.l #ENEMY_UY, -(sp)                  ;y coordinate
    
   jsr DisplayImage
    
   add.l #SIZE_OF_DISPLAYING_IMAGE, sp     ;fix the stack
   movem.l (sp)+, REGISTERS_DRAW_BITMAP    ;put registers back on the stack

    
drawPlayerImage
    *need to save off all the registers
    movem.l ALL_REGISTERS, -(sp)           ;make sure we don't trash any registers
    
    *local variables
    move.l #PLAYER_RADIUS, d7
    
    *draw an elipse
    move.l #TRAP_DRAW_ELIPSE, d0
    move.l d5, d1
    sub.l d7, d1   ;left x
    move.l d6, d2
    sub.l d7, d2   ;upper y
    move.l d5, d3
    add.l d7, d3   ;right x
    move.l d6, d4
    add.l d7, d4   ;lower y
    trap #15
    
    movem.l (sp)+, ALL_REGISTERS    ;fix stack and return variables

    ;jsr repaint
    rts
    
drawEnemyImage
    movem.l ALL_REGISTERS, -(sp)    ;save off registers
    
    *local varaible so we do not need to use immediates
    move.l #ENEMY_HALF_WIDTH, d7

    move.l #TRAP_DRAW_RECTANGLE, d0
    move.l d3, d1
    sub.l  d7, d1                   ;left x
  
    move.l #ENEMY_UY, d2            ;upper y 480
    
    add.l d7, d3                    ;right x
    
    move.l #ENEMY_LY, d4
    trap #15
    
    movem.l (sp)+, ALL_REGISTERS    ;restore stack
    
    rts 
    
getRandomNumber
   *seed random number for enemy one
   movem.l ALL_REGISTERS, -(sp)
   jsr SeedRandomNumber
   movem.l (sp)+, ALL_REGISTERS
   
   rts
   
*puts delta time in d1   
getDeltaTime
    *get the current time
    move.l #TRAP_GET_TIME, d0
    trap #15
    
    *subtract get the time between last frame and current frame(delta time)
    sub.l d7, d1    ;time subtracted in 100ths of second
    add.l d1, d7    ;update the time to 100ths of a second
   
    rts
    
* Put variables and constants here
subroutineBMP             INCLUDE 'subroutines/subroutineBMP.X68'
subroutineRandom          INCLUDE 'subroutines/Random.X68'
subroutinePlayerMovement  INCLUDE 'subroutines/subroutinePlayerMovement.X68'
subroutineEnemyMovement   INCLUDE 'subroutines/subroutineEnemyMovement.X68'
subroutineInit            INCLUDE 'subroutines/subroutineInit.X68'
subroutine7Segment        INCLUDE 'subroutines/subroutine7Segment.X68'
loadingScreenText         dc.b 'Game is loading.......',0
gameOverTxt               dc.b 'GAME OVER',0
youLostTxt                dc.b 'YOU LOSE',0
youWinTxt                 dc.b 'YOU WON!',0
randomSeed                ds.l 1
randomValue               ds.l 1
playerMovingUp            ds.b 1
playerMovingDown          ds.b 1
enemyAlive                ds.b 1        
enemyDirection            ds.b 1    
numberPositionX           ds.l 1    
numberPositionY           ds.l 1
score                     dc.l 0

    END    START        

































*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
