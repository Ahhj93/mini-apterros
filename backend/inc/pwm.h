#ifndef PWM_H
#define PWM_H

#define PWM_DUTY_CYCLE "/sys/class/pwm/pwmchip0/pwm0/duty_cycle"
#define PWM_PERIOD "/sys/class/pwm/pwmchip0/pwm0/period"
#define PWM_ENABLE "/sys/class/pwm/pwmchip0/pwm0/enable"
#define PWM_CHIP_EXPORT "/sys/class/pwm/pwmchip0/export"
#define PWM_CHIP_UNEXPORT "/sys/class/pwm/pwmchip0/unexport"

/* Apply a PWM signal: period in ns, duty cycle in percent (0 to 100).
 * Returns 0 on success, -1 on error. */
int apply_pwm(long period_ns, double duty_percent);

/* Stop the PWM signal and unexport pwm0.
 * Returns 0 on success, -1 on error. */
int stop_pwm(void);

#endif
