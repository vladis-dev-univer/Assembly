.model small
.stack 100h
.data    

iSymDX                dw  0			;символ строки i
iSymCX                dw  0			;кол-во символов сторки i
jSymDX                dw  0			;символ строки j
jSymCX                dw  0			;кол-во символов строки j

tempDX                dw  0			;темповая переменная символа
flagTemp              dw  0

maxCMDSize equ 127
cmd_size              db  ?
cmd_text              db  maxCMDSize + 2 dup(0)
sourcePath            db  129 dup (0) 

two                   db 2
extension             db "TXT"       
pointSym              db '.'
iBuf                  db  0				;первая строка
jBuf                  db  0				;вторая сторка
buf                   db  0             ;буфер         
sourceID              dw  0

newLineSymbol         equ 0Dh
returnSymbol          equ 0Ah                           
endl                  equ 0
newl                  db 0Dh
cret                  db 0Ah

startText             db  0Dh,0Ah,"Program is started",        		  '$'                                                                                               
startProcessing       db  0Dh,0Ah,"Processing started ... ",          '$'                      
badCMDArgsMessage     db  0Dh,0Ah,"Bad command-line arguments.",      '$'
badSourceText         db  0Dh,0Ah,"Open error",                       '$'    
fileNotFoundText      db  0Dh,0Ah,"File not found",                   '$'
endText               db  0Dh,0Ah,"Program is ended",         		  '$'
errorReadSourceText   db  0Dh,0Ah,"Error reading from source file",   '$'
errorClosingSource    db  0Dh,0Ah,"Cannot close source file",         '$'

.code

println MACRO info         
	push ax                
	push dx                 
	
	mov ah, 09h             ; Команда вывода 
	lea dx, info            ; Загрузка в dx смещения выводимого сообщения
	int 21h                 ; Вызов прервывания для выполнения вывода
	
	mov dl, 0Ah             ; Символ перехода на новую строку
	mov ah, 02h             ; Команда вывода символа
	int 21h                 ; Вызов прерывания
	
	mov dl, 0Dh             ; Символ перехода в начало строки   
	mov ah, 02h            
	int 21h                     
	
	pop dx                 
	pop ax                 
ENDM

;************************************************************** Процедуры для работы перемещением *******************************************************************
incrementTempPos MACRO num       ;Инкрементируем tempDX, если произошло переполнение фиксируем это
    add tempDX, num
    jo overflowTempPos 			 ;если переполнение
    jmp endIncrementTempPos		
	
overflowTempPos:
    inc flagTemp
    mov tempDX, 1
    jmp endIncrementTempPos
    
endIncrementTempPos:            
endm 

decrementEndPos proc			 ;Дикрементируем jSymDX, через один символ назад
    push ax
    mov ax, jSymDX
    dec ax
    cmp ax, 0
    je minusPos
    mov jSymDX, ax
    jmp endDecrement 
    
minusPos:
    dec jSymCX
    mov jSymDX, 32767 
          
endDecrement: 
    pop ax
    ret
	
endp    

incrementStartPos proc          ; Инкрементируем iSymDX, если произошло переполнение фиксируем это
    push ax
    mov ax, iSymDX
    inc ax
    jo overflow 
    mov iSymDX, ax
    jmp endIncrement
	
overflow:
    inc iSymCX
    mov iSymDX, 1
    
endIncrement:
    pop ax
    ret    
endp  
;************************************************************** Конец роцедур для работы перемещением ******************************************************************* 
 
;****************************************************************** Процедуры для работы с файлом ***********************************************************************
fseekCurrent MACRO settingPos
    push ax                  
	push cx                     
	push dx
	
	mov ah, 42h                 ; Записываем в ah код 42h - ф-ция DOS уставноки указателя файла
	mov al, 1                   ; 1 - перемещение указателя отосительно текущей позиции
	mov cx, 0                   ; Обнуляем cx, 
	mov dx, settingPos	        ; премещаем указатель на settingPos символов от начала файла
	int 21h                     ; Вызываем прерывания DOS для исполнения команды   
	
	pop dx                      
	pop cx                      
	pop ax               
ENDM

fseek MACRO fseekPos
    push ax                     
	push cx                     
	push dx
	
	mov ah, 42h                 ; Записываем в ah код 42h - ф-ция DOS уставноки указателя файла
	mov al, 0 			        ; 0 - код перемещения указателя относительно начала файла 
	mov cx, 0                   ; Обнуляем cx, 
	mov dx, fseekPos            ; премещаем указатель на fseekPos символов от начала файла 
	int 21h                     ; Вызываем прерывания DOS для исполнения команды   
	
	pop dx                      
	pop cx                      
	pop ax    
	
ENDM
;************************************************************** Конец процедур для работы с файлом *******************************************************************

;************************************************************** Точка начала программы *******************************************************************
main:
	mov ax, @data           ; Загружаем данные
	mov es, ax              ;
	
	xor ch, ch              ; Обнуляем ch
	mov cl, ds:[80h]		; Количество символов строки, переданной через командную строку
	dec cl                  ; Уменьшаем значение количества символов в строке на 1, т.к. первый символ пробел
	mov bl, cl                
	
	mov si, 82h             ; Смещение на параметр, переданный через командную строки
	lea di, cmd_text        
	
	rep movsb               ; Записать в ячейку адресом ES:DI байт из ячейки DS:SI
	
	mov ds, ax              ; Загружаем в ds данные  
	mov cmd_size, bl        
	
    mov cl, bl
	lea si, cmd_text
    lea di, sourcePath
	
	rep movsb
	
    println startText       ; Вывод строки о начале работы программы
	
	call parseCMD           ; Вызов процедуры парсинга командной строки
	cmp ax, 0               
	jne endMain				; Если ax != 0, т.е. при выполении процедуры произошла ошибка - завершаем программу
	
	call openFile           ; Вызываем процедуру, которая открывает файл, переданный через командную строку и файл для записи результата
	cmp ax, 0               
	jne endMain				      
	
	println startProcessing ; Вывод строки о начале работы процесса	
	
	call reverseAllStrings             ; Реверс всех строк
	call reverseFile                   ; Реверс всего файла
	call reverseCRETAndNewLine         ; Реверс символы cret и newl, т.к. при реверсе файла они тоже реверсуются и на выводе получается не верно                           

endMain:                    
	println endText             ; Выводим сообщение о завершении работы программы                        
	mov ah, 4Ch                 ; Загружаем в ah код команды завершения работы
	int 21h                     ; Вызов прерывания DOS для ее исполнения  
	
parseCMD proc
    xor ax, ax
    xor cx, cx
    
    cmp cmd_size, 0             ; Если параметр не был передан, то переходим в notFound 
    je notFound
    
    mov cl, cmd_size
    
    lea di, cmd_text
    mov al, cmd_size
    add di, ax
    dec di
    
findPoint:                      ; Ищем точку с конца файла, т.к. после неё идет разширение файла
    mov al, '.'
    mov bl, [di]
    cmp al, bl
    je pointFound
    dec di
    loop findPoint
    
notFound:                       ; Если точка не найдена выводим badCMDArgsMessage и завершаем программу
    println badCMDArgsMessage
    mov ax, 1
    ret
    
pointFound:                     ; Количество символов должно быть равно 3, т.к. "txt", если отлично от этого => файл не подходит
    mov al, cmd_size
    sub ax, cx
    cmp ax, 3
     
    jne notFound
     
    xor ax, ax
    lea di, cmd_text
    lea si, extension
    add di, cx
    
    mov cx, 3
    
    repe cmpsb                  ; Сравниваем со строкой Extension расширение файла, если всё совпало - копируем адрес файла в sourcePath 
    jne notFound
    
    mov ax, 0
    ret         
endp

openFile PROC               
	push bx                     
	push dx                                
	push si                                     
	
	mov ah, 3Dh			        ; Функция 3Dh - открыть существующий файл
	mov al, 02h			        ; Режим открытия файла - чтение
	lea dx, sourcePath          ; Загружаем в dx адрес строки с название исходного файла 
	int 21h                     
	
	jb badOpenSource	        ; Если файл не открылся(CF = 1), то прыгаем в badOpenSource
	
	mov sourceID, ax	        ; Загружаем в sourceId значение из ax - индентификатор файла, полученное при открытии файла
	
	mov ax, 0			        ; Загружаем в ax 0, т.е. ошибок во время выполнения процедуры не произшло    
	jmp endOpenProc		        ; Прыгаем в endOpenProc и корректно выходим из процедуры
	
badOpenSource:                  
	println badSourceText       ; Выводим соответсвующее сообщение
	
	cmp ax, 02h                 ; Сравниваем ax с 02h(файл не найден)
	jne errorFound              ; Если ax != 02h file error, прыгаем в errorFound
	
	println fileNotFoundText    ; Выводим сообщение о том, что файл не найден  
	
	jmp errorFound              ; Прыгаем в errorFound
	
errorFound:                     
	mov ax, 1
	
endOpenProc:
    pop si               
	pop dx                                                     
	pop bx                  
	ret                     
ENDP

;******************************************************************* Реверс всех строк ************************************************************************
reverseAllStrings proc             ; Процедура, бработки входного файла
    mov tempDX, 0                  ; Обнуляем tempDX и flagTemp 
    mov flagTemp, 0
    
for1:
    call fseekI                    ; Становимся на i-символ, т.е. начало след. строки
    mov bx, sourceID
	
for2:    
    call readSymbolFromFile        ; Считываем символ с файла
    incrementTempPos 1
    
    cmp ax, 0                      ; (ax = число считанных байт).
    je endFileGG				   ; Если ничего не считали => конец файла
    cmp [buf], 0                   ; Если считали NULL => конец файла
    je endFileGG
    
    cmp [buf], newLineSymbol       ; Проверяем на cret, т.к. сначала идёт cret, и только потом newl
    je  endString                  ; Если cret, то надо реверснуть строку

    jmp for2
    
endString: 
    mov ax, tempDX                 ; temp указывает на конец строки => заносим в j
    mov jSymDX, ax
    mov ax, flagTemp
    mov jSymCX, ax
    call decrementEndPos           ; Указатель стоит перед newl => нам надо его поставить перед последним символом строки
    call decrementEndPos           ; Первый dec - становимся перед cret, второй dec - становимся перед последним символом строки
    call reverse                   ; Реверсируем строку
    
    mov ax, jSymCX                 ; i указывает на начало след. строки
    mov iSymCX, ax
    mov ax, jSymDX
    mov iSymDX, ax
    call incrementStartPos         ; т.к. i сейчас указывает на последний символ строки, надо сместить на начало след., т.е. на 3 символа вперёд
    call incrementStartPos
    call incrementStartPos
    mov ax, iSymDX                 ; i указывает на начало след. строки 
    mov tempDX, ax
    mov ax, iSymCX
    mov flagTemp, ax                 
    
    jmp for1                       ; Продолжаем обработку
    
endFileGG:
    mov ax, tempDX                 ; Если конец строки, то надо реверснуть и последнюю строку
    mov jSymDX, ax
    mov ax, flagTemp
    mov jSymCX, ax
    call decrementEndPos
    call decrementEndPos
    call reverse 
    
    ret
endp


readSymbolFromFile proc
    push bx
    push dx
    
    mov ah, 3Fh                     ; Загружаем в ah код 3Fh - код ф-ции чтения из файла
	mov bx, sourceID                ; В bx загружаем ID файла, из которого собираемся считывать
	mov cx, 1                       ; В cx загружаем количество считываемых символов
	lea dx, buf                     ; В dx загружаем смещения буффера, в который будет считывать данные из файла
	int 21h                         ; Вызываем прерывание для выполнения ф-ции
	
	jnb successfullyRead            ; Если ошибок во время чтения не произошло - прыгаем в goodRead
	
	println errorReadSourceText     ; Иначе выводим сообщение об ошибке чтения из файла
	mov ax, 0                       
	    
successfullyRead:
	pop dx                         
	pop bx
	
	ret    	   
endp
;************************************************************** Реверс всех строк конец процедуры *******************************************************************

;************************************************************************* Реверс файла *****************************************************************************
reverseFile proc
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx
    xor dx, dx
    
    mov iSymDX, 0
    mov iSymCX, 0
    
    fseek 0

getLength:                      ; Определяем длину файла 
    call readSymbolFromFile
    cmp ax, 0                   ; Если ничего не считали => конец файла
    je endGetLength
    cmp [buf], 0                ; Если считали NULL => конец файла
    je endGetLength
    call incrementStartPos
    jmp getLength
    
endGetLength: 
    mov ax,iSymDX
    mov jSymDX, ax
    mov ax, iSymCX
    mov jSymCX, ax
	
    mov iSymDX, 0
    mov iSymCX, 0
    
    call decrementEndPos        ; Указываем на последний символ в файле
    call reverse
    pop dx
    pop cx
    pop bx
    pop ax
    
    ret
endp
;******************************************************************* Реверс файла конец проуедуры **************************************************************************

;******************************************************************* Процедуры для реверса символов ***********************************************************************
reverse proc                    ;reverse symbols between i and j
    push ax
    push iSymCX
    push iSymDX
    push jSymCX
    push jSymDX
    
reverseStart:
    mov ax, iSymCX 
    cmp ax, jSymCX            	;проверяем границы i и j
    jg endReverse				
    cmp ax, jSymCX
    je cmpDX
    jmp reverseSym
	
cmpDX:
    mov ax, iSymDX 
    cmp ax, jSymDX
    jg endReverse   
	
reverseSym:   
    call swapSymbols				;меняем местами символы строк
    call incrementStartPos			;увеличиваем стартовую позицию
    call decrementEndPos			;уменьшаем конечную позицию
    jmp reverseStart				
	
endReverse:
    pop jSymDX
    pop jSymCX
    pop iSymDX
    pop iSymCX    
    pop ax
    ret
endp   


swapSymbols proc
    push ax
    push bx
    push cx
    push dx
    
    call fseekJ
    call readSymbolFromFile
    mov al, buf
    mov jBuf, al
 
    call fseekI
    call readSymbolFromFile
    mov al, buf
    mov iBuf, al
    
    call fseekJ					;устанавливаем указатель строки j
    mov ah, 40h					;функция записи в файл
    mov bx, sourceID			;записываем ID
    mov cx, 1					;число байтов
    lea dx, iBuf				;адрес буфера с данными строки j
    int 21h
    
    call fseekI					;устанавливаем указатель строки i 
    mov ah, 40h					;функция записи в файл
    mov bx, sourceID			;записываем ID
    mov cx, 1					;число байтов			
    lea dx, jBuf				;адрес буфера с данными строки i
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp        

;изменяем указатель строки i
fseekI proc
    push ax
    push bx                     
	push cx                     
	push dx
	
	mov bx, sourceID
    fseek iSymDX
    
    cmp iSymCX, 0
    je endSetPosI
    xor cx, cx    
    mov cx, iSymCX
    
setPosI:
    mov bx, sourceID
    fseekCurrent 32767
    loop setPosI 
    
endSetPosI:
	pop dx                      
	pop cx
	pop bx                      
	pop ax
    ret
endp    
   
;изменяем указатель строки j
fseekJ proc
    push ax
    push bx                     
	push cx                     
	push dx
	
	mov bx, sourceID
    fseek jSymDX
    
    cmp jSymCX, 0
    je endSetPosJ
    xor cx, cx    
    mov cx, jSymCX
    
setPosJ:
    mov bx, sourceID
    fseekCurrent 32767
    loop setPosJ 
    
endSetPosJ:
	pop dx                      
	pop cx
	pop bx                      
	pop ax
    ret
endp 
;****************************************************************** Конец процедур для реверса символов *************************************************************************

;*********************************************** Реверс символа перехода на новую строку и символа перехода в начало строки ****************************************************
reverseCRETAndNewLine proc
    push ax
    push bx
    push cx
    push dx
    
    mov bx, sourceID
    fseek 0    
reverseCRET:
    mov bx, sourceID    
    call readSymbolFromFile     ; Считываем символ с файла
    
    cmp ax, 0                   ; Если ничего не считали => конец файла
    je endOfFile
    cmp [buf], 0                ; Если считали NULL => конец файла
    je endOfFile
    
    cmp [buf], returnSymbol     ; Проверяем на new line
    je  newlFound

    jmp reverseCRET
    
newlFound:
    mov bx, sourceID
    mov ah, 42h                 ; Записываем в ah код 42h - ф-ция DOS уставноки указателя файла
	mov al, 1                   ; 1 - перемещение указателя от текущей позиции
	mov cx, -1                  ; -1 чтобы двигаться назад 
	mov dx, -1	                ; Обнуляем dx, т.е премещаем указатель на 0 символов от начала файла 
	int 21h
    
	mov ah, 40h
    mov bx, sourceID
    mov cx, 1
    lea dx, newl
    int 21h
	
    mov ah, 40h
    mov bx, sourceID
    mov cx, 1
    lea dx, cret
    int 21h             
	
    jmp reverseCRET				;Продолжаем обработку
    
endOfFile: 
    pop dx
    pop cx
    pop bx
    pop ax
    ret
endp   
end main