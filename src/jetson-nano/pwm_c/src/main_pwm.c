/*
 * main_pwm.c - Same sweep as main.c, but built on the pwm.c library.
 *
 * Keeps a 20 ms period (50 Hz) and sweeps the duty cycle from 5 % to
 * 100 % and back, in 5 % steps every 0.5 s, then stops the signal.
 */

#include <stdio.h>
#include <unistd.h>
#include "../inc/pwm.h"

#define PERIOD_NS 20000000L  /* 20 ms = 50 Hz */
#define DUTY_MIN  5          /* % (1 ms) */
#define DUTY_MAX  100        /* % (20 ms) */
#define DUTY_STEP 5          /* % (1 ms) */

int main(void) {
    /* Forward: 5 % -> 100 % (apply_pwm exports pwm0 on the first call) */
    for (int duty = DUTY_MIN; duty <= DUTY_MAX; duty += DUTY_STEP) {
        if (apply_pwm(PERIOD_NS, duty) != 0) {
            stop_pwm();
            return 1;
        }
        printf("duty_cycle = %d %%\n", duty);
        usleep(500000);                 /* 0.5 s between steps */
    }

    /* Backward: 100 % -> 5 % */
    for (int duty = DUTY_MAX; duty >= DUTY_MIN; duty -= DUTY_STEP) {
        if (apply_pwm(PERIOD_NS, duty) != 0) {
            stop_pwm();
            return 1;
        }
        printf("duty_cycle = %d %%\n", duty);
        usleep(500000);
    }

    /* Stop the signal and unexport pwm0 */
    return stop_pwm() == 0 ? 0 : 1;
}
