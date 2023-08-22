*-----------------------------------------------------------
* Title      : Random Number generator
* Written by : Enzo Sornao
* Date       : 07/06/2023
* Description: this program randomly generates a number in the range specified
*-----------------------------------------------------------


seedRandomNumber
        move.b  #TRAP_GET_TIME,d0    
        TRAP    #15               
        lsl.l #8, d1
        lsl.l #8, d1
        lsl.l #8, d1
        swap d1
        lsr.w #8, d1        
        ;get the least signifigant bytes alone
        
        *make sure the number is in the range
        divu #RANDOM_NUMBER_INTERVAL,d1
        
        clr.w d1                ;get rid of the quotient
        swap d1                 ;get the remainder
        
        add.l #1, d1            ;make sure the number isn't zero
        
        move.l d1, randomValue  ;store the random value          
        
        rts















*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
