;R1 = Return Value	
;R2 = Delta One/Two		R7 = L(i)
;R3 = KZero/KTwo		R8 = R(i)
;R4 = KOne/KThree
ZERO	EQU 0
ONE		EQU 1
FOUR 	EQU 4
FIVE 	EQU 5
FINISH	EQU 0x11


		AREA     TEAencrypt, CODE, READONLY
		ENTRY           ; Marks the first instruction to execute
		EXPORT	main	;required by the startup code

main					;required by the startup code
	MOV r0, #ZERO			;flag for loop iteration
	LDR r7, =LZero		;L(i)
	LDR r7, [r7]
	LDR r8, =RZero		;R(i)
    LDR r8, [r8]
	
	;Registers 2-4 as well as the R(i) value (r8) are the parameters for the function	
	LDR r2, =DeltaOne	;for 1st pass
	LDR r2, [r2]
	LDR r3, =KZero		;1st key
	LDR r3, [r3]
	LDR r4, =KOne		;2nd key
	LDR r4, [r4]
loop	

	BL encrypt			;call encryption subroutine
	
	MOV r6, r8			;backing up content from R(i-1)
	ADD r8, r7, r1		;contents of L(i-1) mod-plus f() into R(i)
	MOV r7, r6			;moving contents of R(i-1) into L(i)
	
	CMP r0, #ONE			;check for a 1 in r0 to show that the loop is on the second iteration 
	BEQ done			;if so, then move on to final cipherText
	
	LDR r2, =DeltaTwo	;for 2nd pass
	LDR r2, [r2]
	LDR r3, =KTwo		;key 3
	LDR r3, [r3]
	LDR r4, =KThree		;key 4
	LDR r4, [r4]
	MOV r0, #ONE			;flag to skip this section on second iteration and end loop
	
	B loop

done
	LDR r3, =RTwo		;Load the address of RTwo into r3
	LDR r4, =LTwo		;Load the address of LTwo into r3
	STR r8, [r3]		;RTwo is in r8
	STR r7, [r4]		;LTwo is in r7
	SVC #FINISH			;end program
;=====================================================================================================================
	
encrypt	
	;ROne = LZero add ((RZero LSR) add KZero) xor ((RZero LSL) add KOne) xor (RZero add DeltaOne)
	LSL r9 ,r8, #FOUR 	;  R(i) LSR 4
	ADD R1, r9, r3		;+ K(i)
	
	LSR r9, r8, #FIVE	;    R(i) LSL 5 +
	ADD r9, r9, r4		;    K(i)
	EOR r1, r1, r9		;XOR
	ADD r9, r2, r8		;	 R(i) + Delta(i)
	EOR r1, r1, r9		;XOR
	BX LR				;Return
			
		AREA	 TEAdata, DATA, READWRITE
		
	EXPORT	adrLTwo
	EXPORT	adrRTwo
	EXPORT DeltaOne
	EXPORT DeltaTwo

adrLTwo	DCD LTwo
adrRTwo DCD	RTwo


DeltaOne DCD 0x11111111
DeltaTwo DCD 0x22222222
KZero DCD 0x90001C55
KOne DCD 0x1234ABCD
KTwo DCD 0xFEDCBA98
KThree DCD 0xE2468AC0
LZero DCD 0xA0000009
RZero DCD 0x8000006B
LTwo DCD 0x00000000
RTwo DCD 0x00000000
	
	ALIGN
		
	END                     ; Mark end of file
	