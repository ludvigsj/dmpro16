#include "bsp.h"
#include "em_device.h"
#include "em_chip.h"
#include "em_cmu.h"
#include "em_dma.h"
#include "em_emu.h"
#include "em_rmu.h"
#include "spi_master.h"
#include "display.h"
#include "checksudoku.h"

uint32_t msTicks = 0;

void SysTick_Handler(void)
{
	msTicks++;
}

void Delay(uint32_t dlyTicks)
{
	uint32_t curTicks;
	curTicks = msTicks;
	while ((msTicks - curTicks) < dlyTicks);
}

void GPIO_ODD_IRQHandler(void)
{
	GPIO_IntClear(0x0002);
}

int main()
{
	BSP_Init(BSP_INIT_DK_SPI);
	CHIP_Init();
	setupDmaSpi();

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

	GPIO_PinModeSet(gpioPortE, 0, gpioModePushPull, 1);
	GPIO_PinOutSet(gpioPortE, 0);
	GPIO_PinModeSet(gpioPortE, 1, gpioModeInput, 1);
	NVIC_EnableIRQ(GPIO_ODD_IRQn);
	GPIO_IntConfig(gpioPortE, 1, true, true, true);

	CMU_ClockEnable(cmuClock_CORELE, true);
	if (SysTick_Config(CMU_ClockFreqGet(cmuClock_CORE) / 1000)) while (1);

	/*
	Delay(2000);
	EMU_EnterEM3(true);
	*/

	while (!GPIO_PinOutGet(gpioPortE, 1));


	uint8_t number[1];
	int testBoard[9][9];
	for (int i = 0; i < 81; i++)
	{
		fpgaTransfer((uint8_t*) number, 1);
		sleepUntilDmaDone();
		testBoard[i/9][i%9] = number[0];
	}

	int incorrect = checkSudoku(testBoard);
	displaySudoku(testBoard, 1);

	DMA_Reset();

	RMU_ResetCauseClear();

	Delay(2000);
	GPIO_PinModeSet(gpioPortA, 0, gpioModeInput, 1);
	GPIO->CTRL |= GPIO_CTRL_EM4RET;
	GPIO->CMD |= GPIO_CMD_EM4WUCLR;
	GPIO->EM4WUEN |= GPIO_EM4WUEN_EM4WUEN_A0;

	EMU_EnterEM4();

	return 0;
}

