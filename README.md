# Microsoft Entra Wallet Library

## Introduction
The Microsoft Entra Wallet Library for iOS gives your app the ability to begin using the Microsoft Entra Verified Id platform by supporting the issuance and presentation of Verified Ids in accordance with OpenID Connect, Presentation Exchange, Verifiable Credentials, and more up and coming industry standards.

---
## Installation

You can use cocoapods to install the Wallet Library by adding it to your Podfile:
```ruby

target "YourApp" do
  use_frameworks!
  pod "WalletLibrary", "~> 0.0.1"
end
```
> note: use_frameworks! is required for this Pod.
---
## Quick Start

Here is a simple example of how to use the library. For more in-depth examples, check out the sample app.
 
```Swift

/// Create a verifiedIdClient.
let verifiedIdClient = VerifiedIdClientBuilder().build()

/// Create a VerifiedIdRequestInput using a OpenId Request Uri.
let input = VerifiedIdRequestURL(url: URL(string: "openid-vc://...")!)
let result = await verifiedIdClient.createVerifiedIdRequest(from: input)

/// Every external method's return value is wrapped in a Result object to ensure proper error handling.
switch (result) {
case .success(let request):
    /// A request created from the method above could be an issuance or a presentation request. 
    /// In this example, it is a presentation request, so we can cast it to a VerifiedIdPresentationRequest.
    let presentationRequest = request as? VerifiedIdPresentationRequest
case .failure(let error):
    /// If an error occurs, its value can be accessed here.
    print(error)
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

To fulfill a requirement, cast it to the correct Requirement type and use the `fulfill` method.
```Swift
let verifiedIdRequirement = presentationRequest.requirement as! VerifiedIdRequirement
verifiedIdRequirement.fulfill(with: <Insert VerifiedId>)
```

VerifiedIdRequirement contains a helper function `getMatches` that will filter all of the VerifiedId that satisfies the constraints on the VerifiedIdRequirement from a list of VerifiedIds.
```Swift
let matchingVerifiedIds = verifiedIdRequirement.getMatches(verifiedIds: <List Of VerifiedIds>)
```

You can also validate a requirement to ensure the requirement has been fulfilled.
```Swift
let validationResult = verifiedIdRequirement.validate()
```

Once all of the requirements are fulfilled, you can double check that the request has been satisfied by calling the `isSatisfied` method on the request object. 
```Swift
let isSatisfied = await presentationRequest.isSatisfied()
```

Then, complete the request using the complete method. 
- The `complete` method on a `VerifiedIdIssuanceRequest` returns a successful result that contains the issued `VerifiedId`, or if an error occurs, returns a failure result with the error. 
- The `complete` method on a `VerifiedIdPresentationRequest` returns an empty successful result or if an error occurs, returns a failure result with the error. 
```Swift
let result = await presentationRequest.complete()
```
---
## VerifiedId
A Verified Id is a verifiable piece of information that contains claims about an entity. 

### Style
Issuers have the ability to customize the style of a Verified Id. We support `BasicVerifiedIdStyle` which contains basic traits like name, issuer, background color, text color, and logo that can be used to represent the look and feel of a Verified Id.

### Storing VerifiedIds
It is the responsibility of the app developer to store the VerifiedIds. We have included helper functions to encode/decode VerifiedIds to easily store the VerifiedIds in a database as a primitive type.

```Swift
/// Encode a VerifiedId into Data.
let encodedVerifiedId = verifiedIdClient.encode(verifiedId: <Insert VerifiedId>)

/// Decode a VerifiedId from Data.
let verifiedId = verifiedIdClient.decode(from: encodedVerifiedId)
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
