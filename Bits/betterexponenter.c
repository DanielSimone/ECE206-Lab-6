#include <stdio.h>

int main()
{
    int maxNumber = 245; //Change this number
    int maxPossible = 1;
    int temp1 = 0;
    int temp2 = 0;
    int exponent = 0;

    loop1:
    temp2 = temp1 - maxNumber;
    if(temp2 >= 0) goto endloop1; //if temp2 is zero or positive, branch to endloop1
        maxPossible += maxPossible;
        temp1 = maxPossible - 1;
        exponent++;
        goto loop1;
    endloop1:

    printf("The number of bits needed is: %d\n", exponent);
    printf("The maximum number in decimal is: %d\n", temp1);
}