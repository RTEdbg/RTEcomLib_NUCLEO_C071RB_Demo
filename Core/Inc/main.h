/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file           : main.h
  * @brief          : Header for main.c file.
  *                   This file contains the common defines of the application.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "stm32c0xx_hal.h"
#include "stm32c0xx_ll_dma.h"
#include "stm32c0xx_ll_iwdg.h"
#include "stm32c0xx_ll_rcc.h"
#include "stm32c0xx_ll_crs.h"
#include "stm32c0xx_ll_bus.h"
#include "stm32c0xx_ll_system.h"
#include "stm32c0xx_ll_exti.h"
#include "stm32c0xx_ll_cortex.h"
#include "stm32c0xx_ll_utils.h"
#include "stm32c0xx_ll_pwr.h"
#include "stm32c0xx_ll_usart.h"
#include "stm32c0xx_ll_gpio.h"

/* Private includes ----------------------------------------------------------*/
/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

/* Exported types ------------------------------------------------------------*/
/* USER CODE BEGIN ET */

/* USER CODE END ET */

/* Exported constants --------------------------------------------------------*/
/* USER CODE BEGIN EC */

//***** RTEcom demo specific definitions *****
#define RTECOM_SINGLE_WIRE           0  // 1 - single-wire communication, 0 - two wire communication
#define RTECOM_READ_ENABLED          0  // 1 - Enable the read from memory (debugging support)
                                        // 0 - read from embedded system memory disabled
#define RTECOM_READ_FROM_PERIPHERALS 0  // 1 - atomic 16-bit/32-bit read from RAM or peripheral register enabled
                                        // 0 - byte by byte read from memory or peripherals
#define RTECOM_WRITE_ENABLED         0  // 1 - Enable the write data to memory (debugging support)
                                        // 0 - write to embedded system memory disabled

// Only if a timeout is implemented for receiving messages from the host, the following two macros must be defined.
// Macro RTECOM_LOG_TIME_LAST_DATA_RECEIVED() stores time of the last message reception from the host.
#define RTECOM_LOG_TIME_LAST_DATA_RECEIVED()   uwTick_last_byte_received = uwTick
#define RTECOM_TIMEOUT           100U   // Message reception timeout in ms (unfinished message from host)
    // Note: For single wire communication, the timeout must be longer than the data send time.

// If an inline rte_com_send_data() function is implemented, define the file name of the header with implementation
#define RTECOM_SERIAL_DRIVER "Portable/rte_com_STM32_driver.h"

// Definitions for the rte_com_send_data() function in the rte_com_STM32_driver.h
#define STM32_DMA_UNIT          DMA1
#define STM32_LL_DMA_CHANNEL    LL_DMA_CHANNEL_1
#define STM32_USART             USART2

/* USER CODE END EC */

/* Exported macro ------------------------------------------------------------*/
/* USER CODE BEGIN EM */

/* USER CODE END EM */

/* Exported functions prototypes ---------------------------------------------*/
void Error_Handler(void);

/* USER CODE BEGIN EFP */
#if defined RTECOM_TIMEOUT
extern uint32_t uwTick_last_byte_received;
#endif

/* USER CODE END EFP */

/* Private defines -----------------------------------------------------------*/
#define BUTTON_Pin LL_GPIO_PIN_13
#define BUTTON_GPIO_Port GPIOC
#define BUTTON_EXTI_IRQn EXTI4_15_IRQn
#define LD1_Pin LL_GPIO_PIN_5
#define LD1_GPIO_Port GPIOA
#define LD2_Pin LL_GPIO_PIN_9
#define LD2_GPIO_Port GPIOC

/* USER CODE BEGIN Private defines */

/* USER CODE END Private defines */

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
