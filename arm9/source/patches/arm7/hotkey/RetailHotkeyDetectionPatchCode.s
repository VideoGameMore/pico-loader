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

    // Visible proof that the hotkey fired before entering the reset path.
    ldr r2, regSoundCnt
    movs r3, #0
    strh r3, [r2]

    // ARM7-only controlled reset. Point the BIOS ARM7 reset vector at a
    // resident ARM-state trampoline in this patch, then invoke SoftReset.
    // No ARM9 game hook or ARM9 callback is involved.
    ldr r2, arm7ResetVectorAddress
    adr r3, patch_retailhotkeydetect_postreset_arm
    str r3, [r2]
    swi 0x00

    // SoftReset should never return.
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
    // Re-enable the master sound register as the unmistakable indication that
    // ARM7 actually reached our code after BIOS SoftReset, then park ARM7.
    ldr r0, postresetSoundCnt
    ldr r1, postresetSoundEnabled
    strh r1, [r0]
1:
    b 1b

.balign 4
postresetSoundCnt:
    .word 0x04000500
postresetSoundEnabled:
    .word 0x0000807F

.pool
.end
