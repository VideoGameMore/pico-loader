# Retail return hotkey experiment log

Goal: L + R + Down + Select returns a retail DS game directly to Pico Loader.
Test numbers label experiments; GitHub workflow run numbers can differ.

## Hardware results confirmed in the October 4 session

| Test | Result |
| --- | --- |
| 79 | Historical result: boots, no hotkey response |
| 80 | Boots, hotkey mutes, no freeze |
| 81 | Boots, full-sector transfer marker mutes, no freeze |
| 82 | Boots, no observable hotkey response |
| 83 | Boots, embedded loader9 sector transfer marker mutes, no freeze |
| 84 | Boots, loader7 sector transfer marker mutes, no freeze |
| 85 | Boots, 512-byte staging marker mutes, no freeze |
| 86 | Boots, two checked loader7 header words match, mutes, no freeze |
| 87 | Game fails to boot: white screens |
| 88 | Skipped this session: source has nested-call LR preservation bug |
| 89 | Pass: two sectors read sequentially through one 512-byte buffer, selected words checked, mutes, no freeze |

Test 89 is the hardware-proven baseline. Test 87's buffer size is a suspect,
not an established root cause. Header checks do not validate the whole file.
No complete loader restart or broad game compatibility has been demonstrated.

## Test 90: staged Thumb execution and return

Based on Test 89. After its sector checks, overwrite the first four buffer bytes
with movs r0, #0x5A; bx lr, call that Thumb entry through BX, and check the returned
token before muting. The probe preserves its incoming LR across all nested calls.
Buffer capacity remains 512 bytes; no fixed game RAM allocation or VRAM remapping
is added. This executes a diagnostic routine, not the real loader.

Copy only picoLoader7.bin and picoLoader9.bin into their existing locations.
Use the same game and hold L + R + Down + Select for approximately half a second.
Expected pass: boots, hotkey mutes, gameplay continues without freezing.
Report boot outcome, mute/no mute, freeze/no freeze.

New code requires CI compilation. Hardware result: PASS reported October 5: staged Thumb execution returns correctly; mute/no-freeze pass.
Deliver as DSPico_Test_90.zip.
Recap around every ten tests, next near Test 100; advance after reported failures.

## Test 91: staged ARM execution and Thumb return

Test 90 passed on hardware. Test 91 preserves its sector checks and 512-byte
buffer, but stages ARM mov r0, #0x5B; bx lr (eight bytes). It enters the aligned
buffer with BX, checks token 0x5B on return to Thumb, then mutes. This matches the
instruction mode used by arm7/source/crt0.s, without executing the real loader,
changing stack, disabling IRQs, or remapping VRAM. Hardware result: PASS reported October 5: boots, mutes, no freeze.
Expected pass: boots, hotkey mutes, no freeze. Copy only the two loader bins.
Deliver as DSPico_Test_91.zip. Next recap remains near Test 100.

## Test 92: validate real ARM7 loader entry instructions from SD

Read/check file sector 0 as before, then read logical file sector 2 instead of
physical sector +1. ARM9 resolves that sector through the CLMT run list before
launch and embeds it in the patch, accommodating a fragmented file. At buffer
+20/+24 verify ARM instructions 0xE59F0028/0xE5C00000 from file offsets 0x414/0x418.
These values were inspected in the compiled Test 91 ARM7 binary. The real entry
code is NOT executed: it disables IRQs and clears BSS, so it requires a complete
loader and coordinated handoff. Retain Test 91's staged ARM token check.
Buffer remains 512 bytes. Expected pass: boots/mutes/no freeze. Hardware PASS reported October 5: boots/mutes/no freeze.
Deliver DSPico_Test_92.zip; replace only picoLoader7.bin and picoLoader9.bin.

## Test 93: complete ARM7 payload read with additive checksum

Purpose: establish complete file retrieval, rather than more header probes.
Read all 48448 bytes (12112 words; 95 SD sectors) through precomputed CLMT physical
extents, reusing the 512-byte buffer. Sum every file word modulo 2^32 and compare
0x355637BE, measured from Test 92's compiled ARM7 binary. Exclude final-sector
padding. Extent publication is bounded to seven runs plus a zero terminator;
invalid/incomplete maps disable the probe. Total E4 status polls are now bounded.
Pass still mutes and returns to gameplay; a short pause may occur while reading.
This is a streaming read: the entire payload is not retained simultaneously.
An additive checksum can collide; it is diagnostic evidence, not cryptographic
or byte-for-byte identity validation. The binary size/sum must be rechecked after
CI compilation. These constants must change if the ARM7 binary later changes.
Hardware result: boots, hotkey does nothing (no mute), reported October 5.
This does not distinguish map/read failure from checksum mismatch.
Deliver DSPico_Test_93.zip; replace only two loader bins.

Direction after a pass: choose restart-memory placement and processor handoff.
Existing OSResetSystemPatch only allocates the reset routine when its game reset
signature is found. ARM7 file reads alone do not establish ARM9 control.
Recap near Test 100 remains planned.

## Test 94: isolate complete transfer from checksum acceptance

One-variable follow-up to Test 93: replace the checksum-mismatch branch with a
same-size Thumb NOP. Extents, exact 12112-word processing, 95-sector read, buffer,
status-poll limit and timing remain unchanged. Sum is still computed but not a
pass requirement. Mute/no-freeze means the full transfer/processing path reached
completion; it does not validate file identity. No mute means the failure is
before checksum acceptance (or hotkey execution was not reached).
Hardware result: boots, no mute, reported October 5.
Deliver DSPico_Test_94.zip. Copy only the two loader bins.

## Test 95: increase full-read E4 status-poll budget

Test 94 failed before checksum acceptance. Test 93 introduced a 255 counter
allowing only 254 E4 polls per sector; the earlier passing probes did not have
a total poll cap. Change ONLY that budget to existing probeTimeout=0x20000,
allowing 131071 E4 polls per sector. Bus waits remain bounded. Full read, extent
map, checksum calculation and disabled checksum gate remain as Test 94.
Mute/no-freeze means complete transfer processing; not checksum validation.
No mute rejects the small-poll-budget hypothesis as a sufficient fix.
Hardware result: user reports pass, boots then mutes, October 5.
Post-mute continued gameplay/no-freeze was not explicitly reported.
The larger poll budget permits full transfer completion on this setup.
Deliver DSPico_Test_95.zip. Copy only the two loader bins.

## Test 96: full-file checksum with proven larger status budget

Restore ONLY the checksum-mismatch branch disabled in Test 94. Preserve Test 95's
0x20000 status budget, 95-sector extent read and 512-byte buffer. Mute now requires
the 12112-word additive sum to equal 0x355637BE. This closes the data-validation
step after Test 95 reached full-transfer completion. Checksum is diagnostic,
not collision-free identity proof. Hardware PASS October 5: boots/mutes/no freeze.
Deliver DSPico_Test_96.zip.
Expected pass: boots, hotkey mutes, gameplay continues without freezing.
Copy only the two loader bins; next recap near Test 100.

## Test 97: ARM7 to ARM9 rendezvous via hardware IPC sync

Keep Test 96's complete-file read and checksum. After success ARM7 writes 0xE
to its IPCSYNC output nibble, preserving other control bits, then mutes. The
SDK2-4 CARDi CPU-read patch checks its IPCSYNC input nibble at its epilogue,
after the read inputs and cardi_common state have been consumed. It preserves
r0; original epilogue restores r1/r2/r3/r4/r6. On request ARM9 writes 0x8008 to
both master brightness registers, darkening both screens without blacking out.
This differs from earlier shared-memory bridges by using hardware signalling
(no ARM9 data-cache visibility dependency) and a post-read insertion point.
No reset, memory remap, wait for peer, or FIFO/IPC interrupt is introduced.
This only observes an SDK2-4 CPU cartridge-read path: SDK5/DMA and a game scene
that does not read through this path may not show the screen marker.
Test: same game, hold hotkey until muted, then change menu or load/start a race
to trigger cartridge reads. Mute plus visibly darker screens while gameplay
continues confirms ARM9 participation. Mute alone confirms ARM7 but not ARM9.
Boot failure means this bridge integration is not boot-safe on this game.
Hardware result October 5: only muted; no screen marker reported. ARM9
participation is unproven; post-hotkey cartridge reads were not explicitly confirmed.
Deliver DSPico_Test_97.zip; copy only the two loader bins.
Next recap near Test 100. Full reset remains unproven.

## Test 98: unconditional ARM9 CPU-read marker

Replace ONLY Test 97's conditional branch with a same-size Thumb NOP.
Every execution of the existing CARDi CPU-read epilogue now writes 0x8008
brightness on both screens regardless of IPCSYNC. ARM7 full-file checksum and
hotkey mute remain unchanged. Watch screens during boot/menu/race loading before
and after hotkey. Darkening proves this hook executes and its brightness marker
is observable; it does not prove IPC request delivery. No darkening leaves hook
reachability versus game brightness overwrite unresolved. Boot failure is failure.
No reset attempted. Deliver DSPico_Test_98.zip; copy only two loader bins.
Hardware result October 5: user reports flicker then normal gameplay; video
shows brief brightness changes. Consistent with marker overwrite, not definitive
proof that every flicker originated in the patch. Recap near Test 100.

## Test 99: ARM9 acknowledgement gates ARM7 audio mute

Remove brightness writes. ARM9 CPU-read epilogue observes ARM7 IPCSYNC E and
publishes D in its own output nibble; clears its output nibble when request
absent. Preserve control bits and saved registers. ARM7 retains checksum probe,
publishes E and sets local ackPending. It no longer mutes immediately. Every
subsequent detector invocation checks for D only while ackPending is set; on D
it clears pending and disables sound. No busy-wait, IRQ/FIFO changes or reset.
Keep gameplay running; after hotkey trigger cartridge reads by loading a race.
Mute is now evidence of full-file read plus ARM9 request/reply, subject to
possible collision with game-owned IPCSYNC nibble use. No mute does not negate
the earlier full-file success. A delayed reply can mute after keys are released.
Hardware pending. Deliver DSPico_Test_99.zip; replace only two loader bins.
Recap near Test 100. Payload placement and actual reset still remain.
