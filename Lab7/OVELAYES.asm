;overlays
cseg segment para public 'code'
overlay proc
    assume cs:cseg
    
      add ax, bx 
      ;div bx
      ;sub ax,bx
      ;mul bx  
      retf   
    overlay endp 
cseg ends
end