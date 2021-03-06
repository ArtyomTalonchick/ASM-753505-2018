.model small
.stack 256
.data
	errorMessage db "ERROR!$"
.code

;переход на новую строку
newline PROC
	push AX
	push DX

	MOV AH, 02h
	MOV DL, 13
	int 21h
	MOV DL, 10
	int 21h

 	pop DX
	pop AX
RET
newline ENDP

output PROC
	push AX
 	push BX
 	push CX
 	push DX
 	mov CX, 0 ;счетчик цифр
 	mov BX,10
 	
 	;пока число больше 10 -> деление на 10 + остаток в стек
 	cycleRestToStack:
 		CMP AX, 10 
 		JC exit
 		MOV DX, 0 
 		div BX
 		push DX
 		inc CX
 	JMP cycleRestToStack
 	exit:		
 		push AX
 		inc CX
 	
 	;вывод чисел из стека 	
 	cycleOutputStack:		
 		pop DX	
 		add DX, 48
 		mov AH, 02h
 		int 21h
 	LOOP cycleOutputStack
 	
 	pop DX
 	pop CX
 	pop BX
 	pop AX
RET
output ENDP

input PROC
 	push BX
 	push CX
 	push DX
 	MOV AX, 0
 	MOV BX, 0
 	MOV CX, 0
 	MOV DX, 0

 	;цикл ввода цифры + формирование числа в BX
 	enterSymbol:
 		mov AH, 01h
 		INT 21h		
 		CMP AL, 13 ;enter
 		JZ exitInput
 		CMP AL, 8 ;backspace
 		JZ backspace

		;проверка на ввод цифры
		SUB AL, 48
 		CMP AL, 10
 		JNC error
		
 		MOV CL, AL
 		MOV AX, 10
 		MUL BX
 		JC error ;выход за границы
 		MOV BX, AX
 		ADD BX, CX
 		JC error
	JMP enterSymbol
 	
 	error:
 		CALL newline
 		LEA DX, errorMessage
     	MOV AH, 09h
   		int 21h
 		mov ax, 4c00h
    	int 21h

 	;обработка клавиши backspace
 	backspace:
		push AX
 		push DX
 	
 		MOV DL, ' '
 		MOV AH, 02h
 		INT 21h
 		
 		MOV DL, 8
 		MOV AH, 02h
 		INT 21h
 		
 		MOV AX, BX
 		CMP AX, 10
 		JNC continue
 		
 		MOV BX, 0
 		pop DX
 		pop AX
 		jmp  enterSymbol

 	continue:	
 		MOV DX, 0
 		MOV BX, 10
 		DIV BX
 		MOV BX, AX
 		
 		pop DX
 		pop AX
     	jmp  enterSymbol
 				
 	exitInput:
 		MOV AX, BX
 		pop DX
 		pop CX
 		pop BX
RET
input ENDP

;деление AX на BX с выводом целого и остатка
division PROC
 	push AX
 	push BX
 	push CX
 	push DX
 	
 	CMP BX, 0 ;если деление на 0
 	JZ error
 	
 	MOV DX, 0
 	DIV BX
 	CALL output
 	MOV CX, DX
 	
 	MOV DL, '('
 	MOV AH, 02h
 	INT 21h
 	
 	MOV AX, CX
 	CALL output
 	
 	MOV DL, ')'
 	MOV AH, 02h
 	INT 21h
 	
 	pop DX
 	pop CX
 	pop BX
 	pop AX
RET
division ENDP

main:
 	mov ax, @data
 	mov ds, ax
 	
 	CALL input
 	MOV CX, AX
 	CALL output
 	
 	CALL newline
 		
 	CALL input
 	MOV BX, AX
 	CALL output
	
 	CALL newline
	
 	MOV AX, CX 

 	CALL division
 	
 	mov ax, 4c00h
 	int 21h
end main 