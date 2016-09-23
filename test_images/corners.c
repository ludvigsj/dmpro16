#include <stdio.h>

int main()
{
	int first = 0;
	int lastline = 0;
	int curline = 0;
	int fpx = -1;
	int lpx = -1;
	int lfpx = -1;

	char buf[640];
	FILE *fp = fopen("sudoku2_right_40deg8bit.gray", "r");

	int i;
	for (i = 0; i < 480; i++)
	{
		fread(buf, 1, 640, fp);
		int j;
		for (j = 0; j < 640; j++)
		{
			if (first == 0)
			{
				if (buf[j] != 0)
				{
					printf("First corner: %d, %d\n", i, j);
					first = 1;
					break;
				}
			}
			else
			{
				if (buf[j] != 0)
				{
					if (fpx == -1)
						fpx = j;
					else
						lpx = j;
				}
			}
		}
		if (first == 1)
		{
			lastline = curline;
			curline = lpx - fpx;
			if (curline == lastline && lastline > 0)
			{
				if (lfpx < fpx)
					printf("Second corner: %d, %d\n", i-1, lfpx);
				else
					printf("Second corner: %d, %d\n", i-1, lpx);
				break;
			}
			lfpx = fpx;
			fpx = lpx = -1;
		}
	}

	fclose(fp);
}
