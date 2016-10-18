#include <string.h>
#include "em_device.h"
#include "em_chip.h"
#include "em_dma.h"
#include "spi_master.h"
#include "font.h"

uint8_t displayBuffer[96][14];

void drawNumber(int number, int x, int y)
{
	for (int i = 0; i < 9; i++)
	{
		displayBuffer[y * 10 + i + 1][x + 2] = font[(number -1) * 9 + i];
	}
}

void drawBoard()
{
	for (int i = 1; i <= 96; i++)
	{
		uint8_t color;
		displayBuffer[i][0] = i;
		displayBuffer[i][13] = 0x00;
		for (int j = 1; j < 13; j++)
		{
			if (j == 1 || j == 12)
				color = 0xff;
			else if (i % 10 == 0 && j != 11)
				color = 0x00;
			else if (i > 90)
				color = 0xff;
			else
				color = 0xfe;
			displayBuffer[i][j] = color;
		}
	}
}

void refresh()
{
	uint8_t clear[2] = { 0x04 | 0x02, 0x00 };
	spiDmaTransfer((uint8_t*) clear, NULL, 2);
	sleepUntilDmaDone();

	uint8_t board[688];
	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[0][0], 686);
	board[687] = 0x00;
	spiDmaTransfer((uint8_t*) board, NULL, 688);
	sleepUntilDmaDone();

	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[48][0], 686);
	board[687] = 0x00;
	spiDmaTransfer((uint8_t*) board, NULL, 688);
	sleepUntilDmaDone();
}

void displaySudoku(int sudoku[9][9])
{
	drawBoard();

	for (int i = 0; i < 9; i++)
	{
		for (int j = 0; j < 9; j++)
		{
			drawNumber(sudoku[i][j], j, i);
		}
	}

	refresh();
}

int main()
{
    int board2[9][9] = {
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

	displaySudoku(board2);

	DMA_Reset();

	while(1);
}
