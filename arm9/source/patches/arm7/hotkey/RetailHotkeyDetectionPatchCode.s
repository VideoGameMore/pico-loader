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

    // DSi/TWL power-management reboot path used by nds-bootstrap/TWiLight.
    // Set warmboot flag first, then request reboot via the ARM7 I2C controller.
    movs r0, #0x70
    movs r1, #1
    bl patch_retailhotkeydetect_i2c_pm_write

    movs r0, #0x11
    movs r1, #1
    bl patch_retailhotkeydetect_i2c_pm_write

    // A successful reboot never returns. If both writes return, restore sound
    // and return to the game so we can distinguish a failed reboot from an
    // ARM7 park-induced freeze.
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

// r0 = PM register, r1 = data. Returns r0 = 1 on ACK, 0 on failure.
// Implements the same register transaction sequence as libnds/TWiLight i2cWriteRegister.
.thumb
.type patch_retailhotkeydetect_i2c_pm_write, %function
patch_retailhotkeydetect_i2c_pm_write:
    push {r2-r7, lr}
    movs r6, r0
    movs r7, r1
    movs r5, #8

i2c_retry:
    ldr r2, i2cDataAddr
    ldr r3, i2cCntAddr

    // Wait until bus idle.
i2c_wait0:
    ldrb r4, [r3]
    movs r0, #0x80
    tst r4, r0
    bne i2c_wait0

    // Select PM device 0x4A.
    movs r4, #0x4A
    strb r4, [r2]
    movs r4, #0xC2
    strb r4, [r3]

i2c_wait1:
    ldrb r4, [r3]
    movs r0, #0x80
    tst r4, r0
    bne i2c_wait1
    movs r0, #0x10
    tst r4, r0
    beq i2c_fail

    bl i2c_pm_delay

    // Select PM register.
    strb r6, [r2]
    movs r4, #0xC0
    strb r4, [r3]

i2c_wait2:
    ldrb r4, [r3]
    movs r0, #0x80
    tst r4, r0
    bne i2c_wait2
    movs r0, #0x10
    tst r4, r0
    beq i2c_fail

    bl i2c_pm_delay

    // Write data and stop transaction.
    strb r7, [r2]
    movs r4, #0xC0
    strb r4, [r3]
    bl i2c_pm_delay
    movs r4, #0xC5
    strb r4, [r3]

i2c_wait3:
    ldrb r4, [r3]
    movs r0, #0x80
    tst r4, r0
    bne i2c_wait3
    movs r0, #0x10
    tst r4, r0
    beq i2c_fail

    movs r0, #1
    pop {r2-r7, pc}

i2c_fail:
    movs r4, #0xC5
    strb r4, [r3]
    subs r5, #1
    bne i2c_retry
    movs r0, #0
    pop {r2-r7, pc}

.type i2c_pm_delay, %function
i2c_pm_delay:
    push {r0, lr}
    movs r0, #0x60
    lsls r0, r0, #2
2:
    subs r0, #1
    bne 2b
    pop {r0, pc}

.balign 4
i2cDataAddr:
    .word 0x04004500
i2cCntAddr:
    .word 0x04004501

.pool
.end
