  .syntax unified
  .cpu cortex-m4
  .thumb
  .global Main
  .global SysTick_Handler
  .global EXTI0_IRQHandler

@ Uncomment if you are providing a EXTI0_IRQHandler subroutine
@  .global EXTI0_IRQHandler

  @ Definitions are in definitions.s to keep this file "clean"
  .include "definitions.s"

  .equ    BLINK_PERIOD, 500
  .equ    LD5, 16384
  .equ    LD3, 8192
  .equ    LD4, 4096
  .equ    LD6, 32768

@
@ To debug this program, you need to change your "Run and Debug"
@   configuration from "Emulate current ARM .s file" to "Graphic Emulate
@   current ARM .s file".
@
@ You can do this is either of the followig two ways:
@
@   1. Switch to the Run and Debug panel ("ladybug/play" icon on the left).
@      Change the dropdown at the top of the Run and Debug panel to "Graphic
@      Emulate current ARM .s file".
@
@   2. ctrl-shift-P (cmd-shift-P on a Mac) and type "Select and Start Debugging".
@      When prompted, select "Graphic Emulate ...".
@



Main:
  PUSH    {R4-R5,LR}


  @ Enable GPIO port D by enabling its clock
  LDR     R4, =RCC_AHB1ENR
  LDR     R5, [R4]
  ORR     R5, R5, RCC_AHB1ENR_GPIODEN
  STR     R5, [R4]


  @ Configure LD3,4,5,and 6 for output
  @ (by BIClearing then ORRing)
  LDR     R4, =GPIOD_MODER
  LDR     R5, [R4]                  @ Read ...
  BIC     R5, #(0b11<<(LD3_PIN*2))  @ Modify ...
  ORR     R5, #(0b01<<(LD3_PIN*2))  @ write 01 to bits 
  STR     R5, [R4]                  @ Write 

  LDR     R4, =GPIOD_MODER
  LDR     R5, [R4]                  @ Read ...
  BIC     R5, #(0b11<<(LD4_PIN*2))  @ Modify ...
  ORR     R5, #(0b01<<(LD4_PIN*2))  @ write 01 to bits 
  STR     R5, [R4]                  @ Write 

  LDR     R4, =GPIOD_MODER
  LDR     R5, [R4]                  @ Read ...
  BIC     R5, #(0b11<<(LD5_PIN*2))  @ Modify ...
  ORR     R5, #(0b01<<(LD5_PIN*2))  @ write 01 to bits 
  STR     R5, [R4]                  @ Write 

  LDR     R4, =GPIOD_MODER
  LDR     R5, [R4]                  @ Read ...
  BIC     R5, #(0b11<<(LD6_PIN*2))  @ Modify ...
  ORR     R5, #(0b01<<(LD6_PIN*2))  @ write 01 to bits 
  STR     R5, [R4]                  @ Write 


  @ We'll blink LEDs (the orange LED) every 1s
  @ Initialise the first countdown to 500 (500ms)

  LDR     R4, =countdown
  LDR     R5, =BLINK_PERIOD
  STR     R5, [R4]  


  @ Configure SysTick Timer to generate an interrupt every 1ms

  LDR     R4, =SYSTICK_CSR            @ Stop SysTick timer
  LDR     R5, =0                      @   by writing 0 to CSR
  STR     R5, [R4]                    @   CSR is the Control and Status Register
  
  LDR     R4, =SYSTICK_LOAD           @ Set SysTick LOAD for 1ms delay
  LDR     R5, =0x3E7F                 @ Assuming a 16MHz clock,
  STR     R5, [R4]                    @   16x10^6 / 10^3 - 1 = 15999 = 0x3E7F

  LDR     R4, =SYSTICK_VAL            @   Reset SysTick internal counter to 0
  LDR     R5, =0x1                    @     by writing any value
  STR     R5, [R4]

  LDR     R4, =SYSTICK_CSR            @   Start SysTick timer by setting CSR to 0x7
  LDR     R5, =0x7                    @     set CLKSOURCE (bit 2) to system clock (1)
  STR     R5, [R4]                    @     set TICKINT (bit 1) to 1 to enable interrupts
                                    @     set ENABLE (bit 0) to 1

  @ Enable (unmask) interrupts on external interrupt Line0
  LDR     R4, =EXTI_IMR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Set falling edge detection on Line0
  LDR     R4, =EXTI_FTSR
  LDR     R5, [R4]
  ORR     R5, R5, #1
  STR     R5, [R4]

  @ Enable NVIC interrupt #6 (external interrupt Line0)
  LDR     R4, =NVIC_ISER
  MOV     R5, #(1<<6)
  STR     R5, [R4]


  LDR     R4, =boolean        @ 
  LDR     R5, [R4]          @
  MOV     R5, #1        @    
  STR     R5, [R4]              

  @ Nothing else to do in Main
  @ Idle loop forever (welcome to interrupts!)
Idle_Loop:
  B     Idle_Loop
  
End_Main:

  POP     {R4-R5,PC}

  .type  EXTI0_IRQHandler, %function
EXTI0_IRQHandler:

  PUSH    {R4,R5,LR}

  LDR     R4, =boolean       
  LDR     R5, [R4]          @
  NEG     R5, R5

  STR     R5, [R4]          @

  LDR     R4, =EXTI_PR      @ Clear (acknowledge) the interrupt
  MOV     R5, #(1<<0)       @
  STR     R5, [R4]          @

  @ Return from interrupt handler
  POP    {R4,R5,PC}



@
@ SysTick interrupt handler
@
 .type  SysTick_Handler, %function
SysTick_Handler: 

  PUSH    {R4, R5, LR}

  CMP     R10, #1
  BEQ     flashAll

  LDR     R4, =boolean        @
  LDR     R5, [R4]          @
  CMP     R5, #0
  BGE     endSysTick

  ADD     R9, R9, #1

  CMP     R11, #1
  BEQ     turnOffFlashedLEDs


  

  LDR     R4, =countdown              @ if (countdown != 0) {
  LDR     R5, [R4]                    @
  CMP     R5, #0                      @
  BEQ   .LelseFire                  @

  SUB     R5, R5, #1                  @   countdown = countdown - 1;
  STR     R5, [R4]                    @

  B     .LendIfDelay                @ }

.LelseFire:                         @ else {

  CMP     R6, #0
  BNE     nextColour1
  LDR     R4, =GPIOD_ODR            @   Invert LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 
  ADD     R7, R7, #1                @ count++
  CMP     R7, #2
  BNE     lastCount
  MOV     R7, #0                    @ count = 0
  MOV     R6, #1                    @ LDIdentifier = 1
  B       lastCount

nextColour1:
  CMP     R6, #1
  BNE     nextColour2
  LDR     R4, =GPIOD_ODR            @   Invert LD4
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD4_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD4_PIN);
  STR     R5, [R4]                  @ 
  ADD     R7, R7, #1                @ count++
  CMP     R7, #2
  BNE     lastCount
  MOV     R7, #0                    @ count = 0
  MOV     R6, #2                    @ LDIdentifier = 2
  B       lastCount

nextColour2:
  CMP     R6, #2
  BNE     nextColour3
  LDR     R4, =GPIOD_ODR            @   Invert LD5
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD5_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD5_PIN);
  STR     R5, [R4]                  @ 
  ADD     R7, R7, #1                @ count++
  CMP     R7, #2
  BNE     lastCount
  MOV     R7, #0                    @ count = 0
  MOV     R6, #3                    @ LDIdentifier = 3
  B       lastCount

nextColour3:
  LDR     R4, =GPIOD_ODR            @   Invert LD6
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD6_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD6_PIN);
  STR     R5, [R4]                  @ 
  ADD     R7, R7, #1                @ count++
  CMP     R7, #2
  BNE     lastCount
  MOV     R7, #0                    @ count = 0
  MOV     R6, #0                    @ LDIdentifier = 0
  B       lastCount
 

lastCount:
  LDR     R4, =countdown            @   countdown = BLINK_PERIOD;
  LDR     R5, =BLINK_PERIOD         @
  STR     R5, [R4]                  @


.LendIfDelay:                       @ }

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  @ Return from interrupt handler
endSysTick:  
  CMP     R9, #0
  BEQ     final
  LDR     R4, =boolean        @
  LDR     R5, [R4]          @
  CMP     R5, #0
  BLT     final
  LDR     R4, =GPIOD_ODR            @  
  LDR     R5, [R4]                  @
  LDR     R8, =LD5
  CMP     R5, R8
  BEQ     success
  LDR     R8, =LD3
  CMP     R5, R8
  BEQ     turnOffLD3
  LDR     R8, =LD4
  CMP     R5, R8
  BEQ     turnOffLD4
  LDR     R8, =LD6
  CMP     R5, R8
  BEQ     turnOffLD6
final:  
  POP     {R4, R5, PC}

success:
  MOV     R10, #1
  B       final

flashAll:
  LDR     R4, =GPIOD_ODR            @   Turn off LD5
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD5_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn on LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn on LD4
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD4_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn on LD5
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD5_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn on LD6
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD6_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  MOV     R10, #0
  MOV     R11, #1

  B       final

turnOffFlashedLEDs:
  LDR     R4, =GPIOD_ODR            @   Turn off LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn off LD4
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD4_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn off LD5
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD5_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =GPIOD_ODR            @   Turn off LD6
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD6_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  MOV     R11, #0
  MOV     R7, #0                    @ count = 0
  MOV     R6, #0                    @ LDIdentifier = 0
  B       final



turnOffLD3:
  LDR     R4, =GPIOD_ODR            @   Turn off LD3
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD3_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 
  MOV     R6, #0                    @ LDIdentifier = 0
  MOV     R7, #0                    @ count = 0

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  B       final

turnOffLD4:
  LDR     R4, =GPIOD_ODR            @   Turn off LD4
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD4_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 
  MOV     R6, #0                    @ LDIdentifier = 0
  MOV     R7, #0                    @ count = 0

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  B       final

turnOffLD6:
  LDR     R4, =GPIOD_ODR            @   Turn off LD6
  LDR     R5, [R4]                  @
  EOR     R5, #(0b1<<(LD6_PIN))     @   GPIOD_ODR = GPIOD_ODR ^ (1<<LD3_PIN);
  STR     R5, [R4]                  @ 
  MOV     R6, #0                    @ LDIdentifier = 0
  MOV     R7, #0                    @ count = 0

  LDR     R4, =SCB_ICSR             @ Clear (acknowledge) the interrupt
  LDR     R5, =SCB_ICSR_PENDSTCLR   @
  STR     R5, [R4]                  @

  B       final

  .section .data

countdown:
  .space  4

boolean:
  .space  4


  .end
