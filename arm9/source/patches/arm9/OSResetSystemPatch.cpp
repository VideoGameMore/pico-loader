#include "common.h"
#include "patches/PatchContext.h"
#include "thumbInstructions.h"
#include "patches/platform/LoaderPlatform.h"
#include "OSResetSystemPatchCode.h"
#include "RetailReturnHotkeyPatchCode.h"
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

static const u32 sOSIrqHandlerPattern[] = { 0xE92D4000u, 0xE3A0C301u, 0xE28CCE21u, 0xE51C1008u };
static const u32 sOSIrqHandlerPatternAlt[] = { 0xE3A0C301u, 0xE28CCE21u, 0xE51C1008u, 0xE14F0000u };
static const u32 sOSIrqHandlerPatternAlt5[] = { 0xE3A0C301u, 0xE5BC2208u, 0xE1EC00D8u, 0xE3520000u };

bool OSResetSystemPatch::FindPatchTarget(PatchContext& patchContext)
{
    _osResetSystem = nullptr;
    _irqHandler = nullptr;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5Old, sizeof(sOSResetSystemPatternSdk5Old));
        if (!_osResetSystem)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5New, sizeof(sOSResetSystemPatternSdk5New));
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridOld, sizeof(sOSResetSystemPatternSdk5HybridOld));
            _hybrid = true;
        }
        if (!_osResetSystem)
        {
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk5HybridNew, sizeof(sOSResetSystemPatternSdk5HybridNew));
            _hybrid = true;
        }
    }
    else
    {
        if (patchContext.GetSdkVersion() >= 0x4017530)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk4, sizeof(sOSResetSystemPatternSdk4));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x3017530)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk3, sizeof(sOSResetSystemPatternSdk3));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2017532)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2New, sizeof(sOSResetSystemPatternSdk2New));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004F50)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2, sizeof(sOSResetSystemPatternSdk2));
        if (!_osResetSystem && patchContext.GetSdkVersion() >= 0x2004EE9)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternSdk2Old, sizeof(sOSResetSystemPatternSdk2Old));
        if (!_osResetSystem)
            _osResetSystem = patchContext.FindPattern32(sOSResetSystemPatternPokemonDownloader, sizeof(sOSResetSystemPatternPokemonDownloader));
    }

    if (_osResetSystem)
        LOG_DEBUG("Found end of OS_ResetSystem at %p\n", _osResetSystem);
    else
        LOG_DEBUG("OS_ResetSystem not found\n");

    if (_loaderInfo && _loaderInfo->launcherPath[0] != 0)
    {
        _irqHandler = patchContext.FindPattern32(sOSIrqHandlerPattern, sizeof(sOSIrqHandlerPattern));
        if (!_irqHandler)
            _irqHandler = patchContext.FindPattern32(sOSIrqHandlerPatternAlt, sizeof(sOSIrqHandlerPatternAlt));
        if (!_irqHandler)
            _irqHandler = patchContext.FindPattern32(sOSIrqHandlerPatternAlt5, sizeof(sOSIrqHandlerPatternAlt5));

        if (_irqHandler)
            LOG_DEBUG("Found ARM9 IRQ dispatcher at %p\n", _irqHandler);
        else
            LOG_WARNING("ARM9 IRQ dispatcher not found; retail return hotkey disabled\n");
    }

    return true;
}

void OSResetSystemPatch::ApplyPatch(PatchContext& patchContext)
{
    u32 offset = 0;
    if (patchContext.GetSdkVersion().IsTwlSdk())
    {
        patch_osresetsystem_arm7Entry_address = 0x02FFFE34;
        if (_hybrid)
        {
            offset = 0x80;
            if (!_runInDSiMode)
                patch_osresetsystem_entry_jump_to_twl_arm7_sync = THUMB_NOP;
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

    if (_osResetSystem)
    {
        *(u32*)((u8*)_osResetSystem + offset) = 0xE51FF004;
        *(u32*)((u8*)_osResetSystem + offset + 4) = (u32)patchCode->GetOSResetSystemFunction();
    }

    if (_irqHandler)
    {
        u32 returnAddress = (u32)(_irqHandler + 2);
        if (patchContext.GetAutoloadAdjuster())
            returnAddress = patchContext.GetAutoloadAdjuster()->AdjustInitialToFinal(returnAddress);

        auto hotkeyPatchCode = patchContext.GetPatchCodeCollection().AddUniquePatchCode<RetailReturnHotkeyPatchCode>
        (
            patchContext.GetPatchHeap(),
            _irqHandler[0],
            _irqHandler[1],
            (const void*)returnAddress,
            patchCode->GetReturnToLauncherFunction()
        );

        _irqHandler[0] = 0xE51FF004;
        _irqHandler[1] = (u32)hotkeyPatchCode->GetEntryFunction();
    }

    _cheatsPointer = patchCodePart2->GetCheatsPointerAtTarget();
}
