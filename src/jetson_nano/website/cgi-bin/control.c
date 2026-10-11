#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>

static int parse_integer(const char *text, int *result)
{
    char *end;
    long value;

    if (*text == '\0')
        return 0;

    /* Ici, on accepte uniquement des chiffres. */
    for (const char *p = text; *p; ++p) {
        if (*p < '0' || *p > '9')
            return 0;
    }

    errno = 0;
    value = strtol(text, &end, 10);

    if (errno != 0 || *end != '\0' || value > INT_MAX)
        return 0;

    *result = (int)value;
    return 1;
}

static int bad_request(void)
{
    printf("Status: 400 Bad Request\r\n");
    printf("Content-Type: text/plain; charset=utf-8\r\n");
    printf("Cache-Control: no-store\r\n\r\n");
    printf("Parametres invalides.\n");
    printf("Exemple : ?period=5&duty_cycle=50\n");
    return 0;
}

int main(void)
{
    const char *query = getenv("QUERY_STRING");
    char buffer[256];

    int period = 0;
    int duty_cycle = 0;
    int has_period = 0;
    int has_duty_cycle = 0;

    if (query == NULL || *query == '\0' ||
        strlen(query) >= sizeof(buffer))
        return bad_request();

    strcpy(buffer, query);

    char *pair = buffer;

    while (pair != NULL) {
        char *next = strchr(pair, '&');

        if (next != NULL)
            *next++ = '\0';

        char *equals = strchr(pair, '=');

        if (equals == NULL)
            return bad_request();

        *equals = '\0';
        const char *value = equals + 1;

        if (strcmp(pair, "period") == 0) {
            if (has_period || !parse_integer(value, &period))
                return bad_request();

            has_period = 1;
        } else if (strcmp(pair, "duty_cycle") == 0) {
            if (has_duty_cycle ||
                !parse_integer(value, &duty_cycle))
                return bad_request();

            has_duty_cycle = 1;
        } else {
            return bad_request();
        }

        pair = next;
    }

    if (!has_period || !has_duty_cycle ||
        period <= 0 || duty_cycle > 100)
        return bad_request();

    /*
     * Ton traitement C ici, par exemple :
     *
     * appliquer_configuration(period, duty_cycle);
     */

    printf("Content-Type: text/plain; charset=utf-8\r\n");
    printf("Cache-Control: no-store\r\n\r\n");
    printf("Parametres recus :\n");
    printf("period = %d\n", period);
    printf("duty_cycle = %d %%\n", duty_cycle);

    return 0;
}