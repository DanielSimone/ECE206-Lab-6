#include <stdio.h>

int multiply(int x)
{
    int product = 0;
    int i;

    for (i = 0; i < 2; i++)
        product += x;

    return product;
}

int power(int exponent)
{
    int result = 1;
    int i;

    for (i = 0; i < exponent; i++)
        result = multiply(result);

    return result;
}

int main() {
    int maxNumber = 12;
    int maxPossible = 1;
    int exponent;

    for(exponent = 1; maxPossible < maxNumber; exponent++)
    {
        maxPossible = power(exponent) - 1;
    }

    exponent -= 1;

    printf("The number of bits needed is: %d\n", exponent);
    printf("The maximum number in decimal is: %d\n", maxPossible);
}
