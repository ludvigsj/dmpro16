#include <stdio.h>

int main()
{
	int first = 0;
	int second = 0;

	int ltx, lty, rtx, rty, fpxx, fpxy, lpxx, lpxy;
	fpxx = 9999;
	lpxx = -1;

	char buf[640];
	FILE *fp = fopen("../../../test_images/foto7.gray", "r");

	int i;
	for (i = 0; i < 480; i++)
	{
		fread(buf, 1, 640, fp);
		int j;
		for (j = 0; j < 640; j++)
		{
			if (first == 0 || second == 0)
			{
				if ((unsigned) buf[j] >= 128 && (
						((unsigned) buf[j+1] <= 128) &&
						((unsigned) buf[j+2] <= 128) &&
						((unsigned) buf[j+3] <= 128)))
				{
					rtx = j;
					rty = i;
					first = 1;
				}
				if ((unsigned) buf[j] >= 128 && second == 0)
				{
					ltx = j;
					lty = i;
					second = 1;
				}
			}
			else
			{
				if (((unsigned) buf[j] ) >= 128 && j < fpxx)
				{
					fpxx = j;
					fpxy = i;
				}
				else if (((unsigned) buf[j] ) >= 128 && j > lpxx)
				{
					lpxx = j;
					lpxy = i;
				}
			}
		}
	}

	if (fpxy < lpxy)
		printf("First corner: right: %d, %d\nSecond corner: left: %d, %d\n", rtx, rty, fpxx, fpxy);
	else
		printf("First corner: left: %d, %d\nSecond corner: right: %d, %d\n", ltx, lty, lpxx, lpxy);

	fclose(fp);
}
