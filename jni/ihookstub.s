.global _shellcode_start
.global _shellcode_end
.global _hookstub_enter
.global _hookstub_leave
.global _old_function_addr
.global _mutex
.global _thread_lock
.global _thread_unlock

.data

_shellcode_start:
    stmfd   sp!, {r0-r12, lr} 
	mrs     r11, cpsr
	mrs		r12, spsr
	stmfd	sp!, {r11,r12}
	adr		r12, _old_lr_stack_offset
	ldr		r11, [r12]
	adr		r10, _old_lr_stack
	str		lr,  [r10, r11]
	add		r11, #4
	str		r11, [r12]
	adr     r12, _hookstub_enter
	ldr		r12, [r12]
    blx     r12
	ldmfd   sp!, {r11, r12}
	msr     cpsr, r11
	msr		spsr, r12
    ldmfd   sp!, {r0-r12, lr}

    adr		r12, _old_function_addr
	ldr		r12, [r12]
    blx		r12
	
	stmfd   sp!, {r0-r12}
	mrs     r11, cpsr
	mrs		r12, spsr
	stmfd	sp!, {r11,r12}
	adr     r12, _hookstub_leave
	ldr		r12, [r12]
    blx     r12
	adr		r12, _old_lr_stack_offset
	ldr		r11, [r12]
	sub		r11, #4
	str		r11, [r12]
	adr		r12, _old_lr_stack
	ldr		lr, [r12, r11]
	ldmfd   sp!, {r11, r12}
	msr     cpsr, r11
	msr		spsr, r12
    ldmfd   sp!, {r0-r12}
	
	bx		lr
    
_hookstub_enter:
.word 0xffffffff

_hookstub_leave:
.word 0xffffffff

_old_function_addr:
.word 0xffffffff

_mutex:
.word 0x00000000

_thread_lock:
.word 0xffffffff

_thread_unlock:
.word 0xffffffff

_old_lr_stack_offset:
.word 0x00000000

_old_lr_stack:
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff
.word 0xffffffff

_shellcode_end:

.end