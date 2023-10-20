# OpenID Presentation Exchange Request Processor
[Presentation Exchange](https://identity.foundation/presentation-exchange/) is a data format defining the exchange of credentials. Combined with the [OpenID Connect Verifiable Presentations](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html) extension creates a complete verified id request and response flow.

```mermaid
classDiagram

class OpenIdRawRequest {
    - type: RequestType
    - raw: Data?
    - promptValueForIssuance: String
}

RawRequest --|> OpenIdRawRequest

RawRequest ..> RequestHandling: uses
RawRequest ..> RequestProcessor: uses

<<interface>> RequestHandling
class RequestHandling {
    ~handle(input: RawRequest) VerifiedIdRequest
}

class OpenIdRequestHandler {
    - configuration: LibraryConfiguration
    - openIdResponder: OpenIdResponder
    - manifestResolver: ManifestResolver
    - verifiedIdRequester: VerifiedIdRequester
    ~handleRequest(request: RawRequest): VerifiedIdRequest
}

class OpenIdPresentationRequest {
    - rawRequest: OpenIdRawRequest
    - responder: OpenIdResponder
    - configuration: LibraryConfiguration
}
OpenIdPresentationRequest ..> PresentationResponseContainer: uses

class VerifiedIdRequirement {
    - encrypted: Bool
    - required: Bool 
    - types: [String]
    - purpose: String?
    - issuanceOptions: [VerifiedIdRequestInput]
    - id: String?
    - constraint: VerifiedIdConstraint
    - selectedVerifiedId: VerifiedId?
    - exclusivePlacement: [String]
    ~getMatches(verifeidIds: [VerifiedId]): [VerifiedId]
    ~fulfill(verifiedId: VerifiedId): VerifiedIdResult<null>

    ~exclusive(ids: [String])
}

class PresentationResponseContainer {
    - request: PresentationRequest
    - expiryInSeconds: Int
    - audienceUrl: String
    - audienceDid: String
    - nonce: String
    - requestedIdTokenMap: [:]
    - requestedSelfAttestedClaimMap: [:]
    - requestedVCMap: [:]
    ~addVerifiableCredential(id: String, vc: VerifiableCredential)
    ~add(requirement: Requirement)
    
}
PresentationResponseContainer ..> VerifiedIdRequirement: uses

OpenIdPresentationRequest o-- VerifiedIdRequirement

VerifiedIdRequest --|> OpenIdPresentationRequest

RequestHandling --|> OpenIdRequestHandler
OpenIdRawRequest ..> OpenIdRequestHandler: uses

class RequestProcessorFactory {
    - requestProcessors: [RequestProcessor]
    ~getRequestProcessor(for: RawRequest) RequestProcessor
}
<<Interface>> RequestProcessor
class RequestProcessor {
    ~canProcess(raw: RawRequest) Bool
    ~process(raw: RawRequest) VerifiedIdRequest
}

class OpenIdPresentationExchangeRequestProcessor {
    ~canProcess(raw: RawRequest) Bool
    ~process(raw: RawRequest) VerifiedIdRequest
}

RequestProcessor --|> OpenIdPresentationExchangeRequestProcessor

RequestProcessorFactory o-- OpenIdPresentationExchangeRequestProcessor
OpenIdPresentationExchangeRequestProcessor ..> OpenIdPresentationRequest: creates
OpenIdRequestHandler *-- RequestProcessorFactory
<<Interface>> RawRequest
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest {
    - style: RequesterStyle
    - requirement: Requirement
    - rootOfTrust: RootOfTrust
    ~isSatisfied(): Bool
    ~complete(): VerifiedIdResult<T>
    ~cancel(message: String?): VerifiedIdResult<null>
}
```

`OpenIdPresentationExchangeRequestProcessor` can be called by `OpenIdRequestHandler` with the request. If the request is an `OpenIdRawRequest`, the processor will parse the `raw` value for a definition and form the corresponding `VerifiedIdRequest`.

In parsing, it converts `input_definition`s into `VerifiedIdRequirement`s. `VerifiedIdRequirement` is fulfilled by supplying a `VerifiedId` that matches constraints.

Once all `VerifiedIdRequirement`s have been satisfied, the OpenIdPresentationRequest can `complete()`. This will create a `PresentationResponseContainer` and `add` each requirement to the container. Once added, the container can be serialized, signed, and send according to the request's parameters.

**Proposed Change**: `exclusivePlacement` can be added to `VerifiedIdRequirement` with `exclusive(with: [definition_id])` to ensure input definitions / requirements do not share the same verifiable presentation. `PresentationResponseContainer` will note these exclusions and any subject conflicts to create and map as many verifiable presentations as required.