#include <stdio.h>

int main()
{
	char buf[640];
	FILE *fp = fopen("sudoku_bl_corner.raw", "rb");
	int i;
	for (i = 0; i < 480; i++)
	{
		size_t returnval = fread(buf, 1, 640, fp);
		int j;
		printf("\n");
		for (j = 0; j < 20); j++)
		{
			char temp = buf[j];
			printf("%x", temp);
		}
	}

	fclose(fp);
}
