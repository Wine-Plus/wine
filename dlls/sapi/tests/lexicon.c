/*
 * Speech API (SAPI) lexicon tests.
 *
 * Copyright 2026 Wine-Plus contributors
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 */

#define COBJMACROS

#include "sapiddk.h"
#include "sperror.h"

#include "wine/test.h"

static void test_lexicon(void)
{
    SPWORDPRONUNCIATIONLIST list = { 0 };
    ISpLexicon *lexicon;
    DWORD generation;
    HRESULT hr;

    /* TTS engines create it unconditionally. */
    hr = CoCreateInstance(&CLSID_SpLexicon, NULL, CLSCTX_INPROC_SERVER, &IID_ISpLexicon, (void **)&lexicon);
    ok(hr == S_OK, "got %#lx.\n", hr);
    if (FAILED(hr)) return;

    hr = ISpLexicon_GetPronunciations(lexicon, L"wineplusnonexistentword", 0x409, eLEXTYPE_USER | eLEXTYPE_APP,
                                      &list);
    ok(hr == SPERR_NOT_IN_LEX, "got %#lx.\n", hr);
    CoTaskMemFree(list.pvBuffer);

    generation = 0xdeadbeef;
    hr = ISpLexicon_GetGeneration(lexicon, &generation);
    ok(hr == S_OK, "got %#lx.\n", hr);
    ok(generation != 0xdeadbeef, "generation not set.\n");

    ISpLexicon_Release(lexicon);
}

START_TEST(lexicon)
{
    CoInitialize(NULL);
    test_lexicon();
    CoUninitialize();
}
