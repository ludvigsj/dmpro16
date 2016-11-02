#ifndef SPI_MASTER_H
#define SPI_MASTER_H

void setupDmaSpi();
void spiDmaTransfer(uint8_t *txBuffer, uint8_t *rxBuffer, int bytes);
void displayTransfer(uint8_t *txBuffer, int bytes);
void fpgaTransfer(uint8_t *rxBuffer, int bytes);
void sleepUntilDmaDone(void);

#endif
