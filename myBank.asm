include 'emu8086.inc'
org 100h 

DEFINE_PRINT_NUM_UNS
DEFINE_SCAN_NUM  

.MODEL SMALL
.STACK
.DATA


customers db "User1   ",10,13,"$"
          db "User2 ",10,13,"$"
          db "User3    ",10,13,"$"
          db "User4   ",10,13,"$" 
          db "User5 ",10,13,"$"
          db "User6   ",10,13,"$"
          db "User7 ",10,13,"$"
          db "User8  ",10,13,"$" 
          db "User9 ",10,13,"$"
          db "user10  ",10,13,"$"
        
bals dw 1000,2000,3000,7800,5600,9000,780,90,89,700

pins db "1234"
     db "5678"
     db "9012"
     db "3456"
     db "7890"
     db "1122"
     db "3344"
     db "5566"
     db "7788" 
     db "9900" 
      
c_len  db 11
pass_len     db 4    

password     db 5,?,5 dup(" ")
new_balance  dw ?
withdrawn    dw ?  ;amount requested by user 
deposited    dw ?  ;amount deposited by user
customerbal  dw ?  ;balance of any user
acc_no       db ?  ;account number 
counter      db 3 

     

menu  db 10,13,"Press 1 to check balance"
      db 10,13,"Press 2 to withdraw"
      db 10,13,"Press 3 to deposit"
      db 10,13,"Press 4 to exit",10,13, "$"

wlcm0     db "LEE BANK",10,13, "$"
wlcm1     db "Please enter your account number:",10,13, "$"
wlcm2     db 10,13,"Welcome ",7, "$" 
wrngEntry db "You have not selected a valid option!",10,13, "$"
pass_msg  db "Please enter your password: $"
withdrw   db 10,13,"Enter Amount to Withdraw: $"
depo      db 10,13,"Enter Amount to Deposit: $"
less      db 10,13,"You have insufficient funds! ", 10,13,"$" 
balance   db 10,13,"Your balance is KSH. $"  
newbal    db 10,13,"Your new balance is KSH. $"
new_trans db 10,13,"Would you like another transaction? (y or n)$"
wrong_pin db 10,13,"Wrong Pin! Try Again.",10,13,"$"
blocked   db 10,13,"Too many trials!",10,13,"$"   
no_acc    db 10,13,"That account doesn't exist!",10,13,"$"
bye       db 10,13,"Thank you for banking with us.$" 


.CODE
start:
    mov ax,@data  ;points to position of data
    mov ds, ax    ;copies address of data to data segment
    mov es, ax    ;copies address of data to extra segment 
    
     
    
    mov ah,9
    lea dx, wlcm0  ;output lee bank
    int 21h
    
    mov ah,9
    lea dx, wlcm1    ;prompt for account number
    int 21h     

acc_in:
    mov ah, 7 ;read input from user, single character
    int 21h 
    
    cmp al,'0'
    jb error0
    cmp al,'9'
    ja error0
    sub al,30h ;change to interger. 30h is 0 in ascii
    mov acc_no, al   ;store that value in acc no
    jmp pass_in
     
error0:
    mov ah,9
    lea dx, no_acc        ;error if acc no is invalid
    int 21h
    jmp acc_in
    
pass_in:
    mov ah,9
    mov dx, offset pass_msg     ;asks for the password
    int 21h 
    
read_pass:
    call read_input 
    cld           ; clear direction flag to ensure comparison of strings
    mov si,offset pins
    mov al,acc_no         ;
    mul pass_len     ;iterate through the pins
    add si,ax
    mov di,offset password+2
    mov cx,4  ;compare 4 input password characters  
    repe cmpsb ;compare strings in source and destination
    je correct_pass
    jne error1 
    
error1:
    sub counter,1
    cmp counter,0    ;give the user 3 chances 
    je error2
    mov dx,offset wrong_pin  
    mov ah,9 
    int 21h
    jmp read_pass
    
error2:
    lea dx, blocked
    mov ah,9           ;blocks the acount after 3 chances
    int 21h
    jmp finish
   
correct_pass:
    mov ah,9
    lea dx, wlcm2      ;says welcome
    int 21h  
    
    lea dx,customers
    mov cx, 0         ;loop through customers
    mov cl, acc_no
    cmp cx,0
    je print1
    
customerloop: 
    add dl,c_len
    loop customerloop  
    
print1:         
    mov ah,9         ;print out user's name
    int 21h
   
transaction:    
    mov ah,9
    lea dx,menu   ;print out the name
    int 21h
    
menu_process:
    mov ah,1    ;read character input from the user
    int 21h 
    
    sub al,30h   ;change character to integer
    
    cmp al,1
    jz checkBal
    cmp al,2
    jz  withdraw     
    cmp al,3
    jz deposit
    cmp al,4
    jz exit
    cmp al,5
    jae choose_again  
 
    
choose_again: 
    mov dx,offset wrngEntry
    mov ah,9                    
    int 21h
    jmp menu_process 

checkBal: 
    mov ah,9
    lea dx,balance
    int 21h

    lea bx,bals
    add bl,acc_no 
    add bl, acc_no          ;check for balance in bals
    mov ax,[bx]    
    mov customerbal,ax  

    mov ax,customerbal
    call PRINT_NUM_UNS
    
    
    jmp new_transaction  
    
    
withdraw:
    mov ah,9
    lea dx,withdrw
    int 21h
    
    call SCAN_NUM   ;reads the amount the user has keyed in
    
    mov withdrawn,cx
    cmp cx,customerbal       ;compare value customer balance with value typed in
    jae insufficient_credit
    
    mov ax,customerbal
    sub ax,withdrawn 
    mov new_balance,ax
    mov customerbal,ax ;updates customer balance
    
    mov ah, 9
    lea dx,newbal
    int 21h
    
    mov ax,customerbal
    call PRINT_NUM_UNS
    
    jmp new_transaction 
    
deposit:
     mov ah,9
     lea dx,depo
     int 21h
     
     call SCAN_NUM  
     mov deposited, cx; move the value read into deposited
     
     mov ax,customerbal
     add ax,deposited 
     mov new_balance,ax
     mov customerbal,ax
     
     mov ah,9
     lea dx,newbal
     int 21h
     
     mov ax,customerbal
     call PRINT_NUM_UNS
     
     jmp new_transaction
     
exit:
    mov ah,9
    lea dx,bye
    int 21h
    jmp finish 
    
new_transaction:
    mov ah,9
    lea dx,new_trans
    int 21h
    
    mov ah,1
    int 21h 
    
    or al,20h  ;force character to lowercase for comparison
    cmp al,'y'
    je transaction
    
    mov ah,9
    lea dx,bye
    int 21h
    
    jmp finish 
    
insufficient_credit:
    mov ah,9
    lea dx, less
    int 21h 
    jmp transaction
    
finish:
    mov ah,7 ;wait for user to press any key
    int 21h
    mov ah,4ch ;return control to OS
    int 21h
    

read_input proc
	mov bx,offset password+2
	mov cx,4 ;4 characters to be entered as the password
next_char:	
	mov ah, 7
	int 21h
; check for ENTER key:
    cmp     al, 0Dh
    jne     not_cret
    JMP     stop_in
not_cret:
    CMP     AL, 8                   ; 'BACKSPACE' pressed?
    JNE     b_space_checked
    PUTC    8                       ; backspace.
    PUTC    ' '                     ; clear position.
    PUTC    8                       ; backspace again to put the cusor in position
    inc     cx
    JMP     next_char
b_space_checked:
    mov     [bx],al
    inc     bx
    ;Print a '*' to hide the password
    PUTC    '*'
    loop next_char    
stop_in:
	ret
    read_input endp  

end start 
