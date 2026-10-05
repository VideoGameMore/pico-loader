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

    // Test 92: validate the header and real ARM7 crt0 entry instructions,
    // then retain Test 91's staged ARM execution/Thumb return diagnostic.
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

    // Logical file sector 2 contains entry offset 0x414. ARM9 resolved
    // its physical sector from the cluster map before game launch.
    ldr r4, patch_retailhotkeydetect_loaderEntrySector
    cmp r4, #0
    beq read_failed
    bl read_one_sector
    cmp r0, #0
    beq read_failed

    // Check actual ARM crt0 instructions at file offsets 0x414/0x418.
    // These bytes are read from SD, not synthesized by the staged probe.
    adr r1, loaderSectorBuffer
    ldr r3, [r1, #20]
    ldr r5, expectedEntryWord0
    cmp r3, r5
    bne read_failed
    ldr r3, [r1, #24]
    ldr r5, expectedEntryWord4
    cmp r3, r5
    bne read_failed

    // Loader crt0 starts in ARM mode. Stage eight bytes, enter with BX
    // using a word-aligned address, then BX LR back to the Thumb caller.
    adr r1, loaderSectorBuffer
    adr r3, stagedExecutionTemplate
    ldr r5, [r3]
    str r5, [r1]
    ldr r5, [r3, #4]
    str r5, [r1, #4]
    bl execute_staged_probe
    cmp r0, #0x5B
    bne read_failed

    movs r0, #1
    pop {pc}

// BL sets the Thumb return address; BX enters the staged routine in ARM mode.
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
.global patch_retailhotkeydetect_loaderEntrySector
patch_retailhotkeydetect_loaderEntrySector:
    .word 0
expectedEntryWord0:
    .word 0xE59F0028
expectedEntryWord4:
    .word 0xE5C00000
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
    .word 0xE3A0005B        // ARM: mov r0, #0x5B
    .word 0xE12FFF1E        // ARM: bx lr (return to Thumb)

.balign 4
loaderSectorBuffer:
    .space 512

.pool
.end
