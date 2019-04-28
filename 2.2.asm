STACK   SEGMENT PARA    STACK
STACK_AREA  DW              100h DUP(?)
STACK_TOP   EQU             $-STACK_AREA
STACK   ENDS

 
DATA    SEGMENT PARA
    LEN     EQU     128
    MSG1    DB      'Input an oprand(1-4):',0DH,0AH,'$'
    MSG2    DB      'Input string 1:',0DH,0AH,'$'
    MSG3    DB      'Input string 2:',0DH,0AH,'$'
    MSG4    DB      '<','$'
    MSG5    DB      '=','$'
    MSG6    DB      '>','$'
    MSG7    DB      'Invalid oprand!',0DH,0AH,'$'
    MSG8    DB      'Input a char:',0DH,0AH,'$'
    MSG9_1  DB      'Char $'
    MSG9_2  DB      ' in $'
    MSG10   DB      'Not find $'
    NEW_LINE DB     0DH,0AH,'$'

    STR1    DB      LEN-1
            DB      0
            DB      LEN DUP(0)
    STR2    DB      LEN-1
            DB      0
            DB      LEN DUP(0)
    STR3    DB      LEN-1
            DB      0
            DB      LEN DUP(0)
    CHAR    DB      0
    OP      DB      0
DATA    ENDS


CODE    SEGMENT PARA
        ASSUME  CS:CODE,DS:DATA,SS:STACK


DISP_MSG        MACRO   MSG
        MOV     DX,OFFSET MSG
        MOV     AH,9
        INT     21H
        ENDM


GET_STR MACRO   STR
        MOV     DX,OFFSET STR     
        MOV     AH,0AH
        INT     21H 
        
        MOV     CL,STR+1 ;输入时以00H结尾
        XOR     CH,CH
        MOV     DI,OFFSET STR+2
        ADD     DI,CX
        XOR     AL,AL 
        STOSB
        ENDM


PUT_STR     MACRO   STR
        MOV     DI,OFFSET STR+2 ;输出时补'$'
        MOV     CL,STR+1
        XOR     CH,CH
        ADD     DI,CX
        MOV     AL,'$' 
        STOSB

        MOV     DX,OFFSET STR+2
        MOV     AH,9
        INT     21H
        ENDM


GET_CHAR MACRO  CHAR
        MOV     AH,1
        INT     21H
        MOV     CHAR,AL
        ENDM


PUT_CHAR MACRO  CHAR
        MOV     DL,CHAR
        MOV     AH,2
        INT     21H
        ENDM


GET_OP   MACRO 
        GET_CHAR OP
        SUB     OP,30H
        ENDM


STRCPY  MACRO   STR1,STR2,STR3
        MOV     SI,OFFSET STR1+2
        MOV     DI,OFFSET STR3+2
        CLD
        XOR     CH,CH
        MOV     CL,STR1+1
        INC     CL
        MOV     BL,CL
        REP     MOVSB

        MOV     SI,OFFSET STR2+2
        MOV     CL,STR2+1
        INC     CL
        ADD     BL,CL
        REP     MOVSB
        MOV     STR3+1,BL
        
        ENDM


STRCMP    PROC
        MOV     SI,OFFSET STR1+2
        MOV     DI,OFFSET STR2+2
        XOR     CH,CH
        MOV     CL,STR1+1
        CMP     CL,STR2+1
        JBE     ELSE1
        MOV     CL,STR2+1
ELSE1:
        INC     CX
        CLD
        REPE    CMPSB
        RET
STRCMP    ENDP


P1  PROC
        CALL STRCMP
        PUT_STR    STR1
        JB      LAB1
        JZ      LAB2
        JA      LAB3
LAB1:
        
        DISP_MSG    MSG4
        JMP     P1_RET
LAB2:   
        DISP_MSG    MSG5
        JMP     P1_RET
LAB3:   
        DISP_MSG    MSG6
        ;JMP     P1_RET

P1_RET: 
        PUT_STR    STR2
        RET
P1      ENDP


P2  PROC
        MOV     SI,OFFSET STR1+2
        MOV     DI,OFFSET STR3+2
        CLD
        XOR     CH,CH
        MOV     CL,STR1+1
        MOV     BL,CL
        REP     MOVSB

        MOV     SI,OFFSET STR2+2
        MOV     CL,STR2+1
        ADD     BL,CL
        INC     CL
        REP     MOVSB
        MOV     STR3+1,BL

        PUT_STR    STR3
        RET
P2  ENDP


P3  PROC
        DISP_MSG    MSG8
        GET_CHAR    CHAR
        DISP_MSG    NEW_LINE

        MOV     DI,OFFSET STR1+2
        MOV     CL,STR1+1
        XOR     CH,CH
        CLD
        MOV     AL,CHAR
        REPNZ   SCASB
        JZ      FOUND
NOT_FOUND:
        DISP_MSG    MSG10
        PUT_CHAR    CHAR
        DISP_MSG    NEW_LINE
        JMP         P3_RET
FOUND:
        DISP_MSG    MSG9_1
        PUT_CHAR    CHAR
        DISP_MSG    MSG9_2
        PUT_STR     STR1
        DISP_MSG    NEW_LINE
P3_RET:
        RET
P3  ENDP


P4  PROC
        CALL    STRCMP
        JA      P4_ABOVE
        STRCPY  STR1,STR2,STR3
        JMP     P4_RET
P4_ABOVE:   
        STRCPY  STR2,STR1,STR3
P4_RET:
        PUT_STR STR3
        RET
P4  ENDP


SWITCH  PROC
        CMP     OP,1
        JNE     LP2
        CALL    P1
        JMP     SWITCH_RET
LP2:    CMP     OP,2
        JNE     LP3
        CALL    P2
        JMP     SWITCH_RET
LP3:    CMP     OP,3
        JNE     LP4
        CALL    P3
        JMP     SWITCH_RET
LP4:    CMP     OP,4
        JNE     ERROR
        CALL    P4
        JMP     SWITCH_RET
ERROR:
        DISP_MSG MSG7
SWITCH_RET:
        RET
SWITCH  ENDP


MAIN    PROC    FAR
        MOV     AX,DATA
        MOV     DS,AX
        MOV     ES,AX 
        
        DISP_MSG    MSG2
        GET_STR     STR1
        DISP_MSG    NEW_LINE
        DISP_MSG    MSG3
        GET_STR     STR2
        DISP_MSG    NEW_LINE
        DISP_MSG    MSG1
        GET_OP
        DISP_MSG    NEW_LINE

        CALL    SWITCH
            
EXIT:   MOV     AX,4C00H
        INT     21H
MAIN    ENDP


CODE    ENDS
        END     MAIN