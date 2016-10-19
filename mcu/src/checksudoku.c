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
		if ((rowflags != 0x1ff) || (colflags != 0x1ff))
			miss++;
	}

	for (k = 0; k < 3; k++)
		for (l = 0; l < 3; l++)
		{
			int flags = 0;
			for (i = 0; i < 3; i++)
				for (j = 0; j < 3; j++)
					flags |= 1 << (sudoku[k * 3 + i][l * 3 + j] - 1);
			if (flags != 0x1ff)
				miss++;
		}

	return miss;
}

