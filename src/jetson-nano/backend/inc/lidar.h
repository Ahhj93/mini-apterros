#ifndef LIDAR_H
#define LIDAR_H

#define LIDAR_I2C_BUS "/dev/i2c-1"
#define LIDAR_ADDR 0x62

/* Take one distance measurement with the LIDAR-Lite v3.
 * Returns 0 on success (distance stored in *distance_cm), -1 on error. */
int lidar_read_distance(int *distance_cm);

#endif
