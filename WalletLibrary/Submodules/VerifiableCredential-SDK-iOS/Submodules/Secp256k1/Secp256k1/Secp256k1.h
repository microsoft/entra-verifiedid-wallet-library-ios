//
//  Copyright (C) Microsoft Corporation. All rights reserved.
//

//#import <Foundation/Foundation.h>
#ifndef FOUNDATION_EXPORT
    #if defined(__cplusplus)
        #include <iostream>
        #define FOUNDATION_EXPORT extern "C"
    #else
        #define FOUNDATION_EXPORT extern
    #endif
#endif

//! Project version number for Secp256k1.
FOUNDATION_EXPORT double Secp256k1VersionNumber;

//! Project version string for Secp256k1.
FOUNDATION_EXPORT const unsigned char Secp256k1VersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Secp256k1/PublicHeader.h>

//#import "include/secp256k1.h"

//#include "../include/secp256k1_ecdh.h"

//#import "Secp256k1/Secp256k1.h"

//#import "secp256k1.h"


