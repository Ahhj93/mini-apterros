/*
 * sensors.c - CGI script returning the current sensor readings as JSON.
 *
 * Polled by the web page to display the sensors in real time.
 * Example call: /cgi-bin/sensors.cgi
 * Example answer: {"lidar":{"ok":true,"distance_cm":123}}
 */

#include <stdio.h>
#include "../inc/lidar.h"

int main(void)
{
    int distance_cm;

    /* Always answer 200: a failing sensor is reported in the JSON,
     * so that the other sensors can still be displayed. */
    printf("Content-Type: application/json\r\n");
    printf("Cache-Control: no-store\r\n\r\n");

    if (lidar_read_distance(&distance_cm) == 0)
        printf("{\"lidar\":{\"ok\":true,\"distance_cm\":%d}}\n", distance_cm);
    else
        printf("{\"lidar\":{\"ok\":false,\"distance_cm\":null}}\n");

    return 0;
}
