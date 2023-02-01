/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation
import WalletLibrary

class VerifiedIdUseCase {
    
    private var verifiedIdClientBuilder: VerifiedIdClientBuilder
    
    init() {
        self.verifiedIdClientBuilder = VerifiedIdClientBuilder()
    }
    
    func createVerifiedIdRequest(from input: VerifiedIdClientInput) async throws -> any VerifiedIdRequest {
        let verifiedIdClient = verifiedIdClientBuilder.build()
        let request = try await verifiedIdClient.createVerifiedIdRequest(from: input)
        return request
    }
    
    func resetVerifiedIdClientBuilder() { }
}
