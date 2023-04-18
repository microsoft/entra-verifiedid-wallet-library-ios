This SDK is used in the [Microsoft Authenticator app](https://www.microsoft.com/en-us/account/authenticator) in order to interact with [verifiable credentials](https://www.w3.org/TR/vc-data-model/) and [Decentralized Identifiers (DIDs)](https://www.w3.org/TR/did-core/) on the [ION network](https://github.com/decentralized-identity/ion). It can be integrated with any app to provide interactions using verifiable credentials.
 
# Verifiable Credentials 
 
Verifiable credentials is a [W3C standard](https://www.w3.org/TR/vc-data-model/) that can be used to validate information about people, organizations, and more. Verifiable credentials put people in control of their personal information, enabling more trustworthy digital experiences while respecting people's privacy. 
 
To learn more about verifiable credentials, please review our [documentation.](https://aka.ms/didfordevs)

# How to use SDK

## Initializing SDK
`VerifiableCredentialSDK` - this class is used to initialize the SDK. You may want to call during your dependency injection initialization:
```swift
/// Both parameters are optional:
/// - logConsumer: conforms to the VCLogConsumer to inject logging into the SDK.
/// - accessGroupIdentifier: String to tell the SDK where to save keys in KeyChain. If nil, will use the default access group.
/// Returns: Result<VCSDKStatus, Error>
let result = VerifiableCredentialSDK.initialize(logConsumer: sdkLogConsumer, accessGroupIdentifier: accessGroupIdentifier);

switch result {
    case .success(let status):
        print("\(status) will equal success or new master identifier created")
    case .failure(let error):
        print("Initialization failed because of specific error")
}
```

We currently support the following services:

```swift
IssuanceService()
PresentationService()
```

## APIs

Our APIs use PromiseKit. Read more about promises [here](https://github.com/mxcl/PromiseKit). 

All our public APIs return `Promise<T>` objects. This forces explicit error handling.

You can unpack and handle these promises easily in Swift with the `done` and `catch` statements

```swift
functionThatReturnPromise().done { objectReturned in
    handleRequestSuccess(objectReturned) // will be smartcasted into <T>
}.catch { error in
    handleRequestFailure(error)
}
```

## Receive a Verifiable Credential (IssuanceService)

To receive a verifiable credential you need a service endpoint providing an issuance contract. You can either get it from someone or create your own. See [How to customize your credentials](https://docs.microsoft.com/en-us/azure/active-directory/verifiable-credentials/credential-design) for more information or use an existing provider. In the future, we plan to support the DIF standard [Credential Manifest](https://identity.foundation/credential-manifest/).

```swift
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
```

Most issuance requests will ask you for attestations that the user might need to provide. Provide them by filling the values for the existing keys in the three available maps for self attested claims, idtokens and vcs.

```swift
private func addRequestedData(response: IssuanceResponseContainer) {
    response.requestedSelfAttestedClaimMap["key string found in contract"] = "user specified values"
    response.requestedIdTokenMap["configuration uri"] = "your idToken"
    response.requestedVCMap["credential type"] = yourVc
}
```

See the [full sample](https://github.com/microsoft/VerifiableCredential-SDK-iOS/tree/master/VCSamples/VCSamples/IssuanceSamples.swift).

## Present Verifiable Credentials (PresentationService)

A presentation request can ask for multiple VCs and follows the [Presentation Exchange](https://identity.foundation/presentation-exchange/) of the Decentralized Identity Foundation. In code, presenting follows an almost identical pattern as issuance.

```swift
   
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
```

You can only present VCs in a presentation request. Add the requested VCs:

```swift
private func addRequestedData(response: PresentationResponseContainer) {
    response.requestedVCMap["credential type"] = yourVc
}
```

See the [full sample](https://github.com/microsoft/VerifiableCredential-SDK-iOS/tree/master/VCSamples/VCSamples/IssuanceSamples.swift).

## Pairwise Identifiers

By default every relationship to relying parties (RP) will use a different DID per Relying Party such that they can not correlate users actions. The client will automatically fetch exchanged VCs from the original issuer. This behavior can be disabled on a per call basis with the `isPairwise` flag in `send`.

# Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
