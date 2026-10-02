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

    // Test 81: go beyond the successful E4 status probe from Test 80.
    // Perform a complete DSpico sector-0 read transaction (E3 -> E4 -> E5)
    // and only mute audio after all 512 bytes have been returned and drained.
    // This proves the injected ARM7 path can actually read from the DSpico SD
    // interface while a retail title is running, which is the prerequisite for
    // an ARM7-driven rebootstrap path that does not depend on fragile game hooks.
    bl patch_retailhotkeydetect_dspico_read_probe
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

// Returns r0=1 only after a complete DSpico read of SD sector 0 succeeds.
// Every wait is bounded so an unavailable or busy card bus returns cleanly.
.thumb
.type patch_retailhotkeydetect_dspico_read_probe, %function
patch_retailhotkeydetect_dspico_read_probe:
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
    // Enable/start the DSpico card interface. Test 80 proved this is required
    // before the injected ARM7 code can issue the extended card commands.
    movs r3, #0x80
    strb r3, [r2, #0x09]

    // E3: request SD sector 0. Sector 0 keeps this diagnostic independent of
    // loader layout/cluster metadata; the payload is read and discarded.
    movs r3, #0xE3
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
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
    // E4: poll until the requested SD operation completes.
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

    // SD operation is still pending. Wait for this status command to finish
    // before issuing the next E4 poll.
    ldr r5, probeTimeout
read_wait_status_done:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_poll_status
    subs r5, #1
    bne read_wait_status_done
    b read_failed

read_fetch_sector:
    // Ensure the E4 transfer is fully idle before starting E5.
    ldr r5, probeTimeout
read_wait_before_e5:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_start_e5
    subs r5, #1
    bne read_wait_before_e5
    b read_failed

read_start_e5:
    // E5: fetch the 512-byte sector payload.
    movs r3, #0xE5
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
    ldr r3, dataTransferSettings
    str r3, [r2, #0x0C]

    // Drain all 128 words. We do not store the diagnostic sector; reaching the
    // end of this loop is the observable proof that the full read path works.
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
