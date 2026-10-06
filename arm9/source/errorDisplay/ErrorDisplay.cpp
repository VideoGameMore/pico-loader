#include "common.h"
#include <stdlib.h>
#include <libtwl/mem/memVram.h>
#include <libtwl/gfx/gfx.h>
#include <libtwl/gfx/gfxStatus.h>
#include <libtwl/gfx/gfxPalette.h>
#include <libtwl/gfx/gfxBackground.h>
#include "nitroFont2.h"
#include "font_nft2.h"
#include "fastClear.h"
#include "ErrorDisplay.h"

static void waitForVBlank()
{
    while (gfx_getVCount() != 191);
    while (gfx_getVCount() == 191);
}

static bool readAButton()
{
    return ((~REG_KEYINPUT) & KEY_A) != 0;
}

bool ErrorDisplay::PrintDiagnostic(const char* statusString)
{
    // ARM9 loader heap is in VRAM A. Never use the loaded game's 0x02100000.
    u8* buffer = (u8*)malloc(256 * 192);
    if (!buffer)
        return false;
    Print(statusString, true, buffer);
    free(buffer);
    return true;
}

void ErrorDisplay::Print(const char* errorString, bool pressAToContinue, u8* diagnosticBuffer)
{
    mem_setVramEMapping(MEM_VRAM_E_MAIN_BG_00000);
    auto textBuffer = diagnosticBuffer ? diagnosticBuffer : (u8*)0x02100000;
    memset(textBuffer, 0, 256 * 192);
    nft2_header_t diagnosticFont;
    const nft2_header_t* font;
    if (diagnosticBuffer)
    {
        // Resolve a local header; repeated diagnostics must not rebase global font pointers.
        diagnosticFont = *(const nft2_header_t*)font_nft2;
        if ((u32)diagnosticFont.glyphInfoPtr < (u32)font_nft2)
        {
            diagnosticFont.glyphInfoPtr = (const nft2_glyph_t*)((u32)font_nft2 + (u32)diagnosticFont.glyphInfoPtr);
            diagnosticFont.charMapPtr = (const nft2_char_map_entry_t*)((u32)font_nft2 + (u32)diagnosticFont.charMapPtr);
            diagnosticFont.glyphDataPtr = (const u8*)((u32)font_nft2 + (u32)diagnosticFont.glyphDataPtr);
        }
        font = &diagnosticFont;
    }
    else
    {
        nft2_unpack((nft2_header_t*)font_nft2);
        font = (const nft2_header_t*)font_nft2;
    }
    nft2_string_render_params_t renderParams =
    {
        x: 0,
        y: 0,
        width: 256,
        height: 192
    };
    nft2_renderString(font, errorString, textBuffer, 256, &renderParams);
    memcpy((void*)GFX_BG_MAIN, textBuffer, 256 * 192);
    waitForVBlank();
    // 4 bit grayscale palette
    for (int i = 0; i < 16; i++)
    {
        int gray = i * 2 + (i == 0 ? 0 : 1);
        GFX_PLTT_BG_MAIN[i] = gray | (gray << 5) | (gray << 10);
    }
    REG_BG3PA = 256;
    REG_BG3PB = 0;
    REG_BG3PC = 0;
    REG_BG3PD = 256;
    REG_BG3X = 0;
    REG_BG3Y = 0;
    REG_BG3CNT = (1 << 7) | (1 << 14);
    REG_BLDCNT = 0;
    REG_DISPCNT = 3 | (1 << 11) | (1 << 16);
    REG_MASTER_BRIGHT = 0;
    GFX_PLTT_BG_SUB[0] = 0;
    REG_MASTER_BRIGHT_SUB = 0x8010;
    REG_DISPCNT_SUB = 0x10000;
    if (pressAToContinue)
    {
        waitForVBlank();
        bool previousAButtonState = readAButton();
        while (true)
        {
            waitForVBlank();
            bool aButtonState = readAButton();
            if (!previousAButtonState && aButtonState)
            {
                break;
            }
            previousAButtonState = aButtonState;
        }
    }
    else
    {
        while (true);
    }

    REG_MASTER_BRIGHT = 0x4010;
    REG_MASTER_BRIGHT_SUB = 0x4010;
    REG_DISPCNT = 0;
    REG_DISPCNT_SUB = 0;
    mem_setVramEMapping(MEM_VRAM_E_LCDC);
    fastClear((void*)0x06880000, 0x10000);
    fastClear((void*)GFX_PLTT_BG_MAIN, 512);
    fastClear((void*)GFX_PLTT_BG_SUB, 512);
}
