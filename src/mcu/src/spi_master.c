/*****************************************************************************
 * @file spi_master.c
 * @brief DMA SPI master transmit/receive example
 * @author Silicon Labs
 * @version 2.06
 ******************************************************************************
 * @section License
 * <b>(C) Copyright 2014 Silicon Labs, http://www.silabs.com</b>
 *******************************************************************************
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 * DISCLAIMER OF WARRANTY/LIMITATION OF REMEDIES: Silicon Labs has no
 * obligation to support this Software. Silicon Labs is providing the
 * Software "AS IS", with no express or implied warranties of any kind,
 * including, but not limited to, any implied warranties of merchantability
 * or fitness for any particular purpose or warranties against infringement
 * of any proprietary rights of a third party.
 *
 * Silicon Labs will not be liable for any consequential, incidental, or
 * special damages, or any other relief, or for any claim by any third party,
 * arising from your use of this Software.
 *
 ******************************************************************************/

#include <stdbool.h>
#include <string.h>
#include <stdint.h>
#include "em_device.h"
#include "em_chip.h"
#include "em_usart.h"
#include "em_gpio.h"
#include "em_dma.h"
#include "em_cmu.h"
#include "em_emu.h"
#include "em_int.h"
#include "dmactrl.h"
#include "spi_master.h"

#define DMA_CHANNEL_RX   0
#define DMA_CHANNEL_TX   2
#define DMA_CHANNELS     3

/* DMA Callback structure */
DMA_CB_TypeDef spiCallback;

/* Transfer Flags */
volatile bool rxActive;
volatile bool txActive;

/* SPI Data Buffers */
//const char spiTxData[] = "Hello World! This is Gecko!";
const char spiTxData[] = {0x01 | 0x02, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00};

#define SPI_TRANSFER_SIZE (sizeof(spiTxData)/sizeof(char))
volatile char spiRxData1[SPI_TRANSFER_SIZE];
volatile char spiRxData2[SPI_TRANSFER_SIZE];


/**************************************************************************//**
 * @brief  Call-back called when transfer is complete
 *****************************************************************************/
void transferComplete(unsigned int channel, bool primary, void *user)
{
  (void) primary;
  (void) user;
  
  /* Clear flag to indicate complete transfer */
  if (channel == DMA_CHANNEL_TX || channel == 1)
  {
    txActive = false;  
  }
  else if (channel == DMA_CHANNEL_RX)
  {
    rxActive = false;
  }
}



/**************************************************************************//**
 * @brief  Enabling clocks
 *****************************************************************************/
void setupCmu(void)
{  
  /* Enabling clocks */
  CMU_ClockEnable(cmuClock_DMA, true);  
  CMU_ClockEnable(cmuClock_GPIO, true);  
  CMU_ClockEnable(cmuClock_USART0, true);
  CMU_ClockEnable(cmuClock_USART1, true);  
}



/**************************************************************************//**
 * @brief  Setup SPI as Master
 *****************************************************************************/
void setupSpi(void)
{
  USART_InitSync_TypeDef usartInit0 = USART_INITSYNC_DEFAULT;
  USART_InitSync_TypeDef usartInit1 = USART_INITSYNC_DEFAULT;
  
  /* Initialize SPI */
  usartInit0.databits = usartDatabits8;
  usartInit0.baudrate = 1000000;
  usartInit0.master = 1;
  usartInit0.msbf = 1;
  usartInit0.clockMode = usartClockMode0;
  USART_InitSync(USART0, &usartInit0);
  usartInit1.databits = usartDatabits8;
  usartInit1.baudrate = 1000000;
  usartInit1.master = 1;
  usartInit1.msbf = 0;
  usartInit1.clockMode = usartClockMode0;
  USART_InitSync(USART1, &usartInit1);
  
  /* Turn on automatic Chip Select control */
  //USART0->CTRL |= USART_CTRL_AUTOCS | USART_CTRL_CSINV | USART_CTRL_AUTOTX;
  USART0->CTRL |= USART_CTRL_AUTOCS | USART_CTRL_CSINV;
  USART1->CTRL |= USART_CTRL_AUTOCS | USART_CTRL_CSINV;
  
  /* Enable SPI transmit and receive */
  USART_Enable(USART0, usartEnable);
  USART_Enable(USART1, usartEnable);
  
  /* Configure GPIO pins for SPI */
  GPIO_PinModeSet(gpioPortE, 10, gpioModePushPull, 0); /* MOSI */
  GPIO_PinModeSet(gpioPortE, 11, gpioModeInput,    0); /* MISO */
  GPIO_PinModeSet(gpioPortE, 12, gpioModePushPull, 0); /* CLK */
  GPIO_PinModeSet(gpioPortE, 13, gpioModePushPull, 1); /* CS */

  GPIO_PinModeSet(gpioPortD, 0, gpioModePushPull, 0); /* MOSI */
  GPIO_PinModeSet(gpioPortD, 1, gpioModeInput,    0); /* MISO */
  GPIO_PinModeSet(gpioPortD, 2, gpioModePushPull, 0); /* CLK */
  GPIO_PinModeSet(gpioPortD, 3, gpioModePushPull, 1); /* CS */
 
  /* Enable routing for SPI pins from USART to location 1 */
  USART0->ROUTE = USART_ROUTE_TXPEN |
                  USART_ROUTE_RXPEN | 
                  USART_ROUTE_CSPEN | 
                  USART_ROUTE_CLKPEN | 
                  USART_ROUTE_LOCATION_LOC0;

  USART1->ROUTE = USART_ROUTE_TXPEN | 
                  USART_ROUTE_RXPEN |
                  USART_ROUTE_CSPEN | 
                  USART_ROUTE_CLKPEN | 
                  USART_ROUTE_LOCATION_LOC1;
}



/**************************************************************************//**
 * @brief Configure DMA in basic mode for both TX and RX to/from USART
 *****************************************************************************/
void setupDma(void)
{
  /* Initialization structs */
  DMA_Init_TypeDef        dmaInit;
  DMA_CfgChannel_TypeDef  rxChnlCfg;
  DMA_CfgDescr_TypeDef    rxDescrCfg;
  DMA_CfgChannel_TypeDef  txChnlCfg;
  DMA_CfgDescr_TypeDef    txDescrCfg;
  DMA_CfgChannel_TypeDef  txChnlCfg1;
  DMA_CfgDescr_TypeDef    txDescrCfg1;
  
  /* Initializing the DMA */
  dmaInit.hprot        = 0;
  dmaInit.controlBlock = dmaControlBlock;
  DMA_Init(&dmaInit);
  
  /* Setup call-back function */  
  spiCallback.cbFunc  = transferComplete;
  spiCallback.userPtr = NULL;
  
  /*** Setting up RX DMA ***/

  /* Setting up channel */
  rxChnlCfg.highPri   = false;
  rxChnlCfg.enableInt = true;
  rxChnlCfg.select    = DMAREQ_USART0_RXDATAV;
  rxChnlCfg.cb        = &spiCallback;
  DMA_CfgChannel(DMA_CHANNEL_RX, &rxChnlCfg);

  /* Setting up channel descriptor */
  rxDescrCfg.dstInc  = dmaDataInc1;
  rxDescrCfg.srcInc  = dmaDataIncNone;
  rxDescrCfg.size    = dmaDataSize1;
  rxDescrCfg.arbRate = dmaArbitrate1;
  rxDescrCfg.hprot   = 0;
  DMA_CfgDescr(DMA_CHANNEL_RX, true, &rxDescrCfg);

  /* Setting up channel */
  txChnlCfg1.highPri   = false;
  txChnlCfg1.enableInt = true;
  txChnlCfg1.select    = DMAREQ_USART0_TXBL;
  txChnlCfg1.cb        = &spiCallback;
  DMA_CfgChannel(1, &txChnlCfg1);

  /* Setting up channel descriptor */
  txDescrCfg1.dstInc  = dmaDataIncNone;
  txDescrCfg1.srcInc  = dmaDataInc1;
  txDescrCfg1.size    = dmaDataSize1;
  txDescrCfg1.arbRate = dmaArbitrate1;
  txDescrCfg1.hprot   = 0;
  DMA_CfgDescr(1, true, &txDescrCfg1);
  
  /*** Setting up TX DMA ***/

  /* Setting up channel */
  txChnlCfg.highPri   = false;
  txChnlCfg.enableInt = true;
  txChnlCfg.select    = DMAREQ_USART1_TXBL;
  txChnlCfg.cb        = &spiCallback;
  DMA_CfgChannel(DMA_CHANNEL_TX, &txChnlCfg);

  /* Setting up channel descriptor */
  txDescrCfg.dstInc  = dmaDataIncNone;
  txDescrCfg.srcInc  = dmaDataInc1;
  txDescrCfg.size    = dmaDataSize1;
  txDescrCfg.arbRate = dmaArbitrate1;
  txDescrCfg.hprot   = 0;
  DMA_CfgDescr(DMA_CHANNEL_TX, true, &txDescrCfg);
}



/**************************************************************************//**
 * @brief  SPI DMA Transfer
 * NULL can be input as txBuffer if tx data to transmit dummy data
 * If only sending data, set rxBuffer as NULL to skip DMA activation on RX
 *****************************************************************************/
void spiDmaTransfer(uint8_t *txBuffer, uint8_t *rxBuffer,  int bytes)
{ 
  GPIO_PinOutSet(gpioPortD, 3);
  /* Only activate RX DMA if a receive buffer is specified */  
  if (rxBuffer != NULL)
  {
    /* Setting flag to indicate that RX is in progress
     * will be cleared by call-back function */
    rxActive = true;
    
    /* Clear RX regsiters */
    USART0->CMD = USART_CMD_CLEARRX;
    
    /* Activate RX channel */
    DMA_ActivateBasic(DMA_CHANNEL_RX,
                      true,
                      false,
                      rxBuffer,
                      (void *)&(USART0->RXDATA),
                      bytes - 1); 
  }
  /* Setting flag to indicate that TX is in progress
   * will be cleared by call-back function */
  txActive = true;
  
  /* Clear TX regsiters */
  USART1->CMD = USART_CMD_CLEARTX;
  
  /* Activate TX channel */
  DMA_ActivateBasic(DMA_CHANNEL_TX,
                    true,
                    false,
                    (void *)&(USART1->TXDATA),
                    txBuffer,
                    bytes - 1); 
}

void displayTransfer(uint8_t *txBuffer, int bytes)
{
  GPIO_PinOutSet(gpioPortD, 3);

  /* Setting flag to indicate that TX is in progress
   * will be cleared by call-back function */
  txActive = true;
  
  /* Clear TX regsiters */
  USART1->CMD = USART_CMD_CLEARTX;
  
  /* Activate TX channel */
  DMA_ActivateBasic(DMA_CHANNEL_TX,
                    true,
                    false,
                    (void *)&(USART1->TXDATA),
                    txBuffer,
                    bytes - 1); 
}

void fpgaTransfer(uint8_t *rxBuffer, int bytes)
{
	GPIO_PinOutSet(gpioPortE, 13);

    /* Setting flag to indicate that RX is in progress
     * will be cleared by call-back function */
    rxActive = true;
    
    /* Clear RX regsiters */
    USART0->CMD = USART_CMD_CLEARRX;
    
    /* Activate RX channel */
    DMA_ActivateBasic(DMA_CHANNEL_RX,
                      true,
                      false,
                      rxBuffer,
                      (void *)&(USART0->RXDATA),
                      bytes - 1); 

	txActive = true;

	USART0->CMD = USART_CMD_CLEARTX;

	DMA_ActivateBasic(1,
					  true,
					  false,
					  (void *)&(USART0->TXDATA),
					  NULL,
					  bytes - 1);
}



/**************************************************************************//**
 * @brief  Returns if an SPI transfer is active
 *****************************************************************************/
bool spiDmaIsActive(void)
{
  bool temp;
  temp = rxActive;
  temp = temp | txActive;
  return temp;
}



/**************************************************************************//**
 * @brief  Sleep in EM1 until DMA transfer is done
 *****************************************************************************/
void sleepUntilDmaDone(void)
{
  /* Enter EM1 while DMA transfer is active to save power. Note that
   * interrupts are disabled to prevent the ISR from being triggered
   * after checking the transferActive flag, but before entering
   * sleep. If this were to happen, there would be no interrupt to wake
   * the core again and the MCU would be stuck in EM1. While the 
   * core is in sleep, pending interrupts will still wake up the 
   * core and the ISR will be triggered after interrupts are enabled
   * again. 
   */ 
  bool isActive = false;
  
  while(1)
  {
    INT_Disable();
    isActive = spiDmaIsActive();
    if ( isActive )
    {
      EMU_EnterEM1(); 
    }
    INT_Enable();
    
    /* Exit the loop if transfer has completed */
    if ( !isActive )
    {
      break;
    }
  }  
}

void setupDmaSpi()
{
	setupCmu();
	setupSpi();
	setupDma();
}


/**************************************************************************//**
 * @brief  Main function
 * This example sets up the DMA to transfer outbound and incoming data from the
 * SPI (USART1) to/from the source/destination buffers. Three tests are done:
 * 1) Transmit data (string) without reading received data
 * 2) Transmit data (string) and transfer received data to RAM buffer
 * 3) Transmit dummy data and transfer received data to RAM buffer
 *****************************************************************************/
/*
int main(void)
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
  /* Initialize chip /
  CHIP_Init();
  
  /* Configuring clocks in the Clock Management Unit (CMU) /
  setupCmu();
  
  /* Configura USART for SPI /
  setupSpi();
    
  /* Configure DMA transfer from RAM to SPI using ping-pong /      
  setupDma();
  
  /* Send data to slave, no data reception /
  //spiDmaTransfer((uint8_t*) spiTxData, NULL, SPI_TRANSFER_SIZE);

	uint8_t board[688];
	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[0][0], 686);
	board[687] = 0x00;
	spiDmaTransfer((uint8_t*) board, NULL, 688);
	sleepUntilDmaDone();
	board[0] = 0x01 | 0x02;
	memcpy(&board[1], &displayBuffer[48][0], 686);
	board[687] = 0x00;
	spiDmaTransfer((uint8_t*) board, NULL,688);
	uint8_t clear[2] = {0x04 | 0x02, 0x00};
//	spiDmaTransfer((uint8_t*) clear, NULL, 2);

  /* Sleep until DMA is done /
  sleepUntilDmaDone();
/*
  spiDmaTransfer(displayBuffer, NULL, 1344);
  sleepUntilDmaDone();
  spiDmaTransfer((uint8_t*) 0x00, NULL, 1);
  sleepUntilDmaDone();
  /
  
  /* Send data to slave and save received data in buffer /
  //spiDmaTransfer((uint8_t*) spiTxData, (uint8_t*) spiRxData1, SPI_TRANSFER_SIZE);
  
  /* Sleep until DMA is done /
  //sleepUntilDmaDone();
  
  /* Send dummy data to slave and save received data in buffer /
  //spiDmaTransfer(NULL, (uint8_t*) spiRxData2, SPI_TRANSFER_SIZE);

  /* Sleep until DMA is done /
  //sleepUntilDmaDone();
 
  /* Cleaning up after DMA transfers /
  DMA_Reset();

  /* Done /
  while (1);
}
*/
