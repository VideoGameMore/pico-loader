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

    // Probe the DSpico cartridge-side custom command path directly.
    // E4 (GET_SD_STAT) is read-only. Only mute if a cartridge response arrives.
    bl patch_retailhotkeydetect_dspico_probe
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

// Returns r0=1 if the DSpico answers the custom E4 command, else r0=0.
// All waits are bounded so a busy cartridge bus cannot hang ARM7 indefinitely.
.thumb
.type patch_retailhotkeydetect_dspico_probe, %function
patch_retailhotkeydetect_dspico_probe:
    ldr r2, cardRegBase

    // Wait for any in-flight card transfer to finish.
    ldr r5, probeTimeout
probe_wait_idle:
    ldrb r3, [r2, #0x0F]
    lsrs r3, r3, #8
    bcc probe_idle
    subs r5, #1
    bne probe_wait_idle
    movs r0, #0
    bx lr

probe_idle:
    // Match the known-good DSPico SD request path: enable/start the card
    // interface before issuing a custom command from this injected ARM7 code.
    movs r3, #0x80
    strb r3, [r2, #0x09]

    // card_romSetCmd(0xE400000000000000ull)
    movs r3, #0xE4
    str r3, [r2, #0x10]
    movs r3, #0
    str r3, [r2, #0x14]

    // One-word DSpico status transfer.
    ldr r3, probeTransferSettings
    str r3, [r2, #0x0C]

    ldr r5, probeTimeout
probe_wait_data:
    ldrb r3, [r2, #0x0E]
    lsrs r3, r3, #8
    bcs probe_got_data
    subs r5, #1
    bne probe_wait_data
    movs r0, #0
    bx lr

probe_got_data:
    // Consume the returned status word so the transfer can complete cleanly.
    ldr r3, cardDataReg
    ldr r3, [r3]
    movs r0, #1
    bx lr

.balign 4
cardRegBase:
    .word 0x04000198
cardDataReg:
    .word 0x04100010
probeTransferSettings:
    .word 0xA7446000
probeTimeout:
    .word 0x00020000

.pool
.end
