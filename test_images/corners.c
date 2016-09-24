#include <stdio.h>

int main()
{
	int first = 0;

	int fpxx, fpxy, lpxx, lpxy;
	fpxx = 9999;
	lpxx = -1;

	char buf[640];
	FILE *fp = fopen("sudoku2_middle_75%_-25deg8bit.gray", "r");

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
					printf("First corner: %d, %d\n", j, i);
					first = 1;
					break;
				}
			}
			else
			{
				if (buf[j] != 0 && j < fpxx)
				{
					fpxx = j;
					fpxy = i;
				}
				else if (buf[j] != 0 && j > lpxx)
				{
					lpxx = j;
					lpxy = i;
				}
			}
		}
	}

	if (fpxy < lpxy)
		printf("Second corner: left: %d, %d\n", fpxx, fpxy);
	else
		printf("Second corner: right: %d, %d\n", lpxx, lpxy);

	fclose(fp);
}
