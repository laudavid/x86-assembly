STACK 	SEGMENT	PARA	STACK
		DW		100H DUP(?)
STACK	ENDS

DATA	SEGMENT	PARA             
	X		DW 	0
	Y		DW  0
	TEN     DB  10
	MSG_1 	DB 	'Please input X and Y:',0DH,0AH,'$'
	MSG_2   DB	'The result is:','$'
	NEW_LINE DB	0DH,0AH,'$'
DATA 	ENDS

CODE 	SEGMENT PARA
		ASSUME	CS:CODE,DS:DATA,SS:STACK

DISP	MACRO	MSG
		PUSH  	DX
		PUSH 	AX

		MOV     DX,OFFSET MSG
		MOV     AH,9
		INT     21H

		POP 	AX
		POP	 	DX
ENDM


GETNUM  MACRO   NUM
		MOV 	AH,1
		INT 	21H
		AND     AL,0FH
		MUL     TEN
		MOV     BX,AX

		MOV 	AH,1
		INT 	21H
		AND     AL,0FH
		
        XOR     AH,AH
		ADD     AX,BX
		MOV     NUM,AX
ENDM

PUTNUM     MACRO ;显示AX中16位十进制结果
		    XOR     CX,CX   
            MOV     BX,10
LOOP1:      
			XOR     DX,DX
            DIV     BX
            PUSH    DX
            INC     CX
            CMP     AX,0
            JNZ     LOOP1
LOOP2:                          ;依次输出栈中保存的每一位结果
            POP     DX
			OR      DL,30H
			MOV     AH,2
			INT     21H
            LOOP    LOOP2
ENDM


MAIN	PROC 	FAR
		MOV 	AX,DATA
		MOV 	DS,AX
		MOV 	ES,AX
		
		DISP	MSG_1
		GETNUM  X
		GETNUM  Y
		DISP	NEW_LINE
		MOV     AX,X
		MUL     Y
		DISP	MSG_2
		PUTNUM

		MOV 	AX,4C00H
		INT 	21H
MAIN 	ENDP

CODE 	ENDS
		END 	MAIN
