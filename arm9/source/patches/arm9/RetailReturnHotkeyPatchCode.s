.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    // Preserve the state seen by the SDK IRQ dispatcher.
    stmdb sp!, {r0-r3, r12, lr}

    // Only count the hotkey on VBlank IRQs so the hold time is frame based.
    ldr r0, regIf
    ldr r1, [r0]
    tst r1, #1
    beq chain_original

    // REG_KEYINPUT is active-low. Require L + R + DOWN + SELECT.
    ldr r0, regKeyInput
    ldrh r1, [r0]
    ldr r2, hotkeyMask
    ands r1, r1, r2
    bne clear_counter

    adr r0, holdCounter
    ldr r1, [r0]
    add r1, r1, #1
    str r1, [r0]
    cmp r1, #30
    blo chain_original

    // The reset patch does not return. Restore registers first, then jump
    // directly into Pico Loader's existing OS_ResetSystem replacement.
    ldmia sp!, {r0-r3, r12, lr}
    ldr r12, patch_retailreturnhotkey_reset_address
    bx r12

clear_counter:
    adr r0, holdCounter
    mov r1, #0
    str r1, [r0]

chain_original:
    ldmia sp!, {r0-r3, r12, lr}

    // Replay the two ARM instructions replaced at the start of OS_IrqHandler.
.global patch_retailreturnhotkey_original_instruction0
patch_retailreturnhotkey_original_instruction0:
    .word 0
.global patch_retailreturnhotkey_original_instruction1
patch_retailreturnhotkey_original_instruction1:
    .word 0

    ldr pc, patch_retailreturnhotkey_return_address

.balign 4
regIf:
    .word 0x04000214
regKeyInput:
    .word 0x04000130
hotkeyMask:
    .word 0x00000384
holdCounter:
    .word 0

.global patch_retailreturnhotkey_return_address
patch_retailreturnhotkey_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
