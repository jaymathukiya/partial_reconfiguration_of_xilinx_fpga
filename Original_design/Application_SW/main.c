#include "stdio.h"
#include "xaxidma.h"
#include "xparameters.h"
#include "sleep.h"
#include "xil_cache.h"
#include "xuartps.h"

int main(){

	u32 a[2];
	u32 b[1];
	u32 c[1];
    u32 status;

    int choice;
  //  char d;

    // Initialize UART
    XUartPs UART_PS;
    XUartPs_Config *Config = XUartPs_LookupConfig(XPAR_XUARTPS_0_DEVICE_ID);
    XUartPs_CfgInitialize(&UART_PS, Config, Config->BaseAddress);

    //Initialize DMA
    XAxiDma myDma1,  myDma2;
   	XAxiDma_Config *myDmaConfig1, *myDmaConfig2;

   	//DMA1
   	myDmaConfig1 = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma1, myDmaConfig1);
	if(status != XST_SUCCESS){
		print("DMA initialization 1 failed\n");
		return -1;
	}
	print("DMA initialization 1 success..\n");

	//DAM2
	myDmaConfig2 = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_1_BASEADDR);
	status = XAxiDma_CfgInitialize(&myDma2, myDmaConfig2);
	if(status != XST_SUCCESS){
		print("DMA initialization 2 failed\n");
		return -1;
	 }
	 print("DMA initialization 2 success..\n");

    while(1){

    	 char d;

		xil_printf("Enter your choice\n");
		xil_printf("*****************\n");
		xil_printf("1.Summation\n2.Multiplication\n3.Exit\n");
		scanf("%d",&choice);

		xil_printf("choice:%d\n\r",choice);

		for (int j=0; j<2;j++){
			xil_printf("Enter a number %0d: ",j+1);
			scanf("%lu",&a[j]);
			printf("%lu\n",a[j]);
		}

		switch(choice){
		case 1:

			myDmaConfig1 = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
			status = XAxiDma_CfgInitialize(&myDma1, myDmaConfig1);
			if(status != XST_SUCCESS){
				print("DMA initialization 1 failed\n");
				return -1;
			}

			//xil_printf("Status before data transfer %0x\n",status);
			Xil_DCacheFlush();

			status = XAxiDma_SimpleTransfer(&myDma1, (u32)a, 2*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);
			if(status != XST_SUCCESS){
				print("DMA1 Transfer failed\n");
				return -1;
			}
			while (XAxiDma_Busy(&myDma1, XAXIDMA_DMA_TO_DEVICE)) {}

			status = XAxiDma_SimpleTransfer(&myDma1, (u32)b, 1*sizeof(u32),XAXIDMA_DEVICE_TO_DMA);
			while (XAxiDma_Busy(&myDma1, XAXIDMA_DEVICE_TO_DMA)) {}
			//print("DMA transfer success..\n");

			for(int i=0;i<1;i++)
				xil_printf("The summation is = %0d\n",b[i]);

			xil_printf("Enter something to continue\n\r");
			scanf("%s",&d);
			break;

		case 2:

			myDmaConfig2 = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_1_BASEADDR);
			status = XAxiDma_CfgInitialize(&myDma2, myDmaConfig2);
			if(status != XST_SUCCESS){
				print("DMA initialization 2 failed\n");
				return -1;
			 }

			//xil_printf("Status before data transfer %0x\n",status);
			Xil_DCacheFlush();

			status = XAxiDma_SimpleTransfer(&myDma2, (u32)a, 2*sizeof(u32),XAXIDMA_DMA_TO_DEVICE);
			if(status != XST_SUCCESS){
				print("DMA2 Transfer failed\n");
				return -1;
			}
			while (XAxiDma_Busy(&myDma2, XAXIDMA_DMA_TO_DEVICE)) {}

			status = XAxiDma_SimpleTransfer(&myDma2, (u32)c, 1*sizeof(u32),XAXIDMA_DEVICE_TO_DMA);
			if(status != XST_SUCCESS){
				print("DMA initialization failed\n");
				return -1;
			}
			while (XAxiDma_Busy(&myDma2, XAXIDMA_DEVICE_TO_DMA)) {}
			//print("DMA transfer success..\n");

			for(int i=0;i<1;i++)
					xil_printf("The multiplication is = %0d\n",c[i]);

			xil_printf("Enter something to continue\n\r");
			scanf("%s",&d);
			break;

		case 3:
			xil_printf("\n!!! Program is Exited !!!\nRerun to continue\n");
			return 0;

		default:
			xil_printf("Wrong choice\n");
			break;
		}
    }
	return 0;
}

