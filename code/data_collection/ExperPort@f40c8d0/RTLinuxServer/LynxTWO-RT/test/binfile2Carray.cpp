
#include <fstream>
#include <iostream>
#include <unistd.h>
#include <cstdio>

int main(int argc, char **argv)
{
	const char *array_name = "stdin_array";
	if (argc == 2) {
		array_name = argv[1];
	}
	std::clog << "Using array name: " << array_name << std::endl;
		

	std::cout << "static const char " << array_name << "[] = {";
	int i = 0;	
	while (std::cin) {
		int c;
		char buf[16];

		if (!(i++ % 10)) std::cout << "\n\t"; // make sure we have 10 per line
		c = std::cin.get();
		if (std::cin.good()) {
			int n = std::snprintf(buf, sizeof(buf), "0x%02x%s", c, std::cin.peek() != std::ifstream::traits_type::eof() ? ", " : " ");
			std::cout.write(buf, n);
		}
	}
	std::cout << "\n};\n";
	return 0;
}

