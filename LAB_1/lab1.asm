.386
.MODEL FLAT, STDCALL
; прототипы внешних функций (процедур) описываются директивой EXTERN,
; после знака @ указывается общая длина передаваемых параметров,
; после двоеточия указывается тип внешнего объекта – процедура
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN ExitProcess@4: PROC; функция выхода из программы
EXTERN lstrlenA@4: PROC; функция определения длины строки

.DATA; сегмент данных
DIN DD ?; дескриптор ввода
DOUT DD ?; дескриптор ввывода
WELCOME_MSG DB "Введите число в шестнадцатиричной системе счисления", 13, 10, 0
ERROR_MSG DB "Неверный формат числа. Возврат к началу ввода", 13, 10, 0
BUF DB 200 dup (?); буфер для ввода/вывода строк длинной 200 байт
STRN DD ?; строка для вывода
LENS DD ?; переменная для количества выведенных символов

SIGN_FLAG DD ?;

FIRST_NUMBER DD 0; первое число
SECOND_NUMBER DD 0; второе число


.CODE; сегмент кода

; процедура перевода строки в число
STRTOINT PROC
MOV ESI, [ESP+4]
PUSH ESI
CALL lstrlenA@4
MOV ECX, EAX
SUB ECX, 2
MOV EDI, 16
XOR EBX, EBX
XOR EAX, EAX
MOV BL, [ESI]
CMP BX, '-'
JE MINUS
JNE NONMINUS
MINUS:
	MOV SIGN_FLAG, -1
	INC ESI
	DEC ECX
	JMP ENDMINUS
NONMINUS:
	MOV SIGN_FLAG, 1
	JMP ENDMINUS
ENDMINUS:
CONVERT:
	MOV BL, [ESI]
	CMP BX, 'A'
	JB TEN
	CMP BX, 'F'
	JA ERROR_NONINT
	SUB BX, 'A'
	ADD BX, 10
	JMP FINAL_SUM
	TEN:
		CMP BX, '0'
		JB ERROR_NONINT
		CMP BX, '9'
		JA ERROR_NONINT
		SUB BX, '0'
		JMP FINAL_SUM
	FINAL_SUM:
		MUL EDI
		ADD EAX, EBX
	INC ESI
LOOP CONVERT
IMUL SIGN_FLAG
MOV EBX, 0
JMP ENDCONVERT
ERROR_NONINT:
	PUSH OFFSET ERROR_MSG
	CALL PRINT
	MOV EBX, 1
	JMP ENDCONVERT
ENDCONVERT:
RET 4
STRTOINT ENDP

;процедура перевода числа в строку в 10 системе счисления
INTTOSTR PROC
MOV ESI, [ESP+4]
MOV EAX, [ESP+8]
CMP EAX, 0
JL NEGATIVE
JMP ENDNEGATIVE
NEGATIVE:
	MOV BYTE PTR[ESI], '-'
	INC ESI
	MOV EDI, -1
	IMUL EDI
	JMP ENDNEGATIVE
ENDNEGATIVE:
MOV ECX, 199
MOV EDI, 10
MOV ECX, 0
CONVERT_TO_INT:
	DIV EDI
	ADD EDX, '0'
	PUSH EDX
	INC ECX
	XOR EDX, EDX
CMP EAX, 0
JNE CONVERT_TO_INT
POP_STACK:
	POP EDX
	MOV BYTE PTR[ESI], DL
	INC ESI
LOOP POP_STACK
MOV BYTE PTR[ESI], 13
MOV BYTE PTR[ESI+1], 10
RET 8
INTTOSTR ENDP


CLEAR_BUF PROC
MOV EDI, OFFSET BUF
mov CX, 200
sub AL, AL ;обнуляем записываемый байт 
REP STOSB 
RET 
CLEAR_BUF ENDP


; процедура перекодировки строки
ENCODE PROC
MOV EAX, [ESP+4]; взятие параметра в регистр EAX

PUSH EAX
PUSH EAX
; вызов функции перекодировки
CALL CharToOemA@8
RET 4
ENCODE ENDP

; процедура вывода текста
PRINT PROC
MOV EAX, [ESP+4]; взятие параметра в регистр EAX
MOV STRN, EAX; поещение параметра в переменную STRN
PUSH STRN; помещение в стек адреса строки
; вызов функции для получения длины
CALL lstrlenA@4; результат записывается в EAX

; вызов функции WriteConsoleA для вывода строки STRN
PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH EAX; 3-й параметр
PUSH STRN; 2-й параметр
PUSH DOUT; 1-й параметр
CALL WriteConsoleA@20
RET 4
PRINT ENDP

; процедура ввода
READ PROC
MOV EAX, [ESP+4]; взятие параметра в регистр EAX
MOV STRN, EAX; поещение параметра в переменную STRN

PUSH 0; в стек помещается 5-й параметр
PUSH OFFSET LENS; 4-й параметр
PUSH 200; 3-й параметр
PUSH STRN; 2-й параметр
PUSH DIN; 1-й параметр
CALL ReadConsoleA@20 ;
RET 4
READ ENDP


MAIN PROC
; получение дескриптора ввода
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX; перемещение результата из регистра EAX в ячейку памяти с именем DIN

; получение дескриптора вывода
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX; перемещение результата из регистра EAX в ячейку памяти с именем DOUT

PUSH OFFSET WELCOME_MSG; помещение параметров функции в стэк
; вызов функции перекодировки строки
CALL ENCODE

PUSH OFFSET ERROR_MSG; помещение параметров функции в стэк
; вызов функции перекодировки строки
CALL ENCODE

START1:

PUSH OFFSET WELCOME_MSG; перемещение параметров функции в стэк
; вызов функции вывода в консоль
CALL PRINT

PUSH OFFSET BUF; перемещение параметров функции в стэк
; вызов функции ввода с консоли
CALL READ; результат записывается в BUF

PUSH OFFSET BUF; перемещение параметров функции в стэк
; вызов функции перевода строки в число
CALL STRTOINT
CMP EBX, 0
JNE START1
MOV FIRST_NUMBER, EAX

CALL CLEAR_BUF

START2:
PUSH OFFSET WELCOME_MSG; помещение параметров функции в стэк
CALL PRINT; вызов функции вывода в консоль

PUSH OFFSET BUF; помещение параметров функции в стэк
; вызов функции ввода с консоли
CALL READ; результат записывается в BUF

PUSH OFFSET BUF; помещение параметров функции в стэк
; вызов функции перевода строки в число
CALL STRTOINT
CMP EBX, 0
JNE START2
MOV SECOND_NUMBER, EAX

CALL CLEAR_BUF

MOV EAX, FIRST_NUMBER
ADD EAX, SECOND_NUMBER

PUSH EAX
PUSH OFFSET BUF
CALL INTTOSTR

PUSH OFFSET BUF
CALL PRINT

PUSH 0; параметр: код выхода
CALL ExitProcess@4

MAIN ENDP
END MAIN