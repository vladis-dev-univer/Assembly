.model small 
.stack 100h
.data 
    platform        db 0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0DBh,11h,0FEh,11h ;платформа(символ, цвет)
    platformRight   dw ?         ;для запонминания правой и левой границ платформы,
    platformLeft    dw ?         ;чтобы в дальнейшем перемещать ее положение
    line_title      db 0DBh,01h  ;символ, цвет
    line            dw 0005h     ;отступ от верхней границы (5)
    ball            db 02h,0Eh   ;символ, цвет  
    size_platform   dw 001Ah     ;26->13*2                
    size_line       dw 00A0h     ;ширина отступа и кирпича(160)                  
    platformLoc     dw 0F50h     ;начальная позиция платформы     
    ballLoc         dw 0FA0h     ;начальная позиция шарика
    repeat          dw 8F00h     ;повторений в цикле (скорость)
    endLine         dw 0FA0h     ;правая граница
    byteDivider     db 0002h     ;нужна для того, чтобы понять, нужен пробел в начале рисования кирпича или нет
    curX            dw 005Ah     ;начальная позиция (x) шарика
    curY            dw 0017h     ;начальная позиция (y) шарика
    vectorX         dw -2h       ;вектор передвижения мячика по X
    vectorY         dw -1h       ;вектор передвижения мячика по Y
    points          dw 0000h     ;кол-во набранных очков                           
    max_coints      dw 01F4h     ;максимальное кол-во очков (500)                
    points_str      db 10 dup(?) ;для перевода в строку кол-ва очков           
    LEN             dw 0         ;длинна строки в score                 
    score           db ' ',0Fh,'s',0Fh,'c',0Fh,'o',0Fh,'r',0Fh,'e',0Fh,':',0Fh,' ',0Fh ,' ',0h,' ',07h  ,' ',07h
    size_score      dw 0x0015h 

;для вывода на экран информации о правилах игры
           ;повернуть влево
    rules  db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,'C',0Fh,'l',0Fh,'i',0Fh,'c',0Fh,'k',0Fh,' ',0Fh
           db 'o',0Fh,'n',0Fh,' ',0Fh,'t',0Fh,'h',0Fh,'e',0Fh,' ',0Fh,'a',0Fh,'r',0Fh,'r',0Fh,'o',0Fh,'w',0Fh
           db ' ',0Fh,'(',0Fh,'<',0Fh,'-',0Fh,')',0Fh,' ',0Fh,'t',0Fh,'o',0Fh,' ',0Fh,'t',0Fh,'u',0Fh,'r',0Fh
           db 'n',0Fh,' ',0Fh,'l',0Fh,'e',0Fh,'f',0Fh,'t',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh 
           ;повернуть вправо 
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,'C',0Fh,'l',0Fh,'i',0Fh,'c',0Fh,'k',0Fh,' ',0Fh
           db 'o',0Fh,'n',0Fh,' ',0Fh,'t',0Fh,'h',0Fh,'e',0Fh,' ',0Fh,'a',0Fh,'r',0Fh,'r',0Fh,'o',0Fh,'w',0Fh
           db ' ',0Fh,'(',0Fh,'-',0Fh,'>',0Fh,')',0Fh,' ',0Fh,'t',0Fh,'o',0Fh,' ',0Fh,'t',0Fh,'u',0Fh,'r',0Fh
           db 'n',0Fh,' ',0Fh,'r',0Fh,'i',0Fh,'g',0Fh,'h',0Fh,'t',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh  
           ;начть игру   
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh
           db ' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,' ',0Fh,'T',0Fh,'o',0Fh,' ',0Fh,'s',0Fh,'t',0Fh,'a',0Fh
           db 'r',0Fh,'t',0Fh,' ',0Fh,'t',0Fh,'h',0Fh,'e',0Fh,' ',0Fh,'g',0Fh,'a',0Fh,'m',0Fh,'e',0Fh,' ',0Fh 
           db 'p',0Fh,'r',0Fh,'e',0Fh,'s',0Fh,'s',0Fh,' ',0Fh,'a',0Fh,'n',0Fh,'y',0Fh,' ',0Fh,'k',0Fh,'e',0Fh
           db 'y',0Fh,'!',0Fh,'!',0Fh,'!',0Fh
           
    size_rules dw 01A8h   ;424 символов
    
    game_over   db 'G',0Fh,'A',0Fh,'M',0Fh,'E',0Fh,' ',0h,'O',0Fh,'V',0Fh,'E',0Fh,'R',0Fh
    winner      db 'W',0Fh,'I',0Fh,'N',0Fh 
    flag        db 0
    curSpeed    dw 8F00h  ;скорость         
    
    SPA     equ 20h       ;код пробела                
    PL      equ 0FEh      ;дизайн плиток (с отверстиями в виде квадратиков)            
   
    LEFT    equ 4B00h     ;расширенный код "<-"
    RIGHT   equ 4D00h     ;расширенный код "->"  
    ENTER   equ 1C0Dh     ;расширенный код "Enter"  
    
.code 
 start:   
    main1: 
    call begin         ;начало
    call cursorHide    ;скрываем курсор
    call clearScreen   ;очищаем экран
    call drawRules     ;пишем правила игры
    call drawTitle     ;рисуем верхнюю границу
    call drawScore     ;рисуем текущий счёт
    call points_show   ;рисуем число набранных очков
    call drawPlatform  ;рисуем платформу
    call drawBall      ;рисуем мяч
    call drawBreaks    ;рисуем кирпичики
    call go            ;нажимаем любую клавишу для начала 
 main:                 ;главный цикл игры
    mov cx,[repeat]           
  cycle:  
    call movePlatform  ;проверяем движ. платформы
    dec cx             ;уменьшаем счётчик до нуля
    cmp cx, 0          ;если не 0, идем занаво на цикл
    jne cycle                 
    call moveBall      ;иначе перемещаем и      
    call drawBall      ;рисуем мячик
    jmp main           ;и идем опять в main
     
    begin:
        mov ax,@data
        mov ds, ax
        mov ah,00    ;установка видеорежима                      
        mov al,03    ;видеорежим номер 3 (16 цветов) с очисткой экрана 
        int 10h      ;прерывание bios
        
        push 0B800h              ;запоминаем начало видеопамяти в стек
        pop es                   ;восстанавливаем видео память в es
        mov ax, [platformLoc]    ;запоминаем позицию платформы в ax              
        mov [platformLeft], ax   ;из ax записываем начало(левую позицию) платформы           
        mov [platformRight], ax  ;-||- и конец(правую позицию) платформы, но она не конечная
        mov ax, [size_platform]  ;записываем в ax размер плотформы          
        add [platformRight],ax   ; и добовляем этот размер к концу(правой позиции) плотфоры, теперь она конечная!          
        ret
     go:
        mov ah, 00h     ;функция читает(ожидает) нажатую клавишу          
        int 16h   
     cursorHide:                  
        mov ah,1        ;ф-я установки размера курсора         
        mov cx, 2000h   ;делаем курсор незаметным(обычный курсор - 0607h)           
        int 10h 
        ret
     drawScore:
        mov di, 00h           ;заносим 0 в di
        lea si, score         ;заносим адрес
        mov cx, [size_score]  ;заносим размер в cx(15)
        rep movsb             ;записываем я ячейку по адресу es:di байт из ячейки с адресом ds:si (пока cx станет равным 0)
        ret
     drawTitle:                 
        xor ax, ax         ;обнуляем ax
        mov ax, 0001h      ;заносим в ax 1
        mul [size_line]    ;умножаем 1 на ax получаем значение size_line (160)       
        mov di, ax         ;заносим это значение в di(160), для контроля завершения
        add ax, size_line  ;увеличиваем ax на size_line (т.е. ax = 320), для того, чтобы рисовать символ и цвет
     cycle_:                 
        cmp di, ax                 ;проверяем, если мы все нарисовали,   
        je return                  ;то выходим  
        mov si, offset line_title  ;заносим адрес нашей плитки для отрисовки верхней полосы на экране
        mov cx, 2                  ;затем заносим в cx 2 для того, чтобы скопировать только два байта
        rep movsb                  ;записываем я ячейку по адресу es:di байт из ячейки с адресом ds:si (пока cx станет равным 0)
        jmp cycle_                 ;повторяем снова
     clearScreen:               
        mov ah,6       ;функция прокрутки окна(вверх)
        mov al,0       ;на весь размер           
        mov bh,7       ;байт атрибутов для заполнения экрана            
        xor cx,cx      ;обнуляем координату левого верхнего угла(ch=0,cl=0)           
        mov dl,79      ;устанавливаем значение правого нижнего угла        
        mov dh,24      ;(24,79)
        int 10h
        ret
     drawBreaks:
        ;получаем позицию откуда надо начинать рисовать             
        mov ax, [line]       ;получаем место с которого надо рисовать  
        mul [size_line]        
        mov bx, ax           ;800     
        add ax, [size_line]  ;добавляем длину линии(960 - 3C0h), чтобы потом проверять с bx  
        mov cx, 0032h        ;кол-во кирпичиков (50)     
     loopl:         
        call drawBlock      ;рисуем кирпич  
        call drawSpace      ;рисуем пробел    
        dec cx              ;уменьшаем счётчик   
        cmp cx, 0           ;пока счётчик не равен 0, рисуем кирпичи и пробелы
        je return           ;если закончили - выходим   
        cmp bx, ax          ;если мы нарисовали всю линию   
        jge new_line        ;переходим на новую
        jmp loopl           ;иначе дорисовываем до конца линию
     new_line:                   
        add ax, [size_line] ;добовляем размер следующей строки   
        add [line],1        ;опускаем позицию линии на 1 вниз    
        push ax             ;сохраняем значение ax (1120 - 460h)
        mov ax, [line]      ;помещаем в ax 6 - следующая строка
        div [byteDivider]   ;делим на 2, чтобы проверить нужно ли делать отступ от начала или нет
        cmp ah, 1           ;если в остатке 1, то не нужно, 
        je step             ;переходим в step   
        add bx, 8           ;иначе делаем пробел в размере кирпичика  
        pop ax              ;восстанавливаем ax
        jmp loopl           ;переходим на рисование новой линии    
     step:
        pop ax              ;восстанвливаем ax
        mov bx, ax          ;заносим его в bx
        sub bx, [size_line] ;в bx добовляем длину линии для дальшейшего сравнения с ax     
        jmp loopl           ;начинаем рисовать слежующую линию
     drawBlock:               ;блок из 1 элемента  
        push cx               ;запоминаем кол-во кирпичиков
        mov cx, 0004h         ;кол-во выемок в кирпичике   
     drawBlock2:              ;рисуем кирпичек с 4-я отверстиями        
        mov es:[bx], PL       ;получаем элемен, который потом будет закрашен
        mov es:[bx+1], 021h   ;получаем цвет кирпичика(светло-зелёный) и цвет соответствующего элемента (синий)  
        add bx, 2             ;добавляем 2(т.к. мы сделали два действия), чтобы потом сравнить с ax   
        dec cx                ;уменьшаем счётчик
        cmp cx, 0             ;проверяем, сколько отверстий наресованно    
        jne drawBlock2        ;рисуем дальше, если не четыре
        pop cx                ;восстанавливаем кол-во кирпичиков    
        ret
     drawSpace:             ;пространство 1 элемента         
        push cx             ;запоминаем кол-во кирпичиков
        mov cx, 0004h       ;пустое расстояние такое же, как расстояние кирпичика
     drawSpace2:
        mov es:[bx], SPA    ;заполняем пробелом    
        mov es:[bx+1], 0h   ;получаем цвет (чёрный)
        add bx, 2           ;добавляем 2(т.к. мы сделали два действия), чтобы потом сравнить с ax
        dec cx              ;проверяем сколько мы запонили места
        cmp cx, 0           ;проверяем сколько мы запонили места
        jne drawSpace2      ;заполняем дальше, если не верное расстояние
        pop cx              ;восстанавливаем кол-во кирпичиков
        ret  
     drawPlatform:                  
        mov di, [platformLoc]      ;позиция платформы
        mov cx, [size_platform]    ;размер платформы
        mov si, offset platform    ;адрес платформы
        cld
        rep movsb                  ;рисуем платформу
        ret  
     movePlatform:              ;проверяем куда нужно передвинуть платформу
        mov ah, 01h           
        int 16h                 ;если мы нажали любую клавишу, то 
        jnz checkKey            ;переходим в checkKey и обрабатываем движ. платформы
        ret
     checkKey:                  ;сравнение с кодами справа и слева
        mov ah, 00h             ;функция читает(ожидает) нажатую клавишу
        int 16h 
        cmp ax, RIGHT           ;если нажата клавиша '->', то 
        je  go_right            ;переходим на процедуру перемещение платформы вправо 
        cmp ax, LEFT            ;если нажата клавиша '<-', то
        je  go_left             ;переходим на процедуру перемещение платформы влево
        ret
     go_right:                         ;двигаем вправо   
        mov bx, [platformLoc]          ;помещаем начало платформы(левая позиция) в bx
        add bx, [size_platform]        ;добовляем к bx разиер платформы и получаем правую позицию платформы  
        cmp bx, [endLine]              ;если мы перешли правую границу окна, то не меняем позицию, 
        jge movePlatform               ;а идем на проверку передвежения платформы
        mov es:[bx],PL                 ;добавляем элемент справа, который потом будет закрашен
        mov es:[bx+1], 011h            ;закрашиваем элемент и остальную область в синий цвет
        mov bx, [platformLoc]          ;получаем левую позицию платформы
        mov es:[bx],SPA                ;очищаем место, которое нам уже не надо
        mov es:[bx+1],0h               ;и закрышиваем чёрным цветом
        add [platformLoc],2            ;меняем позицию платформы
        add [platformRight], 2         ;добавляем к правой стороне платформы 2
        add [platformLeft], 2          ;и к левой стороне 
        jmp movePlatform               ;переходим на проверку движ. платформы
     go_left:                       ;двигаем влево    
        cmp [platformLoc], 0F00h    ;если мы перешли левую границу окна, то не меняем позицию,    
        jle movePlatform            ;а идем на проверку передвежения платформы 
        sub [platformLoc], 2        ;меняем позицию платформы
        sub [platformRight], 2      ;вычитаем из правой стороны 2
        sub [platformLeft], 2       ;и из левой    
        mov bx, [platformLoc]       ;получаем левую позицию платформы
        add bx, [size_platform]     ;добовляем к bx разиер платформы и получаем правую позицию платформы    
        mov es:[bx],SPA             ;очищаем место, которое нам уже не надо
        mov es:[bx+1],0h            ;и закрышиваем чёрным цветом
        mov bx, [platformLoc]       ;получаем левую позицию платформы     
        mov es:[bx],PL              ;добавляем элемент слева, который потом будет закрашен
        mov es:[bx+1], 011h         ;закрашиваем элемент и остальную область в синий цвет
        jmp movePlatform            ;переходим на проверку движ. платформы
     drawBall:
        xor bx, bx               ;обнуляем bx
        mov bx, [ballLoc]        ;заносим позицию шарика в bx
        xor ax, ax               ;обнуляем ax
        mov ax, [curY]           ;заносим координату Y в ax
        mul [size_line]          ;ax умнажаем на ширину
        add ax, [curX]           ;и добавляем позицию X - получаем положение шарика в центре платформы
        mov [ballLoc], ax        ;и заносим его в адрес "ballLoc"
        cmp ax, bx               ;сравниваем с bx
        je return             
        mov di, ax               ;занисим нашу позицию в di
        mov si, offset ball      ;занесй адрес смещения для рисования мячика в si
        mov cx, 2                ;нарисавать надо две вещи - сам шарик и цвет
        cld                      ;очистка флага направления
        rep movsb                ;рисуем
        mov es:[bx], SPA         ;поле смены позиции, когда мячик начал движение
        mov es:[bx+1], 0h        ;убираем/очищаем предыдущую позицию
        ret     
        
     ;изменяем направление ветора Y
     changeVectorY:          
        neg [vectorY]            
        jmp checkBorderX  
     ;изменяем направление ветор X
     changeVectorX: 
        neg [vectorX]
        jmp next  
        
     moveBall:     
     ;проверяем границу Y             
     checkBorderY:             
        cmp [curY], 2  ;верхняя граница         
        je changeVectorY  
     ;проверяем границу Y
     checkBorderX:              
        xor dx, dx               
        mov dx, [size_line]     ;заносим в dx ширину кирпичиков
        sub dx, [vectorX]        
        cmp [curX], dx          ;проверяем текущее положение X
        jge  changeVectorX      ;если он возле правой стенки
        cmp [curX], 0           ;проверяем текущее положение X
        jle  changeVectorX      ;если он возле левой стенки
     next:                       
        xor ax, ax  
        mov ax, [curY]          ;заносим текущее положение Y
        add ax, [vectorY]       ;меняем положение Y
        mov [curY], ax          ;делаем текущим
        xor bx, bx
        mov bx, [curX]          ;заносим текущее положение X 
        add bx, [vectorX]       ;меняем положение X
        cmp bx, 0               ;проверяем положение X
        jl back1
      next1:  
        mov [curX], bx          ;делаем текущим положение X
        mul [size_line]          
        add ax, bx              
        mov di, ax
        push di
        mov ax, es:[di]         ;записываем в видеопамять
        
     ;проверка на поподание в кирпич и на поражение
     next2:  
        pop di
        mov ax, es:[di]
        cmp al, PL        ;если попал в кирпич
        je back_move      ;переходим на проверку поподания в кирпич и движение назад
        cmp [curY], 0019h      ;проверяем не вышли ли мы за нижнюю границу карты(т.е. проиграли)    
        je gameOver
        cmp al, 0FEh           ;проверка верхней границы
        jne check_go_awake      
        ret  
     back1:                   
        neg [vectorX]            ;меняем направление
        add bx, [vectorX]      
        add bx, [vectorX]      
        jmp next1   
     back_move: 
        call checkBrick       
        neg [vectorY]            ;меняем направление вектора X        
        neg [vectorX]            ;меняем направление вектора Y
        mov ax, [curY]           ;записываем в ax текущее положение Y
        add ax, [vectorY]        ;добавляем вектор Y 
        mov [curY], ax           ;записываем в текущее положение
        mov ax, [curX]           ;тоже самое с вектором X
        add ax, [vectorX]        ;-||-
        mov [curX], ax           ;-||-
        neg [vectorX]            ;меняем направление вектора X
        call checkChangeVector  
        ret 
               
     ;проверка на изменение направления движения мячика, при попадании на платформу
     checkChangeVector:           
        mov dx, [platformLeft]       
        sub dx, [size_line] 
        cmp dx, [ballLoc]       
        je decVectorX               ;если платформа слева(самый конец)
        add dx, 2                
        cmp dx, [ballLoc]
        je decVectorX               ;если платформа слева(один шаг вправо от конца)
        add dx, 2
        cmp dx, [ballLoc]       
        je decVectorX               ;если платформа слева(два шага вправо от конца)
        
        mov dx, [platformRight] 
        sub dx, [size_line]     
        cmp dx, [ballLoc]
        je incVectorX                ;если платформа справа(самый конец)
        sub dx, 2
        cmp dx, [ballLoc]
        je incVectorX                ;если платформа справа(один шаг влево от конца)
        sub dx, 2
        cmp dx, [ballLoc]
        je incVectorX                ;если платформа справа(два шага влево от конца)
        ret
     decVectorX:  ;уменьшаем X
        sub [vectorX], 2
        ret
     incVectorX:  ;увеличиваем Y
        add [vectorX], 2
        ret 
     
     ;проверка поподания в кирпич                                                  
     checkBrick:                
        cmp [curY],0018h       ;если мячик на плитке, 
        je return              ;выходим
        ;cmp [curY],0001h      ;левый нижний угол
        ;je return
        mov ax, [curY]         ;текущее положение Y
        mul [size_line]        ;получаем весь кирпич
        mov bx, ax             ;запоминаем его
        add bx, [curX]         ;текущее положение X
     loop1:                 ;проверяем попали мы именно в керпич          
        sub bx, 2           ;отнимаем от bx 2      
        cmp bx, ax
        jl go1
        cmp es:[bx], SPA    ;проверяем на пробел
        jne loop1           ;пока не будет проверен весь кирпич
     go1:                       
        add bx, 2           ;добавляем к bx 2, т.е. мы перешли в loop1 на 2   
        call drawSpace
        add [points],10     ;добавляем за каждый сбитый кирпичик по 10-ке       
        call points_show    ;рисуем кол-во очков в score: ___ 
        
     return:
        ret  
            
     gameOver:            ;Конец игры. Очищаем экран и выводим сообщение о проигрыше
        call clearScreen         
        mov ax,000Ah
        mul [size_line]
        add ax,0048h
        mov di, ax
        mov si, offset game_over
        mov cx, 0012h
        rep movsb 
        push ax
       
        call sleep                 
        jmp reload       ;продолжение или окончание игры...            
     sleep:
        mov cx,20        ;время ожидания в микросек.(старшая часть)
        mov dx,0         ;время ожидания в микросек.(младшая часть)  
        mov ah,86h       ;функция задержки       
        int 15h          ;задержка       
        
     cycle_read:        ;проверка наличия символа в буфере
        mov ah,1              
        int 16h
        jnz read
        ret   
     read:              ;чтение символа с ожиданием
        xor ah,ah               
        int 16h 
        jmp cycle_read 
          
     check_go_awake: 
        mov bx, [ballLoc]     ;получаем текущую позицию мячика     
        add bx, [vectorX]     ;добовляем vectorX(смещение мячика по Ox)   
        mov ax, es:[bx]       ;заночим в видеопамять  
        cmp al, 0FEh          ;проверяем, где маяик
        jne return            ;выходим, если он отталкивается от платформы
        mov ax, [curY]        ;и меняем координаты X и Y  
        mul [size_line]
        mov dx, ax
        add ax, [curX]           
        sub ax, [vectorX]
        mov bx, ax
        mov ax, es:[bx]         
        cmp al, 0FEh
        jne return  
              
     ;оброботка исключительных ситуаций при поподании в керпич(сразу два кирпича, 
     ;если мы в верхней границе, т.е. пока не выйдем от туда убирать все керпичики, 
     ;в которые поподает мячик)
     loop3:                  
        sub bx, 2
        cmp bx, dx
        je go2
        cmp es:[bx],0FEh
        je loop3
        add bx, 2
     go2:                        
        call drawSpace
        mov bx, [ballLoc]          
        add bx, [vectorX]        
     loop4:                        
        sub bx,2                  
        cmp es:[bx],0FEh
        je loop4
     next3:
        add bx,2                    
        call drawSpace
        neg [vectorY]             
        neg [vectorX]
        mov ax, [curY]
        add ax, [vectorY]
        mov [curY], ax
        mov ax, [curX]
        add ax, [vectorX]
        mov [curX], ax              
        add [points],20
        call points_show 
            
points_show:                         
    push bx                 ;запоминаем bx
    mov ax, [max_coints]    ;заносим максимальное кол-во очков в ax
    cmp [points], ax        ;проверяем не набрали ли мы это максимальное кол-во очков
    je win                  ;если да, то мы выйграли, иначе - рисуем набранное кол-во очков
    lea bx, points          
    lea di, points_str      ;записываем адрес нашей строки(в которую мы будем записывать кол-во набранных очков) в di
    call pointsTOstr        ;перевод число(кол-во набранных очков) в строку              
    
    mov cx, LEN             ;заносим в cx кол-во раз сколько нужно рисовать
    mov di, 10h             ;заносим 
    lea si, points_str      ;получаем адрес нашей строки с очками
    cld                     ;очищаем вектор направления
    rep movsb               ;рисуем кол-во набранных очков           
    pop bx                  ;восстонавливаем bx
    ret 
;Процедура перевод числа в строку         
pointsTOstr PROC   
;запоминаем регистры                        
    push ax
    push bx
    push cx
    push di    
;переводим в строку
    mov ax, [bx]
    mov bx, 10
    xor cx, cx       
division:
    xor dx, dx
    div bx          ;делим на 10(10-я система),
    push dx         ;запоминаем остаток
    inc cx          ;увиличиваем кол-во символов, которое в итоге будет
    cmp ax, 0       ;пока не 0
    jne division    
    
    mov LEN, cx    ;n-делений заносим в размер строки (кол-во символов)
    add LEN, cx    ;размер строки
save_in_str:
    pop dx
    add dl, '0'         ;переводим в символ
    mov [di], dl        ;добавляем в адрес points_str
    inc di              ;увиличиваем di
    mov [di], 0Fh       ;зарисовываем
    inc di              ;увиличиваем di
    loop save_in_str    ;повторяем, пока di != 0
       
    ;восстонавливаем регистры и выходим
    pop di 
    pop cx
    pop bx
    pop ax
    ret
endp 

drawRules proc
    mov di, 00h            ;заносим 0 в di
    lea si, rules          ;заносим в si начальный адрес нашего текста
    mov cx, [size_rules]   ;в cx заносим размер 
    rep movsb              ;записываем я ячейку по адресу es:di байт из ячейки с адресом ds:si (пока cx станет равным 0)
    
    mov ah, 1              ;ждём ввода с клавиатуры
    int 21h 
    call clearScreen    
ret
endp

reload:     ;Обновление или завершение игры
    ;по нажатию enter начинаем игру сново
    mov ah, 00h
    int 16h
    mov bx, ENTER
    cmp ax, bx 
    jne endProgram    ;если нажата не enter выходим
    ;устанавливаем значения, чтобы начать игру заново
    mov [points], 0
    mov [platformLoc],0F50h
    mov [ballLoc],0FA0h
    mov [curX],005Ah
    mov [curY],0017h
    mov [vectorX],-2h
    mov [vectorY],-1h  
    mov [line], 5 
    mov [repeat],8F00h
    mov [flag], 0 
    ;и вызываем те же функции, что и в начале, см. выше
    call begin
    call clearScreen 
    call drawTitle 
    call drawScore
    call points_show 
    call drawPlatform 
    call drawBall
    call drawBreaks
    call go 
    jmp main  ;переходим на главный цикл игры  
    
endProgram:  ;Завершение игры и прогаммы
    call clearScreen
    mov ax, 4C00h
    int 21h
win:        ;Конец игры. Вывод сообщения о ПОБЕДЕ!
        call clearScreen
        mov ax,000Ah
        mul [size_line]
        add ax,0048h
        mov di, ax
        mov si, offset winner
        mov cx,000Eh
        rep movsb 
        push ax
        call sleep
        jmp reload