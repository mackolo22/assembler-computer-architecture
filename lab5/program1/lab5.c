#include <stdio.h>

extern int check_rounding_mode();
extern int set_rounding_mode(int mode);

int main(void)
{
    printf("\nAktualnie ustawiony tryb zaokrąglania: ");
    switch(check_rounding_mode())
    {
        case 0: 
        {
            printf("W kierunku najbliższej liczby.\n");
            break;
        }
        case 1:
        {
            printf("W dół.\n");
            break;
        }
        case 2: 
        {
            printf("W górę.\n");
            break;
        }
        case 3: 
        {
            printf("W kierunku zera (obcięcie).\n");
            break;
        }
    }

    int mode;
    printf("\nWprowadź nowy tryb zaokrąglania\n");
    printf("0 - w kierunku najbliższej liczby\n");
    printf("1 - w dół\n");
    printf("2 - w górę\n");
    printf("3 - w kierunku zera (obcięcie)\n");
    printf("Twój wybór: ");
    scanf("%d", &mode);
    set_rounding_mode(mode);

    printf("\nZmieniono tryb zaokrąglania na: ");   
    switch(check_rounding_mode())
    {
        case 0: 
        {
            printf("w kierunku najbliższej liczby.\n");
            break;
        }
        case 1:
        {
            printf("w dół.\n");
            break;
        }
        case 2: 
        {
            printf("w górę.\n");
            break;
        }
        case 3: 
        {
            printf("w kierunku zera (obcięcie).\n");
            break;
        }
    }

    return 0;
}
