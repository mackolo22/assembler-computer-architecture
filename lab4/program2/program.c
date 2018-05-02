#include <stdio.h>

long number = 0;
char number_as_string[] = "";

int main(void)
{
    printf("Podaj liczbę: ");
    scanf("%ld", &number);

    asm(       
    "movq $0, %%rsi \n"
    "movq $8, %%rbx \n"
    "movq $0, %%r12 \n"
    "movq %0, %%rax \n"
    "convert_to_8: \n"
    "cmp $0, %%rax \n"
    "je pop_digits \n"
    "movq $0, %%rdx \n"
    "div %%rbx \n"
    "push %%rdx \n"
    "inc %%rsi \n"
    "jmp convert_to_8 \n"
    "pop_digits: \n"
    "cmp $0, %%rsi \n"
    "je done \n"
    "movq $0, %%rbx \n"
    "pop %%rbx \n"
    "add $0x30, %%bl \n"
    "movb %%bl, (%1, %%r12, 1) \n"
    "inc %%r12 \n"
    "dec %%rsi \n"
    "jmp pop_digits \n"
    "done: \n"
    :
    :"r"(number), "r"(number_as_string)
    :"%rax", "%rbx", "%rdx", "%rsi", "%r12"
    );

    printf("Liczba w zapisie ósemkowym: %s\n", number_as_string);

    return 0;
}
