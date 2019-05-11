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
                                ;显示完整64位二进制结果，通过循环左移并和1按位与的方式，从高到低依次获取并输出结果的各个二进制位
            MOV     CX,16 
            MOV     BX,RESULT_4 
LOOP1:      ROL     BX,1
            MOV     DX,BX
            AND     DX,1
            OR      DX,30H
            MOV     AH,2
            INT     21H
            LOOP    LOOP1

            MOV     CX,16
            MOV     BX,RESULT_3 
LOOP2:      ROL     BX,1
            MOV     DX,BX
            AND     DX,1
            OR      DX,30H
            MOV     AH,2
            INT     21H
            LOOP    LOOP2

            MOV     CX,16
            MOV     BX,RESULT_2 
LOOP3:      ROL     BX,1
            MOV     DX,BX
            AND     DX,1
            OR      DX,30H
            MOV     AH,2
            INT     21H
            LOOP    LOOP3

            MOV     CX,16
            MOV     BX,RESULT_1 
LOOP4:      ROL     BX,1
            MOV     DX,BX
            AND     DX,1
            OR      DX,30H
            MOV     AH,2
            INT     21H
            LOOP    LOOP4                                               

EXIT:       MOV     AX,4C00H
            INT     21H
 
MAIN        ENDP

CODE        ENDS
            END     MAIN