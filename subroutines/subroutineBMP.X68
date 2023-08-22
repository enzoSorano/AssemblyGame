*-----------------------------------------------------------
* Title      :  Bitmap as Subroutie
* Written by :  Enzo Sorano
* Date       :
* Description: this program will read a bmp and display the image to screen taking the top left (x,y) for the chunk and the top left (x,y) of the screen to display the image
*USAGE:
* anything that ends with Image will store the actual incbin
* anything that ends with ImageData will store the Height width etc
*-----------------------------------------------------------
   
*-------------------------PARAMETERS FOR THE FUNCTION-----------
CHUNK_HEIGHT                    EQU 24
CHUNK_WIDTH                     EQU 20
CHUNK_X                         EQU 16
CHUNK_Y                         EQU 12
SCREEN_X                        EQU 8
SCREEN_Y                        EQU 4
SIZE_OF_DISPLAYING_IMAGE        EQU 24

*------------------------------CONSTANTS------------------------
FILE_OFFSET_TO_PIXEL_DATA       EQU 10



LoadImageData
    move.l a0, a1
    adda #FILE_OFFSET_TO_PIXEL_DATA, a0
    move.l (a0)+, d7
    jsr LittleToBigEndianLong
    add.l d7, a1                    ;a1 now has the address of the pixel array

    move.l a1, (a5)+                ;store the address of the pixel array
    
    ;grab the header size
    move.l a0, a2
    move.l (a0)+, d7
    jsr LittleToBigEndianLong
    
    add.l d7, a2                    ;a2 now has the address of the color table
    
    move.l a2, (a5)+
    
    ;a0 now points to the image width
    move.l (a0)+, d7
    jsr LittleToBigEndianLong
    move.l d7, d5                   ;d5 now holds the width of the image
    
    move.l d5, (a5)+                ;store the width of the immage
    
    ;a0 now points to the immage height
    move.l (a0), d7
    jsr LittleToBigEndianLong
    move.l d7, d3                   ;d3 now holds the height of the immage
    
    move.l d3, (a5)+                ;store the height of the image
    
    rts
    

LittleToBigEndianLong
    ror.w #$8, d7
    swap d7
    ror.w #$8, d7
    
    rts
DisplayImage
    move.l (a5)+, a1            ;load the adress of the pixel array
    move.l (a5)+, a2            ;load the address of the color table
    move.l (a5)+, d5            ;load the width of the image
    move.l (a5)+, d3            ;load the height of the image
    
    move.l SCREEN_Y(sp),d2
    add.l  CHUNK_HEIGHT(sp), d2  ;y screen coordinate now points to the bottom left corner of the chunk image
    
    *move the adress of the pixel array to the bottom left corner of the chunk image
    move.l #0, d6
    move.l d3, d7               ;move the height of the image into d7
    sub.l CHUNK_Y(sp),d7        ;subtract the chunk Y's offset
    sub.l CHUNK_HEIGHT(sp), d7  ;subtract the chunk height
    
    cmp.l d7, d6                ;if the height of the chunk is greater than or equal to the image, then don't loop
    bge DontLoop
    
    LoopBack:
        add.l d5, a1            ;add the width of the image to the address of the pixel array
        addi.l #1, d6           ;increment the loop counter
        cmp.l d7, d6            ;check if the loop counter has reached they y offset, if not then loop back
        BNE LoopBack
    DontLoop:
        *move the x offset
        add.l CHUNK_X(sp), a1
        
        *calculate the width of the chunk to be drawn considering the screen coordinates
        move.l SCREEN_X(sp), d4                     ;move the screens x coordinate
        add.l  CHUNK_WIDTH(sp), d4                  ;add the chunk image's width

        *calcualte the remaing width of the image
        lea RemainingWidthOfBmp, a4
        move.l d5, (a4)                             ;move the width of the image
        move.l CHUNK_WIDTH(sp), d6                  ;move the chunk images width
        sub.l d6, (a4)
        move.l CHUNK_X(sp), d6
        sub.l d6, (a4)
        
        clr.l d6
        
        *draw the pixels
    DrawEachRow:
        move.l SCREEN_X(sp), d7
        
    DrawEachPixel:
        clr.w d6
        
        move.b (a1)+, d6            ;load the offset adress of the color table and increment
        lsl.l #$02, d6              ;multiply the offset address by 4 because each color is 4 bytes long
        move.l (a2, d6), d1         ;load the color of the pixel to a data register
        lsr.l  #$8, d1              ;shift out padding byte
        
      
        move.l #TRAP_PEN_COLOR, d0  ;set the pen color
        trap #15
        
        *draw the pixel on the x y coordinates
        move.l d7, d1
        
        move.l #TRAP_DRAW_PIXEL, d0
        trap #15
        
        addi.w #1, d7               ;increment the x-coordinate
        
        cmp.w d4, d7                ;check if the chunk width has been reached
        bne DrawEachPixel
        
        *increment the pixel array by the remaining width of the image
        add.l (a4), a1
        
        *pixel array is now pointing to the begging of the next row of the image
        
        add.l CHUNK_X(sp), a1
        
        *de-crement the y coordinate
        subi.w #1, d2
        
        ;check the y coordinate if at the max,if not continue drawing
        cmp.l SCREEN_Y(sp), d2
        BNE DrawEachRow
        
        rts


BackgroundImage         INCBIN 'subroutines/mario_background_2.bmp'
RemainingWidthOfBmp     ds.l 1
BackgroundImageData     ds.l 4



    ;END    START        ; last line of source
    














*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
