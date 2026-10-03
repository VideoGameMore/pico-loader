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

    // Test 87: stage two consecutive 512-byte sectors from picoLoader7.bin
    // into ARM7-owned RAM. Runtime remains entirely ARM7 + DSpico.
    bl patch_retailhotkeydetect_dspico_loader_probe
    cmp r0, #0
    beq detection_done

    // PASS marker only after both sectors are read/stored and validated.
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
    ldr r4, patch_retailhotkeydetect_loaderSector
    cmp r4, #0
    beq read_failed

    ldr r2, cardRegBase
    adr r1, loaderSectorBuffer
    movs r0, #2

read_next_sector:
    ldr r5, probeTimeout
read_wait_idle:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc read_idle
    subs r5, #1
    bne read_wait_idle
    b read_failed

read_idle:
    movs r3, #0x80
    strb r3, [r2, #0x09]

    // E3: request current physical sector.
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
    b read_failed

read_poll_status:
    // E4: poll SD operation completion.
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
    // E5: receive one complete 512-byte sector into staging RAM.
    movs r3, #0xE5
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]
    ldr r3, dataTransferSettings
    str r3, [r2, #0x0C]

    movs r5, #128
read_store_words:
    push {r5}
    ldr r5, probeTimeout
read_wait_word:
    ldrb r3, [r2, #0x0E]
    lsrs r3, r3, #8
    bcs read_word_ready
    subs r5, #1
    bne read_wait_word
    pop {r5}
    b read_failed

read_word_ready:
    ldr r3, cardDataReg
    ldr r3, [r3]
    str r3, [r1]
    adds r1, #4
    pop {r5}
    subs r5, #1
    bne read_store_words

    // Advance to the next physical sector and repeat once.
    adds r4, #1
    subs r0, #1
    bne read_next_sector

    // First sector header must still match the known picoLoader7.bin data.
    adr r1, loaderSectorBuffer
    ldr r3, [r1]
    ldr r4, expectedHeaderWord0
    cmp r3, r4
    bne read_failed
    ldr r3, [r1, #8]
    ldr r4, expectedHeaderWord8
    cmp r3, r4
    bne read_failed

    // In this build the second 512-byte sector of picoLoader7.bin is zeroed.
    // Confirm we actually advanced to sector +1 instead of reading sector 0
    // twice. Checking its first two words is enough for this diagnostic.
    movs r3, #128
    lsls r3, r3, #2
    adds r1, r3
    ldr r3, [r1]
    cmp r3, #0
    bne read_failed
    ldr r3, [r1, #4]
    cmp r3, #0
    bne read_failed

    movs r0, #1
    bx lr

read_failed:
    movs r0, #0
    bx lr

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

// Two-sector ARM7-owned staging area (1024 bytes total).
.balign 4
loaderSectorBuffer:
    .space 1024

.pool
.end
