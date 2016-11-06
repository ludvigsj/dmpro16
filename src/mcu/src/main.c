#include "bsp.h"
#include "em_device.h"
#include "em_chip.h"
#include "em_dma.h"
#include "spi_master.h"
#include "display.h"
#include "checksudoku.h"

int main()
{
	BSP_Init(BSP_INIT_DK_SPI);

    int board[9][9] = {
    {1, 2, 3, 4, 5, 6, 7, 8, 9},
    {7, 5, 9, 1, 8, 3, 4, 2, 6},
    {6, 4, 8, 2, 9, 7, 3, 1, 5},
    {3, 7, 4, 9, 1, 5, 2, 6, 8},
    {8, 9, 6, 3, 7, 2, 1, 5, 4},
    {5, 1, 2, 8, 6, 4, 9, 7, 3},
    {9, 3, 1, 5, 2, 8, 6, 4, 7},
    {2, 6, 5, 7, 4, 9, 8, 3, 1},
    {4, 8, 7, 6, 3, 1, 5, 9, 2},
    };

	CHIP_Init();
	setupDmaSpi();

	uint8_t number[1];
	fpgaTransfer((uint8_t*) number, 1);
	sleepUntilDmaDone();
	int testBoard[9][9] = { { number[0] } };
	displaySudoku(testBoard, 0);
	//displaySudoku(board, 1);

	/*
	int incorrect = checkSudoku(board);
	displaySudoku(board, incorrect);
	*/

	DMA_Reset();
	while(1);

}
