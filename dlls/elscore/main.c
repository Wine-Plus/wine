/*
 * Extended Linguistic Services (ELS)
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

#include "windef.h"
#include "winbase.h"
#include "winerror.h"

#include "wine/debug.h"

WINE_DEFAULT_DEBUG_CHANNEL(elscore);

/* No linguistic services (language/script detection, transliteration) are
 * provided: enumeration reports none, so applications use their own
 * fallbacks. The structures from elscom.h are only passed through. */

HRESULT WINAPI MappingGetServices(void *options, void **services, DWORD *count)
{
    FIXME("(%p, %p, %p) no services available\n", options, services, count);

    if (!services || !count)
        return E_INVALIDARG;
    *services = NULL;
    *count = 0;
    return HRESULT_FROM_WIN32(ERROR_NOT_FOUND);
}

HRESULT WINAPI MappingFreeServices(void *services)
{
    TRACE("(%p)\n", services);
    return S_OK;
}

HRESULT WINAPI MappingRecognizeText(void *service, const WCHAR *text, DWORD length, DWORD index,
                                    void *options, void *bag)
{
    FIXME("(%p, %s, %lu, %lu, %p, %p) stub\n", service, debugstr_wn(text, length), length, index,
          options, bag);
    return E_INVALIDARG;
}

HRESULT WINAPI MappingDoAction(void *bag, DWORD range, const WCHAR *action)
{
    FIXME("(%p, %lu, %s) stub\n", bag, range, debugstr_w(action));
    return E_INVALIDARG;
}

HRESULT WINAPI MappingFreePropertyBag(void *bag)
{
    TRACE("(%p)\n", bag);
    return S_OK;
}
