# Transfer recorded data to the host via a serial channel (Demo for STM32C0)

![LogoRTEdbg–small](https://github.com/RTEdbg/RTEdbg/assets/144953452/e123f541-1d05-44ca-a85e-34a7abeded22)

## Introduction

**This repository contains a library of functions, a sample driver for a family of microcontrollers, and demonstration code for transferring data to a host over a serial channel.** 
The RTEcomLib library is part of the RTEdbg toolkit. See the **[RTEdbg main repository](https://github.com/RTEdbg/RTEdbg)** for the complete toolkit description and links to documentation and other repositories.

The code in this repository demonstrates:
1. How to transfer data logged with the RTEdbg library to the host over a serial channel. The demo shows how to transfer data between the embedded system and the host over a two-wire and a single-wire (half-duplex) connection. Single-wire communication is especially useful for microcontrollers with a very limited number of pins or where almost all pins are busy.
2. How to implement an exception handler for ARM Cortex-M0/M0+ that logs the contents of CPU registers and part of the stack with minimal program memory usage - see **[Exception_handler_Cortex-M0.md](./Exception_handler_Cortex-M0.md)** for details. <br> **Note:** The hard fault is triggered after pressing key B1 (blue key on the NUCLEO-C071RB board) twice. A hard fault has a very high (fixed) priority. When the processor enters this handler, it stops executing lower-priority code and thus stops the reception of data from the serial channel in the `USART2_IRQHandler()`. In this demo, data transfer to the host is re-enabled after the watchdog resets the processor.

Serial data transfer can also be used if transfers with the RTEgetData utility using GDB server protocol in parallel with the IDE's built-in debugger are not possible, or if it would limit the functionality of debugging (e.g. if it would be necessary to disable the Live View functionality).

The serial channel in the demo is initialized with the following parameters:
* Number of bits: 8
* Parity: none
* Stop bits: 1

Data transfer to the host is possible with the **[RTEgetData](https://github.com/RTEdbg/RTEgetData)** utility. See the data transfer batch file examples in `ReadData-COM-Once.bat` and `ReadData-COM-Persistent.bat`.

In the demo code, the focus is on displaying the data transfer rather than logging. The firmware only logs the following events
- Type of reset after reset (power-on, watch-dog, from NRST pin, ...)
- Periodic watchdog update (IWDG)
- Start of the interrupt program EXTI4_15_IRQHandler() by key B1 (blue key on the NUCLEO-C071RB board)

This code is also a demonstration that logging continues normally after a system reset - e.g. watchdog, reset with key B1 (black key on the demo board). The watchdog reset occurs after about 16 seconds, because the IWDG counter is no longer refreshed after 10 seconds.

The source code for the data transfer functions in the RTEcomLib folder - see the serial communication library [Readme](./RTEcomLib/Readme.md) for details.

### Communicating in a Noisy Environment
If serial communication is used in an electrically noisy environment, the following measures should be taken:
1. Keep the connection to the host as short as possible, use twisted and/or shielded cable, filtering, etc.
2. Enable parity on the serial link.
3. Implement the timeout for data reception in the embedded system - see the example of implementation in the `main.c` demo file <br> `#if defined RTECOM_TIMEOUT ...` <br>
**Alternative Implementation:** 
In the data reception function (in the demo, this is `USART2_IRQHandler()`), after receiving each byte, store the current time at the end of the function (e.g., `uwTick` if using an STM32). At the beginning of the function, check if the time difference is too large (greater than the timeout value). If so, reset the index to 0 (`g_rtecom.no_received = 0;`) and store the newly received data. <br>
This approach ensures that if a timeout occurs between received bytes, the reception buffer is reset, preventing partial or corrupted data sequences.

When the host and the embedded system get out of sync, the host data transfer utility should send either a BREAK sequence of bits or 10 consecutive characters with a value greater than RTECOM_LAST_COMMAND (e.g. 0xFF).
<br> **Note:** If a BREAK character is received, the USART will treat it as a framing error.

### How to test the two-wire or single-wire communication on the NUCLEO-C071RB demo board

The default setup enables two-wire communication. The ST-LINK v2 integrated on the NUCLEO PCB enables a serial communication (VCP of the ST-LINK). Nothing has to be done for a two-wire test. The RTECOM_SINGLE_WIRE compile time parameter has to be set to 0 to enable single-wire communication. The following modifications have to be done 
on the NUCLEO-C071RB also:
1. Connect one side of the 1k0 resistor to VCC (e.g. to CN7 - pin 7).
2. Connect the anode of a Schottky diode (e.g. BAT42) to CN10 - pin 6 (PA3).
3. Connect the cathode of the Schottky diode to CN10 - pin 18 (PA2). 
   <br> Connect the other side of the 1k0 resistor to this pin as well.

### Maximum baud rates
The maximum data transfer rate depends on
* The embedded system peripherals and their clock rates.
* The serial port used to transfer data to the host and its clock rate (in this example, the VCP peripheral in the on-board ST-LINK).
* Characteristics and length of the connection (e.g. cable) between the two serial ports, etc.
* And also the clock speed of the processor and the quality of the driver implementation for the serial channel - how many CPU cycles it takes to send and receive a single character. Transferring data to the host should not overload the CPU core, as this would interfere too much with the execution of the application in the embedded system.

On the NUCLEO-C071, the tested processor (STM32C071) and the processor implementing the ST-LINK v2 and USB VCP serial links are very close to each other. The transmission speed for two-wire communication is only limited by the maximum baud rate value that can be set for both serial interfaces, given the limitations of the serial peripherals and their clocks and prescalers. The maximum value that can be achieved is 1500 kbps. Correct speeds are also 1000 kbps, 600 kbps, 115200 bps, etc.

For single wire communication, the speeds are generally lower and depend mainly on the value of the pull-up resistor and the total capacitance (it depends mainly on the type and length of the cable). The minimum value of the pull-up resistor depends mainly on how much current the output MOSFET TxD pin of the processor can sink. In the case of the NUCLEO-C071RB conversion, a 1k00 pull-up resistor was used and the connections were very short. The maximum speed tested was 1500 kbps.

Very high baud rates are usually not useful for real-time projects because interrupts to receive messages from the host take CPU time away from the application under test. This is especially true for single-wire (half-duplex) communication, where each transmission to the host also triggers an interrupt because the serial peripheral receives what it sends. One solution to reduce the processor load at high communication speeds with single-wire communication would be to process the data received from the interrupt with a DMA unit.

To achieve faster transfer execution and less impact on the tested application, at least for the serial channel transfer functions, enable a higher level of compiler optimization and use optimized low-level code in the serial channel interrupt program to receive data from the host.

**Note:** More powerful processor cores include execution acceleration mechanisms such as write buffers and data caches. If DMA is used to transfer data to the host, either the message filter must be set to 0 and a memory barrier instruction must be executed before the transfer begins, or there must be some other way to ensure that the data is properly written to memory. In the case of a data cache, this can also be achieved by placing the `g_rtedbg' structure in a memory region configured with the write-through storage method.

Compare the initial version (v0.99) and latest version using e.g. WinMerge to see what has been done to integrate the RTEcomLib serial communication library and the RTElib data logging library.

## Notes on the STM32C071 Demo Project
The code of this project is intended to demonstrate functions for transferring logged and other data from the embedded system. The functions for transferring data over the serial channel are located in the file *RTEcomLib/rte_com*.c. The *RTEcomLib* folder also contains header files and a DMA driver for the STM32 processor family. The definitions of the various constants needed to compile the data transfer functions are located in the file *Core/Inc/main.h*.

The demo project code was generated using the STM32CubeMX. LL (Low Level Drivers) instead of the standard HAL was enabled for all peripheral drivers in "Project Manager => Advanced Options". The generated initialization code is far from what the author would consider low-level. It has not been optimized for general use - only the code in the `RTEcomLib` folder has been optimized. For your project, you may need to manually optimize the initialization code and remove any unnecessary components if you encounter problems with Flash memory space.

## How to contribute or get help
Follow the [Contributing Guidelines](https://github.com/RTEdbg/RTEdbg/blob/master/docs/CONTRIBUTING.md) for bug reports and feature requests regarding the RTEdbg library.

When asking a support question, be clear and take the time to explain your problem properly. If your problem is not strictly related to this project, we recommend that you use [Stack Overflow](https://stackoverflow.com/), [r/Embedded](https://www.reddit.com/r/embedded/) or similar question-and-answer website instead. First, check if the Readme.md files or [RTEdbg manual](https://github.com/RTEdbg/RTEdbg/releases/download/Documentation/RTEdbg.library.and.tools.manual.pdf) already contains an answer to your question or a solution to your problem.
