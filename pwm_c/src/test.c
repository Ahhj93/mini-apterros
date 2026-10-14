#include <stdio.h>
#include <unistd.h>
#include "../inc/pwm_c.h"

int main (int argc, char ** argv){
	FILE * fpointer0=fopen(PWM_CHIP_EXPORT,"w");
	printf("%p\n",(void*)fpointer0);
	fwrite("0",8,1,fpointer0);
	fclose(fpointer0);
	sleep(1);
	FILE * fpointer1=fopen(PWM_DUTY_CYCLE,"w+");
	printf("%p\n",(void*)fpointer1);
	fwrite("5000000",8,1,fpointer1);
	fclose(fpointer1);
	FILE * fpointer2=fopen(PWM_PERIOD,"w+");
	printf("%p\n",(void*)fpointer2);
	fwrite("20000000",8,1,fpointer2);
	fclose(fpointer2);
	FILE * fpointer3=fopen(PWM_ENABLE,"w+");
	printf("%p\n",(void*)fpointer3);
	fwrite("1",8,1,fpointer3);
	fclose(fpointer3);
}
