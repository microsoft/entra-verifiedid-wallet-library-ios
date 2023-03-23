# Microsoft Entra Wallet Library

> TODO: Add blurb about what this library is for.

## Quick Start

Add pod to PodFile.

```ruby
use_frameworks!

target "YourApp" do
  pod "WalletLibrary", "~> 0.0.1"
end
```

### Using the Wallet Library
Here is a quick example of how to use the library. For more in depth examples, check out the Demo app.
 
```Swift

/// Create a verifiedIdClient.
let verifiedIdClient = try VerifiedIdClientBuilder().build()

/// Create a VerifiedIdRequestInput using a OpenId Request Uri.
let input = VerifiedIdRequestURL(url: URL(string: "openid-vc...")!)
let request = try await verifiedIdClient.createVerifiedIdRequest(from: input)

/// A request created from the method above could be an issuance or a presnetation request.
switch(request) {
    case let issuanceRequest as? VerifiedIdIssuanceRequest:
        /// handle issuance request...
    case let presentationRequest as? VerifiedIdPresentationRequest:
        /// handle presentation request...
}
```

At the time of publish, we support the following requirements for an issuance request:
* GroupRequirement
* SelfAttestedClaimRequirement
* IdTokenRequirement
* AccessTokenRequirement
* VerifiedIdRequirement
* PinRequirement

We support the following requirements for a presentation request:
* VerifiedIdRequirement

To fulfill a requirement, cast it to the correct Requirement type and use fulfill method.
```Swift
let verifiedIdRequirement = presentationRequest.requirement as! VerifiedIdRequirement
verifiedIdRequirement.fulfill(with: <Insert VerifiedId>)
```

Once all of the requirements are fulfilled, complete the request using the complete method.
```Swift
let result = await presentationRequest.complete()
```
## Documentation

* [External Architecture](Docs/LibraryArchitecture.md)
* [Microsoft Docs](https://learn.microsoft.com/en-us/azure/active-directory/verifiable-credentials/)

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
