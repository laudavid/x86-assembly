STACK       SEGMENT PARA    STACK
STACK_AREA  DW      100h DUP(?)
STACK_TOP   EQU     $-STACK_AREA
STACK       ENDS


DATA        SEGMENT PARA
TABLE_LEN   EQU 10
TABLE       DB  'LIUWEI',0,'$'
            DB  'LW1234',0,'$'
            DB  'ASDFGH',0,'$'
            DB  'QWERWQ',0,'$'
            DB  'ZXCVWQ',0,'$'
            DB  '1234WQ',0,'$'
            DB  'asPOIU',0,'$'
            DB  '123We5',0,'$'
            DB  'e3MNBc',0,'$'
            DB  'e3MNBC',0,'$'
P_TABLE     DW  TABLE_LEN DUP(0)
NEW_LINE    DB  0DH,0AH,'$'
DATA        ENDS


CODE    SEGMENT PARA
        ASSUME  CS:CODE,DS:DATA,SS:STACK


INIT    PROC
        MOV     DI,OFFSET TABLE
        MOV     SI,OFFSET P_TABLE  
        MOV     CX,TABLE_LEN
        MOV     AL,'$'
        CLD
LOOP1:
        MOV     [SI],DI
        ADD     SI,2
LOOP2:  
        SCASB
        JNZ     LOOP2
        LOOP    LOOP1
        
        RET
INIT    ENDP


OUTPUT  PROC
        MOV     CX,TABLE_LEN
        MOV     SI,OFFSET P_TABLE
OUTPUT_NEXT:    
        MOV     DX,[SI]
        MOV     AH,9
        INT     21H              
        ADD     SI,2
        LOOP    OUTPUT_NEXT

        MOV     DX,OFFSET NEW_LINE
        MOV     AH,9
        INT     21H
        
        RET
OUTPUT  ENDP


STRCMP  PROC
        PUSH    SI

        MOV     SI,AX
        MOV     DI,DX
        CLD
CMP_NEXT:
        CMPSB
        JNZ     CMP_RET
        CMP     BYTE PTR [SI],'$'
        JZ      CMP_RET
        JMP     CMP_NEXT
CMP_RET:
        POP     SI
        RET
STRCMP    ENDP


SORT    PROC
LP1:    
        MOV     BX,1
        MOV     CX,TABLE_LEN
        DEC     CX
        MOV     SI,OFFSET P_TABLE
LP2:        
        MOV     AX,[SI]
        MOV     DX,[SI+2]
        CALL    STRCMP
        JBE     CONTINUE
        XCHG    AX,[SI+2]
        MOV     [SI],AX
        MOV     BX,0
CONTINUE:
        ADD     SI,2
        LOOP    LP2

        CMP     BX,1
        JNZ     LP1

        RET
SORT    ENDP


MAIN    PROC    FAR
        MOV     AX,DATA
        MOV     DS,AX
        MOV     ES,AX

        CALL    INIT
        CALL    OUTPUT
        CALL    SORT
        CALL    OUTPUT
EXIT:   
        MOV     AX,4C00H
        INT     21H
MAIN    ENDP

CODE    ENDS
        END     MAIN
 