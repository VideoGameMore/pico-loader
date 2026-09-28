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
    // Same VBlank epilogue convention already used by CheatEnginePatch.
    pop {r0, r1}
    mov lr, r1
    push {r2-r5, lr}

    // KEYINPUT is active-low. Require L + R + Down + Select.
    ldr r2, regKeyInput
    ldrh r3, [r2]
    ldr r4, hotkeyMask
    ands r3, r4
    bne clear_counter

    adr r2, holdCounter
    ldr r3, [r2]
    adds r3, #1
    str r3, [r2]
    cmp r3, #30
    blo detection_done

    // Only trigger when the ARM9 reset/launcher patch supplied a valid entry.
    ldr r2, patch_retailhotkeydetect_arm9ReturnAddress
    cmp r2, #0
    beq detection_done
    b begin_reboot

clear_counter:
    adr r2, holdCounter
    movs r3, #0
    str r3, [r2]

detection_done:
    pop {r2-r5}
    pop {r3}
    bx r3

begin_reboot:
    // From here on there is intentionally no return to the game.
    // Disable ARM7 interrupts before taking over the reset sequence.
    ldr r0, regIme
    movs r1, #0
    str r1, [r0]

    // Copy a tiny synchronization/boot stub to ARM7 private WRAM so it remains
    // executable while ARM9 remaps main memory and VRAM during the reboot.
    adr r0, arm7_iwram_region
    adr r1, arm7_iwram_region_end
    ldr r2, arm7IwramBase
copy_arm7_stub:
    cmp r0, r1
    beq arm7_stub_copied
    ldr r3, [r0]
    str r3, [r2]
    adds r0, #4
    adds r2, #4
    b copy_arm7_stub

arm7_stub_copied:
    // Tell the retail ARM9 reset handler where BIOS soft-reset should jump.
    ldr r0, biosArm9BootAddr
    ldr r1, patch_retailhotkeydetect_arm9ReturnAddress
    str r1, [r0]

    // Send the standard Nitro/libnds reset command from ARM7 to ARM9.
    // The retail ARM9 FIFO reset handler will perform the first sync and then
    // soft-reset into patch_osresetsystem_returnToLauncherFromArm7.
    ldr r0, regIpcSync
wait_fifo_space:
    ldr r1, [r0, #4]
    movs r2, #2
    tst r1, r2
    bne wait_fifo_space
    ldr r1, resetCode
    str r1, [r0, #8]

    ldr r0, arm7IwramBase
    adds r0, #1
    bx r0

// This entire region is copied verbatim to 0x03800000. Keep all literals used
// by the stub inside the copied range so PC-relative loads stay valid.
.balign 4
arm7_iwram_region:
    ldr r0, iwramRegIpcSync

1:
    // Wait for ARM9's first reset-sync value.
    ldrb r1, [r0]
    cmp r1, #1
    bne 1b
    movs r1, #1
    strb r1, [r0, #1]

2:
    // Complete the reset handshake.
    ldrb r1, [r0]
    cmp r1, #0
    bne 2b
    movs r1, #0
    strb r1, [r0, #1]

3:
    // ARM9 has now loaded Pico Loader ARM7 into VRAM C and mapped it to ARM7.
    // It signals 3 when it is safe to jump to the new ARM7 entry point.
    ldrb r1, [r0]
    cmp r1, #3
    bne 3b
    ldr r0, iwramLoaderArm7Base
    ldr r0, [r0]
    bx r0

.balign 4
iwramRegIpcSync:
    .word 0x04000180
iwramLoaderArm7Base:
    .word 0x06000000
arm7_iwram_region_end:

.balign 4
regKeyInput:
    .word 0x04000130
regIme:
    .word 0x04000208
regIpcSync:
    .word 0x04000180
biosArm9BootAddr:
    .word 0x02FFFE24
resetCode:
    .word 0x0C04000C
arm7IwramBase:
    .word 0x03800000
hotkeyMask:
    .word 0x00000384
holdCounter:
    .word 0

.global patch_retailhotkeydetect_arm9ReturnAddress
patch_retailhotkeydetect_arm9ReturnAddress:
    .word 0

.pool
.end
