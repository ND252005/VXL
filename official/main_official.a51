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
SJMP main
; Hàm khoi tao UART
UART_Init:
    ORL TMOD,   #20H    ; Timer1 mode 2 (8-bit auto-reload)
    MOV TH1,    #0FDH   ; Giá tri TH1 cho speed baud 9600 voi 11.0592MHz
    MOV TL1,    #0FDH   ; gia tri cho thanh ghi TL1
    MOV SCON,   #50H    ; UART mode 1, nhan du lieu (REN = 1)
    SETB TR1            ; Bat Timer1
    RET

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

; Hàm xu ly lenh
Process_command:
    MOV A, index
    JZ End_Process      ; N?u index = 0, không x? lý
    MOV A, buffer       ; Lay ký tu dau tien
    CJNE A, #'K', End_Process ; Neu không phai 'K', bo qua
    MOV R1, #BUFFER_ADDR
    INC R1 
    MOV A, @R1     ; L?y ký t? th? hai
    CJNE A, #'1', CHECK_0
    CLR P2.0            ; N?u 'K1', on LED (P2_0 = 0)
    SJMP End_Process
CHECK_0:
    SETB P2.0           ; Neu 'K0', off LED (P2_0 = 1)
End_Process:
    RET

; Chuong trinh chinh
main:
    ACALL UART_Init     ; khoi tao UART
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
    ACALL UART_Sendstring ; Gui chuoi qua UART
    ACALL Process_command ; Xu lý lenh
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