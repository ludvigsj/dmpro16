/* Made by: Ludvig
 *
 * Purpose: Test of the matrix-transformation-concept. This will eventually
 * not be run as C code, but on the FPGA.
 */

#include <stdio.h>
#include <stdlib.h>

const int DST_W = 252;
const int DST_H = 252;

const int SRC_W  = 640;
const int SRC_H  = 480;

int points[4];

int argPoints(int argc, char *argv[]){
        int i;
        if(argc == 5)
        for(i = 0; i < 4; i++){
                points[i] = atoi(argv[i+1]);
        }
        return 1;
}

/* Does:
 * 
 * [x', y'] = A*[x, y] + [x1, y1]
 *
 * where 
 *
 * [x', y'] = dstPt
 *   [x, y] = srcPt 
 *
 *        A = | a -b |
 *            | b  a |
 *
 * where
 *
 * a = (x2 - x1)/DST_W
 * b = (y2 - y1)/DST_H
 */
int transform(int *dstPt, int *srcPt){
        int x_diff = points[2]-points[0];
        int y_diff = points[3]-points[1];
        srcPt[0] = ((x_diff*dstPt[0])-(y_diff*dstPt[1]))/DST_W + points[0];
        srcPt[1] = ((y_diff*dstPt[0])+(x_diff*dstPt[1]))/DST_H + points[1];
}

int transformALot(){
        int dstPt[2];
        int srcPt[2];
        while(scanf("%d %d", dstPt, dstPt+1) > 0){
                transform(dstPt, srcPt);
                printf("%d %d\n", srcPt[0], srcPt[1]);
        }
        return 0;
}

// Returns 1 if inside bounds, 0 otherwise
int check_bounds(){
        int top_left[2] = {0, 0};
        int top_right[2] = {0, DST_W};
        int bottom_left[2] = {DST_H, 0};
        int bottom_right[2] = {DST_H, DST_W};
        int *corners[4] = {top_left, top_right, bottom_left, bottom_right};
        int out[2];
        int i;

        for(i = 0; i < 4; i++){
                transform(corners[i], out);
                if(out[0] < 0 || out[0] >= SRC_W || out[1] < 0 || out[1] >= SRC_H){
                        return 0;
                }
        }
        return 1;
}

int main(int argc, char *argv[]){
        if(!argPoints(argc, argv)){
                printf("Usage: matrix_trans x1 y1 x2 y2\n");
                return 0;
        }
        printf("Matrix loaded with points p1=(%d, %d) and p2=(%d, %d)\n",
                        points[0], points[1], points[2], points[3]);
        if(!check_bounds()){
                printf("Warning: target out of bounds\n");
        }
        transformALot();
        return 0;
}

