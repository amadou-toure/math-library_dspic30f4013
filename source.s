;******************************************************************************
;                                                                             *
;******************************************************************************
;    Filename            :  In_ADC.s  
;                                                                             *
;    Author              :  Alain Royal                                       *
;    Company             :  Institut Teccart                                  *
;                                        *
;    Date                :  26/10/2006                                        *
;    File Version        :  1.20                                              *
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
;                                                                  	          *
;******************************************************************************
;																			  *
;******************************************************************************
; Description:                                                        		  *
;   Cr»tion d'un sinus ? l'aide d'une table de donn»es en m»moire programme	  *
;	avec le DCI et le Codec SI3021											  *
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
 _end_ln: .space 2;
 _y: .space 2;


;------------------------------------------------------------------------------
;Program Specific Constants (literals used in code)

	.equ	Fcy, #7372800

;===========================================================================================
;Code Section in Program Memory
;..............................................................................

.text                             ;Start of Code section
__reset:
        MOV #__SP_init, W15       ;Initalize the Stack Pointer
        MOV #__SPLIM_init, W0     ;Initialize the Stack Pointer Limit Register
        MOV W0, SPLIM
        NOP  
init:
  mov #0,w1
  mov w1,_x
  mov w1,ACCA
  mov #1,w0
  mov wo,_n
  mov #5,w0
  mov w0,_end_ln
  mov #2,w0
  mov w0,_y
  

main:
	
	call _ln_1__x
loop:
        BRA  loop            


;========================================================================================
;========================================================================================
;Subroutine exposant: returns the result of _x^_n and stores the result in w12
;..............................................................................
_exposant:
	mov _n,w3
	dec2 w3,w3
	mov _x,w1
	mov w1,w0
	do w3,_exit
	MUL.SS w0,w1,w12
	mov w12,w0
_exit: 
    NOP
    return
;-------------------------------------------------------------------------------
;========================================================================================
;Subroutine _ln_1__x: returns the result of ln(1+x):
;..............................................................................
_ln_1__x:
    mov _end_ln,w5
    do w5,_exit_ln
;....................part 1.....................................................
    mov _y,w0
    mov w0,_x
    mov _n,w0
    call _exposant
    mov w12,_y
;....................part 2.....................................................
    mov #-1,w0
    mov w0,_x
    mov _n,w1
    inc w1,w1
    call _exposant
    mov w12,_x
;....................part 3.....................................................
    mov _x,w0
    mov _n,w1
    DIV.S w0,w1,w12 
;....................part 4.....................................................
    mov _y,w3
    mov w12,w4
    mac w3*w4,ACCA
;....................part 5.....................................................
    mov _n,w1	
    inc w1,w1
    mov w1,_n
_exit_ln:
    NOP
    return
;-------------------------------------------------------------------------------

;--------End of All Code Sections ---------------------------------------------

.end                               ;End of program code in this file




	
	
	
	