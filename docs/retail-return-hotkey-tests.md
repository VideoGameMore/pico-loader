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
Hardware PASS October 5: audio stayed on until race loaded, then muted.
This supports ARM9 receiving E and replying D before ARM7 mute.
Deliver DSPico_Test_99.zip; replace only two loader bins.
Recap near Test 100. Payload placement and actual reset still remain.

## Test 100: controlled ARM9 parking after acknowledged request

Preserve Test 99 request/reply. After publishing D, ARM9 checks request E,
disables its IME, writes 0x8010 to both master brightness registers, and loops
locally in the patch. Non-request reads still return normally. ARM7 unchanged:
it should see D and mute on a subsequent detector invocation. No VRAM remap,
loader placement, actual reset, or ARM7 parking yet. This intentionally stops
gameplay; user must power-cycle after test. Expected: normal boot until hotkey
and next CPU cartridge read, then both screens black and gameplay halts; mute
if ARM7 detector continues. Black marker occurs after IME disable. Frozen visible
frame alone is not the expected marker. Hardware PASS October 5: both screens
turn black and gameplay stops deliberately, as requested. Audio not explicitly
reported in that result.
Deliver DSPico_Test_100.zip; copy only two loader bins.

### Recap 90-99

90/91: staged Thumb and ARM instructions execute and return.
92: actual ARM7 entry sector reads correctly through file extents.
93/94: full-file transfers fail before checksum gate; no mute.
95: larger E4 poll budget restores full transfer completion.
96: full-file additive checksum gate passes, no freeze.
97: mute only; ARM9 brightness marker not observed.
98: reported flicker, game continues; marker overwrite plausible.
99: mute only after race load, supporting ARM9 request/reply.
Next: park ARM9, choose safe complete-loader placement, stop/redirect ARM7,
perform required hardware/cache setup, then start both loaders. None of the
passing diagnostics establishes actual return-to-loader yet.

## Test 101: retain complete ARM7 loader in ARM7-mapped VRAM C

ARM9 maps VRAM C to ARM7 offset zero (VRAMCNT_C=0x82) BEFORE publishing D,
then follows proven Test 100 black-screen/IME-off park. ARM7 accepts D,
initializes stagingCursor=0x06000000 and runs a second complete-file transfer.
The existing word loop stores each of 12112 words into that 128 KiB bank;
initial pre-request pass has cursor=0 and does not write VRAM. Restore r4
physical-sector state per word. On transfer checksum success, a separate sweep
reads all 48448 stored bytes and checks additive sum 0x355637BE. Only then mute.
No loader execution, entry jump, BSS clearing, VRAM D mapping, or ARM7 park yet.
Black screens now mean ARM9 parked; audio mute additionally supports full retained
ARM7 payload/readback success. Audio continuing can indicate second-read/staging
failure or ARM7 callback unavailable after park. Power-cycle after test.
Hardware FAIL October 5: after blackout audio froze on a sustained note,
without mute. ARM9 park occurred; post-park transfer/verification did not reach
success marker. The sustained note is not proof of VRAM access failure.
Deliver DSPico_Test_101.zip; copy only two loader bins.

## Test 102: isolate ARM7 VRAM C access after ARM9 park

Keep Test 101 ARM9 mapping-before-ack and black-screen park. Keep the proven
initial full-file read/checksum. Replace the entire post-ack full read/copy/sum
with two word write/readback comparisons: 0x5A at 0x06000000 and 0xA5 at
0x0600BD3C (last word of 48448-byte payload). Only mute if both match. This tests
ARM7 callback reaching mapped VRAM at payload boundaries without post-park SD
access. It does not prove a complete retained loader. Pre-request stagingCursor
remains zero. Black+mute supports mapping/access and redirects investigation to
post-park cartridge ownership/transfer or full-copy loop. Black+sustained audio
leaves callback reachability or VRAM access unresolved. Power-cycle afterward.
Hardware PASS October 5: blackout then silence, possibly a fraction later;
no audio. Supports both VRAM boundary checks reaching success.
Deliver DSPico_Test_102.zip; copy only two loader bins.

## Test 103: restore full VRAM copy with explicit Slot-1 ownership

Restore Test 101 ARM7 complete second transfer, staged payload and readback
checksum unchanged. Keep Test 102-proven VRAM C mapping. Before acknowledgement,
ARM9 sets EXMEMCNT bit 11 (0x0800) assigning Slot-1 to ARM7, preserving other
bits. Existing BootstubPatchCode.s documents clearing 0x880 as assigning slots
1/2 to ARM9. No Slot-2 ownership change. Then ARM9 acknowledges/blacks/parks.
Hypothesis: the preceding ARM9 race read left Slot-1 assigned to ARM9, preventing
ARM7's post-park SD commands. Initial pre-request reads previously passed, so
this is a timing/ownership hypothesis, not established root cause.
Pass: blackout followed by mute, supporting full 48448-byte retained payload
with expected readback additive checksum. Failure: no mute/sustained note.
No actual loader execution yet. Power-cycle afterward.
Hardware October 5: user says acted just like last test, nearly same timing.
Interpreted as Test 102-style blackout plus silence; sustained note not reported.
On that reading the full copy/readback succeeded; interpretation stated to user.
Deliver DSPico_Test_103.zip; copy only two loader bins.

## Test 104: ARM7 execution from mapped VRAM C after full staging

Keep Test 103 transfer, readback checksum, ownership and ARM9 park. After payload
verification, write two ARM instructions to unused VRAM C at 0x06010000,
outside 48448-byte payload: mov r0,#0x5B; bx lr. Enter via BX with an aligned
ARM address and a Thumb return address; helper preserves nested-call LR.
Only mute if returned r0 is 0x5B. The full loader bytes remain untouched.
Pass: blackout then mute supports complete retained payload and ARM7 instruction
fetch/execution from this mapped bank. This diagnostic does not execute the real
loader or establish its startup dependencies (boot drive, paths, peer, hardware
state). Failure may sustain sound; power-cycle after test.
Hardware PASS October 5: black screen and mute almost simultaneously on race
load, supporting full-copy/checksum plus VRAM ARM token execution and return.
Deliver DSPico_Test_104.zip; copy only two loader bins.

## Test 105: enter real ARM7 loader and observe its startup handshake

Keep complete staged image, checksum and VRAM token check. Map VRAM D to ARM7
at +128KiB (0x8A) together with C (0x82), matching loader7.ld's 256KiB region.
After verification, replace diagnostic mute with BX to the entry pointer from
the staged header. Unmodified crt0 disables IRQs, clears BSS, sets stack to
0x0380FD80 and enters loaderMain. That code initializes constructors, clears
sound, initializes RTOS, then initIpc publishes HANDSHAKE_PART0=A and waits for
ARM9 A. ARM9 remains parked but polls incoming A; only then sets both master
brightness registers to white (0x4010) and parks permanently WITHOUT replying A.
This deliberately stops at startup before SD mounting/path selection, with no
ARM9 loader payload present. No changes to compiled ARM7 loader binary.
Expected: black, sound stops due to actual loader, then both screens white.
Black+mute alone means real-loader sound clearing may have occurred, not complete
startup handshake. White means ARM7 reached initIpc PART0, not completed boot.
Hardware PASS October 5: black screens -> audio stops -> both screens white.
Confirms real ARM7 loader reached startup PART0 A. Power-cycle afterward.
Deliver DSPico_Test_105.zip.
Copy only two loader bins. Next requirement: stage/start matching ARM9 loader,
then propagate boot-drive and launcher-path parameters for the intended return.

## Test 106: stage matching ARM9 loader while real ARM7 waits

Keep Test 105 real ARM7 loader startup; ARM7 waits on A. When ARM9 receives A,
assign Slot-1 back to ARM9, map VRAM A LCDC, and read the ARM9 loader's physical
file extents through the existing DSPICO SD reader. Before game boot publish up
to four runs from clusterMap9; include all allocated sectors (cluster padding),
bounded to 256 sectors/128 KiB and physical-address overflow checks. No fixed
ARM9 binary size or self-referential embedded checksum. Empty/invalid/too-large
map disables completion. After all reads return, compare the first four ARM9
crt0 instructions to 0xE59F011C,E5C00000,E59F0118,EE010F10. Only then white.
This is complete allocated-sector transfer plus entry-word checking, NOT a
full-file checksum validation. SD reader retains its existing unbounded waits.
ARM7 remains waiting; ARM9 does not enter its loader yet. Expected black, sound
stops, white. White now requires ARM7 startup AND ARM9 image staging/checks.
Black+silence leaves card transfer/map/header check unresolved. Power-cycle.
Hardware PASS October 5: black -> audio stops -> white.
Supports real ARM7 startup plus ARM9 staging/entry checks.
Deliver DSPico_Test_106.zip; copy only two loader bins.
Next: loader startup on ARM9 and correct boot-drive/launcher parameters.

## Test 107: first coordinated loader startup and return attempt

Keep proven image transfer and ARM7 actual startup. Preserve boot drive with
multiboot flag cleared plus 256-byte launcher path in ARM9 patch data, populated
before game patching. CARDi ApplyPatch publishes its relocated data address into
the ARM7 template; ARM9 patching completes before ARM7 template copy. ARM7 reads
that immutable data before entering its loader, sets header bootDrive and both
romPath/launcherPath. Missing pointer or empty path rejects entry. Original raw
header null DLDI, empty save/argv and null cheats remain; null DLDI makes normal
loader initialize platform SD functions. The verified loader checksum precedes
parameter edits. No real loader binaries altered by parameter injection.
Once ARM9 receives ARM7 A and loads/checks its own image, clear master brightness
and BX 0x06800000 instead of parking white. ARM9 crt0 reinitializes MPU/caches,
ITCM/DTCM/BSS/stacks and enters normal loaderMain; it should answer ARM7 A and
complete normal handshake, mount SD and load the preserved launcher as normal
ROM. This is an actual return attempt, not a guaranteed return. Compatibility
outside the tested SDK2-4 CPU read path remains unproven. SD waits remain existing
unbounded implementation. Expected: black/silence then Pico Loader menu; record
any displayed error or black/white hang. Power-cycle if stuck.
Hardware PARTIAL October 5: Pico Loader interface appears but game list empty.
Photo shows launcher shell with back/settings icons; user confirms no controls
respond. This is a launcher hang, not proven directory enumeration failure.
Deliver DSPico_Test_107.zip; copy only two loader bins.

## Test 108: leave ARM7 IRQ context before loader entry

Keep Test 107 images, reads, parameters, ARM9 startup and normal return target.
Replace direct ARM7 BX entry with a small ARM trampoline in the injected patch:
disable IME, establish IRQ stack 0x0380FF80 and SVC stack 0x0380FFC0 with CPU
interrupts masked, switch CPSR to ARM system mode 0x1F, then BX actual loader
entry. Loader crt0 establishes system SP 0x0380FD80 as before. Hardware IME is
off when CPU mask is lifted; loader runtime owns subsequent IRQ setup.
Reason: hotkey path originates inside ARM7 VBlank IRQ; ARM7 crt0 never changes
CPU mode, unlike ARM9 crt0. RTOS startMainThread does not switch mode either.
Inherited IRQ-mode stack/control state can survive polling-based loader startup
and corrupt later scheduling/interrupt-dependent launcher operation. This is a
source-backed hypothesis; user hardware result will determine sufficiency.
No changes to on-disk ARM7 loader binary or its expected checksum.
Expected: return to responsive Pico Loader with games; record empty/frozen shell,
visible error or boot regression. Power-cycle if stuck.
Hardware FAIL October 5: returns to launcher with no games; touch opens layout
settings but back arrow does not work. UI partially responds, unlike earlier
report; CPU-mode fix did not restore storage-backed navigation.
Deliver DSPico_Test_108.zip; copy only two loader bins.

## Test 109: preserve real DLDI driver for the returning launcher

Source review: fallback dldi_init handles a null driver using platform routines,
but does not create a valid DLDI header. DldiDriver::PatchTo then rejects that
buffer, so the launcher does not receive the working cold-boot driver. Launcher
mount/enumeration behavior explains partially responsive UI with no files;
this is a concrete missing-driver defect, not yet proof of sole hang cause.
Reserve 16 KiB at the ARM7 game's main-memory arena before boot, advancing arena
so game allocations exclude it. Publish address in ARM7 injected patch. Add a
fourth ARM7-patch IPC response word; ARM7 loader consumes it and dldi_copyTo copies
its working complete driver to the reserved address. On hotkey, staged ARM7
header.dldiDriver receives this pointer before loader startup. Its dldi_init
copies/relocates the driver into fresh loader storage before clearing main RAM,
and can now patch the launcher stub with a valid real driver. No launcher file
change. Keep Test 108 CPU-state normalization and Test 107 return machinery.
ARM7 loader binary changes due to extra IPC/copy; recompute exact file size,
word count, sector count and checksum after CI before delivering hardware ZIP.
Both bins must be replaced together because IPC response schema changes.
Expected: games visible, layout/back navigation responds, game launches.
Hardware PASS October 5: closed game, returned to usable Pico menu and launched
the game again. Full cycle confirmed on the tested setup.
Deliver DSPico_Test_109.zip; copy only two loader bins.

Test 109 compiled ARM7 payload: 48480 bytes, 12120 words, 95 sectors,
additive checksum 0x0E2D6140. Final CI must match these refreshed constants.

### Recap 100-109

100: ARM9 deliberately parks with black screens.
101: second ARM7 transfer does not reach mute; sustained note.
102: VRAM C boundary access passes.
103: explicit Slot-1 ownership permits full staged copy/readback.
104: ARM7 executes and returns from VRAM token.
105: real ARM7 loader reaches its startup handshake.
106: ARM9 loader image transfer and entry checks pass.
107: launcher interface appears, but games/navigation unavailable.
108: fresh ARM7 CPU mode/stacks do not restore storage.
109: preserved valid DLDI driver restores menu, games and relaunch.
Remaining delay: ARM9 sees the request only on the next CPU cartridge read.

## Test 110: return from VBlank without a new cartridge read

Keep Test 109's working driver, parameters and loader transfer/startup.
Find the standard Nitro ARM9 IRQ dispatch tail by its four exact instructions.
Redirect its pre-autoload bytes to a wrapper; preserve original IRQ table and
return literals. Normal dispatch restores registers and condition flags then
executes the four displaced operations. Only VBlank (IRQ index zero) checks the
ARM7 E request. Defer during a patched SD read or while ROMCTRL is busy.
On request disable IME and enter masked system mode, apply the existing CP15
fix and enter the proven card-read epilogue takeover sequence. Existing read
hook remains a fallback when the standard dispatcher is absent.
No change to on-disk ARM7 loader or expected 48480-byte checksum.
Hardware FAIL October 5: game does not boot; both screens white.
Return-trigger behavior could not be tested. Test from a stationary game menu: hold L+R+Down+Select about
half a second, without starting a race, expect Pico menu and successful relaunch.
Deliver DSPico_Test_110.zip; copy only picoLoader7.bin and picoLoader9.bin.

## Test 111: preserve dispatcher, intercept only IRQ handler return

Test 110 fails before hotkey use. Its rewritten dispatch tail is not boot-safe
on the tested game; the specific cause remains unconfirmed.
Restore all four standard SDK dispatch instructions. Replace only the original
handler-return literal (the target loaded into LR) with the ARM wrapper address.
The game selects and invokes its own IRQ handler exactly as before. On handler
return, wrapper saves/restores post-handler registers and condition flags; the
normal path loads PC with the preserved original SDK epilogue address without
modifying any register. Remove IRQ-index-zero check because r0 is now whatever
the handler returned, not the dispatch index. All returning IRQ handlers can
check the E request, while patched SD-read activity and ROMCTRL busy checks
still defer takeover. Keep the working card-read fallback, driver and loaders.
No ARM7 binary changes or checksum refresh required.
Hardware FAIL October 5: frozen two white screens; game never boots.
The handler-return change did not restore boot. First verify boot. Then hold L+R+Down+Select about half a second
on a stationary game menu without starting a race; expect usable Pico menu and
game relaunch. If boot succeeds but request has no effect, loading a race tests
whether the proven card-read fallback still returns.
Deliver DSPico_Test_111.zip; replace only picoLoader7.bin and picoLoader9.bin.

## Test 112: restore Test 109 and check ordinary BIOS wait calls

User notes earlier IRQ/ARM9 attempts already caused boot failures. Stop extending
that family: remove every Test 110/111 dispatcher/IRQ-return hook and read-active
flag. Restore Test 109 CARDi code exactly except a zero-size exported takeover
label. Preserve proven return/relaunch code and real driver.
SecureSysCallsUnusedSpaceLocator already recognizes and preserves BIOS wait
wrappers in the first 0x800 bytes: SVC3 WaitByLoop, SVC4 IntrWait with movs r2,#0,
SVC5 VBlankIntrWait with movs r2,#0, and SVC6 Halt. Find these exact wrappers before
allocating separate wait code; replace only the SVC halfword with a bounded Thumb
branch to a separate 16-byte trampoline. The trampoline saves BIOS arguments/LR,
calls a request checker, restores arguments, executes the original SVC then
returns to its original caller. Checker preserves registers/condition flags on
no request and defers while ROMCTRL busy. On E it disables IME, applies existing
CP15 fix and enters Test 109 takeover. No IRQ vector/dispatcher/table changes.
Wait helper allocated separately: avoid growing the existing large CARDi block
inside the fragmented 2 KiB secure-area heap. Heap-fit trouble is another
possible explanation for 110/111 white screens, not a proven root cause.
Reachability in the tested Mario Kart menu is not established; if wrappers are
absent or unused, proven cartridge-read return remains the fallback.
No ARM7 on-disk changes; checksum remains 0x0E2D6140 over 48480 bytes.
Hardware FAIL October 5: same frozen two white screens; game does not boot.
The BIOS-wait approach has not established boot safety or trigger reachability.
Verify game boot first, then hotkey on a stationary menu
without starting a race. If no response, load a race to test 109 fallback.
Deliver DSPico_Test_112.zip; copy only picoLoader7.bin and picoLoader9.bin.

## Test 113: exact recovery of the hardware-passing Test 109 implementation

Three consecutive menu-trigger experiments (110,111,112) fail before game boot.
Restore every executable-source difference from Test 109 commit
255eb29782606c14ed21216a3385cacfd829a7f9: CARDi CPP and assembly; delete the added
BIOS wait helper. Keep the complete historical test log. No new hook, changed
trigger, changed allocation, or revised loader is introduced.
Compile and compare both delivered loader binaries byte-for-byte with the original
Test 109 hardware-passing artifact. Exact matching binaries make this a baseline
recovery experiment, not a claim that menu-only return is fixed.
Test: normal game boot, same hotkey, then race load as in Test 109; expect Pico
menu with games, followed by successful game relaunch. If exact baseline also
fails boot, investigate installation/setup or state before further source edits.
Hardware PASS October 5: exits to Pico menu and game reloads again.
Recovery of the exact Test 109 binary pair is confirmed. Deliver DSPico_Test_113.zip; replace only the two loader bins.

## Test 114: measure patch-space capacity without adding a game hook

113 restores boot and return/relaunch. 110/111/112 all consume additional ARM9
patch space, while PatchHeap::Alloc spins forever silently if no contiguous
block fits. This is a concrete failure mechanism and a hypothesis for the
three white-screen regressions; runtime measurements are needed.
Add read-only total/largest-block getters and nonfatal TryAlloc; existing Alloc
retains its required-allocation fatal behavior via TryAlloc. Record capacity
immediately before the unchanged 680-byte CARDi allocation, then after every
required patch is applied and copied. Install no optional code, IRQ hook or
BIOS-wait hook and do not consume additional game patch space.
Show these four byte counts on a temporary pre-boot diagnostic screen.
Unlike existing warning rendering at 0x02100000, diagnostic allocates its
49152-byte text buffer from the loader's own VRAM A heap, never game RAM.
If allocation fails, skip display and proceed. Use a local resolved font header,
free the buffer after A, then perform normal cache flush/boot.
Test: photograph or transcribe the diagnostic screen, press A, verify game boot,
and the proven hotkey + race load return and relaunch. Diagnostic may appear
again whenever a retail game is launched in this test build.
On-disk ARM7 remains identical; game CARDi template remains byte-identical.
Hardware October 5: after selecting Mario Kart, initial white changes to black
screens without text. Pressing A boots Mario Kart. This was a blank waiting
diagnostic, not confirmed game boot failure. Capacity values remain unreadable;
return/relaunch not yet explicitly reported for 114.
Deliver DSPico_Test_114.zip; copy only both loader bins.

## Test 115: readable direct diagnostic rendering

114 waits for A and then boots Mario Kart; text buffer failed to show glyphs.
Its pixel renderer writes bytes into a text buffer allocated from VRAM A heap.
Replace this diagnostic with fixed 5x7 uppercase/digit glyphs drawn at 2x scale
directly into VRAM E's 8-bit bitmap using halfword read-modify-writes. No dynamic
text buffer, formatting library, font relocation, byte pixel writes, or game
RAM scratch storage. Existing warning/error renderer is restored unchanged.
Print the same four capacity values and the 680-byte base patch requirement.
No new game hook or game patch allocation. Keep 114 capacity bookkeeping and
nonfatal optional allocator; working CARDi and ARM7 stay byte-identical to 109.
Hardware PASS October 5: visible diagnostic reports before total/max 1240, after total/max 76, base 680. Pressing A boots game; original return and relaunch work without freezing. Photograph visible status, press A, then boot and original
hotkey + race load return/relaunch. Return trigger still requires next read.
Deliver DSPico_Test_115.zip; copy only both loader bins.

## Test 116: reclaim 128 bytes from persisted launcher parameters

115 confirms only 76 contiguous bytes remain after required patches. Compact
the persisted launcher path from 256 to 128 bytes, reducing CARDi from 680 to
552 bytes. Copy only 32 words into fresh loader headers, whose remaining path
bytes are zero on disk. Require a nonempty complete NUL-terminated path within
127 characters; otherwise leave game boot intact and disable the ARM7 hotkey
request by clearing its extent map. Never truncate a pathname or enter takeover
with invalid parameters. Ordinary game reads and the working loader/DLDI
handoff remain unchanged. No new trigger is installed yet.
Expected Mario Kart diagnostic: before total/max 1240, after total/max 204,
base patch 552. Photograph counts, press A, then verify the same hotkey plus
race load, usable Pico menu and successful relaunch. Hardware PASS October 5: diagnostic 1240/1240 before, 204/204 after, base 552; same working boot/return/relaunch.
Both on-disk loaders still copied; ARM7 binary expected byte-identical to 109.
Deliver DSPico_Test_116.zip.

## Test 117: optional BIOS-wait trigger within measured capacity

116 hardware passes and confirms 204 contiguous bytes free. Revisit the
previously untested BIOS-wait trigger with the measured capacity available.
Unlike 112, allocate its ARM checker plus up to four 16-byte Thumb stubs as
ONE optional block only AFTER all required patches are copied. TryAlloc
failure skips it without changing wrappers or preventing boot. Preflight every
Thumb branch before publishing any hook. No IRQ dispatcher or IRQ return edits.
Expose relocated existing CARDi takeover and CP15 fixer addresses without
growing CARDi's 552-byte template. On no request checker restores registers
and flags; stub restores BIOS arguments and executes original SVC. On E
request, idle cartridge required, disable IME, run existing CP15 fix and enter
existing return handshake. ARM7 binary unchanged; race-read fallback retained.
Diagnostic adds WAIT HOOKS count; photograph before A. Verify boot then hotkey
from a stationary game menu without loading a race. If no response, load a race
to test fallback, then menu navigation and relaunch. Hook reachability and
hardware behavior pending. Deliver DSPico_Test_117.zip, copy only both bins.

Hardware Test 117 October 5: 1240 before, 20 after, WAIT HOOKS 0. User confirms
boot and race-triggered fallback return. No wait hook was installed; installer
allocated 184 bytes then rejected at least one branch. Range rejection is
established by the code path; exact addresses and reason remain unknown.

## Test 118: individual branch acceptance and address diagnostics

Keep the working return and same 120-byte wait checker. Reserve four extra
bytes and align checker/stubs to four bytes (required for ARM instructions
and Thumb PC-relative literals). Maximum optional request is 188 bytes,
within measured 204. Build all stubs before publishing any wrapper branch.
Accept each in-range even branch individually; an unreachable wrapper no
longer cancels all four. Never bypass the range check. Show decimal SITE and
STUB addresses for the last rejected pair, or first pair if none rejected.
Diagnostic keeps installed WAIT HOOKS and remaining capacity. This tests
placement and installs only branches the encoder can represent.
Hardware pending. Photograph before A, verify boot, menu-only hotkey and
fallback race if necessary. Deliver DSPico_Test_118.zip, copy both bins only.

Hardware Test 118 October 5 photo: before 1240, after total/max 16,
SITE 33556378 (0x0200079A), STUB 33566684 (0x02002FDC), WAIT HOOKS 0.
Branch displacement is 10302 (stub-site-4), beyond +2046. Required patches
are in the existing .parent area, not adjacent to secure BIOS wrappers.
Photo establishes placement failure. User subsequently confirms boot and race load closes the game.

## Test 119: nearby optional secure heap when required patches use parent

Track the existing selection of .parent memory for mandatory patches.
If that mode is used and the entire secure 0x800 region is disjoint from
parent, discover unused secure space through the existing syscall locator
into a separate optional heap. Allocate the same aligned 188-byte maximum
helper/stub block there. Preserve recognized syscall wrappers; no fixed
scratch address or newly claimed game RAM. If required patches instead used
secure space, keep using their existing residual heap and never rediscover
occupied space. Nonfatal allocation and individual branch checks retained.
Existing ARM7 and CARDi payload remain unchanged. Diagnostic SITE/STUB should
now be nearby and WAIT HOOKS should be nonzero; parent free count may remain
204 because optional code uses a separate region.
Hardware pending: photograph, A, game boot, menu-only hotkey, Pico navigation
and relaunch. Check race fallback if menu trigger has no response.
Deliver DSPico_Test_119.zip, copy only picoLoader7.bin and picoLoader9.bin.

Hardware Test 119 October 6: before 1240, after total/max 204, SITE/STUB 0,
WAIT HOOKS 0. Game boots; hotkey alone does nothing; subsequent race load
returns to Pico menu. Relaunch not separately reported in this result.
Nearby installation exited before publishing branches; exact early check
not measured. Main heap remains untouched by optional code.

## Recap 110-119

110/111: added IRQ paths fail game boot; execution not established.
112: BIOS-wait experiment also fails boot before trigger can be tested.
113: exact 109 binaries restore boot, usable Pico menu and relaunch.
114: diagnostic waits invisibly; A boots game.
115: readable diagnostic proves only 76 bytes remain after required patches.
116: compact bounded launcher parameters recover 128 bytes; boot/return/relaunch pass.
117: helper fits but zero hooks; boot and race fallback pass.
118: zero hooks despite per-site checking; address measurement proves 10302-byte
branch displacement, outside short Thumb branch range. Race fallback passes.
119: nearby allocation attempt exits early; boot and race fallback pass.
Known working: hotkey request, race-read acknowledgement, both loaders, storage,
Pico menu and relaunch. Menu-only trigger remains uninstalled and unproven.
Correction to early reasoning: Mario Kart uses .parent patch memory, while
wait wrappers are in the separate secure area. Capacity counts described the
parent heap; they were not measurements of secure-area free capacity.

## Test 120: split nearby stubs from helper; expose installer state

Keep the 120-byte ARM checker in the proven required-patch heap (optional
124-byte aligned reservation). Allocate each 16-byte Thumb stub separately
with 20-byte aligned reservations from nearby secure space when mandatory
patches use disjoint parent memory. This avoids requiring a single nearby
188-byte block. Nonfatal allocation and individual branch checks retained.
Diagnostic STATE codes: 1 missing takeover/fixer or short image; 2 no wait
sites; 3 secure/parent overlap; 4 nearby heap empty; 5 helper allocation fails;
7 no accepted branch after stub attempts; 8 one or more hooks installed.
NEAR TOTAL/MAX measured before optional allocations. STATE 4 prints first
two secure words as WORD ZERO/ONE to identify a rejected locator signature.
Otherwise SITE/STUB identify final attempted pair. Publish only after all
accepted stubs are written. No new IRQ edits or modified loader handoff.
Hardware pending: photograph, A, verify boot and menu-only hotkey, fallback
race if necessary, Pico navigation and relaunch. Deliver DSPico_Test_120.zip.

Hardware Test 120 October 6: STATE 8, nearby total 1936/max128, parent after80,
SITE33556378, STUB33554584, WAIT HOOKS4. Fragmentation explains Test119:
its single188-byte request could not fit a128-byte largest block.
Game boots. Hotkey plus active menu navigation stays in-game. After idle,
attract/demo mode returns to Pico; race start also returns. Existing read
fallback is sufficient to explain both exits. The four Thumb secure wrappers
are installed but timely menu-trigger execution is not demonstrated.

## Test 121: add recognized static ARM BIOS wait wrappers

Keep Test120's installed Thumb hooks and same ARM checker. Scan static ARM9
image after secure0x800 for exact unconditional ARM SVC3/4/5/6 plus BX LR;
SVC4/5 additionally require preceding MOV r2,#0. Stop before module-parameter
autoloadStart when it lies within image, avoiding branch rewriting in payloads
whose runtime addresses relocate. No IRQ/vector/table edits.
Each optional aligned32-byte reservation contains a28-byte ARM stub saving
r0-r3,r12,LR, calling existing checker, restoring registers, executing original
SVC and returning via preserved LR. Replace only SVC with non-linking ARM B.
Check full signed branch range/alignment before publishing. Reuse the existing
nearby heap; nonfatal allocation preserves game boot and fallback.
Diagnostic shows THUMB HOOKS and ARM HOOKS separately. ARM wrapper existence,
boot safety and menu reachability remain hardware tests, not assumptions.
Test: photograph counts, A, verify boot, hotkey plus menu navigation without
waiting for attract mode. Then fallback/demo if necessary, usable Pico/relaunch.
Deliver DSPico_Test_121.zip; replace only both loader bins.

Hardware Test 121 October 6: STATE8, nearby1936/max128, parent after80,
THUMB HOOKS4, ARM HOOKS0. User confirms same behavior: game boots;
hotkey does not immediately exit; starting a race returns to Pico.
No new ARM hook was installed, so this did not extend trigger coverage.

## Test 122: recognize relocated ARM BIOS wait wrappers

121 scans only static code. Extend the exact SVC3/4/5/6 plus BX LR search
through the decompressed NTR ARM9 image, using PatchContext's existing
AutoloadAdjuster to calculate each instruction's final runtime address.
Require wrapper instructions (including MOV r2,#0 for SVC4/5) to retain
contiguous runtime addresses. Relocated targets are accepted only in standard
SDK ITCM 0x01FF8000..0x02000000 or main RAM 0x02003000..0x02400000,
excluding secure stub and parent-helper regions. Other relocations are skipped.
Encode and bound-check the branch from the final PC; write it to original
payload bytes for game startup to copy. Original SVC is replayed in the same
28-byte ARM stub; registers, caller LR, existing checker and fallback unchanged.
Nonfatal allocation, signed ARM branch bounds and prepare-before-publish retained.
No IRQ edits. ARM7 and required CARDi transfer code unchanged.
Diagnostic AUTO HOOKS counts installed relocated ARM wrappers, a subset of
ARM HOOKS. If ARM/AUTO remain zero, no additional menu execution path was
installed and the photograph itself establishes that result; do not infer
wait calls are absent from every game or that installed hooks are reached.
Hardware pending: photo, press A, verify boot, then menu hotkey while moving
through menus. If no immediate return, race fallback; verify usable Pico.
Deliver DSPico_Test_122.zip; replace only picoLoader7.bin and picoLoader9.bin.
