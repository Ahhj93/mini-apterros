#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "../inc/pwm.h"

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

/* Read a number from a sysfs file (returns 0 on success, -1 on error) */
static int read_value(const char *path, long *value) {
    FILE *f = fopen(path, "r");
    if (f == NULL) {
        perror(path);
        return -1;
    }
    int ok = fscanf(f, "%ld", value) == 1;
    fclose(f);
    return ok ? 0 : -1;
}

/* Apply a PWM signal: period in ns, duty cycle in percent (0 to 100).
 * Returns 0 on success, -1 on error. */
int apply_pwm(long period_ns, double duty_percent) {
    if (period_ns <= 0 || duty_percent < 0.0 || duty_percent > 100.0) {
        fprintf(stderr, "apply_pwm: invalid period (%ld ns) or duty (%.2f %%)\n",
                period_ns, duty_percent);
        return -1;
    }

    long duty_ns = (long)(period_ns * duty_percent / 100.0);

    /* Export pwm0 only if its folder does not exist yet */
    if (access(PWM_PERIOD, F_OK) != 0) {
        if (write_value(PWM_CHIP_EXPORT, 0) != 0)
            return -1;
        sleep(1);                       /* wait for the kernel to create it */
    }

    /* The kernel refuses duty_cycle > period, so the write order depends
     * on whether the new period is shorter than the current duty cycle */
    long current_duty = 0;
    read_value(PWM_DUTY_CYCLE, &current_duty);

    if (period_ns < current_duty) {
        if (write_value(PWM_DUTY_CYCLE, duty_ns) != 0) return -1;
        if (write_value(PWM_PERIOD, period_ns) != 0) return -1;
    } else {
        if (write_value(PWM_PERIOD, period_ns) != 0) return -1;
        if (write_value(PWM_DUTY_CYCLE, duty_ns) != 0) return -1;
    }

    return write_value(PWM_ENABLE, 1);  /* start the signal */
}
