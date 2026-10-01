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

    // Use the retail SDK's native reset FIFO handoff. This does not hook any
    // ARM9 game routine: ARM7 supplies a managed reset-vector destination and
    // asks the SDK reset machinery to transfer ARM9 there.
    ldr r2, arm9ResetVectorAddress
    ldr r3, patch_retailhotkeydetect_arm9_transition_address
    cmp r3, #0
    beq detection_done
    str r3, [r2]

    ldr r2, ipcFifoTxAddress
    ldr r3, sdkResetCommand
    str r3, [r2]
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
arm9ResetVectorAddress:
    .word 0x02FFFE24
ipcFifoTxAddress:
    .word 0x04000188
sdkResetCommand:
    .word 0x0C04000C
hotkeyMask:
    .word 0x00000384

.global patch_retailhotkeydetect_arm9_transition_address
patch_retailhotkeydetect_arm9_transition_address:
    .word 0

holdCounter:
    .word 0
firedFlag:
    .word 0

.pool
.end
