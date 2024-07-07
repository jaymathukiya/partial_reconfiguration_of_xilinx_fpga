#ifndef SRC_PCAP_H_
#define SRC_PCAP_H_

#include "xdevcfg.h"
#include "xparameters.h"
#include "xil_types.h"

/*
 * SLCR registers
 */

#define SLCR_PCAP_CLK_CTRL XPAR_PS7_SLCR_0_S_AXI_BASEADDR + 0x168

#define MAX_COUNT 1000000000

#define SLCR_LOCK	0xF8000004
#define SLCR_UNLOCK	0xF8000008
#define SLCR_LVL_SHFTR_EN 0xF8000900

#define SLCR_PCAP_CLK_CTRL_EN_MASK 0x1
#define SLCR_LOCK_VAL	0x767B
#define SLCR_UNLOCK_VAL	0xDF0D

int initPCAP(u32 DEVICE_ID,XDcfg *DcfgInstance);
int partialReconfigure(XDcfg *DcfgInstance,char *bitStreamBuffer);
#endif /* SRC_PCAP_H_ */
