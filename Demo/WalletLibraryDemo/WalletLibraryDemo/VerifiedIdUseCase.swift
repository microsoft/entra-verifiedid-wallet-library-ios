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
    
    func createVerifiedIdClient(from input: VerifiedIdClientInput) async throws -> any VerifiedIdClient {
        self.verifiedIdClientBuilder = verifiedIdClientBuilder.with(input: input)
        let verifiedIdClient = try await verifiedIdClientBuilder.build()
        return verifiedIdClient
    }
    
    func resetVerifiedIdClientBuilder() { }
}
