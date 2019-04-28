STACK       SEGMENT PARA STACK
STACK_AREA  DW      100h DUP(?)
STACK_TOP   EQU     $-STACK_AREA
STACK       ENDS            ；①-1定义堆栈段

DATA        SEGMENT PARA
TABLE_LEN   DW 16
TABLE       DW 200,300,400,10,20,0,1,8
            DW 41H,40,42H,50,60,0FFFFH,2,3
DATA        ENDS            ;①-2定义数据段

CODE        SEGMENT
            ASSUME  CS:CODE,DS:DATA
            ASSUME  SS:STACK        ;②SET SS,SP,DS
MAIN        PROC        FAR
        
START:      MOV     AX,STACK
            MOV     SS,AX
            MOV     SP,STACK_TOP
            MOV     AX,DATA
            MOV     DS,AX           ;③SET SS,SP,DS

LP1:        MOV     BX,1
            MOV     CX,TABLE_LEN
            DEC     CX
            MOV     SI,OFFSET TABLE
LP2:        MOV     AX,[SI]
            CMP     AX,[SI+2]
            JBE     CONTINUE
            XCHG    AX,[SI+2]
            MOV     [SI],AX
            MOV     BX,0
CONTINUE:
            ADD     SI,2
            LOOP    LP2

            CMP     BX,1
            JZ      EXIT
            JMP     SHORT   LP1

EXIT:       MOV    AX,4C00H
            INT     21H             ;④返回DOS
MAIN        ENDP                    ;只有一个子程序
CODE        ENDS                    ; ①-3定义代码段
            END     START           ;⑤总结束

