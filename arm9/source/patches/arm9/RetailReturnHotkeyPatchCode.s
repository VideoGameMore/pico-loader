.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    // This function replaces only IRQ vector-table entry 0 (VBlank). The SDK
    // IRQ dispatcher itself remains untouched. Preserve the state a normal
    // VBlank callback would receive while checking the hotkey.
    stmdb sp!, {r1-r3, r12, lr}

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

    // The reset path does not return. Restore callback state first, then jump
    // into Pico Loader's return-to-launcher routine.
    ldmia sp!, {r1-r3, r12, lr}
    ldr r0, patch_retailreturnhotkey_reset_address
    bx r0

clear_counter:
    adr r1, holdCounter
    mov r2, #0
    str r2, [r1]

chain_original:
    // Restore the callback state. The SDK dispatcher normally loads the VBlank
    // handler address into r0 before bx r0, so load the original handler into
    // r0 here to reproduce that entry state and preserve ARM/Thumb interwork.
    ldmia sp!, {r1-r3, r12, lr}
    ldr r0, patch_retailreturnhotkey_original_vblank_address
    bx r0

.balign 4
regKeyInput:
    .word 0x04000130
hotkeyMask:
    .word 0x00000384
holdCounter:
    .word 0

.global patch_retailreturnhotkey_original_vblank_address
patch_retailreturnhotkey_original_vblank_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
