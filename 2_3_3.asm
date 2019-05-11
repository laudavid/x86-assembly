STACK       SEGMENT PARA    STACK
STACK_AREA  DW      100h DUP(?)
STACK_TOP   EQU     $-STACK_AREA
STACK       ENDS


DATA        SEGMENT PARA
STR_LEN     EQU     128
STR1        DB      STR_LEN-1
            DB      0
            DB      STR_LEN DUP(0)

TABLE_LEN   EQU     10
TABLE       DB      'LW',0,'$'
            DB      'ABCD',0,'$'
            DB      'QWERRR',0,'$'
            DB      'asf',0,'$'
            DB      'we@12',0,'$'
            DB      '12we',0,'$'
            DB      'asPOIU',0,'$'
            DB      'W123W',0,'$'
            DB      'e3Mc',0,'$'
LAST_STR    DB      STR_LEN DUP(0)
P_TABLE     DW      TABLE_LEN DUP(0)
NEW_LINE    DB      0DH,0AH,'$'
MSG1        DB      'Input a string:',0DH,0AH,'$'
MSG2        DB      'Before sort:',0DH,0AH,'$'
MSG3        DB      'After sort:',0DH,0AH,'$'
DATA        ENDS


CODE    SEGMENT PARA
        ASSUME  CS:CODE,DS:DATA,SS:STACK


DISP_MSG        MACRO   MSG
        MOV     DX,OFFSET MSG
        MOV     AH,9
        INT     21H
        ENDM


PUT_STR         MACRO STR
        PUSH    CX
        MOV     BH,0
        MOV     AH,3
        INT     10H

        MOV     BP,OFFSET STR+2
        MOV     CL,STR+1
        XOR     CH,CH

        MOV     BH,0
        MOV     AL,1
        MOV     BL,70H
        MOV     AH,13H
        INT     10H

        MOV     DL,0
        MOV     AH,2
        INT     21H

        POP     CX
        ENDM


GET_STR MACRO   STR
        MOV     DX,OFFSET STR     
        MOV     AH,0AH
        INT     21H 
        
        MOV     CL,STR+1 ;输入时以00H结尾
        XOR     CH,CH
        MOV     DI,OFFSET STR+2
        ADD     DI,CX
        CLD
        XOR     AL,AL 
        STOSB
        MOV     AL,'$'
        STOSB
        ENDM


STRCPY  MACRO   STR1,STR2
        MOV     SI,OFFSET STR1+2
        MOV     DI,OFFSET STR2
        CLD
        XOR     CH,CH
        MOV     CL,STR1+1
        ADD     CX,2
        REP     MOVSB
        ENDM


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
        CMP     DX,OFFSET LAST_STR
        JZ      LOOP4 
        MOV     AH,9
        INT     21H
        JMP LOOP3
LOOP4:
        PUT_STR STR1
LOOP3:
        ADD     SI,2
        LOOP    OUTPUT_NEXT

        DISP_MSG NEW_LINE
        
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

        DISP_MSG    MSG1
        GET_STR     STR1
        DISP_MSG    NEW_LINE
        STRCPY      STR1,LAST_STR

        CALL    INIT
        DISP_MSG    MSG2
        CALL    OUTPUT
        CALL    SORT
        DISP_MSG    MSG3
        CALL    OUTPUT
EXIT:   
        MOV     AX,4C00H
        INT     21H
MAIN    ENDP

CODE    ENDS
        END     MAIN