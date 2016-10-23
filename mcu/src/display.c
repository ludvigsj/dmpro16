#include <string.h>
#include "em_dma.h"
#include "spi_master.h"
#include "font.h"

uint8_t displayBuffer[96][14];

void drawNumber(int number, int x, int y)
{
	for (int i = 0; i < 9; i++)
	{
		displayBuffer[y * 10 + i + 1][x + 2] = numbers[(number -1) * 9 + i];
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

void drawResult(int incorrect)
{
	if (incorrect)
	{
		const uint8_t in[] = { 2, 3 };
		for (int i = 0; i < sizeof(in); i++)
		{
			for (int j = 0; j < 8; j++)
			{
				displayBuffer[i * 8 + j + 1][12] = letters[in[i] * 8 + j];
			}
		}
	}

	const uint8_t result[] = { 0, 4, 5, 5, 1, 0, 6 };
	for (int i = 0; i < sizeof(result); i++)
	{
		for (int j = 0; j < 8; j++)
		{
			displayBuffer[(i + 2) * 8 + j + 1][12] = letters[result[i] * 8 + j];
		}
	}
}

void refresh()
{
	uint8_t clear[2] = { 0x04 | 0x02, 0x00 };
	displayTransfer((uint8_t*) clear, 2);
	sleepUntilDmaDone();

	uint8_t board[688];
	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[0][0], 686);
	board[687] = 0x00;
	displayTransfer((uint8_t*) board, 688);
	sleepUntilDmaDone();

	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[48][0], 686);
	board[687] = 0x00;
	displayTransfer((uint8_t*) board, 688);
	sleepUntilDmaDone();
}

void displaySudoku(int sudoku[9][9], int incorrect)
{
	drawBoard();

	for (int i = 0; i < 9; i++)
	{
		for (int j = 0; j < 9; j++)
		{
			drawNumber(sudoku[i][j], j, i);
		}
	}

	drawResult(incorrect);

	refresh();
}

