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

    // Briefly mute so we can tell the hotkey fired.
    ldr r2, regSoundCnt
    movs r3, #0
    strh r3, [r2]

    // Test the TWL PMIC reboot request without parking ARM7 afterward.
    // If the reboot command is actually accepted, execution never returns.
    bl patch_retailhotkeydetect_request_twl_reboot

    // If we get here, the reboot request was ignored. Restore sound and
    // return cleanly to the game's VBlank handler so a black screen cannot
    // be caused simply by parking ARM7.
    ldr r2, regSoundCnt
    ldr r3, soundCntEnabled
    strh r3, [r2]
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
soundCntEnabled:
    .word 0x0000807F
hotkeyMask:
    .word 0x00000384

holdCounter:
    .word 0
firedFlag:
    .word 0

.balign 4
.thumb
.type patch_retailhotkeydetect_request_twl_reboot, %function
patch_retailhotkeydetect_request_twl_reboot:
    ldr r0, spiCnt
    ldr r2, spiData

wait_idle_0:
    ldrh r1, [r0]
    movs r3, #0x80
    tst r1, r3
    bne wait_idle_0

    ldr r1, spiCntHold
    strh r1, [r0]
    movs r1, #0x10
    strh r1, [r2]

wait_idle_1:
    ldrh r1, [r0]
    movs r3, #0x80
    tst r1, r3
    bne wait_idle_1

    ldr r1, spiCntLast
    strh r1, [r0]
    movs r1, #1
    strh r1, [r2]

wait_idle_2:
    ldrh r1, [r0]
    movs r3, #0x80
    tst r1, r3
    bne wait_idle_2
    bx lr

.balign 4
spiCnt:
    .word 0x040001C0
spiData:
    .word 0x040001C2
spiCntHold:
    .word 0x00008802
spiCntLast:
    .word 0x00008002

.pool
.end
