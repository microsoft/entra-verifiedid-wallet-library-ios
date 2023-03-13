/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import VCEntities
import VCToken
@testable import WalletLibrary

struct MockVerifiableCredentialHelper {
    
    func createMockVerifiableCredential(expectedTypes: [String] = []) -> WalletLibrary.VerifiableCredential {
        let raw = createVCEntitiesVC(expectedTypes: expectedTypes)
        let contract = createMockContract()
        return try! VerifiableCredential(raw: raw, from: contract)
    }
    
    func createVCEntitiesVC(expectedTypes: [String]) -> VCEntities.VerifiableCredential {
        let claims = VCClaims(jti: "",
                              iss: "",
                              sub: "",
                              iat: 0,
                              exp: 0,
                              vc: VerifiableCredentialDescriptor(context: [],
                                                                 type: expectedTypes,
                                                                 credentialSubject: [:]))
        return VCEntities.VerifiableCredential(headers: Header(), content: claims)!
    }

    func createMockContract() -> Contract {
        let mockCardDisplay = CardDisplayDescriptor(title: "mock title",
                                                    issuedBy: "mock issuer",
                                                    backgroundColor: "mock background color",
                                                    textColor: "mock text color",
                                                    logo: nil,
                                                    cardDescription: "mock description")
        let mockConsentDisplay = ConsentDisplayDescriptor(title: nil,
                                                          instructions: "mock purpose")
        let mockDisplayDescriptor = DisplayDescriptor(id: nil,
                                                      locale: nil,
                                                      contract: nil,
                                                      card: mockCardDisplay,
                                                      consent: mockConsentDisplay,
                                                      claims: [:])
        let mockContractInputDescriptor = ContractInputDescriptor(credentialIssuer: "mock credential issuer",
                                                                  issuer: "mock issuer",
                                                                  attestations: nil)
        return Contract(id: "mockContract",
                        display: mockDisplayDescriptor,
                        input: mockContractInputDescriptor)
    }
    
}
