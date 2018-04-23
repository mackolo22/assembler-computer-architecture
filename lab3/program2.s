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
cmp $0, %rdi
je FirstElement
movq $5, %rbx
dec %rdi
call Recursion
mul %rbx
add $7, %rax
ret

FirstElement:
movq $-2, %rcx
dec %rdi
mul %rcx
ret
