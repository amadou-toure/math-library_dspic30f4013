;******************************************************************************
;                                                                             *
;******************************************************************************
;    Filename            :  In_ADC.s  
;                                                                             *
;    Author              :  Amadou Toure                                      *
;    Company             :  Institut Teccart                                  *
;                                        *
;    Date                :  20/03/2025                                        *
;    File Version        :  1.00                                             *
;                                                                             *
;    Files Required: p30F6014.gld, p30f6014.inc				      *
;    Fichiers n»cessaires:
;									      *
;                Init_ADC.s						      *
;				 isr_Adc.s
;																			  *
;    Tools Used:MPLAB GL : 6.60                                               *
;               Compiler : 1.10                                               *
;               Assembler: 1.10                                               *
;               Linker   : 1.10                                               *
;                                                                  	        
;******************************************************************************
;																			  *
;******************************************************************************
; Description:                                                        		 
;  sous programme permetant d'effectuer l'operation ln(1+x)		      *		
;                                                                             *
;******************************************************************************

        .equ __30F4013, 1
        .include "p30f4013.inc"
;		.include "\alain\travaux\DSPic\demo\dspicdem_v1_1\common.inc"


;..............................................................................
;Configuration bits:
;..............................................................................

      ; config __FOSC, CSW_FSCM_OFF & XT_PLL4    ;Turn off clock switching and
                                            ;fail-safe clock monitoring and
                                            ;use the External Clock as the
                                            ;system clock

 ;       config __FWDT, WDT_OFF              ;Turn off Watchdog Timer

;        config __FBORPOR, PBOR_ON & BORV_27 & PWRT_16 & MCLR_EN
                                            ;Set Brown-out Reset voltage and
                                            ;and set Power-up Timer to 16msecs
                                            
 ;       config __FGS, CODE_PROT_OFF         ;Set Code Protection Off for the 
                                            ;General Segment

;..............................................................................
;Program Specific Constants (literals used in code)
;..............................................................................

        .equ SAMPLES, 64         ;Number of samples

;..............................................................................
;Global Declarations:
;..............................................................................

        .global __reset          ;The label for the first line of code. 
		.global __INT1Interrupt

;..............................................................................
;Uninitialized variables in Near data memory (Lower 8Kb of RAM)
;..............................................................................


		.section .bss
Reserved: 	.space 0x24	; Espaces reserv»s 
 _x: .space 2;
 _n: .space 2;
 _N: .space 2;
 _number: .space 2;
    


;------------------------------------------------------------------------------
;Program Specific Constants (literals used in code)

	.equ	Fcy, #7372800

;===============================================================================
;Code Section in Program Memory
;..............................................................................

.text                             ;Start of Code section
__reset:
        MOV #__SP_init, W15       ;Initalize the Stack Pointer
        MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
        MOV W0, SPLIM
        NOP  
init:
call _INIT_LN
  

main: 
	call _ln_1_PLUS_x
loop:
        BRA  loop            

;===============================================================================
;===============================================================================
;Subroutine exposant: returns the result of _number^_n and stores the result in
;w12 and w0
;...............................................................................

_exposant:;add the value in _number and the exposant in _n, the result is
	  ;in w12 and w0
	mov _n,w2
	cp w2,#1
	bra z,_if_n_is_1
	cp0 w2
	bra z,_else_if_n_is_null
	dec2 w2,w2 
	mov _number ,w1 
	mov w1,w0
	do w2,_exit_exposant
	MUL.SS w0,w1,w12
	mov w12,w0

_exit_exposant: 
      NOP
    return
_if_n_is_1:
    mov _number,w12
    mov w12,w0
    nop
    return
_else_if_n_is_null:
    mov #1,w12
    mov w12,w0
    nop
    return

;-------------------------------------------------------------------------------
;===============================================================================
;Subroutine _ln_1_PLUS_x: returns the result of ln(1+x):
;the subroutine is subdivided in 4 parts
;..............................................................................
_ln_1_PLUS_x:
    mov _N,w3
    dec w3,w3
    do w3,_exit_ln ;start of the loop
_part_1:;(-1^_n+1)--------------------------------------------------------------
    mov _n,w0
    inc w0,w0
    mov w0,_n
    call _minus_1_exponent_n 
    mov w0,w7
    mov _n,w0
    dec w0,w0
    mov w0,_n
_part_2:;(part_1/_n)------------------------------------------------------------
    mov _n,w4
    cp w4,#1 
    bra z,_if_w4_is_1
    repeat #17
    DIVf w7,w4
    mov w0,w5 ;initializing w5 for MAC in part 4
_part_3:;(_x^_n)
   mov _x,w0
   mov w0,_number
   call _exposant ;result in w12 or w0
   mov w12,w6 ;initializing w6 for MAC in part 4
_part_4:;(mac)
   mac w5*w6,A
   mov _n,w4
   inc w4,w4
   mov w4,_n
_exit_ln:
  
   NOP
   sftac A,#-15
   return
;-------------------------------------------------------------------------------
_if_w4_is_1:
    mov _x,w6
    LAC w6,A
     mov _n,w4
   inc w4,w4
   mov w4,_n
    ;sftac A,#-15
    bra _exit_ln

     
      
;-------------------------------------------------------------------------------
_minus_1_exponent_n:
    mov _n,w3
    mov #2,w2
    repeat #17
    div.s w3,w2
    cp0 w1
    bra z,_if_n_is_pair
    mov #-1,w0
    return
_if_n_is_pair:
    mov #1 ,w0
    return
   

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;===============================================================================
;Subroutine _ln_1_PLUS_x initialization section: define the diferent variables 
;values here and the accumulator configuration
;..............................................................................
_INIT_LN:
  BCLR CORCON,#IF
  BSET CORCON,#SATA
  BSET CORCON,#ACCSAT
  clr A
  ;initializing _n
  mov #1,w0
  mov w0,_n
  ;initializing _x
  mov #2,w0
  mov w0,_x
  ;initializing _N(numbers of iteration of our loop)
  mov #4,w0
  mov w0,_N
  
  return

;--------End of All Code Sections ----------------------------------------------

.end                               ;End of program code in this file




	
	
	
	