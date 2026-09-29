.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    // Preserve the state seen by the SDK IRQ dispatcher.
    stmdb sp!, {r0-r3, r12, lr}

    // ARM7 owns hotkey detection and writes "PICO" into shared RAM.
    ldr r0, retailReturnMarkerAddress
    ldr r1, [r0]
    ldr r2, markerValue
    cmp r1, r2
    bne chain_original

    // Build 44 diagnostic: acknowledge the request back to ARM7. ARM7 will
    // mute audio only after it sees this ACK, proving this ARM9 hook executed
    // and both CPUs agree on the mailbox address.
    ldr r1, ackValue
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
retailReturnMarkerAddress:
    .word 0x02FFFDF0
markerValue:
    .word 0x5049434F
ackValue:
    .word 0x41434B21

.global patch_retailreturnhotkey_return_address
patch_retailreturnhotkey_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
