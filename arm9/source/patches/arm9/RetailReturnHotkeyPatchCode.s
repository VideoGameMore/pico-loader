.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    // Preserve the state seen by the SDK IRQ dispatcher.
    stmdb sp!, {r0-r3, r12, lr}

    // ARM7 owns hotkey detection. It writes "PICO" into shared RAM when
    // L+R+Down+Select has been held long enough. Check that mailbox on every
    // ARM9 IRQ so we do not depend on the game's own soft-reset command.
    ldr r0, retailReturnMarkerAddress
    ldr r1, [r0]
    ldr r2, markerValue
    cmp r1, r2
    bne chain_original

    // Consume the request before leaving the game.
    mov r1, #0
    str r1, [r0]

    // The return path does not come back. Restore the interrupted register
    // state, then jump directly into Pico Loader's launcher-return routine.
    ldmia sp!, {r0-r3, r12, lr}
    ldr r12, patch_retailreturnhotkey_reset_address
    bx r12

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
retailReturnMarkerAddress:
    .word 0x02FFFDF0
markerValue:
    .word 0x5049434F

.global patch_retailreturnhotkey_return_address
patch_retailreturnhotkey_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
