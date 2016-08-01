.global _shellcode_start
.global _shellcode_end
.global _hookstub_enter
.global _hookstub_leave
.global _old_function_addr

.data

_shellcode_start:
    stmfd   sp!, {r0-r12, lr} 
	mrs     r11, cpsr
	mrs		r12, spsr
	stmfd	sp!, {r11,r12}
	adr     r12, _hookstub_enter
	ldr		r12, [r12]
    blx     r12
	ldmfd   sp!, {r11, r12}
	msr     cpsr, r11
	msr		spsr, r12
    ldmfd   sp!, {r0-r12, lr}

	sub		sp, #400
	push	{lr}
	add		sp, #404
    adr		r12, _old_function_addr
	ldr		r12, [r12]
    blx		r12
	sub		sp, #404
	pop		{lr}
	add		sp, #400
	
	stmfd   sp!, {r0-r12, lr}
	mrs     r11, cpsr
	mrs		r12, spsr
	stmfd	sp!, {r11,r12}
	adr     r12, _hookstub_leave
	ldr		r12, [r12]
    blx     r12
	ldmfd   sp!, {r11, r12}
	msr     cpsr, r11
	msr		spsr, r12
    ldmfd   sp!, {r0-r12, lr}
	
	bx		lr
	
_hookstub_enter:
.word 0xffffffff

_hookstub_leave:
.word 0xffffffff

_old_function_addr:
.word 0xffffffff

_shellcode_end:
.word 0x00000000

.end