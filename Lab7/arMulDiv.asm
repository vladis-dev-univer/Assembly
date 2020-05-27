cseg segment para public 'code'
overlay proc
    assume cs:cseg
    
      mov ax,3
      
      retf   
    overlay endp 
cseg ends
end