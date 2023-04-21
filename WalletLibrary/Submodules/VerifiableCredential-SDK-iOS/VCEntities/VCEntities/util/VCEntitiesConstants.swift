/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

struct VCEntitiesConstants {
    static let SELF_ISSUED = "https://self-issued.me"
    static let SELF_ISSUED_V2 = "https://self-issued.me/v2/openid-vc"
    
    // TODO: temporary until deterministic key generation is implemented.
    static let MASTER_ID = "master"
    
    // key actions in a DID Document
    static let SIGNING_KEYID_PREFIX = "sign_"
    static let UPDATE_KEYID_PREFIX = "update_"
    static let RECOVER_KEYID_PREFIX = "recover_"
    
    // JWK public key
    static let SUPPORTED_PUBLICKEY_TYPE = "EcdsaSecp256k1VerificationKey2019"
    static let PUBLICKEY_AUTHENTICATION_PURPOSE_V1 = "authentication"
    static let PUBLICKEY_AUTHENTICATION_PURPOSE_V0 = "auth"
    static let PUBLICKEY_GENERAL_PURPOSE_V0 = "general"
    
    // OIDC Protocol
    static let ALGORITHM_SUPPORTED_IN_VP = "ES256K"
    static let DID_METHODS_SUPPORTED = "did:ion"
    static let JWT = "JWT"
    static let RESPONSE_TYPE = "id_token"
    static let RESPONSE_MODE = "post"
    static let SCOPE = "openid"
    static let SUBJECT_IDENTIFIER_TYPE_DID = "did:ion"
    
    static let PIN = "pin"
}
