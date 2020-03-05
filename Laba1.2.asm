;Laba#1    
       
;Model of memory used for COM.

;    .model tiny   ;start COM-file
;    .code
;    org 100h
            
;start:    

;    mov ah,9
;    mov dx, offset message
;    int 21h
;    ret           ;end COM-file (or int 20h)
    
;message db "Hello, my name is Vlad!$" 
   
;end start  



;///////////////////////////////////////////////////



;Model of memory used for EXE. 
    .model small
    .stack 100h
    .data  
str db 'Hello, my name is Vlad!',0dh,0ah,'$' 
    .code
start: 
    mov ax,@data
    mov ds,ax                           
    mov dx,offset str
    mov ah,9   
    int 21h    
    mov ax,4Ch  
    int 21h
    
end start
    

        
        