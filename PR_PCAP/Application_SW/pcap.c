#include "pcap.h"

int initPCAP(u32 DEVICE_ID,XDcfg *DcfgInstance){
	int Status;
	XDcfg_Config *ConfigPtr;
	ConfigPtr = XDcfg_LookupConfig(DEVICE_ID);
	Status = XDcfg_CfgInitialize(DcfgInstance, ConfigPtr,ConfigPtr->BaseAddr);
	XDcfg_SetLockRegister(DcfgInstance, 0x757BDF0D);
	if (Status != XST_SUCCESS) {
		xil_printf("PCAP initialization failed\n\r");
		return XST_FAILURE;
	}

//Enable the PCAP clock.
	Status = Xil_In32(SLCR_PCAP_CLK_CTRL);
	if (!(Status & SLCR_PCAP_CLK_CTRL_EN_MASK)) {
		Xil_Out32(SLCR_UNLOCK, SLCR_UNLOCK_VAL);
		Xil_Out32(SLCR_PCAP_CLK_CTRL,(Status | SLCR_PCAP_CLK_CTRL_EN_MASK));
		Xil_Out32(SLCR_UNLOCK, SLCR_LOCK_VAL);
	}
	return XST_SUCCESS;
}


int partialReconfigure(XDcfg *DcfgInstance,char *bitStreamBuffer){
	int Status;
	u32 bitStreamSize;
	bitStreamSize = 372132;

//	print("you have entered.\n");
//	xil_printf("status before = %d\n",Status);

//Clear the interrupt status bits
	XDcfg_IntrClear(DcfgInstance, XDCFG_IXR_D_P_DONE_MASK|XDCFG_IXR_DMA_DONE_MASK);
///Transfer bitstream in non secure mode
	Status = XDcfg_Transfer(DcfgInstance, (u8 *)bitStreamBuffer,bitStreamSize,(u8 *)XDCFG_DMA_INVALID_ADDRESS,0, XDCFG_NON_SECURE_PCAP_WRITE);
	if (Status != XST_SUCCESS) {
		xil_printf("Reconfiguration failed\n\r");
		return XST_FAILURE;
	}
//	xil_printf("status after = %d\n",Status);

//Poll IXR_DMA_DONE
	Status = XDcfg_IntrGetStatus(DcfgInstance);
	while ((Status & XDCFG_IXR_DMA_DONE_MASK) != XDCFG_IXR_DMA_DONE_MASK)
	{
		Status = XDcfg_IntrGetStatus(DcfgInstance);
	}
//Poll IXR_D_P_DONE
	Status = XDcfg_IntrGetStatus(DcfgInstance);
	while ((Status & XDCFG_IXR_D_P_DONE_MASK) != XDCFG_IXR_D_P_DONE_MASK)
	{
		Status = XDcfg_IntrGetStatus(DcfgInstance);
	}
	return XST_SUCCESS;
}
