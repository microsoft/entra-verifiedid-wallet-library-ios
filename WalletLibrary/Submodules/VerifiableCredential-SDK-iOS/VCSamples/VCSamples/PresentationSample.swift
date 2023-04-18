/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import VCServices
import VCEntities
import PromiseKit

class PresentatonSample {
    
    func presentationSample() {
        /// set up presentation service through dependency injection if you like.
        let presentationService = PresentationService()
        
        presentationService.getRequest(usingUrl: "<presentation request url>").done { presentationRequest in
            self.handle(successfulRequest: presentationRequest, with: presentationService)
        }.catch { error in
            self.handle(failedRequest: error)
        }
    }
    
    private func handle(successfulRequest request: PresentationRequest, with service: PresentationService) {
        
        let response: PresentationResponseContainer
        
        do {
            response = try PresentationResponseContainer(from: request)
        } catch {
            VCSDKLog.sharedInstance.logError(message: "Unable to create PresentationResponseContainer.")
            return
        }
        
        service.send(response: response).done { _ in
            self.handleSuccessfulResponse()
        }.catch { error in
            self.handle(failedResponse: error)
        }
    }
    
    private func handleSuccessfulResponse() {
        /// handle successful presentation how you wish
    }
    
    private func handle(failedRequest: Error) {
        VCSDKLog.sharedInstance.logError(message: "Unable to fetch request.")
    }
    
    private func handle(failedResponse: Error) {
        VCSDKLog.sharedInstance.logError(message: "Unable to send presentation response.")
    }
}
