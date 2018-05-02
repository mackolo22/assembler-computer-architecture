.data 
SYSEXIT = 60
EXIT_SUCCESS = 0
scanf_format: .asciz "%d %f %lf"
printf_format: .asciz "%f \n"

.bss 
.comm int_x, 4
.comm float_y, 4
.comm double_z, 8

.text
.global main

main:
movq $0, %rax
movq $scanf_format, %rdi
movq $int_x, %rsi
movq $float_y, %rdx
movq $double_z, %rcx
call scanf

movq $2, %rax
movq $0, %rdi
movq $0, %rcx
mov int_x(, %rcx, 4), %edi
movss float_y, %xmm0
movsd double_z, %xmm1
call function

movq $1, %rax
movq $printf_format, %rdi
sub $8, %rsp
call printf

program_exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
