FLAGS = -Wall -Wextra -pedantic -g

.PHONY: all main pinmux pwm control control_server clean

all: main

pinmux: src/pinmux.c
	gcc $(FLAGS) src/pinmux.c -o pinmux

pwm: src/pwm.c inc/pwm.h
	gcc $(FLAGS) -c src/pwm.c -o pwm.o

control: src/control.c pwm
	gcc $(FLAGS) src/control.c pwm.o -o ../website/cgi-bin/control.cgi

control_server: control
	sudo cp ../website/cgi-bin/control.cgi /usr/lib/cgi-bin/control.cgi
	sudo chmod 755 /usr/lib/cgi-bin/control.cgi
	sudo cp ../website/html/index.html /var/www/html/index.html
	sudo chmod 644 /var/www/html/index.html

main: src/main.c
	gcc $(FLAGS) src/main.c -o main

clean: 
	rm -f *.o main ../website/cgi-bin/control.cgi
