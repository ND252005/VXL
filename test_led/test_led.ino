#define led_pin 7
void setup() {
    pinMode(led_pin, OUTPUT);
    Serial.begin(115200);
}
String str = "";
void loop() {
    if(Serial.available()) {
        char ch = Serial.read();
        if(ch != '\n')  str += ch;
        else {
            Serial.println(str);
            process_command(str);
            str = "";
        }
    }
}

void process_command(String s) {
    char first = s.charAt(0);
    char second = s.charAt(1);
    if(first == 'l') {
        if(second == '1')   digitalWrite(led_pin, 1);
    }  
    if(first == 'l') {
        if(second == '0')   digitalWrite(led_pin, 0);
    }  
}