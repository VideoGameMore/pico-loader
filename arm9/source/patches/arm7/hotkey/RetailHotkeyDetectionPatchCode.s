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

    // Enter a controlled ARM7 BIOS reset, returning into the resident
    // post-reset trampoline below. No ARM9 game hook is involved.
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
    // We have control after the ARM7 BIOS reset. Request a TWL hardware reboot
    // directly from the power-management chip over ARM7 SPI.
    ldr r0, postresetSpiCnt
    ldr r2, postresetSpiData

postreset_wait_idle_0:
    ldrh r1, [r0]
    tst r1, #0x80
    bne postreset_wait_idle_0

    // PMIC register byte, keep chip select asserted for the data byte.
    ldr r1, postresetSpiCntHold
    strh r1, [r0]
    mov r1, #0x10
    strh r1, [r2]

postreset_wait_idle_1:
    ldrh r1, [r0]
    tst r1, #0x80
    bne postreset_wait_idle_1

    // PMIC_REG_TWL = 0x10, PMIC_TWL_REBOOT = 1.
    ldr r1, postresetSpiCntLast
    strh r1, [r0]
    mov r1, #1
    strh r1, [r2]

postreset_wait_idle_2:
    ldrh r1, [r0]
    tst r1, #0x80
    bne postreset_wait_idle_2

    // A successful reboot never returns. Park here if the command is ignored.
1:
    b 1b

.balign 4
postresetSpiCnt:
    .word 0x040001C0
postresetSpiData:
    .word 0x040001C2
postresetSpiCntHold:
    .word 0x00008802
postresetSpiCntLast:
    .word 0x00008002

.pool
.end
