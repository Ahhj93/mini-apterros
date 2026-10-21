/*
 * pinmux.c - Configures the pinmux of the Jetson Nano header pins
 * used as PWM outputs.
 *
 * Writes directly to the hardware registers through /dev/mem,
 * so it must be run as root.
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

/*
 * Writes a 32-bit value to the physical address addr.
 * Maps the 4 KiB page containing the register, writes the value,
 * then reads it back and prints it for verification.
 */
static void w(int fd, off_t addr, uint32_t val) {
    /* Start of the page and offset of the register inside it. */
    off_t base = addr & ~0xFFF;
    off_t off  = addr & 0xFFF;

    volatile uint32_t *p = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                                MAP_SHARED, fd, base);
    if (p == MAP_FAILED) { perror("mmap"); exit(1); }

    /* Register write, then read back. */
    p[off / 4] = val;
    printf("0x%lx -> 0x%x\n", (long)addr, p[off / 4]);

    munmap((void *)p, 4096);
}

int main(void) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("/dev/mem"); return 1; }

    /* Pin 32 */
    w(fd, 0x700031fc, 0x45); w(fd, 0x6000d504, 0x2);

    /* Pin 33 */
    w(fd, 0x70003248, 0x46); w(fd, 0x6000d100, 0x00);

    close(fd);
    return 0;
}
