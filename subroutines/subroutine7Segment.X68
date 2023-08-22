*-----------------------------------------------------------
* Title      : 7 segment display
* Written by : Enzo Sorano
* Date       : 07/24/2023
* Description: this program manages and draws a 7 segmenet display
*-----------------------------------------------------------

Display7Segment
    *Load the X and Y positions of the score
    lea     numberPositionX, a3     ;top Left X
    lea     numberPositionY, a4     ;top left y
    
    *set the pen width
    move.l #TRAP_SET_PEN_WIDTH, d0
    move.l #DIGIT_PEN_WIDTH, d1
    trap #15
    
    *set the color for the rectangle that covers the current
    move.l #TRAP_PEN_COLOR, d0
    move.l #BLACK_COLOR, d1
    trap #15
                               
    move.l #TRAP_SET_FILL_COLOR, d0    
    trap #15
    
    *cover the current rectangle
    move.l (a3), d1           ;left top x position into a data register
    move.l (a4), d2           ;left top y coordiante into a data register
    
    move.l (a3), d3           ;top left x
    move.l #DIGIT_WIDTH, d7         
    mulu.w #1, d7    
    add.l d7, d3                    
    
    move.l (a4), d4
    add.l  #LED_SIZE, d4
    add.l  #LED_SIZE, d4      ;bottom right y
    
    move.l #TRAP_DRAW_RECTANGLE, d0
    trap #15 
   
    *make pen color white so we can see the lines
    move.l #WHITE_COLOR, d1
    move.l #TRAP_PEN_COLOR, d0
    trap #15
 
PRINTTHENEXTDIGIT:
   
    lea DigitTable, a6       ;load the DigitTable
    add.l d6, a6             ;add the digit we want to draw(which is the offset)
                             ;a6 now points the appropriate digit to be drawn
                                    
    move.l #0, d5            ;load initial offset to 0
    move.b (a6), d3          ;load the digit masked value
    
CHECKNEXTBIT:
    lsr.l #1, d3
    bcs DRAWLINE
    
INCREMENTBITCOUNTER:
    addi.l #1, d5
    cmpi.l #SEGMENT7, d5    ;check if we have drawn all of the segments
    bne CHECKNEXTBIT        ;if not draw the next segment
    
    bra ESCAPE7SEGMENT
    
DRAWLINE:
    lsl.l #2, d5            ;multiply counter by 4 because data is stored in long words
    
    lea Led_Start_X1, a5    ;load the starting x coordinate data
    add.l d5, a5            ;add the offset to get the segment we want to draw
    move.l (a5), d1         ;load the starting x caoordinate into the data register
    add.l (a3), d1          ;add the x_position on the screen that we want to the starting_x_position of the segment 
        
    lea Led_Start_Y1, a5    ;load the starting y coordinate data
    add.l d5, a5            ;add the offset to get the segment we want to draw
    move.l (a5), d2         ;load the starting y caoordinate into the data register
    add.l (a4), d2          ;add the y_position on the screen that we want to the starting_y_position of the segment 
    
    move.l #TRAP_MOVE_X_Y, d0  ;this trap code moves xy
    trap #15
    
    lea Led_End_X2, a5      ;load the ending x coordinate of the data
    add.l d5, a5            ;add the offset to get the right 7 segment information
    move.l (a5), d1         ;load the end-x into d1
    add.l (a3), d1          ;add the x_position on the screen that we want to the ending_x_position of the segment
    
    lea Led_End_Y2, a5      ;load the y-coordinate for the end of the line
    add.l d5, a5            ;add the offset to the address to get the right segment
    move.l (a5),d2          ;move the y-coordinate for the end of the line to d2
    add.l (a4),d2           ;add the y_position on the screen that we want to the ending_y_position of the segment
    
    move.l #TRAP_DRAW_LINE, d0
    trap #15
    
    lsr.l   #2,d5           ;divide it by 2 to get back our counter
    
    
    bra INCREMENTBITCOUNTER ;increment the bit counter every time we draw a line
    
    
ESCAPE7SEGMENT:
    move.l #DEFAULT_PEN_WIDTH, d1
    move.l #TRAP_SET_PEN_WIDTH, d0
    trap #15
    
    rts

*LED_OFFSET = distance between segments
*LED_SIZE = length of each segment
 
Led_Start_X1    dc.l    LED_OFFSET,                LED_SIZE,            LED_SIZE,                       LED_OFFSET,            0,                               0,                      LED_OFFSET
Led_Start_Y1    dc.l    0,                         LED_OFFSET,          LED_SIZE+LED_OFFSET,            LED_SIZE+LED_SIZE,     LED_SIZE+LED_OFFSET,             LED_OFFSET,             LED_SIZE
Led_End_X2      dc.l    LED_SIZE-LED_OFFSET,       LED_SIZE,            LED_SIZE,                       LED_SIZE-LED_OFFSET,   0,                               0,                      LED_SIZE-LED_OFFSET
Led_End_Y2      dc.l    0,                         LED_SIZE-LED_OFFSET, LED_SIZE+LED_SIZE-LED_OFFSET,   LED_SIZE+LED_SIZE,     LED_SIZE+LED_SIZE-LED_OFFSET,    LED_SIZE-LED_OFFSET,    LED_SIZE

*       a           
*   f       b       
*       g        
*   e       c
*       d

*Digit table contains the bits necessary to draw the proper segment. The Digit table goes from 0-9
DigitTable      dc.b    $3F,$06,$5B,$4F,$66,$6D,$7D,$07,$7F,$67
    

     
 















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
