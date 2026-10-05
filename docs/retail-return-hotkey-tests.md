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
changing stack, disabling IRQs, or remapping VRAM. Hardware result: pending.
Expected pass: boots, hotkey mutes, no freeze. Copy only the two loader bins.
Deliver as DSPico_Test_91.zip. Next recap remains near Test 100.
