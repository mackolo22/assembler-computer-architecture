.data
STDIN = 0
STDOUT = 1
SYSWRITE = 1
SYSREAD = 0
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
ZERO_ASCII = 0x30

.comm N, BUFLEN

.text
.global main

main:
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $N, %rsi
movq $BUFLEN, %rdx
syscall

dec %rax
movq %rax, %rdi
dec %rdi
movq $1, %rsi
movq $0, %r10
movq $0, %r8

ConvertToNumber:
movq $0, %rax
movb N(, %rdi, 1), %al	
sub $ZERO_ASCII, %al		                
mul %rsi			                        
add %rax, %r8			                    
movq %rsi, %rax
movq $10, %rbx
mul %rbx			                        
movq %rax, %rsi			                    
dec %rdi    
cmp $0, %rdi
jge ConvertToNumber

# r8 zawiera N
movq $1, %rax
movq $0, %rbx
movq $0, %rcx
movq $0, %rdx
movq %r8, %rdi

push %rax
push %rdi
call Recursion

ProgramExit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

/ int Recursion(int n)
/ {
/    if(n == 0)
/        return -2;
/   
/    return 5 * Recursion(n - 1) + 7
/ }
Recursion:
push %rbp
movq %rsp, %rbp
movq 16(%rbp), %rsi
movq 24(%rbp), %r11
movq %r11, %rax
cmp $0, %rsi
je FirstElement
movq $5, %rbx
dec %rsi
push %rax
push %rsi
call Recursion
mul %rbx
add $7, %rax
movq %rbp, %rsp
pop %rbp
ret

FirstElement:
movq $-2, %rcx
dec %rsi
push %rax
push %rsi
mul %rcx
movq %rbp, %rsp
pop %rbp
ret
