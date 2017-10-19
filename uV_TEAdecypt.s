;R1 = Return Value	
;R2 = Delta One/Two		R7 = R(i)
;R3 = KZero/KTwo		R8 = L(i)
;R4 = KOne/KThree
ZERO	EQU 0
ONE		EQU 1
FOUR 	EQU 4
FIVE 	EQU 5
FINISH	EQU 0x11



		AREA     TEAdecrypt, CODE, READONLY
		ENTRY           ; Marks the first instruction to execute
		EXPORT	main	;required by the startup code

main					;required by the startup code
	MOV r0, #ZERO			;flag for loop iteration
	LDR r8, =LTwo		;L(i)
	LDR r8, [r8]
	LDR r7, =RTwo		;R(i)
    LDR r7, [r7]	
	LDR r2, =DeltaTwo	;for 1st pass
	LDR r2, [r2]
	LDR r3, =KTwo		;3rd key
	LDR r3, [r3]
	LDR r4, =KThree		;4th key
	LDR r4, [r4]
loop	
	BL decrypt			;call encryption subroutine
	
	MOV r6, r8			;backing up content from R(i-1)
	SUB r8, r7, r1		;contents of R(i-1) minus f() into L(i)
	MOV r7, r6			;moving contents of R(i-1) into L(i)
	
	CMP r0, #ONE		;check for a 1 in r0 to show that the loop is on the second iteration 
	BEQ done			;if so, then branch to done
	
	LDR r2, =DeltaOne	;for 2nd pass
	LDR r2, [r2]
	LDR r3, =KZero		;1st key
	LDR r3, [r3]
	LDR r4, =KOne		;2nd key
	LDR r4, [r4]
	MOV r0, #ONE		;flag to skip this section on second iteration and end loop
	
	B loop

done
	LDR r3, =RZero		;Load the address of RZero into r3
	LDR r4, =LZero		;Load the address of LZero into r4
	STR r7, [r3]		;RTwo is in r7
	STR r8, [r4]		;LTwo is in r8
	SVC #FINISH			;end program
;=====================================================================================================================
	
decrypt	
	
;ROne = LZero add ((RZero LSR) add KZero) xor ((RZero LSL) add KOne) xor (RZero add DeltaOne)
	LSL r9 ,r8, #FOUR 	;  R(i) LSL 4
	ADD r1, r9, r3		;+ K(i)
	
	LSR r9, r8, #FIVE	;    R(i) LSR 5 +
	ADD r9, r9, r4		;    K(i)
	EOR r1, r1, r9		;XOR
	ADD r9, r2, r8		;	 R(i) + Delta(i)
	EOR r1, r1, r9		;XOR
	BX LR				;Return
			
		AREA	 TEAdata, DATA, READWRITE
			
	EXPORT adrLZero
	EXPORT adrRZero
			
adrLZero	DCD LZero
adrRZero	DCD RZero
DeltaOne DCD 0x11111111
DeltaTwo DCD 0x22222222
KZero DCD 0x90001C55
KOne DCD 0x1234ABCD
KTwo DCD 0xFEDCBA98
KThree DCD 0xE2468AC0
LZero DCD 0x00000000
RZero DCD 0x00000000
LTwo DCD 0xB72599B2
RTwo DCD 0xCF8E5A4C
	
	ALIGN
		
	END                     ; Mark end of file
	