/**
  ******************************************************************************
  * @file      startup_stm32c071xx.s
  * @author    MCD Application Team
  * @brief     STM32C071xx devices vector table GCC toolchain.
  *            This module performs:
  *                - Set the initial SP
  *                - Set the initial PC == Reset_Handler,
  *                - Set the vector table entries with the exceptions ISR address,
  *                - Configure the clock system
  *                - Branches to main in the C library (which eventually
  *                  calls main()).
  *            After Reset the Cortex-M0+ processor is in Thread mode,
  *            priority is Privileged, and the Stack is set to Main.
  *******************************************************************************
  * @attention
  *
  * Copyright (c) 2022 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  *******************************************************************************
  */

  .syntax unified
	.cpu cortex-m0plus
	.fpu softvfp
	.thumb

.global	g_pfnVectors
.global	Default_Handler

/* start address for the initialization values of the .data section.
defined in linker script */
.word _sidata
/* start address for the .data section. defined in linker script */
.word _sdata
/* end address for the .data section. defined in linker script */
.word _edata
/* start address for the .bss section. defined in linker script */
.word _sbss
/* end address for the .bss section. defined in linker script */
.word _ebss

  .section .text.Reset_Handler
  .weak Reset_Handler
  .type Reset_Handler, %function
Reset_Handler:
  ldr   r0, =_estack
  mov   sp, r0          /* set stack pointer */
/* Call the clock system initialization function.*/
  bl  SystemInit

/* Copy the data segment initializers from flash to SRAM */
  movs r1, #0
  b LoopCopyDataInit

CopyDataInit:
  ldr r3, =_sidata
  ldr r3, [r3, r1]
  str r3, [r0, r1]
  adds r1, r1, #4

LoopCopyDataInit:
  ldr r0, =_sdata
  ldr r3, =_edata
  adds r2, r0, r1
  cmp r2, r3
  bcc CopyDataInit
  ldr r2, =_sbss
  b LoopFillZerobss
/* Zero fill the bss segment. */
FillZerobss:
  movs r3, #0
  str  r3, [r2]
  adds r2, r2, #4


LoopFillZerobss:
  ldr r3, = _ebss
  cmp r2, r3
  bcc FillZerobss


/* Call static constructors */
  bl __libc_init_array
/* Call the application's entry point.*/
  bl main

LoopForever:
    b LoopForever


.size Reset_Handler, .-Reset_Handler

/**
 * @brief  This is the code that gets called when the processor receives an
 *         unexpected interrupt or exception.
 *
 * @param  None
 * @retval : None
*/
    .section .text.Default_Handler,"ax",%progbits
Default_Handler:
/* Note: This is a simplified version of the exception handler. It assumes that
 *       the MSP was used. See the 'Exception_handler_Cortex-M0.md' for details.
 *       There are already some registers on the stack when the CPU enters the
 *       fault service routine. Additional registers are pushed onto the stack
 *       later. It is used as a buffer or data structure with the data it is
 *       logging. It is recommended to check if there is enough space before
 *       pushing additional content onto the stack.
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
/*********************************************************************************/


  .size Default_Handler, .-Default_Handler
/******************************************************************************
*
* The minimal vector table for a Cortex M0.  Note that the proper constructs
* must be placed on this to ensure that it ends up at physical address
* 0x0000.0000.
*
******************************************************************************/
   .section .isr_vector,"a",%progbits
  .type g_pfnVectors, %object


g_pfnVectors:
  .word  _estack
  .word  Reset_Handler
  .word  NMI_Handler
  .word  HardFault_Handler
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  0
  .word  SVC_Handler
  .word  0
  .word  0
  .word  PendSV_Handler
  .word  SysTick_Handler
  .word  WWDG_IRQHandler                   /* Window WatchDog                             */
  .word  PVD_VDDIO2_IRQHandler             /* PVD through EXTI Line detect                */
  .word  RTC_IRQHandler                    /* RTC through the EXTI line                   */
  .word  FLASH_IRQHandler                  /* FLASH                                       */
  .word  RCC_CRS_IRQHandler                /* RCC, CRS                                    */
  .word  EXTI0_1_IRQHandler                /* EXTI Line 0 and 1                           */
  .word  EXTI2_3_IRQHandler                /* EXTI Line 2 and 3                           */
  .word  EXTI4_15_IRQHandler               /* EXTI Line 4 to 15                           */
  .word  USB_DRD_FS_IRQHandler             /* USB Dual Role                               */
  .word  DMA1_Channel1_IRQHandler          /* DMA1 Channel 1                              */
  .word  DMA1_Channel2_3_IRQHandler        /* DMA1 Channel 2 and Channel 3                */
  .word  DMAMUX1_DMA1_CH4_5_IRQHandler     /* DMAMUX1, DMA1 Channel 4 and 5               */
  .word  ADC1_IRQHandler                   /* ADC1                                        */
  .word  TIM1_BRK_UP_TRG_COM_IRQHandler    /* TIM1 Break, Update, Trigger and Commutation */
  .word  TIM1_CC_IRQHandler                /* TIM1 Capture Compare                        */
  .word  TIM2_IRQHandler                   /* TIM2                                        */
  .word  TIM3_IRQHandler                   /* TIM3                                        */
  .word  0                                 /* reserved                                    */
  .word  0                                 /* reserved                                    */
  .word  TIM14_IRQHandler                  /* TIM14                                       */
  .word  0                                 /* reserved                                    */
  .word  TIM16_IRQHandler                  /* TIM16                                       */
  .word  TIM17_IRQHandler                  /* TIM17                                       */
  .word  I2C1_IRQHandler                   /* I2C1                                        */
  .word  I2C2_IRQHandler                   /* I2C1                                        */
  .word  SPI1_IRQHandler                   /* SPI1                                        */
  .word  SPI2_IRQHandler                   /* SPI1                                        */
  .word  USART1_IRQHandler                 /* USART1                                      */
  .word  USART2_IRQHandler                 /* USART2                                      */
  .word  0                                 /* reserved                                    */
  .word  0                                 /* reserved                                    */
  .word  0                                 /* reserved                                    */

  .size g_pfnVectors, .-g_pfnVectors
/*******************************************************************************
*
* Provide weak aliases for each Exception handler to the Default_Handler.
* As they are weak aliases, any function with the same name will override
* this definition.
*
*******************************************************************************/

  .weak      NMI_Handler
  .thumb_set NMI_Handler,Default_Handler

  .weak      HardFault_Handler
  .thumb_set HardFault_Handler,Default_Handler

  .weak      SVC_Handler
  .thumb_set SVC_Handler,Default_Handler

  .weak      PendSV_Handler
  .thumb_set PendSV_Handler,Default_Handler

  .weak      SysTick_Handler
  .thumb_set SysTick_Handler,Default_Handler

  .weak      WWDG_IRQHandler
  .thumb_set WWDG_IRQHandler,Default_Handler
  
  .weak      PVD_VDDIO2_IRQHandler
  .thumb_set PVD_VDDIO2_IRQHandler,Default_Handler

  .weak      RTC_IRQHandler
  .thumb_set RTC_IRQHandler,Default_Handler

  .weak      FLASH_IRQHandler
  .thumb_set FLASH_IRQHandler,Default_Handler

  .weak      RCC_CRS_IRQHandler
  .thumb_set RCC_CRS_IRQHandler,Default_Handler

  .weak      EXTI0_1_IRQHandler
  .thumb_set EXTI0_1_IRQHandler,Default_Handler

  .weak      EXTI2_3_IRQHandler
  .thumb_set EXTI2_3_IRQHandler,Default_Handler

  .weak      EXTI4_15_IRQHandler
  .thumb_set EXTI4_15_IRQHandler,Default_Handler
  
  .weak      USB_DRD_FS_IRQHandler
  .thumb_set USB_DRD_FS_IRQHandler,Default_Handler  

  .weak      DMA1_Channel1_IRQHandler
  .thumb_set DMA1_Channel1_IRQHandler,Default_Handler

  .weak      DMA1_Channel2_3_IRQHandler
  .thumb_set DMA1_Channel2_3_IRQHandler,Default_Handler

  .weak      DMAMUX1_DMA1_CH4_5_IRQHandler
  .thumb_set DMAMUX1_DMA1_CH4_5_IRQHandler,Default_Handler

  .weak      ADC1_IRQHandler
  .thumb_set ADC1_IRQHandler,Default_Handler

  .weak      TIM1_BRK_UP_TRG_COM_IRQHandler
  .thumb_set TIM1_BRK_UP_TRG_COM_IRQHandler,Default_Handler

  .weak      TIM1_CC_IRQHandler
  .thumb_set TIM1_CC_IRQHandler,Default_Handler

  .weak      TIM2_IRQHandler
  .thumb_set TIM2_IRQHandler,Default_Handler

  .weak      TIM3_IRQHandler
  .thumb_set TIM3_IRQHandler,Default_Handler

  .weak      TIM14_IRQHandler
  .thumb_set TIM14_IRQHandler,Default_Handler

  .weak      TIM16_IRQHandler
  .thumb_set TIM16_IRQHandler,Default_Handler

  .weak      TIM17_IRQHandler
  .thumb_set TIM17_IRQHandler,Default_Handler

  .weak      I2C1_IRQHandler
  .thumb_set I2C1_IRQHandler,Default_Handler
  
  .weak      I2C2_IRQHandler
  .thumb_set I2C2_IRQHandler,Default_Handler  

  .weak      SPI1_IRQHandler
  .thumb_set SPI1_IRQHandler,Default_Handler
  
  .weak      SPI2_IRQHandler
  .thumb_set SPI2_IRQHandler,Default_Handler  

  .weak      USART1_IRQHandler
  .thumb_set USART1_IRQHandler,Default_Handler

  .weak      USART2_IRQHandler
  .thumb_set USART2_IRQHandler,Default_Handler

