;====================================================================
; Serial communication
;====================================================================

STACKSG SEGMENT PARA STACK 'STACK'
    DW 20 DUP(?)                  ; Allocate stack (20 words)
STACKSG ENDS

DATASG SEGMENT PARA 'DATA'

ARRAY DB 'HELLO WORLD '               ; Stored name (8 characters)
HATA  DB ' ERROR '                ; Error message (7 characters)

DATASG ENDS

CODE SEGMENT PUBLIC 'CODE'
ASSUME CS:CODE, SS:STACKSG, DS:DATASG

START:
    ;------------------------------
    ; INITIALIZE DATA SEGMENT
    ;------------------------------
    PUSH DS                      ; Save old DS
    XOR AX, AX                   ; AX = 0000
    PUSH AX                      ; Push 0 (for proper termination)

    MOV AX, DATASG              ; Load address of data segment
    MOV DS, AX                  ; Initialize DS

    ;------------------------------
    ; INITIALIZE 8251 USART
    ;------------------------------
    MOV DX, 020AH               ; Control register address

    MOV AL, 01001101B           ; Mode instruction:
                               ; Asynchronous, 8-bit, no parity,
                               ; 1 stop bit, baud factor = 1
    OUT DX, AL

    MOV AL, 40H                 ; Reset command for 8251
    OUT DX, AL

    MOV AL, 01001101B           ; Reinitialize mode
    OUT DX, AL

    MOV AL, 00010101B           ; Enable transmitter & receiver
    OUT DX, AL

;==============================
; MAIN LOOP (RUNS FOREVER)
;==============================
ENDLESS:

    ;------------------------------
    ; WAIT FOR FIRST INPUT (NUMBER)
    ;------------------------------
    MOV DX, 020AH               ; Status register

WAIT_FIRST:
    IN AL, DX
    TEST AL, 02H                ; Check RxRDY (bit 1)
    JZ WAIT_FIRST               ; Wait until data arrives

    MOV DX, 0208H               ; Data register
    IN AL, DX                   ; Read ASCII character

    SUB AL, '0'                 ; Convert ASCII ? number
    CMP AL, 9
    JA ERROR                    ; If >9 ? invalid

    XOR SI, SI                  ; SI = 0 (index pointer)

    CMP AL, 0
    JZ FULLNAME                 ; If 0 ? print full name

    CBW                         ; Convert AL ? AX
    MOV CX, AX                  ; CX = number of chars to check

;==============================
; CHECK INPUT CHARACTERS
;==============================
CHECK_LOOP:

    MOV DX, 020AH

WAIT_CHAR:
    IN AL, DX
    TEST AL, 02H                ; Wait for RxRDY
    JZ WAIT_CHAR

    MOV DX, 0208H
    IN AL, DX                   ; Read character

    CMP AL, ARRAY[SI]           ; Compare with stored name
    JNE ERROR                   ; If mismatch ? ERROR

    INC SI                      ; Next character
    LOOP CHECK_LOOP

;==============================
; SEND REMAINING CHARACTERS
;==============================
FULLNAME:

    MOV CX, 0CH                   ; Total length of name
    SUB CX, SI                  ; Remaining characters

SEND_LOOP:

    MOV DX, 020AH

WAIT_TX:
    IN AL, DX
    AND AL, 01H                 ; Check TxRDY (bit 0)
    JZ WAIT_TX                  ; Wait until ready

    MOV DX, 0208H
    MOV AL, ARRAY[SI]           ; Load next character
    OUT DX, AL                  ; Send to terminal

    INC SI
    LOOP SEND_LOOP

    JMP CONTINUE

;==============================
; ERROR HANDLING (FIXED)
;==============================
ERROR:

    MOV CX, 7                   ; Length of " ERROR "
    XOR SI, SI                  ; Start from first character

ERROR_LOOP:

    MOV DX, 020AH

WAIT_TX_ERR:
    IN AL, DX
    AND AL, 01H                 ; Check TxRDY
    JZ WAIT_TX_ERR

    MOV DX, 0208H
    MOV AL, HATA[SI]            ; Get error character
    OUT DX, AL                  ; Send it

    INC SI
    LOOP ERROR_LOOP

;==============================
; REPEAT PROGRAM
;==============================
CONTINUE:
    JMP ENDLESS                 ; Infinite loop

CODE ENDS
END START