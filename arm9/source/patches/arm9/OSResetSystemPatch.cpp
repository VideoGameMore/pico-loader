#include "common.h"
#include "patches/PatchContext.h"
#include "thumbInstructions.h"
#include "patches/platform/LoaderPlatform.h"
#include "patches/arm7/hotkey/RetailHotkeyDetectionPatchCode.h"
#include "OSResetSystemPatchCode.h"
#include "OSResetSystemPatch.h"

static const u32 sOSResetSystemPatternSdk2Old[] = { 0xE59F101Cu, 0xE3A00010u, 0xE5815000u, 0xEB000005u };
static const u32 sOSResetSystemPatternSdk2[] = { 0xE59F1018u, 0xE3A00010u, 0xE5814000u, 0xEB000004u };
static const u32 sOSResetSystemPatternSdk2New[] = { 0xE59F1014u, 0xE3A00010u, 0xE5814000u, 0xEB000003u };
static const u32 sOSResetSystemPatternSdk3[] = { 0xE59F1014u, 0xE3A00010u, 0xE5814000u, 0xEBFFFFD9u };
static const u32 sOSResetSystemPatternSdk4[] = { 0xE59F103Cu, 0xE59F003Cu, 0xE5814000u, 0xEBFFFFD6u };
static const u32 sOSResetSystemPatternPokemonDownloader[] = { 0xE59F1010u, 0xE3A00010u, 0xE5814000u, 0xEBFFFFDEu };

static const u32 sOSResetSystemPatternSdk5Old[] = { 0xE1A04000u, 0xE1D100B0u, 0xE3500002u, 0x1A000000u };
static const u32 sOSResetSystemPatternSdk5New[] = { 0xE1A05000u, 0xE1D100B0u, 0xE3500002u, 0x1A000000u };
static const u32 sOSResetSystemPatternSdk5HybridOld[] = { 0xE1A04000u, 0xE1D100B0u, 0xE3500002u, 0x0A000006 };
static const u32 sOSResetSystemPatternSdk5HybridNew[] = { 0xE1A05000u, 0xE1D100B0u, 0xE3500002u, 0x0A000006 };

bool OSResetSystemPatch::FindPatchTarget(PatchContext& patchContext)
{
    _osResetSystem = nullptr;
    _hybrid = false;

    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5Old, sizeof(sOSResetSystemPatternSdk5Old));
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5New, sizeof(sOSResetSystemPatternSdk5New));
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridOld, sizeof(sOSResetSystemPatternSdk5HybridOld));
            if (_osResetSystem)
                _hybrid = true;
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridNew, sizeof(sOSResetSystemPatternSdk5HybridNew));
            if (_osResetSystem)
                _hybrid = true;
        }
    }
    else
    {
        if (patchContext.GetSdkVersion() >= 0x4017530)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk4, sizeof(sOSResetSystemPatternSdk4));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x3017530)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk3, sizeof(sOSResetSystemPatternSdk3));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2017532)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2New, sizeof(sOSResetSystemPatternSdk2New));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004F50)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2, sizeof(sOSResetSystemPatternSdk2));
        }
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004EE9)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2Old, sizeof(sOSResetSystemPatternSdk2Old));
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternPokemonDownloader, sizeof(sOSResetSystemPatternPokemonDownloader));
        }
    }

    if (_osResetSystem)
    {
        LOG_DEBUG("Found end of OS_ResetSystem at %p\n", _osResetSystem);
    }
    else
    {
        LOG_DEBUG("OS_ResetSystem not found\n");
    }

    // This patch is optional. Even when OS_ResetSystem is absent, the ARM7
    // hotkey can use the same loader machinery without modifying ARM9 IRQ code.
    return true;
}

void OSResetSystemPatch::ApplyPatch(PatchContext& patchContext)
{
    const bool hasLauncher = _loaderInfo && _loaderInfo->launcherPath[0] != 0;

    // This is the source-template value later copied into the ARM7 hotkey patch.
    // Leave it null unless we successfully build a return-to-launcher target.
    patch_retailhotkeydetect_arm9ReturnAddress = nullptr;

    if (!_osResetSystem && !hasLauncher)
    {
        return;
    }

    u32 offset = 0;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        patch_osresetsystem_arm7Entry_address = 0x02FFFE34;
        if (_hybrid)
        {
            offset = 0x80;
            if (!_runInDSiMode)
            {
                patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
            }
        }
        else
        {
            offset = 0x44;
            patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
        }
    }
    else
    {
        offset = 0xC;
        patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
    }

    auto loaderInfoTarget = (loader_info_t*)patchContext.GetPatchHeap().Alloc(sizeof(loader_info_t));
    memcpy(loaderInfoTarget, _loaderInfo, sizeof(loader_info_t));

    auto sdReadPatchCode = patchContext.GetLoaderPlatform()->CreateSdReadPatchCode(
        patchContext.GetPatchCodeCollection(), patchContext.GetPatchHeap());
    auto patchCodePart2 = patchContext.GetPatchCodeCollection().AddUniquePatchCode<OSResetSystemPart2PatchCode>(
        patchContext.GetPatchHeap());
    auto patchCode = patchContext.GetPatchCodeCollection().AddUniquePatchCode<OSResetSystemPatchCode>
    (
        patchContext.GetPatchHeap(),
        loaderInfoTarget,
        sdReadPatchCode,
        patchCodePart2
    );

    // Preserve the game's normal SDK reset behavior whenever its reset routine
    // is known. This path still reloads the current retail title (mode 0).
    if (_osResetSystem)
    {
        *(u32*)((u8*)_osResetSystem + offset) = 0xE51FF004;
        *(u32*)((u8*)_osResetSystem + offset + 4) = (u32)patchCode->GetOSResetSystemFunction();
    }

    // The proven ARM7 VBlank detector will embed this ARM-state entry address.
    // No ARM9 IRQ dispatcher/vector code is modified for the hotkey.
    if (hasLauncher)
    {
        patch_retailhotkeydetect_arm9ReturnAddress =
            patchCode->GetReturnToLauncherFromArm7Function();
        LOG_DEBUG("ARM7 retail return target prepared at %p\n",
            patch_retailhotkeydetect_arm9ReturnAddress);
    }

    _cheatsPointer = patchCodePart2->GetCheatsPointerAtTarget();
}
