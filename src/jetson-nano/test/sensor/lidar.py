from smbus2 import SMBus
import time

ADDR = 0x62
with SMBus(1) as bus:
    while True:
        bus.write_byte_data(ADDR, 0x00, 0x04)        # lancer une mesure
        while bus.read_byte_data(ADDR, 0x01) & 0x01: # attendre la fin (bit busy)
            pass
        hi, lo = bus.read_i2c_block_data(ADDR, 0x8f, 2)
        print((hi << 8) | lo, "cm")
        time.sleep(0.05)