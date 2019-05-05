STACK       SEGMENT PARA    STACK
STACK_AREA  DW              100H DUP(?)
STACK_TOP   EQU             $-STACK_AREA
STACK       ENDS

DATA        SEGMENT PARA
NUM1  DW          0
NUM2  DW          0
RESULT  DW        0
RESULT_L  DW      0
RESULT_H  DW      0
MSG1    DB      'Input num1:',0DH,0AH,'$'
MSG2    DB      'Input num2:',0DH,0AH,'$'
MSG3    DB      'Result without overflow:',0DH,0AH,'$'
MSG4    DB      'Result with overflow:',0DH,0AH,'$'
NEW_LINE DB     0DH,0AH,'$'
DATA        ENDS


CODE        SEGMENT PARA
            ASSUME  CS:CODE,DS:DATA,SS:STACK


DISP_MSG        MACRO   MSG
        MOV     DX,OFFSET MSG
        MOV     AH,9
        INT     21H
ENDM


GET_DIGIT   MACRO NUM,FACTOR
            MOV   AH,1
            INT   21H
            SUB   AL,30H
            MOV   DL,FACTOR
            MUL   DL
            ADD   NUM,AX
            ENDM


GET_NUM     MACRO NUM
            GET_DIGIT NUM,100
            GET_DIGIT NUM,10
            GET_DIGIT NUM,1
            ENDM


PUT_NUM     MACRO

            POP     DX
            OR      DL,30H
            MOV     AH,2
            INT     21H
            ENDM


INPUT       PROC
            DISP_MSG MSG1
            GET_NUM NUM1
            DISP_MSG NEW_LINE
            DISP_MSG MSG2
            GET_NUM NUM2
            DISP_MSG NEW_LINE
            RET
INPUT       ENDP


OUTPUT_32   PROC

            XOR     CX,CX
LOOP1:                      ;显示32位十进制结果，将32位结果分为2个16位，从高到低每16位除以10，将商更新到对应位置，余数与下一个16位组成一个32位数继续除以10，将最后的余数压栈
            MOV     BX,10
            XOR     DX,DX 
            MOV     AX,RESULT_H
            DIV     BX
            MOV     RESULT_H,AX
            MOV     AX,RESULT_L
            DIV     BX
            MOV     RESULT_L,AX

            PUSH    DX
            INC     CX

            XOR     BX,BX
            OR      BX,RESULT_H
            OR      BX,RESULT_L
            CMP     BX,0
            JNZ     LOOP1
LOOP2:                          ;依次输出栈中保存的每一位结果
            PUT_NUM
            LOOP    LOOP2
            RET
OUTPUT_32   ENDP


OUTPUT_16   PROC         ;显示十进制结果

            XOR     CX,CX
LOOP3:                      
            MOV     BX,10
            XOR     DX,DX 
            MOV     AX,RESULT
            DIV     BX
            MOV     RESULT,AX

            PUSH    DX
            INC     CX

            CMP     RESULT,0
            JNZ     LOOP3
LOOP4:                          ;依次输出栈中保存的每一位结果
            PUT_NUM
            LOOP    LOOP4
            RET
OUTPUT_16   ENDP


OUTPUT       PROC
            DISP_MSG MSG3
            CALL OUTPUT_32
            DISP_MSG NEW_LINE
            DISP_MSG MSG4
            CALL OUTPUT_16
            DISP_MSG NEW_LINE
            RET
OUTPUT      ENDP


MAIN        PROC  FAR
            MOV   AX,DATA
            MOV   DS,AX
            
            CALL  INPUT
            
            MOV   AX,NUM1
            MUL   NUM2
            MOV   RESULT,AX
            MOV   RESULT_L,AX 
            MOV   RESULT_H,DX

            CALL OUTPUT

EXIT:       MOV     AX,4C00H
            INT     21H
 
MAIN        ENDP

CODE        ENDS
            END     MAIN