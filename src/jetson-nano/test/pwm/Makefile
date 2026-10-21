FLAGS = -Wall -Wextra -pedantic -g
BACKEND = ../../backend

.PHONY: all main main_pwm test clean

all: main main_pwm test

main: src/main.c inc/pwm_c.h
	gcc $(FLAGS) src/main.c -o main

# Built on the PWM library of the backend.
main_pwm: src/main_pwm.c $(BACKEND)/src/pwm.c $(BACKEND)/inc/pwm.h
	gcc $(FLAGS) -I$(BACKEND)/inc src/main_pwm.c $(BACKEND)/src/pwm.c -o main_pwm

test: src/test.c inc/pwm_c.h
	gcc $(FLAGS) src/test.c -o test

clean:
	rm -f main main_pwm test
