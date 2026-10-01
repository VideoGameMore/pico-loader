.cpu arm7tdmi
.section "patch_retailhotkeydetect", "ax"
.syntax unified

.arm
.global patch_retailhotkeydetect_entry_arm
.type patch_retailhotkeydetect_entry_arm, %function
patch_retailhotkeydetect_entry_arm:
    adr r12, patch_retailhotkeydetect_entry + 1
    bx r12

.thumb
.global patch_retailhotkeydetect_entry
.type patch_retailhotkeydetect_entry, %function
patch_retailhotkeydetect_entry:
    pop {r0, r1}
    mov lr, r1
    push {r2-r5, lr}

check_hotkey:
    ldr r2, regKeyInput
    ldrh r3, [r2]
    ldr r4, hotkeyMask
    ands r3, r4
    bne clear_state

    adr r2, firedFlag
    ldr r3, [r2]
    cmp r3, #0
    bne detection_done

    adr r2, holdCounter
    ldr r3, [r2]
    adds r3, #1
    str r3, [r2]
    cmp r3, #30
    blo detection_done

    adr r2, firedFlag
    movs r3, #1
    str r3, [r2]

    ldr r2, regSoundCnt
    movs r3, #0
    strh r3, [r2]

    ldr r2, arm7ResetVectorAddress
    adr r3, patch_retailhotkeydetect_postreset_arm
    str r3, [r2]
    swi 0x00

    b detection_done

clear_state:
    adr r2, holdCounter
    movs r3, #0
    str r3, [r2]
    adr r2, firedFlag
    str r3, [r2]

detection_done:
    pop {r2-r5}
    pop {r3}
    bx r3

.balign 4
regKeyInput:
    .word 0x04000130
regSoundCnt:
    .word 0x04000500
arm7ResetVectorAddress:
    .word 0x02FFFE34
hotkeyMask:
    .word 0x00000384

holdCounter:
    .word 0
firedFlag:
    .word 0

.balign 4
.arm
.global patch_retailhotkeydetect_postreset_arm
.type patch_retailhotkeydetect_postreset_arm, %function
patch_retailhotkeydetect_postreset_arm:
    ldr r0, arm9StubAddress
    ldr r1, arm9Stub0
    str r1, [r0, #0]
    ldr r1, arm9Stub1
    str r1, [r0, #4]
    ldr r1, arm9Stub2
    str r1, [r0, #8]
    ldr r1, arm9Stub3
    str r1, [r0, #12]
    ldr r1, arm9Stub4
    str r1, [r0, #16]
    ldr r1, arm9Stub5
    str r1, [r0, #20]
    ldr r1, arm9Stub6
    str r1, [r0, #24]
    ldr r1, arm9Stub7
    str r1, [r0, #28]
    ldr r1, arm9Stub8
    str r1, [r0, #32]

    ldr r0, arm9ResetVectorAddress
    ldr r1, arm9StubAddress
    str r1, [r0]

    ldr r0, ipcFifoTx
    ldr r1, arm9ResetCommand
    str r1, [r0]

1:
    b 1b

.balign 4
arm9ResetVectorAddress:
    .word 0x02FFFE24
ipcFifoTx:
    .word 0x04000188
arm9ResetCommand:
    .word 0x0C04000C
arm9StubAddress:
    .word 0x02300000

arm9Stub0:
    .word 0xE59F0014
arm9Stub1:
    .word 0xE59F1014
arm9Stub2:
    .word 0xE1C010B0
arm9Stub3:
    .word 0xE59F0010
arm9Stub4:
    .word 0xE1C010B0
arm9Stub5:
    .word 0xEAFFFFFE
arm9Stub6:
    .word 0x0400006C
arm9Stub7:
    .word 0x0000401F
arm9Stub8:
    .word 0x0400106C

.pool
.end
