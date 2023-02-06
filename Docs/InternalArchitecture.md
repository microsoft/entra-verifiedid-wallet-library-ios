
# Library External Architecture
## Request Handlers
```mermaid
classDiagram
RequestResolverFactory ..|> RequestResolver: creates
RequestResolver ..> AdditionalRequestParams: uses
RequestResolver <|-- OpenIdRequestResolver: implements
RequestResolver ..|> RawRequest: creates
OpenIdRequestResolver ..> OpenIdRawRequest: creates
RawRequest <|-- OpenIdRawRequest: implements
AdditionalRequestParams <|-- OpenIdRequestParams: implements
OpenIdRequestResolver ..> OpenIdRequestParams: uses
RequestHandlerFactory ..|> RequestHandler: creates
RequestHandlerFactory ..> RequestResolver: uses
RequestHandler ..> RequestResolver: uses
RequestHandler ..> VerifiedIdRequestInput: uses
VerifiedIdRequestInput --|> URLInput: implements
RequestHandler ..|> RequestProcessor: uses
RequestProcessor ..|> VerifiedIdRequest: creates
RequestProcessor <|-- OpenIdJWTV1Processor: implements
class RequestResolverFactory{
    ~makeResolver(from: VerifiedIdRequestInput) RequestResolver
}
<<Interface>> RequestResolver
class RequestResolver {
    ~canResolve(using: RequestHandler) Bool
    ~canResolve(from: VerifiedIdClientInput) Bool
    ~resolve(input: VerifiedIdClientInput, using: [AdditionalRequestParams]) RawRequest
}
class OpenIdRequestResolver {
    ~canResolve(using: RequestHandler) Bool
    ~canResolve(from: VerifiedIdClientInput) Bool
    ~resolve(input: VerifiedIdClientInput, using: [AdditionalRequestParams]) RawRequest

}
class RequestHandlerFactory{
    ~makeHandler(from: RequestResolver) RequestHandler
}
class RequestHandler{
    ~handle(input: VerifiedIdRequestInput, using: RequestResolver) VerifiedIdRequest
}
<<Interface>> VerifiedIdRequestInput
class URLInput{
    +init(url)
}
<<Interface>> RequestProcessor
class RequestProcessor {
    -requestParams: AdditionalRequestParams
    ~canProcess(rawRequest: RawRequest) Bool
    ~process(rawRequest: RawRequest) VerifiedIdRequest
}
class OpenIdJWTV1Processor {
    -requestParams: OpenIdRequestParams
    ~canProcess(rawRequest: RawRequest) Bool
    ~process(rawRequest: RawRequest) VerifiedIdRequest
}
class OpenIdRequestParams {
    let protocolVersion: String
}
<<Interface>> AdditionalRequestParams
<<Interface>> RawRequest
class RawRequest {
    -raw: Data
}
class OpenIdRawRequest {
    -raw: Data
}
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest {
    ...
}
```

## Concepts

### Request Resolver
A Request Resolver resolves a raw request from a request input and additional params. A request resolver is specific to a certain type of request handler and input type. 

Ex: An OpenIdURLRequestResolver would know how to resolve a raw open id request token. The additional params would be OpenId specific to be used to send any additional information needed to resolve the request (what version of openid is supported, for example). The result would be a raw openid request that has not been processed or validated yet.

### Request Handler
A request handler is used to handle an input where the request can be resolved by a request resolver and then processed, validated and mapped to a Verified Id Request. A request handler is protocol specific (e.g. OpenIdRequestHandler). It does not need to know to resolve the input as that logic is handles by the resolver, but it can inject any additional parameters into the resolver using Additional Params. 

Ex: An OpenIdRequestHandler would take in any type of input as long as the resolver that is also passed in knows how to resolve the input into an OpenIdRawRequest. The OpenIdRequestHandler would contain a list of OpenIdRequestProcessors that know how to process different types of openid version (e.g. jwt 0.1, jwt 0.2, json-ld, etc). The handler would use the Additional Params that are passed into the resolver to tell the resolver what version of open-id are supported. 

### Request Processor
A request processor is used to process a Raw Request and return a Verified Id Request. A request processor is protocol-version specific. 

Ex. A JWTV1RequestProcessor takes in a OpenIdRawRequest and processes, validates, and maps it to a Verified Id Request. 