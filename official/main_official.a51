; Define const and variable 
BUFFER_SIZE equ 32
BUFFER_ADDR equ 30H  ; Ðia chi bat dau trong ram noi

; Ðinh nghia segment du lieu trong RAM noi (bat dau tu 30H)
DSEG AT 30H
buffer: DS BUFFER_SIZE
index: DS 1


;===========CODE SEGMENT==========
CSEG
ORG 0000H
LJMP main
; Hàm gui mot ky tu qua UART
UART_Sendchar:
    MOV SBUF, A         ; Gui ký tu cua A vào SBUF
WAIT_TI:
    JNB TI, WAIT_TI     ; wait flag TI = 1 (truyen xong)
    CLR TI              ; Reset flag TI 
RET

; Hàm gui mot chuoi ky tu qua UART
UART_Sendstring:
Send_loop:
    MOV A, @R0          ; Lay ký tu cua dia chi R0
    JZ Send_End         ; Neu ký tu la '\0', ket thuc
    ACALL UART_Sendchar ; gui ký tu
    INC R0              ; Tang con tro
    SJMP Send_loop
Send_End:
RET

;XU LY HIEU UNG LED
Delay:
    mov R2, #3         ; Lặp 10 lần, mỗi lần 50ms
Delay_Loop:
    mov TH0, #04Ch      ; 4 bit msb
    mov TL0, #050h      ; 4 bit lsb
    clr TF0             ; Xóa cờ tràn Timer 0
    setb TR0            ; Bật Timer 0
    
WaitT0:
    jnb TF0, WaitT0     ; Đợi đến khi Timer 0 tràn (TF0 = 1)
    
    clr TF0             ; Xóa cờ tràn
    clr TR0             ; Tắt Timer 0
    
    djnz R2, Delay_Loop ; Giảm R2 và lặp nếu chưa đủ 10 lần
RET                     ; Trả về
Effect1:
    MOV 	R1, #7
   
    LoopE1:
        MOV 	p2, #00000000b
        ACALL 	Delay
        ACALL 	Delay
        
        MOV 	p2, #11111111b
        ACALL 	Delay   
        ACALL 	Delay
      
    DJNZ	R1, LoopE1

    MOV     p2, #0FFH

RET

Effect2:
    MOV 	p2, #0FFh
    MOV 	R1, #7
   
    LoopE2:
        MOV 	p2, #01010101b
        ACALL 	Delay
        ACALL 	Delay
        
        MOV 	p2, #10101010b
        ACALL  	Delay
        ACALL  	Delay
        
    DJNZ	R1, LoopE2

    MOV p2, #0FFH

RET

Effect3:
    MOV		p2, #11100111b
    ACALL	Delay
    MOV		p2, #11011011b
    ACALL	Delay
    MOV		p2, #10111101b
    ACALL 	Delay
    MOV		p2, #01111110b
    ACALL	Delay
    
    MOV		p2, #11100111b
    ACALL	Delay
    MOV		p2, #11011011b
    ACALL	Delay
    MOV		p2, #10111101b
    ACALL 	Delay
    MOV		p2, #01111110b
    ACALL	Delay
    
    MOV		p2, #11100111b
    ACALL	Delay
    MOV		p2, #11011011b
    ACALL	Delay
    MOV		p2, #10111101b
    ACALL 	Delay
    MOV		p2, #01111110b
    ACALL	Delay
    
    MOV		p2, #11100111b
    ACALL	Delay
    MOV		p2, #11011011b
    ACALL	Delay
    MOV		p2, #10111101b
    ACALL 	Delay
    MOV		p2, #01111110b
    ACALL	Delay
    
RET

Effect4:
   MOV		p2, #01111110b
   ACALL	Delay
   MOV		p2, #10111101b
   ACALL	Delay
   MOV		p2, #11011011b
   ACALL	Delay
   MOV		p2, #11100111b
   ACALL	Delay
   
   MOV		p2, #01111110b
   ACALL	Delay
   MOV		p2, #10111101b
   ACALL	Delay
   MOV		p2, #11011011b
   ACALL	Delay
   MOV		p2, #11100111b
   ACALL	Delay
   
   MOV		p2, #01111110b
   ACALL	Delay
   MOV		p2, #10111101b
   ACALL	Delay
   MOV		p2, #11011011b
   ACALL	Delay
   MOV		p2, #11100111b
   ACALL	Delay
   
   MOV		p2, #01111110b
   ACALL	Delay
   MOV		p2, #10111101b
   ACALL	Delay
   MOV		p2, #11011011b
   ACALL	Delay
   MOV		p2, #11100111b
   ACALL	Delay

RET

Effect5:
    MOV		A, #01111111b
    ACALL	Delay
   
    LoopE51:
        RL	A
        MOV 	p2, A
        ACALL	Delay
        CJNE A, #01111111B, LoopE51
    
    LoopE52:
        RL	A
        MOV 	p2, A
        ACALL	Delay
        CJNE A, #01111111B, LoopE52
    
    LoopE53:
        RL	A
        MOV 	p2, A
        ACALL	Delay
        CJNE A, #01111111B, LoopE53
    
    LoopE54:
        RL	A
        MOV 	p2, A
        ACALL	Delay
        CJNE A, #01111111B, LoopE54

    MOV p2, #0FFH


RET

Effect6:
    MOV A, #00H           ; Neu 'K0', off LED (P2_0 = 1)
    MOV p2, A
RET

; Hàm xu ly lenh
Process_command:
    MOV A, index
    JZ End_Process      ; Neu index = 0, không xu ly
    MOV A, buffer       ; Lay ký tu dau tien
    CJNE A, #'E', End_Process ; Neu không phai 'K', bo qua
    MOV R1, #BUFFER_ADDR
    INC R1

CHECK_1:
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'1', CHECK_2
    ACALL Effect1
    SJMP End_Process
    
CHECK_2:
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'2', CHECK_3
    ACALL Effect2
    SJMP End_Process
    
CHECK_3:
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'3', CHECK_4
    ACALL Effect3
    SJMP End_Process
    
CHECK_4:    
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'4', CHECK_5
    ACALL Effect4
    SJMP End_Process
    
CHECK_5:    
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'5', CHECK_6
    ACALL Effect5
    SJMP End_Process

CHECK_6:    
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'6', CHECK_0
    ACALL Effect6
    SJMP End_Process


CHECK_0:
    MOV A, #0FFH           ; Neu 'K0', off LED (P2_0 = 1)
    MOV p2, A

End_Process:
    RET

; Chuong trinh chinh
main:
;khoi tao uart
    ORL TMOD,   #21H    ; Timer1 mode 2 (8-bit auto-reload)
    MOV TH1,    #0FDH   ; Giá tri TH1 cho speed baud 9600 voi 11.0592MHz
    MOV TL1,    #0FDH   ; gia tri cho thanh ghi TL1
    MOV SCON,   #50H    ; UART mode 1, nhan du lieu (REN = 1)
    SETB TR1            ; Bat Timer1
Main_loop:
    JNB RI, Main_loop   ; Check flag RI = 1 (flag receive)
    MOV A, SBUF
    CLR RI              ; Reset flag RI
    CJNE A, #0AH, NOT_NEWLINE ; neu khong phai '\n', xu ly tiep not newline
    ; Khi nhan '\n'
    MOV A, index
    MOV R0, #BUFFER_ADDR
    ADD A, R0
    MOV R0, A
    MOV @R0, #0         ; Thêm ký tu null ('\0') vào cuoi buffer
    MOV R0, #BUFFER_ADDR
    ACALL UART_Sendstring ; Gui chuoi qua UART
    ACALL Process_command ; Xu lý lenh
    MOV index, #0       ; Reset index
    ACALL CLR_CPY
    SJMP Main_loop
NOT_NEWLINE:
    MOV A, index
    CJNE A, #BUFFER_SIZE-1, Add_Char ; Ne   u buffer day, bo qua
    SJMP Main_loop
Add_Char:
    MOV R0, #BUFFER_ADDR
    MOV A, index
    ADD A, R0
    MOV R0, A
    MOV A, SBUF         ; Luu ky tu nhan duoc
    MOV @R0, A          ; Luu ký tu vào buffer[index]
    INC index           ; Tang index
    CLR RI
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