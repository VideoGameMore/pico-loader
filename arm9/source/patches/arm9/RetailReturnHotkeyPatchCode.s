.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    stmdb sp!, {r0-r3, r12, lr}

    // Build 49 diagnostic: this function is installed as the game's VBlank
    // vector entry, following the same IRQ-table discovery strategy used by
    // nds-bootstrap. If it executes, force both displays fully black.
    ldr r0, masterBrightMain
    ldr r1, masterBrightBlack
    strh r1, [r0]
    ldr r0, masterBrightSub
    strh r1, [r0]

    ldmia sp!, {r0-r3, r12, lr}

    // Kept for the existing PatchCode relocation interface. Build 49 passes
    // ARM NOPs here because we are no longer replacing dispatcher opcodes.
.global patch_retailreturnhotkey_original_instruction0
patch_retailreturnhotkey_original_instruction0:
    .word 0
.global patch_retailreturnhotkey_original_instruction1
patch_retailreturnhotkey_original_instruction1:
    .word 0

    // Tail-chain to the game's original VBlank callback. BX preserves ARM/Thumb
    // state from bit 0 of the original vector-table entry.
    ldr r12, patch_retailreturnhotkey_return_address
    bx r12

.balign 4
masterBrightMain:
    .word 0x0400006C
masterBrightSub:
    .word 0x0400106C
masterBrightBlack:
    .word 0x00008010

.global patch_retailreturnhotkey_return_address
patch_retailreturnhotkey_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
