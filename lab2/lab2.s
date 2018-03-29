.data
STDOUT = 1
SYSWRITE = 1
SYSREAD = 0
SYSEXIT = 60
SYSOPEN = 2
SYSCLOSE = 3
READ_FILE = 0
WRITE_FILE = 1
EXIT_SUCCESS = 0
BUFLEN = 512
ZERO_ASCII = 0x30	# kod ASCII cyfry 0
NEW_LINE = 0xA		# kod ASCII '\n'

input_file1: .ascii "input1.txt\0"
input_file2: .ascii "input2.txt\0"
output_file: .ascii "output.txt\0"

.bss
.comm input_buffer1, 1024
.comm input_buffer2, 1024
.comm four_bytes, 1024
.comm little_endian, 1024
.comm output_buffer, 1024

.text
.global main

main:

# otwarcie pierwszego pliku tylko do odczytu
movq $SYSOPEN, %rax
movq $input_file1, %rdi
movq $READ_FILE, %rsi
movq $0, %rdx
syscall

movq %rax, %r11		# zapisanie identyfikatora pliku

# odczyt z pierwszego pliku
movq $SYSREAD, %rax
movq %r11, %rdi
movq $input_buffer1, %rsi
movq $1024, %rdx
syscall

dec %rax
dec %rax
movq %rax, %rbx		# zapisanie liczby odczytanych bajtów

movq $SYSCLOSE, %rax
movq %r11,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

movq $SYSOPEN, %rax
movq $input_file2, %rdi
movq $READ_FILE, %rsi
movq $0, %rdx
syscall

movq %rax, %r12

movq $SYSREAD, %rax
movq %r12, %rdi
movq $input_buffer2, %rsi
movq $1024, %rdx
syscall

dec %rax
dec %rax
movq %rax, %r10

movq $SYSCLOSE, %rax
movq %r12,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

movq $0, %rdx
movq $0, %rcx
movq $0, %r9
movq $0, %rsi

read_four_bytes:
cmp $4, %r8
movb input_buffer1(, %rbx, 1), %cl
sub $0x30, %cl
dec %rbx

movb input_buffer1(, %rbx, 1), %ch
sub $0x30, %ch
dec %rbx

movb input_buffer1(, %rbx, 1), %dl
sub $0x30, %dl
dec %rbx

movb input_buffer1(, %rbx, 1), %dh
sub $0x30, %dh
dec %rbx

shl $2, %ch
shl $4, %dl
shl $6, %dh

or %cl, %ch
or %ch, %dl
or %dl, %dh

movq $SYSOPEN, %rax
movq $output_file, %rdi
movq $WRITE_FILE, %rsi
movq $0644, %rdx
syscall

movq %rax, %r10
movq $SYSWRITE, %rax
movq %r10, %rdi
movq $input_buffer1, %rsi
movq $1024, %rdx
syscall

movq $SYSCLOSE, %rax
movq %r10,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

program_exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
