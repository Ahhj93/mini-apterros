import mmap, os, struct
fd = os.open("/dev/mem", os.O_RDWR | os.O_SYNC)

def w(addr, val):
    m = mmap.mmap(fd, 4096, mmap.MAP_SHARED,
                  mmap.PROT_READ | mmap.PROT_WRITE, offset=addr & ~0xFFF)
    o = addr & 0xFFF
    m[o:o+4] = struct.pack("<I", val)
    r = struct.unpack("<I", m[o:o+4])[0]
    m.close()
    print(hex(addr), "->", hex(r))

# Broche 32 (PWM0)
w(0x700031fc, 0x45)
w(0x6000d504, 0x2)
# Broche 33 (PWM2)
w(0x70003248, 0x46)
w(0x6000d100, 0x00)
