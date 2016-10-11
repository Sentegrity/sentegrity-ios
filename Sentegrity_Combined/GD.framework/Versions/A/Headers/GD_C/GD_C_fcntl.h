/*
 * (c) 2016 Good Technology Corporation. All rights reserved.
 */

#pragma once

#include <fcntl.h>

/** \addtogroup capilist
 * @{
 */

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef GD_C_API
# define GD_C_API
#endif
    
    /** C API.
     */
    GD_C_API int GD_fcntl(int fd, int cmd, ...);
    
#ifdef __cplusplus
}
#endif

/** @}
 */
