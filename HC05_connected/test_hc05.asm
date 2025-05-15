;Define const and variable
BUFFER_SIZE equ 32
BUFFER_ADDR equ 30H  ; Ðia chi bat dau trong ram noi

; Ðinh nghia segment du lieu trong RAM noi (bat dau tu 30H)
DSEG AT 30H
buffer: DS BUFFER_SIZE
index: DS 1
CSEG
ORG 0000H
LJMP main
RS_pin BIT 90H  ; P1.0
RW_pin BIT 91H  ; P1.1
EN_pin BIT 92H  ; P1.2
D4_pin BIT 84H  ; P0.4
D5_pin BIT 85H  ; P0.5
D6_pin BIT 86H  ; P0.6
D7_pin BIT 87H  ; P0.7  
; data  =   R5
; time  =   R7

;use r6, r7 for delay time
;DELAY MICRO SECOND 

Delay_us:
    DJNZ R7, Delay_us
    RET 
;DELAY MILLIS SECOND
Delay_ms:
    mov r6, #55H
Delay_ms1:
    DJNZ R6, Delay_ms1
    DJNZ R7, Delay_ms
    RET

;=====GIAO TIEP VOI 1602 4 BIT===== 
LCD_enable:
    SETB EN_pin 
    MOV R7, #3
    LCALL Delay_us
    CLR EN_pin
    MOV R7, #50
    LCALL Delay_us
    RET

;use r5 for data 
LCD_send4bit:
    ; D4_pin = R5.0
    MOV A, R5
    ANL A, #01H
    MOV C, ACC.0
    MOV D4_pin, C
    
    ; D5_pin = R5.1
    MOV A, R5
    RR A
    ANL A, #01H
    MOV C, ACC.0
    MOV D5_pin, C
    
    ; D6_pin = R5.2
    MOV A, R5
    RR A
    RR A
    ANL A, #01H
    MOV C, ACC.0
    MOV D6_pin, C
    
    ; D7_pin = R5.3
    MOV A, R5
    RR A
    RR A
    RR A
    ANL A, #01H
    MOV C, ACC.0
    MOV D7_pin, C
    
    RET
;use r5 luu data truoc khi su dung lenh lcd_sendcommand
LCD_sendcommand:
    ;DICH PHAI 4 BIT
    MOV A, R5
	MOV R4, A
    RR A
    RR A
    RR A
    RR A
    MOV R5, A
    LCALL LCD_send4bit
    LCALL LCD_enable
	MOV A, R4
	MOV R5, A 
    LCALL LCD_send4bit
    LCALL LCD_enable
    RET
;CLEAR MONITOR 
LCD_clear:
    MOV R5, #01H
    LCALL LCD_sendcommand
    MOV R7, #2
    LCALL Delay_ms
    RET
;KHOI TAO LCD
LCD_init:
    MOV R5, #00H
    MOV R7, #20
    LCALL Delay_ms 
    CLR RS_pin
    CLR RW_pin
    MOV R5, #03H
    LCALL LCD_send4bit
    LCALL LCD_enable
    MOV R7, #5
    LCALL Delay_ms
    LCALL LCD_enable
    MOV R7, #100
    LCALL Delay_us 
    LCALL LCD_enable
    MOV R5, #02H 
    LCALL LCD_send4bit
    LCALL LCD_enable
    MOV R5, #28H
    LCALL LCD_sendcommand
    MOV R5, #0CH
    LCALL LCD_sendcommand
    MOV R5, #06H
    LCALL LCD_sendcommand
    MOV R5, #01H
    LCALL LCD_sendcommand
    RET
; r2 = x, r3 = y
LCD_goto:
    CJNE R3, #'0', DONG_1
;DONG 0
    MOV A, #80H
    ADD A, R3
    SJMP SEND_GOTO
DONG_1:
    MOV A, #0C0H 
    ADD A, R3
SEND_GOTO:
    MOV R7, #250
    LCALL Delay_us
    MOV R7, #250
    LCALL Delay_us
    MOV R7, #250
    LCALL Delay_us
    MOV R7, #250
    LCALL Delay_us
    MOV R5, A
    LCALL LCD_sendcommand
    MOV R7, #50
    LCALL Delay_us
    RET

LCD_putchar:
    SETB RS_pin
    LCALL LCD_sendcommand 
    CLR RS_pin
    RET

LCD_putstring: 
    MOV A, @R0          ; Lay ký tu cua dia chi R0
    JZ Send_End         ; Neu ký tu la '\0', ket thuc
    ACALL LCD_putchar
    INC R0              ; Tang con tro
    SJMP LCD_putstring
Send_End:
    RET

;UART BLOCK
UART_Init:
    ORL TMOD,   #20H    ; Timer1 mode 2 (8-bit auto-reload)
    MOV TH1,    #0FDH   ; Giá tri TH1 cho speed baud 9600 voi 11.0592MHz
    MOV SCON,   #50H    ; UART mode 1, nhan du lieu (REN = 1)
    SETB TR1            ; Bat Timer1
    RET

;CHUONG TRINH CHINH 
main:
    ACALL UART_Init     ; khoi tao UART
    ACALL LCD_init      ; khoi tao lcd
    
    MOV SBUF, #'S'      ; Gui ky tu 'S' de xac nhan UART hoat dong
    JNB TI, $           ; Cho den khi ky tu duoc gui xong
    CLR TI              ; Xoa co TI
Main_loop:
    JNB RI, Main_loop   ; Check flag RI = 1 (flag receive)
    MOV A, SBUF
    CLR RI              ; Reset flag RI
    CJNE A, #0AH, NOT_NEWLINE ; neu khong phai '\n', xu ly tiep not newline
    ; Khi nh?n '\n'
    MOV A, index
    MOV R0, #BUFFER_ADDR
    ADD A, R0
    MOV R0, A
    MOV @R0, #0         ; Thêm ký tu null ('\0') vào cuoi buffer
    MOV R0, #BUFFER_ADDR
    LCALL LCD_putstring
    MOV index, #0       ; Reset index
    ACALL CLR_CPY
    SJMP Main_loop
NOT_NEWLINE:
    MOV A, index
    CJNE A, #BUFFER_SIZE-1, Add_Char ; N?u buffer day, bo qua
    SJMP Main_loop
Add_Char:
    MOV R0, #BUFFER_ADDR
    MOV A, index
    ADD A, R0
    MOV R0, A
    MOV A, SBUF         ; Luu ky tu nhan duoc
    MOV @R0, A          ; Luu ký tu vào buffer[index]
    INC index           ; Tang index
    SJMP Main_loop
CLR_CPY:
    MOV R0, #BUFFER_ADDR
    MOV R1, #BUFFER_SIZE
CLR_LOOP:
    MOV @R0, #0
    INC R0
    DJNZ R1, CLR_LOOP
    RET
END