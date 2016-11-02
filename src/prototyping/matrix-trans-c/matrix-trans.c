#include <stdio.h>

const int DEST_W = 252;
const int DEST_H = 252;

const int IN_W = 640;
const int IN_H = 480;

int x_1, y_1, x_2, y_2;

int main(int argc, char* argv[]){
    int a, b, dx, dy, x, y, sample_x, sample_y;
    printf("Corners (format: \"x1 y1 x2 y2\"): ");
    scanf("%d %d %d %d", &x_1, &y_1, &x_2, &y_2);
    
    dx = x_1;
    dy = y_1;

    while(1){
        printf("Input point: ");
        scanf("%d %d", &x, &y);
        sample_x = x_1 + ((x_2-x1)*x)
    }
    return 0;
}
