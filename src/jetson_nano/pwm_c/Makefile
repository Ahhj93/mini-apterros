FLAGS = -Wall -Wextra -pedantic -g

.PHONY: all main pinmux clean

all: main

pinmux: src/pinmux.c
	gcc $(FLAGS) src/pinmux.c -o pinmux

main: src/main.c
	gcc $(FLAGS) src/main.c -o main

clean: 
	rm -f *.o main
