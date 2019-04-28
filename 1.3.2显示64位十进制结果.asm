STACK       SEGMENT PARA    STACK
STACK_AREA  DW              100h DUP(?)
STACK_TOP   EQU             $-STACK_AREA
STACK       ENDS

DATA        SEGMENT PARA
X_H         DW      1606H
X_L         DW      1175H
Y_H         DW      1606H
Y_L         DW      1175H
RESULT_4    DW      0
RESULT_3    DW      0
RESULT_2    DW      0
RESULT_1    DW      0
DATA        ENDS


CODE        SEGMENT PARA
            ASSUME  CS:CODE,DS:DATA,SS:STACK

MAIN        PROC    FAR
            MOV     AX,DATA
            MOV     DS,AX

            MOV     AX,X_L
            MOV     BX,Y_L
            MUL     BX
            MOV     RESULT_1,AX
            MOV     RESULT_2,DX

            MOV     AX,X_H
            MOV     BX,Y_H
            MUL     BX
            MOV     RESULT_3,AX
            MOV     RESULT_4,DX
            
            MOV     AX,X_H
            MOV     BX,Y_L
            MUL     BX
            ADD     AX,RESULT_2
            MOV     RESULT_2,AX
            ADC     RESULT_3,0
            ADC     RESULT_4,0
            ADD     DX,RESULT_3
            MOV     RESULT_3,DX
            ADC     RESULT_4,0

            MOV     AX,X_L
            MOV     BX,Y_H              
            MUL     BX
            ADD     AX,RESULT_2
            MOV     RESULT_2,AX
            ADC     RESULT_3,0
            ADC     RESULT_4,0
            ADD     DX,RESULT_3
            MOV     RESULT_3,DX
            ADC     RESULT_4,0

            XOR     CX,CX
LOOP1:                      ;显示64位十进制结果，将64位结果分为4个16位，从高到低每16位除以10，将商更新到对应位置，余数与下一个16位组成一个32位数继续除以10，将最后的余数压栈
            MOV     BX,10
            XOR     DX,DX 
            MOV     AX,RESULT_4
            DIV     BX
            MOV     RESULT_4,AX
            MOV     AX,RESULT_3
            DIV     BX
            MOV     RESULT_3,AX
            MOV     AX,RESULT_2
            DIV     BX
            MOV     RESULT_2,AX
            MOV     AX,RESULT_1
            DIV     BX
            MOV     RESULT_1,AX

            PUSH    DX
            INC     CX

            XOR     BX,BX
            OR      BX,RESULT_1
            OR      BX,RESULT_2
            OR      BX,RESULT_3
            OR      BX,RESULT_4
            CMP     BX,0
            JNZ     LOOP1

LOOP2:                          ;依次输出栈中保存的每一位结果
            POP     DX
            OR      DL,30H
            MOV     AH,2
            INT     21H
            LOOP    LOOP2


EXIT:       MOV     AX,4C00H
            INT     21H
 
MAIN        ENDP

CODE        ENDS
            END     MAIN