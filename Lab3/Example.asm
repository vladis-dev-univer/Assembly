
       .MODEL SMALL
       .STACK 100H
       .DATA
calc		db	"***CALCULATOR ***$"
operation	db	"Select an Operation$"
addition	db	"[a] Addition $"
subtraction	db	"[b] Subtraction$"
multiplication	db	"[c] Multiplication$"
division	db	"[d] Division$"
op		db	"Your Operation : $"
op_ans		db	6 dup("$")
newline		db	13,10,"$"
addition_wel	db	"You have chosen Addition $"
num1_msg	db	"Input First Number : $"
input_num1	db	10 dup("$")
num2_msg	db	"Input Second Number : $"
input_num2	db	10 dup("$")
sum_msg		db	"The Sum is : $"
sum		db	10 dup("$")
subtraction_wel db	"You have chosen Subtraction $"
difference_msg  db	"The Difference is : $"
difference 	db	10 dup("$")
continue	db	"Would you like to continue?[y/n] : "
cont_ans	db	10 dup("$")
sub_num1	db	10 dup("$")
sub_num2	db	10 dup("$")
mul_wel		db	"You have chosen Multiplication $"
.code
clrscr	proc
	push ax
	mov al, 03h
	mov ah, 00h
	int 10h
	pop ax
	ret
clrscr	endp
readstr	proc
	push ax
	mov ah, 0ah
	int 21h
	pop ax
	ret
readstr	endp
printstr proc
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
printstr endp
begin: mov ax, @data
       mov ds, ax
       mov es, ax
	call clrscr
lbl1:	lea dx,[calc] 
	call printstr  
	lea dx, newline
	call printstr 
      lea dx,[operation]
	call printstr 
	lea dx, newline
	call printstr 
	lea dx,[addition]
	call printstr
	lea dx, newline
	call printstr 
	lea dx,[subtraction]
	call printstr
	lea dx, newline
	call printstr
	lea dx,[multiplication]
	call printstr 
	lea dx, newline
	call printstr
	lea dx,[division]
	call printstr 
	lea dx, newline
	call printstr	
	lea dx,op
	call printstr
		mov al,op_ans[02]
	mov ah,0ah
	int 21h
	cmp op_ans,"a"
	je lbladdition	
lbladdition: 
		lea dx, newline
	call printstr
	
	lea dx, [addition_wel]
	call printstr
	lea dx, newline
	call printstr
	lea dx, [num1_msg]
	call printstr	
	lea dx, input_num1
	mov ah,0ah
	int 21h
		mov ah,input_num1[02]
	mov al,input_num1[03]
	sub ax,3030h
	mov bl,al   ;< --- x9
	mov bh,ah   ;< --- 9x
	lea dx, newline
	call printstr
	lea dx,[num2_msg]
	call printstr
	lea dx,input_num2
	mov ah,0ah
	int 21h
	mov ah, input_num2[02]
	mov al, input_num2[03]
	sub ax,3030h
	aad
	mov ch,al
	add ch,bl
	mov al,ch
	aam
	add ax,3030h 
	mov bl,ah
	sub bh,30h
	add bh,bl
	add bh,30h
	mov sum[0002],bh
	mov sum[0003],al
	mov sum[0005],'$'
	lea dx, newline
	call printstr
	lea dx,[sum_msg]
	call printstr
	lea dx, sum[0002]
	call printstr
	lea dx, newline
	call printstr
lblsubtraction:	
	lea dx, newline
	call printstr	
	lea dx, [subtraction_wel]
	call printstr
	lea dx, newline
	call printstr
	lea dx, [num1_msg]
	call printstr
		lea dx, input_num1
	mov ah,0ah
	int 21h
	mov ah,input_num1[02]
	mov al,input_num2[03]
	sub ax,3030h
	mov bh,ah
	mov bl,al
	lea dx, newline
	call printstr	
	lea dx,[num2_msg]
	call printstr
	lea dx,input_num2
	mov ah,0ah
	int 21h
	mov ah,input_num2[0002]
	mov al,input_num2[0003]
	sub ax,3030h
	aad
	mov ch,al
	sub ch,bl
	mov al,bl
	aam
	add ax,3030h
	mov bl,ah
	sub bh,30h
	sub bh,bl
	add bh,30h
	mov difference[0002],bh
	mov difference[0003],al
	mov difference[0005],'$'
	lea dx,[newline]
	call printstr
	lea dx,[difference_msg]
	call printstr
	lea dx,difference[0002]
	call printstr	
mov ah, 4ch
int 21h
end begin