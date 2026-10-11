#include <errno.h>
#include <limits.h>
#include <netinet/in.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include "../inc/pwm_c.h"

#define API_PORT 8080
#define REQUEST_SIZE 4096

static int write_value(const char *path, long value) {
    char buf[32];
    int length = snprintf(buf, sizeof buf, "%ld", value);
    if (length < 0 || (size_t)length >= sizeof buf) {
        return -1;
    }

    FILE *file = fopen(path, "w");
    if (file == NULL) {
        perror(path);
        return -1;
    }
    if (fwrite(buf, 1, (size_t)length, file) != (size_t)length ||
        fclose(file) != 0) {
        perror(path);
        return -1;
    }
    return 0;
}

static int json_number(const char *json, const char *name, long *value) {
    char key[64];
    const char *cursor;
    char *end;

    if (snprintf(key, sizeof key, "\"%s\"", name) >= (int)sizeof key) {
        return -1;
    }
    cursor = strstr(json, key);
    if (cursor == NULL) {
        return -1;
    }
    cursor = strchr(cursor + strlen(key), ':');
    if (cursor == NULL) {
        return -1;
    }

    errno = 0;
    *value = strtol(cursor + 1, &end, 10);
    if (errno == ERANGE || end == cursor + 1 || *value < 0) {
        return -1;
    }
    return 0;
}

static int apply_pwm(long duty_cycle, long period) {
    if (period <= 0 || duty_cycle > period) {
        return -1;
    }

    /* The period cannot be reduced below the current duty cycle. */
    if (write_value(PWM_ENABLE, 0) != 0 ||
        write_value(PWM_PERIOD, period) != 0 ||
        write_value(PWM_DUTY_CYCLE, duty_cycle) != 0 ||
        write_value(PWM_ENABLE, 1) != 0) {
        return -1;
    }
    printf("duty_cycle = %ld ns, period = %ld ns\n", duty_cycle, period);
    return 0;
}

static void send_response(int client, int status, const char *body) {
    const char *reason = status == 200 ? "OK" :
                         status == 400 ? "Bad Request" : "Not Found";
    char response[512];
    int length = snprintf(
        response, sizeof response,
        "HTTP/1.1 %d %s\r\n"
        "Content-Type: application/json\r\n"
        "Access-Control-Allow-Origin: *\r\n"
        "Access-Control-Allow-Methods: POST, OPTIONS\r\n"
        "Access-Control-Allow-Headers: Content-Type\r\n"
        "Connection: close\r\n"
        "Content-Length: %zu\r\n\r\n%s",
        status, reason, strlen(body), body);
    if (length > 0) {
        (void)send(client, response, (size_t)length, 0);
    }
}

static void handle_request(int client) {
    char request[REQUEST_SIZE];
    ssize_t received = recv(client, request, sizeof request - 1, 0);
    if (received <= 0) {
        return;
    }
    request[received] = '\0';

    if (strncmp(request, "OPTIONS /api/pwm ", 17) == 0) {
        send_response(client, 200, "{\"ok\":true}");
        return;
    }
    if (strncmp(request, "POST /api/pwm ", 14) != 0) {
        send_response(client, 404, "{\"error\":\"route not found\"}");
        return;
    }

    const char *body = strstr(request, "\r\n\r\n");
    long duty_cycle;
    long period;
    if (body == NULL ||
        json_number(body + 4, "duty_cycle", &duty_cycle) != 0 ||
        json_number(body + 4, "period", &period) != 0 ||
        apply_pwm(duty_cycle, period) != 0) {
        send_response(client, 400,
                      "{\"error\":\"invalid PWM values\"}");
        return;
    }
    send_response(client, 200, "{\"ok\":true}");
}

int main(void) {
    int server;
    struct sockaddr_in address;

    if (write_value(PWM_CHIP_EXPORT, 0) != 0) {
        return EXIT_FAILURE;
    }
    sleep(1);
    if (apply_pwm(1000000, 20000000) != 0) {
        return EXIT_FAILURE;
    }

    server = socket(AF_INET, SOCK_STREAM, 0);
    if (server < 0) {
        perror("socket");
        return EXIT_FAILURE;
    }

    int reuse = 1;
    (void)setsockopt(server, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof reuse);
    memset(&address, 0, sizeof address);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = htonl(INADDR_ANY);
    address.sin_port = htons(API_PORT);
    if (bind(server, (struct sockaddr *)&address, sizeof address) != 0 ||
        listen(server, 8) != 0) {
        perror("bind/listen");
        close(server);
        return EXIT_FAILURE;
    }

    printf("PWM API listening on http://0.0.0.0:%d\n", API_PORT);
    for (;;) {
        int client = accept(server, NULL, NULL);
        if (client < 0) {
            perror("accept");
            continue;
        }
        handle_request(client);
        close(client);
    }
}
