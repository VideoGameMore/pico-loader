.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    // We enter at the tail of the SDK IRQ dispatcher. r0 contains the IRQ
    // table index. Preserve all scratch state while checking the hotkey.
    stmdb sp!, {r0-r3, r12}

    // Only count the hotkey on VBlank (IRQ table index 0), so the hold time is
    // frame based and the check runs only once per frame.
    cmp r0, #0
    bne chain_original

    // REG_KEYINPUT is active-low. Require L + R + DOWN + SELECT.
    ldr r1, regKeyInput
    ldrh r2, [r1]
    ldr r3, hotkeyMask
    ands r2, r2, r3
    bne clear_counter

    adr r1, holdCounter
    ldr r2, [r1]
    add r2, r2, #1
    str r2, [r1]
    cmp r2, #30
    blo chain_original

    // The reset path does not return. Restore the interrupted state first,
    // then jump into Pico Loader's return-to-launcher reset routine.
    ldmia sp!, {r0-r3, r12}
    ldr r12, patch_retailreturnhotkey_reset_address
    bx r12

clear_counter:
    adr r1, holdCounter
    mov r2, #0
    str r2, [r1]

chain_original:
    // Restore the register state present at the SDK dispatch tail, then
    // reproduce the four original dispatch operations:
    //   load IRQ vector table, load handler for r0, load IRQ return address,
    //   and branch to the selected handler.
    ldmia sp!, {r0-r3, r12}
    ldr r1, patch_retailreturnhotkey_irq_table_address
    ldr r0, [r1, r0, lsl #2]
    ldr lr, patch_retailreturnhotkey_irq_return_address
    bx r0

.balign 4
regKeyInput:
    .word 0x04000130
hotkeyMask:
    .word 0x00000384
holdCounter:
    .word 0

.global patch_retailreturnhotkey_irq_table_address
patch_retailreturnhotkey_irq_table_address:
    .word 0
.global patch_retailreturnhotkey_irq_return_address
patch_retailreturnhotkey_irq_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
