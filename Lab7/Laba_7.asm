.model	small
.stack	100h 
.data
cmd_length db ?
cmd_line db 127 dup('$') 
count_of_cmd_word db 1
;//////OVERLAYS////////
EPB dw ?;word for overlays!   
	dw 0    
	
run_address dw 0
overlay_seg dw ?
plusOver db "add.bin", 0  
subOver db "sub.bin", 0 
mulOver db "mul.bin", 0 
divOver db "div.bin", 0 
;///////////////////// 

file_name db 50 dup('$')
file_id dw 0000h 
file_size dw 0000h
read_bytes dw 0000h

countOfReadBites dw 200
 
file_buffer db 202 dup ('$')
bufSize dw 0000h

countSize dw 0000h
SecondNum dw 0000h
typeOfOperation db ' '
result dw 0000h                 ;MAX = 65535
resZnak db ' '
string_result db 8 dup ('$')                  

msgCMD_Error db 10,13,"There are less arguments in command line...",10,13,'$'                  
msgFileError db 10,13,"No such file in directory",10,13,'$'
msgFileOpened db 10,13,"File is opened!",10,13,'$'  
msgFileClosed db 10,13,"File is closed!",10,13,10,13,'$'
msgCounting db 10,13,"Counting...",'$' 
msgCountingResult db 10,13,"Counting result...",10,13,'$'
msgResult db 10,13,"Result = $" 

msgOverflow db 10,13,"OVERFLOW!!!$"
msgErrorDownload db 10,13,"ERROR DOWNLOAD OVERLAY$" 
msgCheck db 10,13,"CHECK...$",10,13,'$' 
msgTEST db  10,13,"TESTING$",10,13,'$'
                  
.code 

print_str macro out_str 
    pusha
    mov ah,09h
    mov dx,offset out_str
    int 21h 
    popa
endm

download_overlay macro path
    ;освобождаем память 
    mov ax, es		;сегмент PSP     
    mov bx, zseg 	;сегмент конца программы
    sub bx, ax		;рамер памяти программы
    mov ah, 4Ah
    int 21h			;изменение размера блока памяти
    ;jc error_download  ;проверка ошибки      
     
    ;отводим память для оверлея
    mov bx, 1000h  	;размер блока - 1000H байт
    mov ah, 48h    	;выделяем блок памяти    
    int 21h			;ax:0000 указывает на блок памяти
    ;jc error_download  ;проверка ошибки   
    
    ;подготавливаем к загрузке 
    mov EPB, ax			;EPB(bx)=адрес сегмента для оверлейной загрузки  
    mov EPB+2, ax		;для использования в командах
    mov overlay_seg, ax	;сохраняем оверлейный сегмент 
    mov ax, ds;
    mov es, ax			;ES:BX=EPB 
    
    mov dx, offset path  ; DS:DX указывают на путь
                         ; загружаемой программы
						 
    mov bx, offset EPB 	 ; ES:BX указывают на EPB 
    mov ax, 4B03h ;номер функции загрузки программы(ah=4Bh) и код загрузки оверлея(al=03h).Не создавая при этом блок PSP
    int 21h    
endm 

start:  
    call cmd_parse
    mov	cx,@data                      
    mov	ds,cx 
    
    print_str file_name
    call open_file
    mov file_id,ax
    call get_size_of_file
    call read_file
    call close_file
    
    print_str file_buffer
    
    lea si,file_buffer 
    
    call get_num
    mov result,ax
	
main_counting:    
    call get_operation
    
    call get_num
    mov SecondNum,ax
    
    call get_result
    cmp [si],'='
    jne main_counting
    
    print_str msgCountingResult
    call convert_result_to_string 
    print_str msgResult
    print_str string_result 
    
exit:
    
    mov ah,4Ch
    mov al,00h
    int 21h
    
error_download:
    print_str msgErrorDownload
    jmp exit
    
        
    
testing proc far
    pusha
        mov ah,09h
    mov dx,offset msgTEST
    int 21h 
    popa
    retf
testing endp         

;=======================PROC_CMD======================================
cmd_parse proc
    pusha
    cld   
    
    mov ax,@data
    mov es,ax

    xor cx,cx
    mov cl,ds:[80h]
    mov cmd_length,cl
    cmp cl,0
    je error_cmd
    mov si,82h
    lea di,cmd_line
    rep movsb           ;get cmd line 
    ;print_str cmd_line

    xor cx,cx
    xor ax,ax
    mov cl,cmd_length
    
    mov ax,@data
    mov es,ax
    mov ds,ax
    lea si,cmd_line
    
    lea di,file_name
    call get_cmd_word 
    
    popa
    ret
error_cmd: 
    mov ax,@data
    mov es,ax
    mov ds,ax
    print_str msgCMD_Error
    jmp exit       
cmd_parse endp

;GETTING WORD FROM CMD LINE
get_cmd_word proc
    push ax
    push cx
    push di 
    xor ax,ax
loop_getting:
    mov al,[si]
    
    cmp al,0Dh
    je end_getting

    mov [di],al
    
    inc si
    inc di
    
    loop loop_getting
end_getting:
    mov [di],0
    inc si
            
    pop di
    pop cx
    pop ax
    ret
get_cmd_word endp
;=======================END_PROC_CMD======================================

;=======================PROC_FILE======================================
;OPENING FILE    
open_file proc
    push dx
    mov dx,offset file_name 
    mov ax, 3D02h  ;3D - open file, 02 - for reading and writing  
    int 21h       
    jc error_opening
    jmp is_opened
error_opening:
    print_str msgFileError
    pop dx
    jmp exit
is_opened:
        
    print_str msgFileOpened  

    pop dx
    ret
open_file endp

;READING 
read_file proc 
    push bx
    push cx
    push dx 
    
    mov bx, file_id
    mov al, 00h                    
    xor cx, cx                        
    mov dx, 0000h        
    mov cx, 0000h        
    mov ah, 42h 
   
    int 21h
    
    
    mov bx, file_id              
    mov ah, 3Fh                                             
    mov cx,countOfReadBites         
    mov dx, offset file_buffer    
    int 21h   
    
    mov read_bytes, ax
    dec ax
    mov bufSize,ax

    pop dx
    pop cx
    pop bx
    ret
read_file endp

;CLOSING
close_file proc
    pusha
    mov bx, file_id 
    xor ax, ax       
    mov ah, 3Eh    
    int 21h          
    print_str msgFileClosed
    popa
    ret
close_file endp  

;GETTING SIZE OF FILE
get_size_of_file proc
    pusha    
    xor cx,cx
    xor dx,dx
    mov ah,42h
    mov al,02h
    mov bx,file_id
    int 21h 
    mov file_size,ax
    popa 
    ret
get_size_of_file endp 
;=======================END_PROC_FILE======================================


;=======================PROC======================================
get_num proc
    call count_sizeOfNum
    mov cx,countSize
    mov bx,0Ah
    xor ax,ax
    cmp cx,00001h
    je last_num_end 
    loop_getting_num:
        mov dl,[si]
        sub dl,'0'
        add al,dl
        jc add_to_ah 
        jmp get_ascii 
    add_to_ah:
        cmp ah,00h
        je get_ascii
        inc ah
    get_ascii:            
        cmp ax,00FFh
        ja mul_2_bytes
        jmp mul_byte  
        
    mul_2_bytes:    
        mul bx 
        jc overflow 
        jmp next_part 
    mul_byte:
        mul bl
    
    next_part:         
        inc si  
        dec cx
        cmp cx,0001h
    jne loop_getting_num 
last_num_end:     
    add al,[si]
    sub al,'0'
    inc si    
    ret        
get_num endp

count_sizeOfNum proc
    pusha 
    xor cx,cx
    loop_counting:         
        ;CHECKING OPERATION
        cmp [si],'+'
        je is_counted
        cmp [si],'-'
        je is_counted
        cmp [si],'*'
        je is_counted
        cmp [si],'/'
        je is_counted
        cmp [si],'='
        je is_counted        
        
        inc si
        inc cx 
    jmp loop_counting 
    
is_counted:
    mov countSize,cx        
    popa
    ret
count_sizeOfNum endp

;select operation
get_operation proc
    print_str msgCounting
        ;CHECKING OPERATION
    cmp [si],'+'
    je plus_operation
    cmp [si],'-'
    je minus_operation
    cmp [si],'*'
    je mul_operation
    cmp [si],'/'
    je div_operation
plus_operation:
    mov typeOfOperation,'+'
    inc si
    ret
minus_operation:
    mov typeOfOperation,'-'
    inc si
    ret
mul_operation:
    mov typeOfOperation,'*'
    inc si
    ret 
div_operation:
    mov typeOfOperation,'/'
    
    inc si
    ret              
    
get_operation endp    

;make operation
get_result proc
    pusha
    ;mov ax,result
    ;mov bx,SecondNum
    
    cmp typeOfOperation,'+'
    je get_sum
    cmp typeOfOperation,'-'
    je get_sub    
    cmp typeOfOperation,'*'
    je get_mul
    cmp typeOfOperation,'/'
    je get_div 
get_sum: 
    cmp resZnak,'-'
    je check_
    push si 
    download_overlay plusOver 
    mov ax,result
    mov bx,SecondNum 
    call dword ptr run_address  
    jc overflow
    pop si
    mov	cx,@data                      
    mov	ds,cx 
   ; add ax,bx     
    jmp end_op 
       
check_:
    add ax,bx
    jc polozhitelno
    jmp end_op  
    
polozhitelno:
    mov resZnak,' '
    jmp end_op 
    
get_sub:
    cmp ax,bx
    jl res_less
    jae res_above  
    
res_less:
    ;sub ax,bx
    push si
    download_overlay subOver 
    mov ax,result
    mov bx,SecondNum 
    call dword ptr run_address
    pop si
    mov	cx,@data                      
    mov	ds,cx 
    mov resZnak,'-' 
    
    jmp end_op
    
res_above:    
    ;sub ax,bx
    push si
    download_overlay subOver 
    mov ax,result
    mov bx,SecondNum 
    call dword ptr run_address 
    pop si
    mov	cx,@data                      
    mov	ds,cx
    
    jmp end_op 
    
get_mul:
    ;mul bx  
    push si
    download_overlay mulOver 
    mov ax,result
    mov bx,SecondNum 
    call dword ptr run_address
    jc overflow 
    pop si
    mov	cx,@data                      
    mov	ds,cx 
    
    jmp end_op 
    
get_div:
    ;xor dx,dx
    ;div bx 
    push si
    download_overlay divOver 
    xor dx,dx
    mov ax,result
    mov bx,SecondNum 
    call dword ptr run_address 
    pop si
    mov	cx,@data                      
    mov	ds,cx
    
    jmp end_op
                        
overflow:
    print_str msgOverflow
    mov ah,4Ch
    mov al,00h
    int 21h 
end_op:
	mov result,ax                       
    popa
    ret    
get_result endp 
  
;convert number to string
convert_result_to_string proc
    pusha
    mov cx,000Ah            ;for div 10 
    mov ax,result
    cmp resZnak,'-'
    je getNormalRes
    jmp  normalRes
getNormalRes:
    not ax
    inc ax
normalRes:        
    lea si,string_result
    cmp ax,9F6h
    ja  itoa_high
    jle itoa_low
itoa_high:  
    xor dx,dx      
    div cx 
    mov [si],dl
    add [si],'0'
    inc si 
    
    cmp ax,00FFh
    ja itoa_high 
itoa_low: 
    ;xor ah,ah
    div cl
    ;xor ah,ah
        
    mov [si],ah
    add [si],'0'
    inc si
    xor ah,ah
    cmp ax,00009h
    ja itoa_low   
    mov [si],al
    add [si],'0'
    
    cmp [si],'0'
    jne end_atoi

end_atoi:
    inc si
    mov al,resZnak
    mov [si],al
    lea si,string_result
    mov di,si 
    add di,6
    chek_$: 
    dec di 
    cmp [di],'$'
    je chek_$  
    
reverse:
    mov al,[di] 
    mov bl,[si]
    mov [di],bl 
    mov [si],al
    inc si
    cmp si,di
    je end_reverse
    dec di 
    cmp si,di
    jne reverse
end_reverse:                
    popa
    ret
convert_result_to_string endp
;=======================END_PROC====================================== 
zseg segment
zseg ends 
end start                       