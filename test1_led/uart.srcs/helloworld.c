/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
*/

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xscugic.h"

#include "xuartps.h"
#include "xuartps_hw.h"

#include "sleep.h"

#define UART_DEVICE_ID0           XPAR_XUARTPS_0_DEVICE_ID
#define UART_DEVICE_ID1           XPAR_XUARTPS_1_DEVICE_ID


//#define UART_INT_IRQ_ID    XPAR_XUARTPS_0_INTR  //uart0 interupt id



int Uartinit0(u16 DeviceId);
int Uartinit1(u16 DeviceId);

int Uart_Send(XUartPs* Uart_Ps, u8 *sendbuf, int length);

//void Handler(void *CallBackRef);
//void Uart_Intr_System(XScuGic *Intc, XUartPs *Uart_Ps, u16 UartIntrId);

XUartPs Uart_Ps0;		// data structure
XUartPs Uart_Ps1;
//XScuGic Intc;              // interrupt





int main(void)
{
	init_platform();
	int Status0;
	int Status1;

	xil_printf("Hello World\n\r");

	u32 UartBaseAddress0 = 0xE0000000;
	u32 UartBaseAddress1 = 0xE0001000;
	u8 RecvChar;


	u8 sendbuf[] = "ABCDEFGABCDEFGABCDEF";



	Status0 = Uartinit0(UART_DEVICE_ID0);
		if (Status0 == XST_FAILURE) {
			xil_printf("Uartps0 Failed\r\n");
			return XST_FAILURE;
		}

	Status1 = Uartinit1(UART_DEVICE_ID1);
			if (Status1 == XST_FAILURE) {
				xil_printf("Uartps1 Failed\r\n");
				return XST_FAILURE;
		}

// uart1 is connected to EMIO, send data to PL
	Uart_Send(&Uart_Ps1, sendbuf, 20);


	if (XUartPs_IsSending(&Uart_Ps1)){
		xil_printf("sending\r\n");
	}


		while (1) {
			//there is receive data in the uart1 receiver£¬from pl£»
			//  this byte is transmitted via UART0 to the PC.
			if (XUartPs_IsReceiveData(UartBaseAddress1)) {
				RecvChar = XUartPs_ReadReg(UartBaseAddress1, XUARTPS_FIFO_OFFSET);
				XUartPs_WriteReg(UartBaseAddress0,  XUARTPS_FIFO_OFFSET, RecvChar);
			}
			//if (XUartPs_IsReceiveData(UartBaseAddress0)) {
			//	RecvChar = XUartPs_ReadReg(UartBaseAddress1, XUARTPS_FIFO_OFFSET);
			//	XUartPs_WriteReg(UartBaseAddress0,  XUARTPS_FIFO_OFFSET, RecvChar);
			//}
		}


    cleanup_platform();
	return 0;
}



int Uartinit0(u16 DeviceId)
{

	int Status;
	XUartPs_Config *Config;

	Config = XUartPs_LookupConfig(DeviceId);  // Return pointer to configuration structure
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(&Uart_Ps0, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// UART self-test
    Status = XUartPs_SelfTest(&Uart_Ps0);
    if (Status != XST_SUCCESS)
    return XST_FAILURE;

	//work mode
    XUartPs_SetOperMode(&Uart_Ps0, XUARTPS_OPER_MODE_NORMAL);
	XUartPs_SetBaudRate(&Uart_Ps0, 115200);

	// interrupt
	// receive trigger level specifies the number of bytes in the receive FIFO
	//that cause interrupt to be generated
    // XUartPs_SetFifoThreshold(&Uart_Ps0, 8);

	return XST_SUCCESS;
	}



int Uartinit1(u16 DeviceId)
{

	int Status;
	XUartPs_Config *Config;

	Config = XUartPs_LookupConfig(DeviceId);  // Return pointer to configuration structure
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(&Uart_Ps1, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	// UART self-test
    Status = XUartPs_SelfTest(&Uart_Ps1);
    if (Status != XST_SUCCESS)
      return XST_FAILURE;

	//work mode
    XUartPs_SetOperMode(&Uart_Ps1, XUARTPS_OPER_MODE_NORMAL);
	XUartPs_SetBaudRate(&Uart_Ps1, 115200);

	return XST_SUCCESS;
	}


// interupt


//-------------- send function

int Uart_Send(XUartPs* Uart_Ps, u8 *sendbuf, int length)
{
	int SentCount = 0;

	while (SentCount < length) {
		SentCount += XUartPs_Send(Uart_Ps, &sendbuf[SentCount], 1);
	}

	return SentCount;
}









