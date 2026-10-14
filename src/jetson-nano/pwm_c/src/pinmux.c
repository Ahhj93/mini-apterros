#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>

static void w(int fd, off_t addr, uint32_t val) {
    off_t base = addr & ~0xFFF;      /* début de la page */
    off_t off  = addr & 0xFFF;       /* position dans la page */

    volatile uint32_t *p = mmap(NULL, 4096, PROT_READ | PROT_WRITE,
                                MAP_SHARED, fd, base);
    if (p == MAP_FAILED) { perror("mmap"); exit(1); }

    p[off / 4] = val;                /* écriture du registre */
    printf("0x%lx -> 0x%x\n", (long)addr, p[off / 4]);

    munmap((void *)p, 4096);
}

int main(void) {
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) { perror("/dev/mem"); return 1; }

    w(fd, 0x700031fc, 0x45); w(fd, 0x6000d504, 0x2);   /* broche 32 */
    w(fd, 0x70003248, 0x46); w(fd, 0x6000d100, 0x00);  /* broche 33 */

    close(fd);
    return 0;
}
