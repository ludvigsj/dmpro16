#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <bcm2835.h>

#define SIZE 307200 // 640x480

#define PIN24 RPI_GPIO_P1_18
#define PIN23 RPI_GPIO_P1_16
#define PIN18 RPI_GPIO_P1_12
#define PIN17 RPI_GPIO_P1_11


void send_data();
void init_gpio();

FILE *image;
uint8_t buf[SIZE];

int main(int argc, char ** argv) {
    init_gpio();

    uint8_t value = 1;
    uint8_t prev_value = 1;
    while(1) {
        value = bcm2835_gpio_lev(PIN18);
        if (value == 1 && prev_value == 0) {
            system("/usr/bin/raspiyuv --width 640 --height 480 -n --timeout 1 -y -o \"/home/pi/image.y\"");
            image = fopen("image.y", "rb");
            fread(buf, 1, SIZE, image);
            bcm2835_gpio_write(PIN17, HIGH);
            send_data();
            bcm2835_gpio_write(PIN17, LOW);
        }
        prev_value = value;
    }
    bcm2835_close();
    return 0;
}

void init_gpio() {
    if (!bcm2835_init()) {
        printf("can't open bcm\n");
    }

    bcm2835_gpio_fsel(PIN23, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(PIN17, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(PIN24, BCM2835_GPIO_FSEL_INPT);
    bcm2835_gpio_fsel(PIN18, BCM2835_GPIO_FSEL_INPT);
    bcm2835_gpio_set_pud(PIN24, BCM2835_GPIO_PUD_UP);
    bcm2835_gpio_set_pud(PIN18, BCM2835_GPIO_PUD_UP);

}

void send_data() {
    uint8_t value = 1;
    uint8_t prev_value = 0;
    for (int i = 0; i < SIZE; i++) {
        while (1) {
            value = bcm2835_gpio_lev(PIN24);
            if (value == 1 && prev_value == 0) {
                if (buf[i] > 127) {
                    bcm2835_gpio_write(PIN23, HIGH);
                } else {
                    bcm2835_gpio_write(PIN23, LOW);
                }
                bcm2835_delayMicroseconds(1);
                break;
            }
            prev_value = value;
        }
    }
}
