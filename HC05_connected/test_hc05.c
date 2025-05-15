#include <reg51.h>

#define BUFFER_SIZE 32

char buffer[BUFFER_SIZE];
unsigned char index = 0;

void UART_Init() {
    TMOD |= 0x20;       // Timer1 mode 2 (8-bit auto-reload)
    TH1 = 0xFD;         // T?c d? baud 9600 cho 11.0592 MHz
    SCON = 0x50;        // UART mode 1, REN = 1
    TR1 = 1;            // B?t d?u Timer1
}

void UART_SendChar(char c) {
    SBUF = c;
    while (!TI);        // Ch? truy?n xong
    TI = 0;             // Reset c? truy?n
}

void UART_SendString(char* str) {
    while (*str) {
        UART_SendChar(*str++);
    }
}
void proccess_command(char* str, int index) {
    if(index > 0) {
        if(str[0] == 'K') {
            if(str[1] == '1') {
                P2_0 = 0;
            } else {
                P2_0 = 1;
            }
        }
    }
}

void main() {
		char received;
    UART_Init();
    while (1) {
        while (!RI);                // Ch? có d? li?u nh?n
        received = SBUF;
        RI = 0;                     // Reset c? nh?n
        P2_0 = 0;
        if (received == '\n') {
            buffer[index] = '\0';   // K?t thúc chu?i b?ng NULL
            UART_SendString(buffer);
            proccess_command(buffer, index);
            index = 0;              // Reset l?i v? trí luu
        } else {
            if(index == 0) {
                    // buffer[index++] = 'R';
                    // buffer[index++] = 'E';
                    // buffer[index++] = 'S';
                    // buffer[index++] = 'E';
                    // buffer[index++] = 'N';
                    // buffer[index++] = 'D';
                    // buffer[index++] = ':';
                    // buffer[index++] = ' ';
                    buffer[index++] = received;
            }
            else if (index < BUFFER_SIZE - 1) {
                buffer[index++] = received;
            }
        }
    }
}