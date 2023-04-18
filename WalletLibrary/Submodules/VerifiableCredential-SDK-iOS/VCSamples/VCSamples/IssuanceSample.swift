/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities
import PromiseKit

class IssuanceSample {
    
    func issuanceSample() {
        /// set up issuance service through dependency injection if you like.
        let issuanceService = IssuanceService()
        
        issuanceService.getRequest(usingUrl: "<issuance request url>").done { issuanceRequest in
            self.handle(successfulRequest: issuanceRequest, with: issuanceService)
        }.catch { error in
            self.handle(failedRequest: error)
        }
    }
    
    private func handle(successfulRequest request: IssuanceRequest, with service: IssuanceService) {
        
        let response: IssuanceResponseContainer
        
        do {
            response = try IssuanceResponseContainer(from: request.content, contractUri: "<issuance request url>")
        } catch {
            VCSDKLog.sharedInstance.logError(message: "Unable to create IssuanceResponseContainer.")
            return
        }
        
        service.send(response: response).done { verifiableCredential in
            self.handle(successfulResponse: verifiableCredential)
        }.catch { error in
            self.handle(failedResponse: error)
        }
    }
    
    private func handle(successfulResponse response: VerifiableCredential) {
        /// use verifiable credential
    }
    
    private func handle(failedRequest error: Error) {
        VCSDKLog.sharedInstance.logError(message: "Unable to fetch request.")
    }
    
    private func handle(failedResponse error: Error) {
        VCSDKLog.sharedInstance.logError(message: "Unable to get verifiable credential.")
    }
}
