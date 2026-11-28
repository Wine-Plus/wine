/*
 * Speech API (SAPI) lexicon implementation.
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

#include <stdarg.h>

#define COBJMACROS

#include "windef.h"
#include "winbase.h"
#include "objbase.h"

#include "sapiddk.h"
#include "sperror.h"

#include "wine/debug.h"

#include "sapi_private.h"

WINE_DEFAULT_DEBUG_CHANNEL(sapi);

/* The user and application lexicons. No custom pronunciations are stored:
 * every word is reported as not in the lexicon, which is what TTS engines see
 * on a system where none were added, and they fall back to their own rules. */
struct lexicon
{
    ISpLexicon ISpLexicon_iface;
    LONG ref;
};

static inline struct lexicon *impl_from_ISpLexicon(ISpLexicon *iface)
{
    return CONTAINING_RECORD(iface, struct lexicon, ISpLexicon_iface);
}

static HRESULT WINAPI lexicon_QueryInterface(ISpLexicon *iface, REFIID iid, void **obj)
{
    struct lexicon *This = impl_from_ISpLexicon(iface);

    TRACE("(%p, %s, %p).\n", iface, debugstr_guid(iid), obj);

    if (IsEqualIID(iid, &IID_IUnknown) ||
        IsEqualIID(iid, &IID_ISpLexicon))
        *obj = &This->ISpLexicon_iface;
    else
    {
        *obj = NULL;
        FIXME("interface %s not implemented.\n", debugstr_guid(iid));
        return E_NOINTERFACE;
    }

    IUnknown_AddRef((IUnknown *)*obj);
    return S_OK;
}

static ULONG WINAPI lexicon_AddRef(ISpLexicon *iface)
{
    struct lexicon *This = impl_from_ISpLexicon(iface);
    ULONG ref = InterlockedIncrement(&This->ref);

    TRACE("(%p): ref=%lu.\n", iface, ref);

    return ref;
}

static ULONG WINAPI lexicon_Release(ISpLexicon *iface)
{
    struct lexicon *This = impl_from_ISpLexicon(iface);
    ULONG ref = InterlockedDecrement(&This->ref);

    TRACE("(%p): ref=%lu.\n", iface, ref);

    if (!ref)
        free(This);

    return ref;
}

static HRESULT WINAPI lexicon_GetPronunciations(ISpLexicon *iface, LPCWSTR word, WORD langid, DWORD flags,
                                                SPWORDPRONUNCIATIONLIST *list)
{
    TRACE("(%p, %s, %#x, %#lx, %p).\n", iface, debugstr_w(word), langid, flags, list);

    if (!word || !list)
        return E_POINTER;

    list->pFirstWordPronunciation = NULL;
    return SPERR_NOT_IN_LEX;
}

static HRESULT WINAPI lexicon_AddPronunciation(ISpLexicon *iface, LPCWSTR word, WORD langid,
                                               SPPARTOFSPEECH pos, const SPPHONEID *pronunciation)
{
    FIXME("(%p, %s, %#x, %d, %p): pronunciation not stored.\n", iface, debugstr_w(word), langid, pos,
          pronunciation);

    if (!word)
        return E_POINTER;
    return S_OK;
}

static HRESULT WINAPI lexicon_RemovePronunciation(ISpLexicon *iface, LPCWSTR word, WORD langid,
                                                  SPPARTOFSPEECH pos, const SPPHONEID *pronunciation)
{
    TRACE("(%p, %s, %#x, %d, %p).\n", iface, debugstr_w(word), langid, pos, pronunciation);

    if (!word)
        return E_POINTER;
    return SPERR_NOT_IN_LEX;
}

static HRESULT WINAPI lexicon_GetGeneration(ISpLexicon *iface, DWORD *generation)
{
    TRACE("(%p, %p).\n", iface, generation);

    if (!generation)
        return E_POINTER;
    *generation = 0;
    return S_OK;
}

static HRESULT WINAPI lexicon_GetGenerationChange(ISpLexicon *iface, DWORD flags, DWORD *generation,
                                                  SPWORDLIST *list)
{
    TRACE("(%p, %#lx, %p, %p).\n", iface, flags, generation, list);

    if (!generation || !list)
        return E_POINTER;
    list->pFirstWord = NULL;
    *generation = 0;
    return SP_LEX_NOTHING_TO_SYNC;
}

static HRESULT WINAPI lexicon_GetWords(ISpLexicon *iface, DWORD flags, DWORD *generation, DWORD *cookie,
                                       SPWORDLIST *list)
{
    TRACE("(%p, %#lx, %p, %p, %p).\n", iface, flags, generation, cookie, list);

    if (!generation || !list)
        return E_POINTER;
    list->pFirstWord = NULL;
    *generation = 0;
    if (cookie)
        *cookie = 0;
    return S_OK;
}

static const ISpLexiconVtbl lexicon_vtbl =
{
    lexicon_QueryInterface,
    lexicon_AddRef,
    lexicon_Release,
    lexicon_GetPronunciations,
    lexicon_AddPronunciation,
    lexicon_RemovePronunciation,
    lexicon_GetGeneration,
    lexicon_GetGenerationChange,
    lexicon_GetWords,
};

HRESULT lexicon_create(IUnknown *outer, REFIID iid, void **obj)
{
    struct lexicon *This;
    HRESULT hr;

    if (outer) return CLASS_E_NOAGGREGATION;

    if (!(This = malloc(sizeof(*This))))
        return E_OUTOFMEMORY;
    This->ISpLexicon_iface.lpVtbl = &lexicon_vtbl;
    This->ref = 1;

    hr = ISpLexicon_QueryInterface(&This->ISpLexicon_iface, iid, obj);

    ISpLexicon_Release(&This->ISpLexicon_iface);
    return hr;
}
