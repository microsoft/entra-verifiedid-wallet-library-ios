
# Library Internal Architecture

## Creating a Verified Id Request from Input
```mermaid
classDiagram
RequestResolver ..|> VerifiedIdRequestInput: uses
RequestResolver ..|> Any: creates
RequestHandler ..|> Any: uses
RequestHandler ..|> VerifiedIdRequest: creates
<<Interface>> RequestResolver
class RequestResolver {
    ~canResolve(input: VerifiedIdClientInput) Bool
    ~resolve(input: VerifiedIdClientInput) Any
}
class RequestHandler{
    ~canHandle(rawRequest: Any) Bool
    ~handle(rawRequest: Any) VerifiedIdRequest
}
<<Interface>> VerifiedIdRequestInput
<<Interface>> VerifiedIdRequest
class VerifiedIdRequest {
    ...
}
```

## Concepts

### Request Resolver
A Request Resolver resolves a raw request from a request input. A request resolver is specific to a certain type of protocol and input type. 

Ex: An `OpenIdURLRequestResolver` would know how to resolve a raw open id request token.

### Request Handler
A request handler is used to process, validate and map it to a Verified Id Request. A request handler is protocol specific (e.g. `OpenIdRequestHandler`). 

### Request Processor
TODO 

## Configuring the Request Handler
```mermaid
classDiagram
VerifiedIdClient ..> RequestResolverFactory: uses
VerifiedIdClient ..> RequestHandlerFactory: uses
VerifiedIdClient ..> VerifiedIdRequestInput: uses
RequestResolverFactory ..> VerifiedIdRequestInput: uses
RequestResolverFactory ..|> RequestResolver: creates
RequestResolver ..|> Any: creates
RequestHandlerFactory ..> Any: uses
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