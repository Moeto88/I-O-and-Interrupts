  .equ    GPIOD_BASE, 0x40020C00
  .equ    GPIOD_MODER, (GPIOD_BASE + 0x00)
  .equ    GPIOD_OTYPER, (GPIOD_BASE + 0x04)
  .equ    GPIOD_OSPEEDR, (GPIOD_BASE + 0x08)
  .equ    GPIOD_PUPDR, (GPIOD_BASE + 0x0C)
  .equ    GPIOD_IDR, (GPIOD_BASE + 0x10)
  .equ    GPIOD_ODR, (GPIOD_BASE + 0x14)
  .equ    GPIOD_BSRR, (GPIOD_BASE + 0x18)
  .equ    GPIOD_LCKR, (GPIOD_BASE + 0x1C)
  .equ    GPIOD_AFRL, (GPIOD_BASE + 0x20)
  .equ    GPIOD_AFRH, (GPIOD_BASE + 0x24)

  .equ    RCC_BASE, 0x40023800
  .equ    RCC_AHB1ENR, (RCC_BASE + 0x30)
  .equ    RCC_AHB1ENR_GPIODEN, 0x08

  .equ    SCB_BASE, 0xE000ED00
  .equ    SCB_ICSR, (SCB_BASE + 0x04)

  .equ    SCB_ICSR_PENDSTCLR, (1<<25)

  .equ    SYSTICK_BASE, 0xE000E010
  .equ    SYSTICK_CSR, (SYSTICK_BASE + 0x00)
  .equ    SYSTICK_LOAD, (SYSTICK_BASE + 0x04)
  .equ    SYSTICK_VAL, (SYSTICK_BASE + 0x08)

  .equ    NVIC_ISER, 0xE000E100

  .equ    EXTI_BASE, 0x40013C00
  .equ    EXTI_IMR, (EXTI_BASE + 0x00)
  .equ    EXTI_RTSR, (EXTI_BASE + 0x08)
  .equ    EXTI_FTSR, (EXTI_BASE + 0x0C)
  .equ    EXTI_PR, (EXTI_BASE + 0x14)

  .equ    LD3_PIN, 13 
  .equ    LD4_PIN, 12
  .equ    LD5_PIN, 14
  .equ    LD6_PIN, 15
  