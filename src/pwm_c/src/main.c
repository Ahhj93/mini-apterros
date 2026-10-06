#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "../inc/pwm_c.h"

/* Write a number into a sysfs file (returns 0 on success, -1 on error) */
static int write_value(const char *path, long value) {
    char buf[32];
    snprintf(buf, sizeof buf, "%ld", value);

    FILE *f = fopen(path, "w");
    if (f == NULL) {
        perror(path);              /* prints the real error, e.g. Permission denied */
        return -1;
    }
    fwrite(buf, 1, strlen(buf), f);
    if (fclose(f) != 0) {          /* the value is really sent to the kernel here */
        perror(path);
        return -1;
    }
    return 0;
}

int main(int argc, char **argv) {
    write_value(PWM_CHIP_EXPORT, 0);    /* creates the pwm0 folder */
    sleep(1);                           /* wait for the kernel to create it */

    write_value(PWM_PERIOD, 20000000);  /* 20 ms = 50 Hz (period first) */
    write_value(PWM_DUTY_CYCLE, 1000000);
    write_value(PWM_ENABLE, 1);         /* start the signal */

    /* Forward: 1 ms -> 2 ms */
    for (int duty = 1000000; duty <= 20000000; duty += 1000000) {
        write_value(PWM_DUTY_CYCLE, duty);
        printf("duty_cycle = %d ns\n", duty);
        usleep(500000);                 /* 0.5 s between steps */
    }

    /* Backward: 2 ms -> 1 ms */
    for (int duty = 20000000; duty >= 1000000; duty -= 1000000) {
        write_value(PWM_DUTY_CYCLE, duty);
        printf("duty_cycle = %d ns\n", duty);
        usleep(500000);
    }

    write_value(PWM_ENABLE, 0);         /* stop the signal */
    write_value(PWM_CHIP_UNEXPORT, 0);
    return 0;
}
