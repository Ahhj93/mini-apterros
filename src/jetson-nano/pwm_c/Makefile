FLAGS = -Wall -Wextra -pedantic -g
PWMCHIP = /sys/class/pwm/pwmchip0

.PHONY: all main main_pwm pinmux pwm control control_server pwm_permissions clean

all: main

pinmux: src/pinmux.c
	gcc $(FLAGS) src/pinmux.c -o pinmux

pwm: src/pwm.c inc/pwm.h
	gcc $(FLAGS) -c src/pwm.c -o pwm.o

control: src/control.c pwm
	gcc $(FLAGS) src/control.c pwm.o -o ../website/cgi-bin/control.cgi

# Export pwm0 as root and let Apache (www-data) write to it.
# Lost after a reboot or an unexport: run it again in that case.
pwm_permissions:
	[ -d $(PWMCHIP)/pwm0 ] || sudo sh -c 'echo 0 > $(PWMCHIP)/export'
	sudo chgrp www-data $(PWMCHIP)/pwm0/period $(PWMCHIP)/pwm0/duty_cycle $(PWMCHIP)/pwm0/enable
	sudo chmod g+w $(PWMCHIP)/pwm0/period $(PWMCHIP)/pwm0/duty_cycle $(PWMCHIP)/pwm0/enable

control_server: control pwm_permissions
	sudo cp ../website/cgi-bin/control.cgi /usr/lib/cgi-bin/control.cgi
	sudo chmod 755 /usr/lib/cgi-bin/control.cgi
	sudo cp ../website/html/index.html /var/www/html/index.html
	sudo chmod 644 /var/www/html/index.html

main: src/main.c
	gcc $(FLAGS) src/main.c -o main

main_pwm: src/main_pwm.c pwm
	gcc $(FLAGS) src/main_pwm.c pwm.o -o main_pwm

clean: 
	rm -f *.o main main_pwm ../website/cgi-bin/control.cgi
