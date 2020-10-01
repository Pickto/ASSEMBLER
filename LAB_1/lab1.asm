.386
.MODEL FLAT, STDCALL
; ��������� ������� ������� (��������) ����������� ���������� EXTERN,
; ����� ����� @ ����������� ����� ����� ������������ ����������,
; ����� ��������� ����������� ��� �������� ������� � ���������
EXTERN GetStdHandle@4: PROC
EXTERN WriteConsoleA@20: PROC
EXTERN CharToOemA@8: PROC
EXTERN ReadConsoleA@20: PROC
EXTERN ExitProcess@4: PROC; ������� ������ �� ���������
EXTERN lstrlenA@4: PROC; ������� ����������� ����� ������

.DATA; ������� ������
DIN DD ?; ���������� �����
DOUT DD ?; ���������� �������
WELCOME_MSG DB "������� ����� � ����������������� ������� ���������", 13, 10, 0
ERROR_MSG DB "�������� ������ �����. ������� � ������ �����", 13, 10, 0
BUF DB 200 dup (?); ����� ��� �����/������ ����� ������� 200 ����
STRN DD ?; ������ ��� ������
LENS DD ?; ���������� ��� ���������� ���������� ��������

SIGN_FLAG DD ?;

FIRST_NUMBER DD 0; ������ �����
SECOND_NUMBER DD 0; ������ �����


.CODE; ������� ����

; ��������� �������� ������ � �����
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

;��������� �������� ����� � ������ � 10 ������� ���������
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
sub AL, AL ;�������� ������������ ���� 
REP STOSB 
RET 
CLEAR_BUF ENDP


; ��������� ������������� ������
ENCODE PROC
MOV EAX, [ESP+4]; ������ ��������� � ������� EAX

PUSH EAX
PUSH EAX
; ����� ������� �������������
CALL CharToOemA@8
RET 4
ENCODE ENDP

; ��������� ������ ������
PRINT PROC
MOV EAX, [ESP+4]; ������ ��������� � ������� EAX
MOV STRN, EAX; �������� ��������� � ���������� STRN
PUSH STRN; ��������� � ���� ������ ������
; ����� ������� ��� ��������� �����
CALL lstrlenA@4; ��������� ������������ � EAX

; ����� ������� WriteConsoleA ��� ������ ������ STRN
PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; 4-� ��������
PUSH EAX; 3-� ��������
PUSH STRN; 2-� ��������
PUSH DOUT; 1-� ��������
CALL WriteConsoleA@20
RET 4
PRINT ENDP

; ��������� �����
READ PROC
MOV EAX, [ESP+4]; ������ ��������� � ������� EAX
MOV STRN, EAX; �������� ��������� � ���������� STRN

PUSH 0; � ���� ���������� 5-� ��������
PUSH OFFSET LENS; 4-� ��������
PUSH 200; 3-� ��������
PUSH STRN; 2-� ��������
PUSH DIN; 1-� ��������
CALL ReadConsoleA@20 ;
RET 4
READ ENDP


MAIN PROC
; ��������� ����������� �����
PUSH -10
CALL GetStdHandle@4
MOV DIN, EAX; ����������� ���������� �� �������� EAX � ������ ������ � ������ DIN

; ��������� ����������� ������
PUSH -11
CALL GetStdHandle@4
MOV DOUT, EAX; ����������� ���������� �� �������� EAX � ������ ������ � ������ DOUT

PUSH OFFSET WELCOME_MSG; ��������� ���������� ������� � ����
; ����� ������� ������������� ������
CALL ENCODE

PUSH OFFSET ERROR_MSG; ��������� ���������� ������� � ����
; ����� ������� ������������� ������
CALL ENCODE

START1:

PUSH OFFSET WELCOME_MSG; ����������� ���������� ������� � ����
; ����� ������� ������ � �������
CALL PRINT

PUSH OFFSET BUF; ����������� ���������� ������� � ����
; ����� ������� ����� � �������
CALL READ; ��������� ������������ � BUF

PUSH OFFSET BUF; ����������� ���������� ������� � ����
; ����� ������� �������� ������ � �����
CALL STRTOINT
CMP EBX, 0
JNE START1
MOV FIRST_NUMBER, EAX

CALL CLEAR_BUF

START2:
PUSH OFFSET WELCOME_MSG; ��������� ���������� ������� � ����
CALL PRINT; ����� ������� ������ � �������

PUSH OFFSET BUF; ��������� ���������� ������� � ����
; ����� ������� ����� � �������
CALL READ; ��������� ������������ � BUF

PUSH OFFSET BUF; ��������� ���������� ������� � ����
; ����� ������� �������� ������ � �����
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

PUSH 0; ��������: ��� ������
CALL ExitProcess@4

MAIN ENDP
END MAIN