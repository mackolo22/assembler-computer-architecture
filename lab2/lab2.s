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
.comm input_buffer1, BUFLEN
.comm input_buffer2, BUFLEN
.comm four_bytes, BUFLEN
.comm little_endian1, BUFLEN
.comm little_endian2, BUFLEN
.comm result_buffer, BUFLEN
.comm hexa_buffer, BUFLEN

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
movq $BUFLEN, %rdx
syscall

dec %rax
dec %rax
movq %rax, %rbx		# zapisanie liczby odczytanych bajtów

# zamknięcie pierwszego pliku
movq $SYSCLOSE, %rax
movq %r11,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

# otwarcie drugiego pliku tylko do odczytu
movq $SYSOPEN, %rax
movq $input_file2, %rdi
movq $READ_FILE, %rsi
movq $0, %rdx
syscall

movq %rax, %r12     # zapisanie identyfikatora pliku

movq $SYSREAD, %rax
movq %r12, %rdi
movq $input_buffer2, %rsi
movq $BUFLEN, %rdx
syscall

dec %rax
dec %rax
movq %rax, %r10     # zapisanie liczby odczytanych bajtów

# zamknięcie drugiego pliku
movq $SYSCLOSE, %rax
movq %r12,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

movq $0, %rdx
movq $0, %rcx
movq $0, %rsi

read_four_bytes1:
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

movb %dh, little_endian1(, %rsi, 1)
inc %rsi

cmp $0, %rbx
jg read_four_bytes1

movq %r10, %rbx
movq $0, %rdx
movq $0, %rcx
movq $0, %rsi

read_four_bytes2:
movb input_buffer2(, %rbx, 1), %cl
sub $0x30, %cl
dec %rbx

movb input_buffer2(, %rbx, 1), %ch
sub $0x30, %ch
dec %rbx

movb input_buffer2(, %rbx, 1), %dl
sub $0x30, %dl
dec %rbx

movb input_buffer2(, %rbx, 1), %dh
sub $0x30, %dh
dec %rbx

shl $2, %ch
shl $4, %dl
shl $6, %dh

or %cl, %ch
or %ch, %dl
or %dl, %dh

movb %dh, little_endian2(, %rsi, 1)
inc %rsi

cmp $0, %rbx
jg read_four_bytes2

clc
pushfq
movq $0, %rdi

add_two_numbers:
movb little_endian1(, %rdi, 1), %al
movb little_endian2(, %rdi, 1), %bl
popfq

adc %al, %bl
pushfq
movb %bl, result_buffer(, %rdi, 1)
inc %rdi
cmp $BUFLEN, %rdi
jle add_two_numbers

movq $0, %r8
movq $0, %r9

hexa:
movb result_buffer(, %r8, 1), %al
movb %al, %bl
movb %al, %cl
shr $4, %cl
and $0b1111, %bl
and $0b1111, %cl
add $'0', %bl
add $'0', %cl

cmp $'9', %bl
jle continue
add $7, %bl

continue:
cmp $'9', %cl
jle continue2
add $7, %cl

continue2:
movb %bl, hexa_buffer(, %r9, 1)
inc %r9
movb %cl, hexa_buffer(, %r9, 1)
inc %r9

inc %r8
cmp $256, %r8
jle hexa

save_output_file:
movq $SYSOPEN, %rax
movq $output_file, %rdi
movq $WRITE_FILE, %rsi
movq $0644, %rdx
syscall

movq %rax, %r10
movq $SYSWRITE, %rax
movq %r10, %rdi
movq $hexa_buffer, %rsi
movq $BUFLEN, %rdx
syscall

movq $SYSCLOSE, %rax
movq %r10,  %rdi
movq $0, %rsi
movq $0, %rdx
syscall

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $hexa_buffer, %rsi
movq $BUFLEN, %rdx
syscall

program_exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
