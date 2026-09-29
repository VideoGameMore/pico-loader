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

    // KEYINPUT is active-low. Require L + R + Down + Select.
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

    // Write the PICO marker to the managed arena address, then read it back.
    // Only mute after the round-trip succeeds so the mute is proof that the
    // ARM7 can safely access this exact allocated marker.
    ldr r2, patch_retailhotkeydetect_markerAddress
    ldr r3, markerValue
    str r3, [r2]
    ldr r4, [r2]
    cmp r4, r3
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
markerValue:
    .word 0x4F434950
holdCounter:
    .word 0

.global patch_retailhotkeydetect_markerAddress
patch_retailhotkeydetect_markerAddress:
    .word 0

.pool
.end
