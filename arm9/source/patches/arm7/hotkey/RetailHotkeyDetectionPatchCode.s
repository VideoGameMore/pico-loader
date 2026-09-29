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

    ldr r2, regKeyInput
    ldrh r3, [r2]
    ldr r4, hotkeyMask
    ands r3, r4
    bne clear_counter

    adr r2, holdCounter
    ldr r3, [r2]
    adds r3, #1
    str r3, [r2]
    cmp r3, #30
    blo detection_done

    // Only mute if ARM9's IRQ hook has written its independent heartbeat.
    ldr r2, heartbeatAddress
    ldr r3, [r2]
    ldr r4, heartbeatValue
    cmp r3, r4
    bne detection_done

    ldr r2, regSoundCnt
    movs r3, #0
    strh r3, [r2]
    b detection_done

clear_counter:
    adr r2, holdCounter
    movs r3, #0
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
hotkeyMask:
    .word 0x00000384
heartbeatAddress:
    .word 0x02FFFDF4
heartbeatValue:
    .word 0x48424D21
holdCounter:
    .word 0

.pool
.end
