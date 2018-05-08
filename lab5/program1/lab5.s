.data
fpu_control_word: .short

.text
.global check_rounding_mode, set_rounding_mode
.type check_rounding_mode, @function
.type set_rounding_mode, @function

# RAX zawiera wartość zwracaną
check_rounding_mode:
movq $0, %rax
fstcw fpu_control_word  # zapisanie ustawień jednostki FPU do pamięci
movw fpu_control_word, %ax

# 10 i 11 bit słowa kontrolnego FPU określają tryb zaokrąglania:
# 0 - w kierunku najbliższej liczby
# 1 - w dół
# 2 - w górę
# 3 - w kierunku 0 (obcięcie)
and $3072, %ax  # 0000 1100 0000 0000
shr $10, %ax
ret

# RDI zawiera parametr funkcji - int mode
set_rounding_mode:
movq $0, %rax
fstcw fpu_control_word
movw fpu_control_word, %ax
and $62463, %ax # 1111 0011 1111 1111
shl $10, %rdi
xor %di, %ax
movw %ax, fpu_control_word
fldcw fpu_control_word
ret
