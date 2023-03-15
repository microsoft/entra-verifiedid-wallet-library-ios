#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

@import VerifiableCredentialSDK/Secp256k1;
#import "secp256k1.h"

FOUNDATION_EXPORT double WalletLibraryVersionNumber;
FOUNDATION_EXPORT const unsigned char WalletLibraryVersionString[];