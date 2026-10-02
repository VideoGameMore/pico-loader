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

    // Test 82: use the loader-sector handoff published by ARM9 at patch time,
    // then read the first physical sector of picoLoader9.bin through the same
    // DSpico E3/E4/E5 path that Test 81 proved works during retail gameplay.
    // Audio only mutes if the shared handoff is valid AND the loader sector is
    // successfully returned, making this the first test aimed at rebootstrap
    // data rather than an arbitrary SD sector.
    bl patch_retailhotkeydetect_dspico_loader_probe
    cmp r0, #0
    beq detection_done

    ldr r2, regSoundCnt
    movs r3, #0
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
hotkeyMask:
    .word 0x00000384

holdCounter:
    .word 0
firedFlag:
    .word 0

// Returns r0=1 only after the first physical sector of picoLoader9.bin has
// completed a full E3 request -> E4 status -> E5 512-byte data transaction.
.thumb
.type patch_retailhotkeydetect_dspico_loader_probe, %function
patch_retailhotkeydetect_dspico_loader_probe:
    // Require the Test-82 handoff signature before trusting the sector word.
    ldr r2, loaderHandoffSignatureAddress
    ldr r3, [r2]
    ldr r4, loaderHandoffSignatureValue
    cmp r3, r4
    bne read_failed

    ldr r2, loaderFirstSectorAddress
    ldr r4, [r2]
    cmp r4, #0
    beq read_failed

    ldr r2, cardRegBase

    // Wait for any in-flight retail card transfer to finish.
    ldr r5, probeTimeout
read_wait_idle:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_idle
    subs r5, #1
    bne read_wait_idle
    b read_failed

read_idle:
    // Enable/start the DSpico card interface. Tests 80/81 proved this is
    // required before our injected ARM7 code can issue extended commands.
    movs r3, #0x80
    strb r3, [r2, #0x09]

    // E3 xx xx xx SS SS SS SS: request the loader's first physical sector.
    // Match the byte packing used by DSPicoReadSdSectorsPatchCode.s.
    movs r3, #0xE3
    str r3, [r2, #0x10]
    movs r3, r4
    rors r3, r2              // 0x04000198 & 31 = rotate right 24
    str r3, [r2, #0x14]
    strb r4, [r2, #0x17]
    lsrs r3, r4, #16
    strb r3, [r2, #0x15]
    ldr r3, readRequestSettings
    str r3, [r2, #0x0C]

    // Wait for the request command itself to leave the card bus.
    ldr r5, probeTimeout
read_wait_request_done:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_poll_status
    subs r5, #1
    bne read_wait_request_done
    b read_failed

read_poll_status:
    // E4: poll until the loader-sector SD operation completes.
    movs r3, #0xE4
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
    ldr r3, statusTransferSettings
    str r3, [r2, #0x0C]

    ldr r5, probeTimeout
read_wait_status_data:
    ldrb r3, [r2, #0x0E]
    lsrs r3, r3, #8
    bcs read_status_ready
    subs r5, #1
    bne read_wait_status_data
    b read_failed

read_status_ready:
    ldr r3, cardDataReg
    ldr r3, [r3]
    cmp r3, #0
    bne read_fetch_sector

    ldr r5, probeTimeout
read_wait_status_done:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_poll_status
    subs r5, #1
    bne read_wait_status_done
    b read_failed

read_fetch_sector:
    ldr r5, probeTimeout
read_wait_before_e5:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_start_e5
    subs r5, #1
    bne read_wait_before_e5
    b read_failed

read_start_e5:
    // E5: fetch and drain all 512 bytes of the actual Pico Loader sector.
    movs r3, #0xE5
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
    ldr r3, dataTransferSettings
    str r3, [r2, #0x0C]

    movs r4, #128
read_drain_words:
    ldr r5, probeTimeout
read_wait_word:
    ldrb r3, [r2, #0x0E]
    lsrs r3, r3, #8
    bcs read_word_ready
    subs r5, #1
    bne read_wait_word
    b read_failed

read_word_ready:
    ldr r3, cardDataReg
    ldr r3, [r3]
    subs r4, #1
    bne read_drain_words

    movs r0, #1
    bx lr

read_failed:
    movs r0, #0
    bx lr

.balign 4
loaderHandoffSignatureAddress:
    .word 0x02FFFDE8
loaderFirstSectorAddress:
    .word 0x02FFFDEC
loaderHandoffSignatureValue:
    .word 0x4C445238
cardRegBase:
    .word 0x04000198
cardDataReg:
    .word 0x04100010
readRequestSettings:
    .word 0xA0406000
statusTransferSettings:
    .word 0xA7446000
dataTransferSettings:
    .word 0xA1444000
probeTimeout:
    .word 0x00020000

.pool
.end
