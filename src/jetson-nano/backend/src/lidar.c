/*
 * lidar.c - Reads the distance from the LIDAR-Lite v3 over I2C.
 *
 * Starts a measurement, waits for the busy bit to clear, then reads
 * the 16-bit distance (in cm) from the device registers.
 */

#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/file.h>
#include <linux/i2c-dev.h>
#include "../inc/lidar.h"

#define REG_ACQ_COMMAND 0x00
#define REG_STATUS 0x01
/* Distance high byte (0x0f) with the auto-increment bit (0x80) set. */
#define REG_DISTANCE 0x8f

#define CMD_MEASURE 0x04 /* Measurement with receiver bias correction. */
#define STATUS_BUSY 0x01
#define BUSY_POLL_MAX 1000

/*
 * Writes one byte into a device register.
 * Returns 0 on success, -1 on error.
 */
static int write_register(int fd, unsigned char reg, unsigned char value)
{
    unsigned char buf[2] = { reg, value };

    if (write(fd, buf, sizeof buf) != (ssize_t)sizeof buf) {
        perror("lidar: write_register");
        return -1;
    }
    return 0;
}

/*
 * Reads len bytes starting at a device register.
 * The write and the read are separate transfers (stop in between),
 * as the LIDAR-Lite v3 does not support repeated starts.
 * Returns 0 on success, -1 on error.
 */
static int read_registers(int fd, unsigned char reg, unsigned char *data,
                          size_t len)
{
    if (write(fd, &reg, 1) != 1 || read(fd, data, len) != (ssize_t)len) {
        perror("lidar: read_registers");
        return -1;
    }
    return 0;
}

/*
 * Takes one distance measurement.
 * distance_cm: receives the distance in centimeters.
 * Returns 0 on success, -1 on error.
 */
int lidar_read_distance(int *distance_cm)
{
    unsigned char status = STATUS_BUSY;
    unsigned char data[2];
    int polls;
    int ret = -1;

    int fd = open(LIDAR_I2C_BUS, O_RDWR);
    if (fd < 0) {
        /* Prints the real error, e.g. "Permission denied". */
        perror(LIDAR_I2C_BUS);
        return -1;
    }

    /* Several CGI processes may run at once: one measurement at a time. */
    if (flock(fd, LOCK_EX) != 0) {
        perror("lidar: flock");
        goto out;
    }

    if (ioctl(fd, I2C_SLAVE, LIDAR_ADDR) < 0) {
        perror("lidar: I2C_SLAVE");
        goto out;
    }

    if (write_register(fd, REG_ACQ_COMMAND, CMD_MEASURE) != 0)
        goto out;

    /* Wait for the end of the measurement, without hanging forever. */
    for (polls = 0; polls < BUSY_POLL_MAX && (status & STATUS_BUSY); ++polls) {
        if (read_registers(fd, REG_STATUS, &status, 1) != 0)
            goto out;
    }
    if (status & STATUS_BUSY) {
        fprintf(stderr, "lidar: measurement timed out\n");
        goto out;
    }

    if (read_registers(fd, REG_DISTANCE, data, sizeof data) != 0)
        goto out;

    *distance_cm = (data[0] << 8) | data[1];
    ret = 0;

out:
    /* Closing the file also releases the lock. */
    close(fd);
    return ret;
}
