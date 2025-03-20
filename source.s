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
;    Fichiers nÈcessaires:
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
;   Création d'un sinus ? l'aide d'une table de données en mémoire programme  *
;	avec le DCI et le Codec SI3021						
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
Reserved: 	.space 0x24	; Espaces reservÈs 
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
	;sftac A,#-15
	;call _exposant
	;call _test
	;call _div_test
	
loop:
        BRA  loop            


;===============================================================================
;===============================================================================
;Subroutine exposant: returns the result of _x^_n and stores the result in w12
;...............................................................................
_div_test:
    mov #2,w6
    mov #-1,w2
    repeat #17
    divf w2,w6
    mov w0,w5
    do #7,_end_div_test
    mac w5*w6,A
    inc w6,w6
    
 _end_div_test:
    nop
    sftac A,#-15
    return
    
_exposant:;add the value in _number and the exposant in _n, the result is in w12 and w0
	mov _n,w2
	cp w2,#1
	bra z,_n_is_1
	cp0 w2
	bra z,_n_is_null
	dec2 w2,w2 
	mov _number ,w1 
	mov w1,w0
	do w2,_exit
	MUL.SS w0,w1,w12
	mov w12,w0

_exit: 
    NOP
    return
_n_is_1:
    mov _x,w12
    mov w12,w0
    nop
    return
_n_is_null:
    mov #1,w12
    mov w12,w0
    nop
    return
;-------------------------------------------------------------------------------
;===============================================================================
;Subroutine _ln_1_PLUS_x: returns the result of ln(1+x):
;..............................................................................
_ln_1_PLUS_x:
    
    mov #-1,w2
    mov _N,w3
    dec w3,w3
    do w3,_exit_ln
;--------------------------part_1:(-1/_n)---------------------------------------
    mov _n,w4
    mov #-1,w2
    repeat #17
    DIVf w2,w4
    mov w0,w5 ;initializing w5 for MAC in part 3
;--------------------------part_2:(_x^_n)---------------------------------------
    mov _x,w0
    mov w0,_number
    call _exposant ;result in w12 or w0
    mov w12,w6 ;initializing w6 for MAC in part 3
;--------------------------part_3:(mac)-----------------------------------------
    mac w5*w6,A
    mov _n,w4
    inc w4,w4
    mov w4,_n
;--------------------------part_4:(reset)---------------------------------------
_exit_ln:
    NOP
   sftac A,#-15
    return
;-------------------------------------------------------------------------------
_test:
    
    return
;-------------------------------------------------------------------------------
_INIT_LN:
  BCLR CORCON,#IF
  BSET CORCON,#SATA
  BSET CORCON,#ACCSAT
  
  clr A
  
  mov #1,w0
  mov w0,_n
  
  mov #2,w0
  mov w0,_x
  
  mov #3,w0
  mov w0,_N
  
  return

;--------End of All Code Sections ---------------------------------------------

.end                               ;End of program code in this file




	
	
	
	