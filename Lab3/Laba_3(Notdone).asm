.model small
.stack 100h
.data

calc_menu		        db	10,13,10,13,"***CALCULATOR***$"
operation_menu   	    db	10,13,"Select an Operation$"
addition_menu	        db	10,13,"[A] Addition $"
subtraction_menu	    db	10,13,"[S] Subtraction$"
multiplication_menu	    db	10,13,"[M] Multiplication$"
division_menu	        db	10,13,"[D] Division$"
op_menu		            db	"********************",10,13,"Your Operation : $"
op_ans		            db	6 dup("$")
erorrInput              db  10,13,"Incorrect input!!!$"
endLine		            db	13,10,"$"  
num1_msg	            db	"Input First Number: $"
input_num1	            db	10 dup("$")
num2_msg	            db	"Input Second Number: $" 
input_num2	            db	10 dup("$")
continue	            db	10,13,"Would you like to continue?[y/n] : "
cont_ans	            db	10 dup("$") 
exit_msg                db  10,13,10,13,"   ------------",10,13,"    GOOD BYE :)",10,13,"   ------------",10,13,'$'
result_msg              db  10,13,"Result = $"
.code       

;;;;;;;;;;;;;;;;;;; Вывод ;;;;;;;;;;;;;;;;;;;;;;
printstr proc
	mov ah, 09h
	int 21h
	ret
printstr endp

;;;;;;;;;;;;;;;;;;; Вывод целого числа ;;;;;;;;;;;;;;;;;;;;;;
OutInt proc 
;Проверяем на знак
   test    ax, ax
   jns     oi1
;Если знак минус, выводим минус и делаем число полож.
   mov cx,ax
   mov ah, 02h
   mov dl, '-'
   int 21h
   mov ax, cx
   neg ax
;Количество цифр будем держать в CX.
oi1:  
    xor cx, cx
    mov bx, 10 ;основание сс. 10 для десятеричной
oi2:
    xor dx,dx
    div bx ;Делим число на основание сс.В остатке получается цифра, которая нам нужна
    push dx  ;сохраним её в стэке
    inc cx
;Поверяем содержимое AX
    test ax, ax ;дошли ли мы до конца, т.е. AX = 0?
    jnz oi2
;вывод
    mov ah, 02h
oi3:      
    pop dx  ;Извлекаем очередную цифру, переводим её в символ и выводим
    add dl, '0';к остатку добавляем '0'-30
    int 21h
    loop oi3 ;Повторим ровно столько раз, сколько цифр насчитали  
    ret
OutInt endp  

;;;;;;;;;;;;;;;;;; Ввод ;;;;;;;;;;;;;;;;;;;;;;;;;
input proc
    mov ah,0Ah
    int 21h 
    ret
input endp    

;;;;;;;;;;;;;;;;;; Преобразование в целое число и сохранение его в регистр AX ;;;;;;;;;;;;;;;;;;;;;;
inInt proc  
    xor di,di
    cmp byte ptr [si],"-" 
    jnz i1 
    mov di,1 ;устанвливаем флаг, знак того, что число отриц.
    inc si   
i1:
    xor ax,ax
    mov bx,10 
i2:
    xor cx,cx
    mov cl,[si] ;берем символ
    cmp cl,0dh ;проверяем не последний ли он (для выхода из процедуры)
    jz endin

;Если не последний, то проверяем его на правильность    
    cmp cl,'0' ;Если симво < 0
    jb er
    cmp cl,'9' ;Если симво > 9
    ja er
 
    sub cl,'0' ;делаем из символа число
    mul bx     ;умножаем на 10
    add ax,cx  ;прибавляем к остальным
    inc si     ;переходим к следующему символу
    jmp i2     
er:
    mov dx, offset erorrInput
    mov ah,09
    int 21h
    jmp i3
endin:
    cmp di,1 ;значит, что нужно сделать чило отрицательным
    jnz i3
    neg ax  ;делаем число отрицательным 
i3: 
    ret   
inInt endp 

;;;;;;;;;;;;;;;;;;;; Начало программы ;;;;;;;;;;;;;;;;;;;;;;;;	
start: 
    mov ax, @data
    mov ds, ax
    mov es, ax 
    ;ввод данных
    lea dx, calc_menu
    call printstr
    lea dx, operation_menu
    call printstr
    lea dx, addition_menu
    call printstr 
    lea dx, subtraction_menu
    call printstr 
    lea dx, multiplication_menu
    call printstr
    lea dx, division_menu
    call printstr  
    lea dx, endLine
	call printstr	
	lea dx, op_menu
	call printstr 
    mov dx, offset op_ans
    call input  
	cmp op_ans+2, 'A'
	je addit 
	cmp op_ans+2, 'S'
	je subtract 
	cmp op_ans+2, 'M'
	je multip 
	cmp op_ans+2, 'D'
	je divis  
	jmp erorrChoice
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
addit:   
    ;ввод первого числа
    lea dx, endLine
    call printstr
    lea dx, num1_msg
    call printstr
    mov dx, offset input_num1
    call input    
    ;перевод строки в число
    mov si,offset input_num1+2  
    call inInt 
    push ax
    ;ввод второго числа
    lea dx, endLine
    call printstr
    lea dx, num2_msg
    call printstr 
    mov dx, offset input_num2
    call input 
    lea dx, result_msg
    call printstr 
    ;перевод строки в число и операция
    mov si,offset input_num2+2  
    call inInt
    xor bx,bx
    pop bx
    add ax,bx
    call OutInt
    jmp choiceExit	  	 
subtract:  
    ;ввод первого числа 
    lea dx, endLine
    call printstr
    lea dx, num1_msg
    call printstr
    mov dx, offset input_num1
    call input   
    ;перевод строки в число
    mov si,offset input_num1+2  
    call inInt
    push ax
    ;ввод второго числа
    lea dx, endLine
    call printstr
    lea dx, num2_msg
    call printstr 
    mov dx, offset input_num2
    call input 
    lea dx, result_msg
    call printstr 
    ;перевод строки в число и операция
    mov si,offset input_num2+2  
    call inInt
    xor bx,bx
    pop bx
    sub bx,ax 
    mov ax,bx
    call OutInt
    jmp choiceExit
    
multip:
    ;ввод первого числа
    lea dx, endLine
    call printstr
    lea dx, num1_msg
    call printstr
    mov dx, offset input_num1
    call input  
    ;перевод строки в число
    mov si,offset input_num1+2  
    call inInt
    push ax
    ;ввод второго числа 
    lea dx, endLine
    call printstr
    lea dx, num2_msg
    call printstr 
    mov dx, offset input_num2
    call input 
    lea dx, result_msg
    call printstr 
    ;перевод строки в число и операция
    mov si,offset input_num2+2  
    call inInt
    xor bx,bx
    pop bx
    imul bx 
    call OutInt
    jmp choiceExit
      
divis:
    ;ввод первого числа 
    lea dx, endLine
    call printstr
    lea dx, num1_msg
    call printstr
    mov dx, offset input_num1
    call input  
    ;перевод строки в число
    mov si,offset input_num1+2  
    call inInt
    push ax
    ;ввод второго числа 
    lea dx, endLine
    call printstr
    lea dx, num2_msg
    call printstr 
    mov dx, offset input_num2
    call input 
    lea dx, result_msg
    call printstr  
    ;перевод строки в число и операция
    mov si,offset input_num2+2  
    call inInt
    xor di,di
    xor bx,bx 
    mov bx,ax
    test bx,bx ;Если второе число отриц.
    jns L1
    mov di,1   ;делаем di=1 
    neg bx     ;и число делаем полож.
L1:
    pop ax  
    test ax,ax ;проверяем второе число на минус, если оно отриц.
    jns L2
    add di,1   ;то добовляем к di+1 (di=2)
    neg ax     ;делаем число полож.
L2: 
    push bx 
    idiv bx    ;выполняем деление положительных чисел
    push dx 
    cmp di,2   ;Если делятся два отриц. число
    jns L3     ;иначе, переходим на вывод
    cmp di,1   ;Если хоть одно из них отриц., а другое полож., то добовляем перед выводом числа знак '-'
    js L3      ;иначе, переходим на вывод
    mov cx, ax 
    mov ah, 02h
    mov dl, '-'
    int 21h
    mov ax, cx
L3:
    call OutInt  
    mov ah, 02h
    mov dl, '.'
    int 21h 
    pop ax 
    pop bx
    xor cx,cx
    mov cx,10
    mul cx
    div bx     
    mov dx,ax
    mov ah, 02h 
    add dx,'0'
    int 21h
    jmp choiceExit
    
erorrChoice:
    lea dx, erorrInput
    call printstr 
    jmp choiceExit 
       
choiceExit:
    lea dx,continue
    call printstr
    mov dx, offset cont_ans 
    call input
    cmp cont_ans+2, 'y'
    je start 
    cmp cont_ans+2, 'n'
    je exit
    jne erorrChoice 
    
exit:    
    lea dx, exit_msg
    call printstr
    mov ah, 4ch
    int 21h
end start