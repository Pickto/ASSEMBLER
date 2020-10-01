.386
.MODEL FLAT; 
; прототипы внешних функций (процедур) описываютс€ директивой EXTERN,
; после знака @ указываетс€ обща€ длина передаваемых параметров,
; после двоеточи€ указываетс€ тип внешнего объекта Ц процедура

.DATA; сегмент данных


.CODE; сегмент кода
_ZIP PROC
	MOV ECX, [ESP+8]
	MOV ESI, [ESP+4]
	ADD ESI, [ESP+8]
	INC ECX
	MOV EAX, 0
	XOR EBX, EBX
	ZIP_LOOP:
		MOV BL, [ESI]
		CMP BX, '.'
		JE SKIP
		PUSH EBX
		INC EAX
		SKIP:
			DEC ESI
	LOOP ZIP_LOOP
	INC ESI
	MOV ECX, EAX
	RETURN_LOOP:
		POP EDX
		MOV BYTE PTR[ESI], DL
		INC ESI
	LOOP RETURN_LOOP
	RET
_ZIP ENDP
END