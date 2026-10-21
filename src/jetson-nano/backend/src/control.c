/*
 * control.c - CGI script used to drive the PWM output.
 *
 * Reads the "period" (in ms) and "duty_cycle" (in %) parameters from the
 * HTTP query string, validates them, then applies the PWM configuration.
 * Example call: /cgi-bin/control.cgi?period=5&duty_cycle=50
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
#include "../inc/pwm.h"

/*
 * Converts a string to a non-negative integer.
 * Returns 1 on success (value stored in *result), 0 otherwise.
 */
static int parse_integer(const char *text, int *result)
{
    char *end;
    long value;

    /* Empty values are rejected. */
    if (*text == '\0')
        return 0;

    /* Only digits are accepted (no sign, no whitespace). */
    for (const char *p = text; *p; ++p) {
        if (*p < '0' || *p > '9')
            return 0;
    }

    errno = 0;
    value = strtol(text, &end, 10);

    /* Reject on overflow or trailing characters. */
    if (errno != 0 || *end != '\0' || value > INT_MAX)
        return 0;

    *result = (int)value;
    return 1;
}

/*
 * Sends an HTTP 400 response reporting invalid parameters.
 * Returns 0 so it can be used directly in a "return" from main.
 */
static int bad_request(void)
{
    printf("Status: 400 Bad Request\r\n");
    printf("Content-Type: text/plain; charset=utf-8\r\n");
    printf("Cache-Control: no-store\r\n\r\n");
    printf("Invalid Parameters.\n");
    printf("Example : ?period=5&duty_cycle=50\n");
    return 0;
}

int main(void)
{
    /* The web server passes the URL parameters through QUERY_STRING. */
    const char *query = getenv("QUERY_STRING");
    char buffer[256];

    int period = 0;
    int duty_cycle = 0;
    int has_period = 0;
    int has_duty_cycle = 0;

    /* Query string missing, empty or too long for the buffer. */
    if (query == NULL || *query == '\0' ||
        strlen(query) >= sizeof(buffer))
        return bad_request();

    /* Writable local copy, since parsing writes '\0' into it. */
    strcpy(buffer, query);

    char *pair = buffer;

    /* Walk through each "key=value" pair separated by '&'. */
    while (pair != NULL) {
        char *next = strchr(pair, '&');

        /* Terminate the current pair and move to the next one. */
        if (next != NULL)
            *next++ = '\0';

        char *equals = strchr(pair, '=');

        /* A pair without '=' is invalid. */
        if (equals == NULL)
            return bad_request();

        /* Split the key (pair) from the value (value). */
        *equals = '\0';
        const char *value = equals + 1;

        if (strcmp(pair, "period") == 0) {
            /* Reject duplicated parameters or non-numeric values. */
            if (has_period || !parse_integer(value, &period))
                return bad_request();

            has_period = 1;
        } else if (strcmp(pair, "duty_cycle") == 0) {
            if (has_duty_cycle ||
                !parse_integer(value, &duty_cycle))
                return bad_request();

            has_duty_cycle = 1;
        } else {
            /* Unknown parameter. */
            return bad_request();
        }

        pair = next;
    }

    /*
     * Both parameters are required, the period must be strictly
     * positive and the duty cycle must be between 0 and 100 %.
     */
    if (!has_period || !has_duty_cycle ||
        period <= 0 || duty_cycle > 100)
        return bad_request();

    /* period is given in ms, apply_pwm expects ns. */
    if (apply_pwm(period * 1000000L, duty_cycle) != 0) {
        printf("Status: 500 Internal Server Error\r\n");
        printf("Content-Type: text/plain; charset=utf-8\r\n");
        printf("Cache-Control: no-store\r\n\r\n");
        printf("Failed to apply the PWM configuration.\n");
        return 0;
    }

    /* Success: implicit 200 response echoing the applied parameters. */
    printf("Content-Type: text/plain; charset=utf-8\r\n");
    printf("Cache-Control: no-store\r\n\r\n");
    printf("Received parameters :\n");
    printf("period = %d\n", period);
    printf("duty_cycle = %d %%\n", duty_cycle);

    return 0;
}
