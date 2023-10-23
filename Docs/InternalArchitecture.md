
# Library Internal Architecture

## Creating a Verified Id Request from Input
```mermaid
classDiagram
class RequestHandlerFactory {
    - requestHandlers: [RequestHandler]
    ~getHandler(from resolver: RequestResolver) RequestHandler
}
RequestHandlerFactory o-- RequestHandler
RequestHandlerFactory ..> RequestResolver: uses
RequestHandlerFactory ..> RequestHandler: creates

RawRequest ..> RequestHandler: uses
RequestResolver ..> RawRequest: creates
RequestResolver ..> VerifiedIdRequestInput: uses
RequestProcessor ..> VerifiedIdRequest: creates
RequestHandler ..> VerifiedIdRequest: creates
RawRequest ..> RequestProcessor: uses
<<Interface>> RequestResolver
class RequestResolver {
    ~canResolve(using: RequestHandler) Bool
    ~canResolve(from: VerifiedIdClientInput) Bool
    ~resolve(input: VerifiedIdClientInput) RawRequest
}
class RequestHandler{
    ~handle(input: RawRequest) VerifiedIdRequest
}
<<Interface>> VerifiedIdRequestInput
class RequestProcessorFactory {
    - requestProcessors: [RequestProcessor]
    ~getRequestProcessor(for: RawRequest) RequestProcessor
}
<<Interface>> RequestProcessor
class RequestProcessor {
    ~canProcess(raw: RawRequest) Bool
    ~process(raw: RawRequest) VerifiedIdRequest
}
RequestProcessorFactory o-- RequestProcessor
RequestHandler ..> RequestProcessor: uses
RequestHandler *-- RequestProcessorFactory
<<Interface>> RawRequest
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest {
    ...
}
```

## Concepts

### Request Resolver
A Request Resolver resolves a raw request from a request input and additional params. A request resolver is specific to a certain type of request handler and input type. 

Ex: An `OpenIdURLRequestResolver` would know how to resolve a raw open id request token. The additional params would be OpenId specific to be used to send any additional information needed to resolve the request (what version of openid is supported, for example). The result would be a `OpenIdRawRequest` that has not been processed or validated yet.

### Request Handler
A request handler is used to handle an input where the request can be resolved by a request resolver and then processed, validated and mapped to a Verified Id Request. A request handler is protocol specific (e.g. `OpenIdRequestHandler`). It does not need to know to resolve the input as that logic is handles by the resolver.

Ex: An `OpenIdRequestHandler` would take in any type of input as long as the resolver that is also passed in knows how to resolve the input into an OpenIdRawRequest. The `OpenIdRequestHandler` would contain a list of `OpenIdRequestProcessors` that know how to process different types of openid version or extensions (e.g. jwt 0.1, jwt 0.2, json-ld, etc). `OpenIdRequestHandler` can parse the base OpenID request, then use `OpenIDRequestProcessors` for verified ID logic to form responses, then serialize and send the response according to openID protocol.

### Request Processor
A request processor is used to process a Raw Request and return a Verified Id Request. A request processor is protocol-version specific logic.

Ex. A `JWTV1RequestProcessor` takes in a `OpenIdRawRequest` and processes, validates, and maps it to a Verified Id Request.

## Configuring the Request Handler
```mermaid
classDiagram
VerifiedIdClient ..> RequestResolverFactory: uses
VerifiedIdClient ..> RequestHandlerFactory: uses
VerifiedIdClient ..> VerifiedIdRequestInput: uses
RequestResolverFactory ..> VerifiedIdRequestInput: uses
RequestResolverFactory ..|> RequestResolver: creates
RequestHandlerFactory ..> RequestResolver: uses
RequestHandlerFactory ..|> RequestHandler: creates
RequestHandler ..|> VerifiedIdRequest: creates
class VerifiedIdClient{
    +createRequest(from: VerifiedIdRequestInput) VerifiedIdRequest
}
class RequestResolverFactory{
    ~makeResolver(from: VerifiedIdRequestInput) RequestResolver
}
class RequestHandlerFactory{
    ~makeHandler(from: RequestResolver) RequestHandler
}

```