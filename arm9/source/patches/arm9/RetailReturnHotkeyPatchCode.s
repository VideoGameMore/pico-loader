.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    stmdb sp!, {r0-r3, r12, lr}

    // Build 48 diagnostic: if this hook executes at all, force both displays
    // fully black. This does not depend on ARM7 or shared RAM.
    ldr r0, masterBrightMain
    ldr r1, masterBrightBlack
    strh r1, [r0]
    ldr r0, masterBrightSub
    strh r1, [r0]

    ldmia sp!, {r0-r3, r12, lr}

.global patch_retailreturnhotkey_original_instruction0
patch_retailreturnhotkey_original_instruction0:
    .word 0
.global patch_retailreturnhotkey_original_instruction1
patch_retailreturnhotkey_original_instruction1:
    .word 0

    ldr pc, patch_retailreturnhotkey_return_address

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
