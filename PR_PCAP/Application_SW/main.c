#include "stdio.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xuartps.h"
#include "xddrps.h"
#include "pcap.h"
#include "xdevcfg.h"
#include "xil_types.h"


#define BIT_SIZE 372132

char size1[BIT_SIZE];
char delay1[100];
char size2[BIT_SIZE];
char delay2[100];
char bitStreamBuffer[BIT_SIZE];

u32 checkHalted(u32 baseAddress,u32 offset);

int main(){

	u32 a[2];
	u32 b[1];
    u32 status;

//    int i;
	char c;
	int choice;

// Initialize UART
    XUartPs UART_PS;
    XUartPs_Config *Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);
    XUartPs_CfgInitialize(&UART_PS, Config, Config->BaseAddress);

// Initialize DMA
	XAxiDma_Config *myDmaConfig;
	XAxiDma myDma;
	myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
	if(status != XST_SUCCESS){
		print("DMA initialization failed\n");
		return -1;
	}
	print("DMA initialization success..\n");

// Initialize PCAP
	XDcfg DcfgInstance;
	status = initPCAP(XPAR_XDCFG_0_DEVICE_ID,&DcfgInstance);
	if (status != XST_SUCCESS) {
		print("PCAP initialization failed!!\n\r");
		return XST_FAILURE;
	}

//To get the Addresses of the buffers in DDR
	xil_printf("Address of the file1 is %0x\n\r",size1);
	xil_printf("Address of the file2 is %0x\n\r",size2);
	xil_printf("Address of the buffer is %0x\n\r",bitStreamBuffer);
	xil_printf("Press enter\n\r");
	scanf("%c",&c);

//To Transfer the bitstream data to target buffer
	memset(bitStreamBuffer, 0, BIT_SIZE);
	memcpy(bitStreamBuffer, size2, BIT_SIZE);

//check the buffer data
	print("Data in size1  :");
	for (int j=0; j<20; j++){
		xil_printf("%0x",size1[j]);
	}
	print("\n");

	print("Data in size2  :");
	for (int j=0; j<20; j++){
		xil_printf("%0x",size2[j]);
	}
	print("\n");

	print("Data in buffer:");
	for (int j=0; j<20; j++){
		xil_printf("%0x",bitStreamBuffer[j]);
	}
	print("\n");


	while(1){

		xil_printf("Enter your choice\n");
		xil_printf("*****************\n");
		xil_printf("1.Summation\n2.Multiplication\n");
		scanf("%d",&choice);
		xil_printf("choice:%d\n\r",choice);
		switch(choice){
		case 1:

			partialReconfigure(&DcfgInstance,size1);

/*
			memset(bitStreamBuffer, 0, BIT_SIZE);
			for (int j=0; j<5; j++){
				xil_printf("%0x",bitStreamBuffer[j]);
			}
			print("\n");
			memcpy(bitStreamBuffer, size1, BIT_SIZE);
			for (int j=0; j<5; j++){
				xil_printf("%0x",bitStreamBuffer[j]);
			}
			print("\n");
*/
			print("1\n");
			break;
		case 2:

			partialReconfigure(&DcfgInstance,size2);

/*
			memset(bitStreamBuffer, 0, BIT_SIZE);
			for (int j=0; j<5; j++){
				xil_printf("%0x",bitStreamBuffer[j]);
			}
			print("\n");
			memcpy(bitStreamBuffer, size2, BIT_SIZE);
			for (int j=0; j<5; j++){
				xil_printf("%0x",bitStreamBuffer[j]);
			}
			print("\n");
*/
			print("2\n");
			break;
		default:
			xil_printf("Wrong choice\n");
			break;
		}


		for (int j=0; j<2;j++){
			xil_printf("Enter a number %0d: ",j+1);
			scanf("%lu",&a[j]);
			printf("%lu\n",a[j]);
		}
/*
		XAxiDma_Reset(&myDma);
		status = XAxiDma_ResetIsDone(&myDma);
		if(status != XST_SUCCESS){
			print("DMA reset failed\n");
			return -1;
		}
		print("DMA reset success..\n");
*/

		status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
		if(status != XST_SUCCESS){
			print("DMA initialization failed\n");
			return -1;
		}
		//print("DMA initialization success..\n");

		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
		//xil_printf("Status before data transfer %0x\n",status);
		Xil_DCacheFlush();

		status = XAxiDma_SimpleTransfer(&myDma, (u32)a, 2*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);
		if(status != XST_SUCCESS){
			print("DMA initialization failed\n");
			return -1;
		}

		status = XAxiDma_SimpleTransfer(&myDma, (u32)b, 1*sizeof(u32),XAXIDMA_DEVICE_TO_DMA);

		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
		while(status != 1){
			status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
		}

		status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
		while(status != 1){
			status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
		}
		print("DMA transfer success..\n");

		//xil_printf("%0x\n",b[0]);
		for(int i=0;i<1;i++){
			xil_printf("(%0d) The Result is = %0d\n",i,b[i]);
		}
	}

	return 0;
}


u32 checkHalted(u32 baseAddress,u32 offset){
	u32 status;
	status = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_HALTED_MASK;
	return status;
}
