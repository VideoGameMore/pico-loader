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

    // Proven ARM7 hotkey path.
    adr r2, firedFlag
    movs r3, #1
    str r3, [r2]

    ldr r2, regSoundCnt
    movs r3, #0
    strh r3, [r2]

    // DSi/3DS-mode hardware exposes SCFG at 0x04004700. On those systems,
    // request a full PMIC reboot entirely from ARM7. This resets both CPUs and
    // deliberately avoids installing or invoking any ARM9 game hook.
    ldr r2, regScfgRom
    ldrh r3, [r2]
    cmp r3, #0
    beq unsupported_reboot

    // Save and disable IME while talking to the PMIC over SPI.
    ldr r2, regIme
    ldr r5, [r2]
    movs r3, #0
    str r3, [r2]

    // Read PMIC register 0x10. Read command is register | 0x80.
    ldr r2, regSpiCnt
wait_spi_read_start:
    ldrh r3, [r2]
    movs r4, #0x80
    tst r3, r4
    bne wait_spi_read_start

    ldr r3, spiHold1MHz
    strh r3, [r2]
    movs r3, #0x90
    strh r3, [r2, #2]
wait_spi_read_cmd:
    ldrh r3, [r2]
    movs r4, #0x80
    tst r3, r4
    bne wait_spi_read_cmd

    ldr r3, spiEnd1MHz
    strh r3, [r2]
    movs r3, #0
    strh r3, [r2, #2]
wait_spi_read_data:
    ldrh r3, [r2]
    movs r4, #0x80
    tst r3, r4
    bne wait_spi_read_data
    ldrh r4, [r2, #2]
    movs r3, #0xff
    ands r4, r3

    // Set bit 0 in PMIC register 0x10: full console reboot.
    movs r3, #1
    orrs r4, r3

wait_spi_write_start:
    ldrh r3, [r2]
    movs r3, #0x80
    ldrh r3, [r2]
    movs r3, #0x80
    // Reload status cleanly before testing BUSY.
    ldrh r3, [r2]
    movs r0, #0x80
    tst r3, r0
    bne wait_spi_write_start

    ldr r3, spiHold1MHz
    strh r3, [r2]
    movs r3, #0x10
    strh r3, [r2, #2]
wait_spi_write_cmd:
    ldrh r3, [r2]
    movs r0, #0x80
    tst r3, r0
    bne wait_spi_write_cmd

    ldr r3, spiEnd1MHz
    strh r3, [r2]
    strh r4, [r2, #2]
wait_spi_write_data:
    ldrh r3, [r2]
    movs r0, #0x80
    tst r3, r0
    bne wait_spi_write_data

    // Successful PMIC reboot does not return. If hardware takes a moment,
    // keep ARM7 parked rather than resuming the game in a half-reset state.
reboot_wait:
    b reboot_wait

unsupported_reboot:
    // Keep the known-good visible behavior on hardware without this reboot path.
    ldr r2, retailReturnMarkerAddress
    ldr r3, markerValue
    str r3, [r2]
    b detection_done

clear_state:
    adr r2, holdCounter
    ldr r3, [r2]
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
regIme:
    .word 0x04000208
regSpiCnt:
    .word 0x040001C0
regScfgRom:
    .word 0x04004700
retailReturnMarkerAddress:
    .word 0x02FFFDF0
hotkeyMask:
    .word 0x00000384
markerValue:
    .word 0x5049434F
// SPI_ENABLE | SPI_HOLD | PMIC device | 1MHz
spiHold1MHz:
    .word 0x00008802
// SPI_ENABLE | PMIC device | 1MHz
spiEnd1MHz:
    .word 0x00008002
holdCounter:
    .word 0
firedFlag:
    .word 0

.pool
.end
