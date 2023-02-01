
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
class VerifiedIdClientBuilder{
    +build() VerifiedIdClient
    +with(logConsumer) WalletLibraryLogConsumer
}
class VerifiedIdClient{
    +createRequest(from: VerifiedIdRequestInput) VerifiedIdRequest
}
<<Interface>> VerifiedIdRequestInput
class URLRequestInput{
    +init(url)
    ~resolve() ResolvedInput
}
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest{
    +style: RequesterStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +complete() Result<<T>T>
    +cancel(message: String?) Result<<T>Void>
}
<<Interface>> VerifiedIdIssuanceRequest
class VerifiedIdIssuanceRequest{
    +style: RequesterStyle
    +verifiedIdStyle: VerifiedIdStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +complete() Result<<T>VerifiedId>
    +cancel(message: String?) Result<<T>Void>
}
<<Interface>> VerifiedIdPresentationRequest
class VerifiedIdPresentationRequest{
    +style: RequesterStyle
    +requirement: Requirement
    +rootOfTrust: RootOfTrust
    +complete() Result<<T>Void>
    +cancel(message: String?) Result<<T>Void>
}

class RootOfTrust{
    +verified: String
    +source: String
}
<<Interface>> RequesterStyle
class RequesterStyle{
    +name: String
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
    +validate()
}
class GroupRequirement {
    +required: Bool
    +operator: RequirementOperator
    +requirements: [Requirement]
    +validate()
}
<<enumeration>> RequirementOperator
class RequirementOperator {
    Any
    All 
}
class SelfAttestedRequirement {
    +required: Bool
    +label: String
    +fulfill(with: String)
    +validate()
}
class VerifiedIdRequirement {
    +required: Bool
    +getMatches(from: [VerifiedId]) [VerifiedId]
    +fulfill(with: VerifiedId)
    +validate()
}
class PinRequirement {
    +required: Bool
    +length: Int
    +type: String
    +fulfill(with: String)
    +validate()
}
class IdTokenRequirement {
    +required: Bool
    +configuration: URL
    +clientId: String
    +redirectUri: String
    +scope: String
    +getNonce() String
    +fulfill(with: String)
    +validate()
}
class AccessTokenRequirement {
    +required: Bool
    +configuration: URL
    +clientId: String
    +redirectUri: String
    +scope: String
    +fulfill(with: String)
    +validate()
}
```

## Verified Id
A Verified Id is an abstract representation of a piece of verifiable information. For example, a Verifiable Credential is one type of Verified Id.
```mermaid
classDiagram
VerifiedId ..> VerifiedIdClaim: uses
VerifiedId ..> VerifiedIdType: uses
VerifiedId ..> VerifiedIdStyle: uses
class VerifiedId {
    +id: String
    +type: VerifiedIdType
    +style: VerifiedIdStyle
    +claims: [VerifiedIdClaim]
    +expiresOn: Date
    +issuedOn: Date
    -raw: String
}

<<enumeration>> VerifiedIdType
class VerifiedIdType {
    VerifiableCredential
    MDL
    Other
}

<<interface>> VerifiedIdStyle
class VerifiedIdStyle {
    +name: String
}

class VerifiedIdClaim {
    +id: String
    +label: String?
    +value: Any
}
```

