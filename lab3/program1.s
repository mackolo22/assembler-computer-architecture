.data
STDIN = 0
STDOUT = 1
SYSWRITE = 1
SYSREAD = 0
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
ZERO_ASCII = 0x30

.comm input_buffer, BUFLEN
.comm output_buffer, BUFLEN

.text
.global main

main:
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $input_buffer, %rsi
movq $BUFLEN, %rdx
syscall

movq $input_buffer, %rcx    # rcx zawiera adres bufora
movq $0, %rdi   # licznik iterujący po łańcuchu znaków
movq $0, %rsi   # zawiera długość aktualnego ciągu zer
movq $0, %r10   # zawiera długość najdłuższego ciągu zer
movq $0, %rdx
dec %rax        # usunięcie znaku nowej linii

call find_the_longest_string

print_output:
movq $0, %rdi
add $0x30, %r9
movq %r9, output_buffer(, %rdi, 1)
inc %rdi
movb $'\n', output_buffer(, %rdi, 1)
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $output_buffer, %rsi
movq $BUFLEN, %rdx
syscall
jmp program_exit

no_zeros_print_output:
movq $0, %rdi
movb $'-', output_buffer(, %rdi, 1)
inc %rdi
movb $'1', output_buffer(, %rdi, 1)
inc %rdi
movb $'\n', output_buffer(, %rdi, 1)
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $output_buffer, %rsi
movq $BUFLEN, %rdx
syscall

program_exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

find_the_longest_string:
movb (%rcx, %rdi, 1), %bl
cmp $ZERO_ASCII, %bl
je zero_found
jne zero_not_found

zero_found:
inc %rsi
movq %rcx, %r8
add %rdi, %r8   # r8 zawiera adres wystąpienia zera
cmp %r10, %rsi
jge change_the_longest_value
jmp iterate

change_the_longest_value:
movq %rsi, %r10
movq %r8, %r9
jmp iterate

zero_not_found:
movq $0, %rsi
movq $0, %r8

iterate:
inc %rdi
cmp %rax, %rdi
jl find_the_longest_string

sub %r10, %r9
inc %r9
sub %rcx, %r9

cmp $0, %r10
je no_zeros_print_output
ret
