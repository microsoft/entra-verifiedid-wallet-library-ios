
# Library External Architecture
## Verified Id Client
The Verified Id Client is the main entry point into the library. The client can be configured with optional settings using the Verified Id Client Builder. The client can be used to create Verified Id Requests during an issuance or presentation flow.
```mermaid
classDiagram
VerifiedIdClientBuilder ..|> VerifiedIdClient: creates
VerifiedIdClient ..|> VerifiedIdRequest: creates
VerifiedIdRequest ..> RequesterStyle: uses
VerifiedIdRequest ..> RootOfTrust: uses
VerifiedIdRequest <|-- VerifiedIdIssuanceRequest: implements
VerifiedIdRequest <|-- VerifiedIdPresentationRequest: implements
VerifiedIdClient ..> VerifiedIdRequestInput: uses
VerifiedIdRequestInput <|-- URLRequestInput: implements
RequesterStyle <|-- VerifiedIdManifestIssuerStyle: implements
VerifiedIdPresentationRequest ..> OpenIdVerifierStyle: uses
RequesterStyle <|-- OpenIdVerifierStyle: implements
VerifiedIdIssuanceRequest ..> VerifiedIdManifestIssuerStyle: uses
class VerifiedIdClientBuilder{
    +build() VerifiedIdClient
    +with(logConsumer) WalletLibraryLogConsumer
}
class VerifiedIdClient{
    +createRequest(from: VerifiedIdRequestInput) Result<<T>VerifiedIdRequest>
    +encode(verifiedId: VerifiedId) VerifiedIdResult<<T>Data>
    +decodeVerifiedId(from: Data) VerifiedIdResult<<T>VerifiedId>
}
<<Interface>> VerifiedIdRequestInput
class URLRequestInput{
    +init(url)
}
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest{
    +style: RequesterStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +isSatisfied() Bool
    +complete() VerifiedIdResult<<T>T>
    +cancel(message: String?) VerifiedIdResult<<T>Void>
}
<<Interface>> VerifiedIdIssuanceRequest
class VerifiedIdIssuanceRequest{
    +style: RequesterStyle
    +verifiedIdStyle: VerifiedIdStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +isSatisfied() Bool
    +complete() VerifiedIdResult<<T>VerifiedId>
    +cancel(message: String?) VerifiedIdResult<<T>Void>
}
<<Interface>> VerifiedIdPresentationRequest
class VerifiedIdPresentationRequest{
    +style: RequesterStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +isSatisfied() Bool
    +complete() VerifiedIdResult<<T>Void>
    +cancel(message: String?) VerifiedIdResult<<T>Void>
}

class RootOfTrust{
    +verified: String
    +source: String
}
<<Interface>> RequesterStyle
class RequesterStyle{
    +name: String
}

class VerifiedIdManifestIssuerStyle{
    +name: String
    +requestTitle: String?
    +requestInstructions: String?
}

class OpenIdVerifierStyle{
    +name: String
    +logo: VerifiedIdLogo?
}
```

## Requirements
A Requirement is an object that describes a necessary piece of information to be included to complete a Verified Id Request.

```mermaid
classDiagram
GroupRequirement ..> RequirementOperator: uses
Requirement <|-- GroupRequirement: implements
Requirement <|-- SelfAttestedRequirement: implements
Requirement <|-- VerifiedIdRequirement: implements
Requirement <|-- PinRequirement: implements
Requirement <|-- IdTokenRequirement: implements
Requirement <|-- AccessTokenRequirement: implements
<<Interface>> Requirement
class Requirement {
    +required: Bool
    +validate() VerifiedIdResult<<T>Void>
}
class GroupRequirement {
    +required: Bool
    +requirementOperator: RequirementOperator
    +requirements: [Requirement]
    +validate() VerifiedIdResult<<T>Void>
}
<<enumeration>> RequirementOperator
class RequirementOperator {
    Any
    All 
}
class SelfAttestedRequirement {
    +required: Bool
    +claim: String
    +fulfill(with: String) VerifiedIdResult<<T>Void>
    +validate() VerifiedIdResult<<T>Void>
}
class VerifiedIdRequirement {
    +required: Bool
    +purpose: String?
    +types: [String]
    +issuanceOptions: [VerifiedIdRequestInput]
    +getMatches(verifiedIds: [VerifiedId]) [VerifiedId]
    +fulfill(with: VerifiedId) VerifiedIdResult<<T>Void>
    +validate() VerifiedIdResult<<T>Void>
}
class PinRequirement {
    +required: Bool
    +length: Int
    +type: String
    +fulfill(with: String) VerifiedIdResult<<T>Void>
    +validate() VerifiedIdResult<<T>Void>
}
class IdTokenRequirement {
    +required: Bool
    +configuration: URL
    +clientId: String
    +redirectUri: String
    +scope: String?
    +getNonce() String?
    +fulfill(with: String) VerifiedIdResult<<T>Void>
    +validate() VerifiedIdResult<<T>Void>
}
class AccessTokenRequirement {
    +required: Bool
    +configuration: String
    +clientId: String?
    +scope: String
    +resourceId: String
    +fulfill(with: String) VerifiedIdResult<<T>Void>
    +validate() VerifiedIdResult<<T>Void>
}
```

## Verified Id
A Verified Id is an abstract representation of a piece of verifiable information. For example, a Verifiable Credential is one type of Verified Id.
```mermaid
classDiagram
VerifiedId ..> VerifiedIdClaim: uses
VerifiedId ..> VerifiedIdStyle: uses
BasicVerifiedIdStyle ..> VerifiedIdLogo: uses
VerifiedIdStyle <|-- BasicVerifiedIdStyle: implements
class VerifiedId {
    +id: String
    +style: VerifiedIdStyle
    +expiresOn: Date
    +issuedOn: Date
    +getClaims() [VerifiedIdClaim]
}

<<interface>> VerifiedIdStyle
class VerifiedIdStyle {
    +name: String
}

class BasicVerifiedIdStyle {
    +name: String
    +issuer: String
    +backgroundColor: String
    +textColor: String
    +description: String
    +logo: VerifiedIdLogo?
}

class VerifiedIdLogo {
    +url: URL?
    +altText: String?
}

class VerifiedIdClaim {
    +id: String
    +value: Any
}
```

