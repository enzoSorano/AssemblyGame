*-----------------------------------------------------------
* Title      :  intializer
* Written by :  enzo sorano
* Date       :  08/02/2023
* Description:  this program is used to intalize the game. It sets up all varaibles and declares all helper functins
*-----------------------------------------------------------

*-------------------------------------- INNIT ------------------
intalizeGame 
   *determine player starting direction based on the random number
   jsr getRandomNumber
   
   *set-up intial window and double buffering 
   jsr setOutputWindow
   
   jsr clearScreen
             
   jsr enableDoubleBuffering
 
   
   *load the background information
   lea BackgroundImageData, a5      ;load the data variables into a5
   lea BackgroundImage,     a0      ;load the actual bmp into a0
   jsr LoadImageData
    

   jsr drawLoadingScreen            ;draw the loading screen
    
    
   *draw the original background
   
   lea BackgroundImageData, a5
   lea BackgroundImage,     a0
   
   move.l #0, d1
   move.l #0, d2
   
   movem.l REGISTERS_DRAW_BITMAP, -(sp)    ;save registers
    
   lea BackgroundImageData, a5
   lea BackgroundImage, a0
    
   *pass the arguments using the stack
   move.l #SCREEN_HEIGHT, -(sp)      ;height
   move.l #SCREEN_WIDTH,  -(sp)      ;width
   move.l d1, -(sp)                  ;x offset of the image, which is the same as x co-ordinate
   move.l d2, -(sp)                  ;y offset of the image
   move.l d1, -(sp)                  ;x coordinate
   move.l d2, -(sp)                  ;y coordinate
    
   jsr DisplayImage
    
   add.l #SIZE_OF_DISPLAYING_IMAGE, sp     ;fix the stack
   movem.l (sp)+, REGISTERS_DRAW_BITMAP    ;put registers back on the stack
 
   jsr repaint                          ;repaint the screen
   
   *intalize starting values
   move.l #ENEMY_STARTING_X, d3
   move.l #ENEMY_STARTING_VELOCITY, d4
   move.l #PLAYER_STARTING_X, d5
   move.l #PLAYER_STARTING_Y, d6
   
   *initialize flags
   move.b #0, playerMovingUp
   move.b #0, playerMovingDown
   move.b #0, enemyAlive
   move.b #0, enemyDirection
   
   *draw original player
   jsr drawPlayerImage
   
   *draw intial enemy
   jsr drawEnemyImage
   jsr repaint
   
   *get a time in d7
   move.l #TRAP_GET_TIME, d0
   trap #15
   
   move.l d1, d7
   
   rts










*~Font name~Courier New~
*~Font size~12~
*~Tab type~1~
*~Tab size~4~
