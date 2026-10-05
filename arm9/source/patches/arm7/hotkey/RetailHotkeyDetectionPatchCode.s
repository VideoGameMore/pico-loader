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

    // Test 90: retain Test 89's two-sector validation, then execute a tiny
    // Thumb diagnostic staged in the same ARM7-owned buffer. Mute only after
    // the staged code returns its expected token; no loader reboot yet.
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

.thumb
.type patch_retailhotkeydetect_dspico_loader_probe, %function
patch_retailhotkeydetect_dspico_loader_probe:
    push {lr}
    ldr r4, patch_retailhotkeydetect_loaderSector
    cmp r4, #0
    beq read_failed

    // Read and stage the first sector.
    bl read_one_sector
    cmp r0, #0
    beq read_failed

    // Validate the known first-sector header before reusing the buffer.
    adr r1, loaderSectorBuffer
    ldr r3, [r1]
    ldr r5, expectedHeaderWord0
    cmp r3, r5
    bne read_failed
    ldr r3, [r1, #8]
    ldr r5, expectedHeaderWord8
    cmp r3, r5
    bne read_failed

    // Advance one physical sector and reuse the same 512-byte buffer.
    adds r4, #1
    bl read_one_sector
    cmp r0, #0
    beq read_failed

    // In this build sector +1 begins with zeroes. This confirms we advanced
    // to the next sector without increasing the ARM7 patch staging footprint.
    adr r1, loaderSectorBuffer
    ldr r3, [r1]
    cmp r3, #0
    bne read_failed
    ldr r3, [r1, #4]
    cmp r3, #0
    bne read_failed

    // The sector checks passed. Reuse the buffer for four bytes of executable
    // Thumb code: movs r0, #0x5A; bx lr. This isolates RAM execution/return
    // before attempting to place or execute a complete loader payload.
    adr r1, loaderSectorBuffer
    adr r3, stagedExecutionTemplate
    ldr r3, [r3]
    str r3, [r1]
    adds r1, #1              // Thumb entry address
    bl execute_staged_probe
    cmp r0, #0x5A
    bne read_failed

    movs r0, #1
    pop {pc}

// BL sets the Thumb return address; BX transfers to the staged routine.
// The enclosing probe already saved its own incoming LR.
execute_staged_probe:
    bx r1

// Read physical SD sector r4 through DSpico E3/E4/E5 into loaderSectorBuffer.
// Returns r0=1 on success, r0=0 on timeout/failure. r4 is preserved.
read_one_sector:
    push {r4, lr}
    ldr r2, cardRegBase

    ldr r5, probeTimeout
read_wait_idle:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_idle
    subs r5, #1
    bne read_wait_idle
    b read_one_failed

read_idle:
    movs r3, #0x80
    strb r3, [r2, #0x09]

    movs r3, #0xE3
    str r3, [r2, #0x10]
    movs r3, r4
    rors r3, r2
    str r3, [r2, #0x14]
    strb r4, [r2, #0x17]
    lsrs r3, r4, #16
    strb r3, [r2, #0x15]
    ldr r3, readRequestSettings
    str r3, [r2, #0x0C]

    ldr r5, probeTimeout
read_wait_request_done:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_poll_status
    subs r5, #1
    bne read_wait_request_done
    b read_one_failed

read_poll_status:
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
    b read_one_failed

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
    b read_one_failed

read_fetch_sector:
    ldr r5, probeTimeout
read_wait_before_e5:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_start_e5
    subs r5, #1
    bne read_wait_before_e5
    b read_one_failed

read_start_e5:
    movs r3, #0xE5
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
    ldr r3, dataTransferSettings
    str r3, [r2, #0x0C]

    adr r1, loaderSectorBuffer
    movs r4, #128
read_store_words:
    ldr r5, probeTimeout
read_wait_word:
    ldrb r3, [r2, #0x0E]
    lsrs r3, r3, #8
    bcs read_word_ready
    subs r5, #1
    bne read_wait_word
    b read_one_failed

read_word_ready:
    ldr r3, cardDataReg
    ldr r3, [r3]
    str r3, [r1]
    adds r1, #4
    subs r4, #1
    bne read_store_words

    movs r0, #1
    pop {r4, pc}

read_one_failed:
    movs r0, #0
    pop {r4, pc}

read_failed:
    movs r0, #0
    pop {pc}

.balign 4
.global patch_retailhotkeydetect_loaderSector
patch_retailhotkeydetect_loaderSector:
    .word 0
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
expectedHeaderWord0:
    .word 0x06000414
expectedHeaderWord8:
    .word 0x00030000

.balign 4
stagedExecutionTemplate:
    .hword 0x205A           // movs r0, #0x5A
    .hword 0x4770           // bx lr

.balign 4
loaderSectorBuffer:
    .space 512

.pool
.end
