FLAGS = -Wall -Wextra -pedantic -g

.PHONY: all main pinmux pwm control clean

all: main

pinmux: src/pinmux.c
	gcc $(FLAGS) src/pinmux.c -o pinmux

pwm: src/pwm.c inc/pwm.h
	gcc $(FLAGS) -c src/pwm.c -o pwm.o

control: src/control.c pwm
	gcc $(FLAGS) src/control.c pwm.o -o ../website/cgi-bin/control.cgi

main: src/main.c
	gcc $(FLAGS) src/main.c -o main

clean: 
	rm -f *.o main ../website/cgi-bin/control.cgi
