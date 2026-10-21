FLAGS = -Wall -Wextra -pedantic -g
PWMCHIP = /sys/class/pwm/pwmchip0

.PHONY: all pinmux pwm control control_server pwm_permissions lidar sensors sensors_server i2c_permissions clean

all: control_server sensors_server

pinmux: src/pinmux.c
	gcc $(FLAGS) src/pinmux.c -o pinmux

pwm: src/pwm.c inc/pwm.h
	gcc $(FLAGS) -c src/pwm.c -o pwm.o

control: src/control.c pwm
	gcc $(FLAGS) src/control.c pwm.o -o ../website/cgi-bin/control.cgi

# Export pwm0 as root and let Apache (www-data) write to it.
# Lost after a reboot or an unexport: run it again in that case.
pwm_permissions:
	[ -d $(PWMCHIP)/pwm0 ] || sudo sh -c 'echo 0 > $(PWMCHIP)/export'
	sudo chgrp www-data $(PWMCHIP)/pwm0/period $(PWMCHIP)/pwm0/duty_cycle $(PWMCHIP)/pwm0/enable
	sudo chmod g+w $(PWMCHIP)/pwm0/period $(PWMCHIP)/pwm0/duty_cycle $(PWMCHIP)/pwm0/enable

control_server: control pwm_permissions
	sudo cp ../website/cgi-bin/control.cgi /usr/lib/cgi-bin/control.cgi
	sudo chmod 755 /usr/lib/cgi-bin/control.cgi
	sudo cp ../website/html/index.html /var/www/html/index.html
	sudo chmod 644 /var/www/html/index.html

lidar: src/lidar.c inc/lidar.h
	gcc $(FLAGS) -c src/lidar.c -o lidar.o

sensors: src/sensors.c lidar
	gcc $(FLAGS) src/sensors.c lidar.o -o ../website/cgi-bin/sensors.cgi

# Let Apache (www-data) access the I2C bus through the i2c group.
# Apache is restarted so that the new group is taken into account.
i2c_permissions:
	id -nG www-data | grep -qw i2c || { sudo usermod -aG i2c www-data && sudo systemctl restart apache2; }

sensors_server: sensors i2c_permissions
	sudo cp ../website/cgi-bin/sensors.cgi /usr/lib/cgi-bin/sensors.cgi
	sudo chmod 755 /usr/lib/cgi-bin/sensors.cgi
	sudo cp ../website/html/index.html /var/www/html/index.html
	sudo chmod 644 /var/www/html/index.html

clean: 
	rm -f *.o ../website/cgi-bin/control.cgi ../website/cgi-bin/sensors.cgi
