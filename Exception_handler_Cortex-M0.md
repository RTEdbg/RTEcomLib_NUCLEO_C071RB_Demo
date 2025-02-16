# Exception Handler Demo for Cortex-M0

In this repository, the demo code for logging the processor registers is located in the following files:
* `./Core/Startup/startup_stm32c071rbtx.s` &rarr; Default_Handler - default exception handler (assembly)
* `./Core/Src/main.c` &rarr; log_exception() - the C part of the exception handler
* `./RTEdbg/Fmt/cortex_M0_fault_fmt.h` &rarr; Format definition for the exception handler

This demo demonstrates a relatively simple way to log processor registers when a system exception or unhandled interrupt occurs. This basic version of the exception handler is suitable for projects that only use the Main Stack Pointer (MSP).  The contents of the CPU core registers occupy 18 words of the stack. If more than 18 words are logged, it is considered a stack dump. In the demo code, 30 words are logged into a circular buffer, which means that in addition to the contents of the 18 registers, an additional 12 words of the stack are logged. Both functions together (Default_Handler and log_exception) use only 40 bytes of program memory.

The same exception handler can be used for ARM Cortex-M0 and M0+ processors. The only minor difference is the ICSR register, but the formatting definitions for printing values are designed to be compatible with both processor core types. The registers can be arranged in any order in the stack, as the RTEdbg functionality allows to specify which values are printed first, regardless of their order in memory or in the logged message.

In `startup_stm32c071rbtx.s` the added code for the exception handler (see `Default_Handler`) replaces the infinite loop of the default exception handler. This  handler is triggered for all exceptions or interrupts that do not have a dedicated service routine implemented by the programmer. As a result, logging is performed not only for HardFault and NMI, but also for any interrupt without an associated service routine.

When generating the initial demo code with the STM32CubeMX, the generation of default handlers for interrupts that do not have their own service routines implemented in the project was disabled - see "STM32CubeMX => NVIC Mode and Configuration => Code Generation - Enabled interrupt table".

**Notes:**
1. To trigger a hard fault exception and test the exception handler, press the B1 (USER) button on the NUCLEO-C071RB board twice. This causes a read from an incorrect address, triggering a hard fault.
1. When the exception handler is entered, the registers R0-R3, R12, LR, PC, and xPSR are already stored on the stack. For robust programming, it is advisable to check if there is enough space on the stack for additional registers before saving them to avoid another fatal error that could prevent the completion of the data logging.
2. For projects with an RTOS where the PSP (Program Stack Pointer) is used during task execution, the following must also be considered. When the processor throws an exception, unless it is a tail-chained or late-arriving exception, the processor pushes information onto the current stack. Therefore, when entering the exception handler, it must first check which stack pointer (MSP or PSP) was in use before the exception or interrupt was thrown. In this case, exception logging can be done as shown in the exception handler demo for processors with ARM Cortex-M4 and M7 cores - see [Cortex-M4/M7 exception handler](https://github.com/RTEdbg/RTEdbgDemo/blob/master/Simple_STM32H743\RTEdbg\Demo_code\Cortex_M4-M7_fault_handler.md).
3. If you are interested in how data is passed from assembly code to C code, read the [ARM Procedure Call Standard](https://developer.arm.com/documentation/den0013/d/Application-Binary-Interfaces/Procedure-Call-Standard).
4. If you want to learn more about exception handlers, read [Segger AN00016 - Analyzing HardFaults on Cortex-M CPU](https://www.segger.com/downloads/application-notes/AN00016).

<br>

If you are going to do a large stack dump along with the CPU registers, there are also a few things to keep in mind:
1. Do not dump such a large chunk of stack memory that it would require reading beyond the upper RAM address, which could cause a fatal error during the dump (preventing the dump from being completed and possibly leading to a CPU lockup).
2. Do not log an excessively long dump of exception stack data, which could fill too much of the circular buffer and result in the loss of previously logged content before the exception was thrown.

<br>

## Snippets of code from the demo

**Example of exception handler for devices with a ARM Cortex-M0/M0+ core (startup_stm32c071xx.s) **
```asm
Default_Handler:
/* Note: This is a simplified version of the exception handler. It assumes that
 *       the MSP was used. See the 'Exception_handler_Cortex-M0.md' for details.
 */

	// R0-R3, R12, LR, PC and xPSR are pushed automatically
    push {r4-r7}	// Push the remaining 'low' core registers

    /* Get high registers R8-R11 into low registers since Cortex-M0/M0+
       can only push low registers */
    mov r0, r8
    mov r1, r9
    mov r2, r10
    mov r3, r11
    push {r0-r3}

    /* Push the SP value. */
    mov r1, sp
    push {r1}

    /* Push the ICSR register - pending and active exception vector info */
    ldr r0, =0xE000ED04    // ICSR register address
    ldr r0, [r0]
    push {r0}

	/* The function for logging the stack contents, where the processor has stored
	 * the registers, is started from C because it is easier to implement that way.
	 * A programmer does not need to know the details of the implementation of
	 * RTEdbg functions and macros for logging data.
	 *
	 * The SP address where the registers are is passed to Exception_handler() in
	 * register R1 and the ICSR (Interrupt control and state register) value in R0.
	 */
    mov r1, sp
    b log_exception
```
**Note:** For the robustness of the firmware it's advisable to check if there is still space for additional data (processor registers) in the stack. If during the execution of the HardFault service routine on a Cortex-M0/M0+ processor another exception occurs (e.g. NMI or HardFault), the processor enters the lockup state and can only be awakened by a reset (e.g. Watch-Dog).

<br>

**Data logging for the exception handler in the startup file (main.c)**
```C
void __NO_RETURN __attribute__((naked)) log_exception(uint32_t icsr_reg, const uint32_t *sp)
{
    UNUSED(icsr_reg); // Mark parameter as unused to suppress compiler warnings
    /* The 'icsr_reg' value may be used to check which exception vector is active.
     * Based on this, for example, logging can include either fewer details than
     * in this case or even additional ones.
     */

    // Log the exception details using the RTE_MSGN macro
    RTE_MSGN(MSGN_FATAL_EXCEPTION, F_SYSTEM, sp, 4U * (18U + 12U));
    /* Legend:
     *      MSGN_FATAL_EXCEPTION - Format code name
     *      F_SYSTEM - Message filter number
     *      sp - Address of the stack where the pushed registers are stored
     *      4 * (18 + 12) - Size of the CPU register data to be logged
     *          18 - Number of CPU registers pushed to the stack
     *          12 - Log 12 words of stack data additionally (stack dump example).
     *          4U - Size of each register (32-bit)
     */

    /* Add custom code here to handle the exception.
     * For example:
     * - Set peripherals to an inactive state
     * - Perform a software reset to restart the system
     */

    // Infinite loop to prevent the function from returning
    for (;;)
        ;
}
```

<br>

**Formatting definition for the exception handler in this demo - prints the logged exception data (cortex_M0_fault_fmt.h)) **
```
// MSGN_FATAL_EXCEPTION
#define MSGN_FATAL_EXCEPTION 16U
// "\nCPU registers"
// "\n  R00:0x%[320:32u]08X, R01:0x%08X, R02:0x%08X, R03:0x%08X"
// "\n  R04:0x%[192:32u]08X, R05:0x%08X, R06:0x%08X, R07:0x%08X"
// "\n  R08:0x%[64:32u]08X, R09:0x%08X, R10:0x%08X, R11:0x%08X"
// "\n  R12:0x%[448:32u]08X,  SP:0x%[32:32u](+64)08X,  LR:0x%[480:32u]08X,  PC:0x%[512:32u]08X"
// "\n  xPSR:0x%[544:32u]08X, Flags: V=%[-4:1]u, C=%[1]u, Z=%[1]u, N=%[1]u"
// <EXC_NAMES "\n     Interrupted exception: #%[-32:6u]d - %[-6:6]Y (vector table address: 0x%[-6:6u](*4)02X)"
// "\n  ICSR: 0x%[0:32u]08X"
// <EXC_NAMES "\n     Active exception: #%[-32:9u]u - %[-9:9u]Y (vector table address: 0x%[-9:9u](*4)02X)"
// <EXC_NAMES "\n     Pending exception: #%[+3:9u]u - %[-9:9u]Y (vector table address: 0x%[-9:9u](*4)02X)"
// "%[+1:1u]{ |\n     Interrupt is pending}Y"
// "%[+0:1u]{ |\n     Services a pending exception}Y"
// "%[+2:1u]{ |\n     SysTick exception is pending}Y"
// "%[+1:1u]{ |\n     PendSV exception is pending}Y"
// "%[+2:1u]{ |\n     NMI exception is pending}Y"
/* Delete the last string of format definition (starting with "%[544:32u]) in case no stack dump will be logged. */
/* Note: The "%[544:32u]{ | }Y" is a dummy print to set the address from which the stack data begins. */
// "%[544:32u]{ | }Y\nStack dump (hex)%4H"
```
Notes:
1. The "#define MSGN_FATAL_EXCEPTION 16U" is automatically inserted during the precompile phase.
2. The "%[64:32u]08X" is an example of how to set the address of the first bit and the size of a value to be printed. The value starts at bit 64 (third word), has a size of 32 bits and is an unsigned integer.
3. If only 18 words are logged, then nothing is displayed for "Stack dump (hex)".

<br>

**Example of decoding logged data - displaying register contents and stack contents before exception state.**
```
N00528 33139,171 MSGN_FATAL_EXCEPTION: 
CPU registers
  R00:0x40833FF0, R01:0x40833FF1, R02:0x20000000, R03:0x07000000
  R04:0x200020A0, R05:0x00000B0A, R06:0x00000100, R07:0x0000AAAA
  R08:0xFFFFFFFF, R09:0xFFFFFFFF, R10:0xFFFFFFFF, R11:0xFFFFFFFF
  R12:0xFFFFFFFF,  SP:0x20005F70,  LR:0x0800070D,  PC:0x08000716
  xPSR:0x01000017, Flags: V=0, C=0, Z=0, N=0
     Interrupted exception: #23 - IRQx (vector table address: 0x5C)
  ICSR: 0x00426003
     Active exception: #3 - HardFault (vector table address: 0x0C)
     Pending exception: #38 - IRQx (vector table address: 0x98)
     Interrupt is pending     
Stack dump (hex)
  0: 00000002 FFFFFFF9 00000000 00000B0A 
 10: 00000000 200020A4 FFFFFFFF 08000829 
 20: 08000806 81000000 40003000 200020A4 
```
The stack pointer (SP) points to the location as it was before the exception was thrown.

Legend:
* N00528 - sequential numbers of the decoded message
* 33139,171 - time in milliseconds (time at which this message was logged)
* MSGN30_FATAL_EXCEPTION - format code name