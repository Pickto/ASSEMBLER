#include <iostream>



extern "C" void ZIP(char* BUF, int SIZE);


void main()
{
	char INPUT[200];
	std::cin >> INPUT;
	ZIP(INPUT, std::strlen(INPUT));
	std::cout << INPUT;
}

