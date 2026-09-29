.cpu arm946e-s
.section "patch_retailreturnhotkey", "ax"
.syntax unified

.arm
.global patch_retailreturnhotkey_entry
.type patch_retailreturnhotkey_entry, %function
patch_retailreturnhotkey_entry:
    stmdb sp!, {r0-r3, r12, lr}

    // Heartbeat on every ARM9 IRQ. ARM7 checks this independently of the
    // retail-return request so we can prove the IRQ hook is actually running.
    ldr r0, heartbeatAddress
    ldr r1, heartbeatValue
    str r1, [r0]

    ldmia sp!, {r0-r3, r12, lr}

.global patch_retailreturnhotkey_original_instruction0
patch_retailreturnhotkey_original_instruction0:
    .word 0
.global patch_retailreturnhotkey_original_instruction1
patch_retailreturnhotkey_original_instruction1:
    .word 0

    ldr pc, patch_retailreturnhotkey_return_address

.balign 4
heartbeatAddress:
    .word 0x02FFFDF4
heartbeatValue:
    .word 0x48424D21

.global patch_retailreturnhotkey_return_address
patch_retailreturnhotkey_return_address:
    .word 0
.global patch_retailreturnhotkey_reset_address
patch_retailreturnhotkey_reset_address:
    .word 0

.pool
.end
