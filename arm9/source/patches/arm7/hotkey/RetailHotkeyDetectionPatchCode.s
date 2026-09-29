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
    // Same VBlank epilogue convention already used by CheatEnginePatch.
    pop {r0, r1}
    mov lr, r1
    push {r2-r5, lr}

    // First look for the ARM9 acknowledgement. In this build, audio mutes only
    // after ARM9 has seen and acknowledged the shared mailbox request.
    ldr r2, retailReturnMarkerAddress
    ldr r3, [r2]
    ldr r4, ackValue
    cmp r3, r4
    bne check_hotkey

    movs r3, #0
    str r3, [r2]
    ldr r2, regSoundCnt
    strh r3, [r2]
    b detection_done

check_hotkey:
    // KEYINPUT is active-low. Require L + R + Down + Select.
    ldr r2, regKeyInput
    ldrh r3, [r2]
    ldr r4, hotkeyMask
    ands r3, r4
    bne clear_counter

    // Do not repeatedly post the same request while the buttons remain held.
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

    // Signal ARM9 through shared main RAM. No mute here: the mute now proves
    // the ARM9 consumer actually saw this value and wrote the ACK back.
    ldr r2, retailReturnMarkerAddress
    ldr r3, markerValue
    str r3, [r2]

    adr r2, firedFlag
    movs r3, #1
    str r3, [r2]
    b detection_done

clear_counter:
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
retailReturnMarkerAddress:
    .word 0x02FFFDF0
hotkeyMask:
    .word 0x00000384
markerValue:
    .word 0x5049434F
ackValue:
    .word 0x41434B21
holdCounter:
    .word 0
firedFlag:
    .word 0

.pool
.end
