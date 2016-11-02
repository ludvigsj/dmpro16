#include <stdio.h>

int checkSudoku(int sudoku[9][9])
{
	int i, j, k, l, rowflags, colflags, miss;
	rowflags = colflags = miss  = 0;
	for (i = 0; i < 9; i++)
	{
		for (j = 0; j < 9; j++)
		{
			rowflags |= 1 << (sudoku[i][j] - 1);
			colflags |= 1 << (sudoku[j][i] - 1);
		}
		if ((rowflags != 0x1FF) || (colflags != 0x1FF))
			miss++;
	}

	for (k = 0; k < 3; k++)
		for (l = 0; l < 3; l++)
		{
			int flags = 0;
			for (i = 0; i < 3; i++)
				for (j = 0; j < 3; j++)
					flags |= 1 << (sudoku[k * 3 + i][l * 3 + j] - 1);
			if (flags != 0x1FF)
				miss++;
		}

	return miss;
}

int main()
{
	int board[9][9];
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

	int board3[9][9] = {
	{1, 2, 3, 4, 5, 7, 6, 8, 9},
	{7, 5, 9, 1, 8, 4, 3, 2, 6},
	{6, 4, 8, 2, 9, 3, 7, 1, 5},
	{3, 7, 4, 9, 1, 2, 5, 6, 8},
	{8, 9, 6, 3, 7, 1, 2, 5, 4},
	{5, 1, 2, 8, 6, 9, 4, 7, 3},
	{9, 3, 1, 5, 2, 6, 8, 4, 7},
	{2, 6, 5, 7, 4, 8, 9, 3, 1},
	{4, 8, 7, 6, 3, 5, 1, 9, 2},
	};

	int i, j;
	for (i = 0; i < 9; i++)
		for (j = 0; j < 9; j++)
		{
			board[i][j] = j + 1;
		}


	if (checkSudoku(board) == 0) printf("Yay0!\n");
	if (checkSudoku(board2) == 0) printf("Yay2!\n");
	if (checkSudoku(board3) == 0) printf("Yay3!\n");

	return 0;
}

