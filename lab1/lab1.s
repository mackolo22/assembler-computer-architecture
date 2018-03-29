# Program wczytuje ze standardowego wejścia liczbę w reprezentacji U8
# i wypisuje na standardowe wyjście tę samą liczbę w reprezentacji U6

.data
STDIN = 0
STDOUT = 1
SYSWRITE = 1
SYSREAD = 0
SYSEXIT = 60
EXIT_SUCCESS = 0
BUFLEN = 512
ZERO_ASCII = 0x30	# kod ASCII cyfry 0
THREE_ASCII = 0x33      # kod ASCII cyfry 3
FIVE_ASCII = 0x35	# kod ASCII cyfry 5
EIGHT_ASCII = 0x38	# kod ASCII cyfry 8
INPUT_SYSTEM = 8	# niezbędne do obliczania potęg ósemki
OUTPUT_SYSTEM = 6	# niezbędne do konwersji na system szóstkowy
OPENING_BRACKET = 0x28	# kod ASCII '('
CLOSING_BRACKET = 0x29	# kod ASCII ')'
NEW_LINE = 0xA		# kod ASCII '\n'

error_message: .ascii "Niepoprawna liczba w zapisie U8!\n"
error_message_len = .-error_message

output_message: .ascii "Liczba w reprezentacji U6: "
output_message_len = .-output_message

.comm u8_input, BUFLEN
.comm u6_output, BUFLEN

.text
.global main

main:
# pobranie łańcucha znaków od użytkownika
movq $SYSREAD, %rax
movq $STDIN, %rdi
movq $u8_input, %rsi
movq $BUFLEN, %rdx
syscall

dec %rax	# usunięcie znaku nowej linii '\n'
movq $0, %rdi	# licznik pętli

# rozpoczęcie sprawdzania czy dany ciąg znaków jest
# liczbą w zapisie U8 -> zawiera tylko cyfry od 0 do 7
char_greater_equal_zero:
movb u8_input(, %rdi, 1), %bh
cmp $ZERO_ASCII, %bh
jl invalid_data
jge char_less_than_eight

char_less_than_eight:
cmp $EIGHT_ASCII, %bh
jge invalid_data
jl iterate

iterate:
inc %rdi
cmp %rax, %rdi
jl char_greater_equal_zero
jmp number_is_u8

# wyświetlenie komunikatu o wprowadzeniu niepoprawnych znaków
invalid_data:
movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $error_message, %rsi
movq $error_message_len, %rdx
syscall
jmp program_exit

number_is_u8:
movq $0, %rdi
movb u8_input(, %rdi, 1), %bh
# jeżeli liczba zaczyna się od 0, 1, 2 lub 3 to jest
# dodatnia, a jeżeli od 4, 5, 6 lub 7 to jest ujemna
cmp $THREE_ASCII, %bh
jle number_is_positive
jg number_is_negative

# cl przechowuje informację o tym czy dana
# liczba jest dodatnia '1', czy ujemna '0'
number_is_positive:
movb $1, %cl
jmp prepare_registries

number_is_negative:
movb $0, %cl
jmp prepare_registries

prepare_registries:
movq %rax, %rdi
sub $1, %rdi	# licznik pętli - od długości liczby do 0
mov $1, %rsi	# przechowuje wartość danej potęgi ósemki
mov $0, %r10	# przechowuje wartość liczby w systemie dziesiętnym

convert_to_decimal:
cmp $0, %rdi
jl convert_to_decimal_exit
movq $0, %rax
movb u8_input(, %rdi, 1), %al	# w al jest kod ASCII cyfry na danej pozycji
sub $ZERO_ASCII, %al		# w al jest wartość cyfry na danej pozycji
mul %rsi			# pomnożenie rax przez obecną potęgę ósemki
add %rax, %r10			# dopisanie tymczasowego wyniku do r10
movq %rsi, %rax
movq $INPUT_SYSTEM, %rbx
mul %rbx			# obliczenie kolejnej potęgi ósemki
movq %rax, %rsi			# rsi przechowuje kolejną potęgę ósemki
dec %rdi
jmp convert_to_decimal

convert_to_decimal_exit:
cmp $1, %cl
je prepare_to_convert_to_u6	# jeżeli liczba jest dodatnia
jne include_extension		# jeżeli liczba jest ujemna

# jeżeli liczba jest ujemna, to należy do niej dodać
# wartość: -1*8^n, gdzie n to pozycja rozszerzenia
include_extension:
movq %rsi, %rax	# rsi nadal przechowuje ostatnią obliczoną potęgę ósemki
movq $-1, %rbx
mul %rbx
add %rax, %r10	# dodanie -1*8^n do wyniku
movq %r10, %rax
# zamiana liczby ujemnej na dodatnią w celu uproszczenia
# obliczeń niezbędnych do konwersji na system szóstkowy
movq $-1, %rbx
mul %rbx
# przygotowanie rejestrów do dalszych operacji
movq %rax, %r10
movq $OUTPUT_SYSTEM, %rbx
movq $0, %rsi
jmp add_negative_extension

# przygotowanie rejestrów do dalszych operacji
prepare_to_convert_to_u6:
movq %r10, %rax
movq $OUTPUT_SYSTEM, %rbx	# rbx będzie służyć do dzielenia rax przez 6
movq $0, %rsi			# rsi wskazuje ile cyfr jest na stosie
jmp add_positive_extension

# dopisanie "(0)" do łańcucha wynikowego
add_positive_extension:
movq $0, %r12	# r12 to licznik zapisu do bufora wyjściowego
movb $OPENING_BRACKET, u6_output(, %r12, 1)
inc %r12
movb $ZERO_ASCII, u6_output(, %r12, 1)
inc %r12
movb $CLOSING_BRACKET, u6_output(, %r12, 1)
inc %r12
jmp convert_to_u6

# dopisanie "(5)" do łańcucha wynikowego
add_negative_extension:
movq $0, %r12 # r12 to licznik zapisu do bufora wyjściowego
movb $OPENING_BRACKET, u6_output(, %r12, 1)
inc %r12
movb $FIVE_ASCII, u6_output(, %r12, 1)
inc %r12
movb $CLOSING_BRACKET, u6_output(, %r12, 1)
inc %r12
jmp convert_to_u6

convert_to_u6:
cmp $0, %rax
je pop_digits	# rax == 0 oznacza koniec konwersji
movq $0, %rdx
div %rbx	# wynik dzielenia trafia do rax, a reszta do rdx
push %rdx	# reszta z dzielenia trafia na stos
inc %rsi	# zwiększenie ilości cyfr na stosie
jmp convert_to_u6

pop_digits:
cmp $0, %rsi
je check_correction
movq $0, %rbx
pop %rbx	# zdjęcie cyfry wyniku ze stosu
call generate_output
dec %rsi
jmp pop_digits

generate_output:
cmp $1, %cl
je output_positive_number
jne output_negative_number

# rbx zawiera cyfrę na danej pozycji, więc należy do
# niej dodać kod ASCII zera, aby otrzymać cyfrę w ASCII
output_positive_number:
add $0x30, %bl
movb %bl, u6_output(, %r12, 1)
inc %r12
ret

# obliczona liczba (X)  w reprezentacji U6 jest dodatnia,
# należy więc obliczyć jej uzupełnienie, poprzez pozycyjne
# odjęcie X od liczby: (5)6, np:
#
#	   (5)55556
#	 - (0)13051  <- X
#  	 ----------
#	 = (5)42505
#
# w tym momencie następuje jednak de facto odjęcie X
# od liczby (5)5, a dopiero w dalszej części programu
# zostanie dodana korekta (+1) na najniższej pozycji
output_negative_number:
movb $5, %ch
sub %bl, %ch
movb %ch, %bl
# dodanie kodu zera, aby otrzymać kod ASCII cyfry
add $0x30, %bl
movb %bl, u6_output(, %r12, 1)
inc %r12
ret

check_correction:
cmp $1, %cl
jne include_correction	# jeżeli liczba jest ujemna to należy dodać korektę

print_output:
movb $NEW_LINE, u6_output(, %r12, 1)	# dopisanie znaku nowej linii

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $output_message, %rsi
movq $output_message_len, %rdx
syscall

movq $SYSWRITE, %rax
movq $STDOUT, %rdi
movq $u6_output, %rsi
movq $BUFLEN, %rdx
syscall

jmp program_exit

include_correction:
dec %r12	# powrót do najmniej znaczącej pozycji liczby
movb u6_output(, %r12, 1), %bl
add $1, %bl	# dodanie korekty (+1) do najniższej pozycji
movb %bl, u6_output(, %r12, 1)
inc %r12
jmp print_output

# zakończenie programu
program_exit:
movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall
