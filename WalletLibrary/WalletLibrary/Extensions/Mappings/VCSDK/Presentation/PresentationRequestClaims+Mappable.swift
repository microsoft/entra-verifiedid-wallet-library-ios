/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * Errors thrown in Pin Descriptor Mappable extension.
 */
extension PresentationRequestClaims: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any> 
    {
        var obj: [String: Any] = [:]
        obj[CodingKeys.clientID.rawValue] = clientID
        obj[CodingKeys.redirectURI.rawValue] = redirectURI
        obj[CodingKeys.responseType.rawValue] = responseType
        obj[CodingKeys.responseMode.rawValue] = responseMode
        obj[CodingKeys.idTokenHint.rawValue] = idTokenHint
        obj[CodingKeys.state.rawValue] = state
        obj[CodingKeys.nonce.rawValue] = nonce
        obj[CodingKeys.prompt.rawValue] = prompt
        obj[CodingKeys.registration.rawValue] = registration
        obj[CodingKeys.iat.rawValue] = iat
        obj[CodingKeys.exp.rawValue] = exp
        obj[CodingKeys.scope.rawValue] = scope
        obj[CodingKeys.claims.rawValue] = claims
        obj[CodingKeys.jti.rawValue] = jti
        obj[CodingKeys.pin.rawValue] = pin
        return obj
    }
}

extension RequestedVPToken: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any>
    {
        var obj: [String: Any] = [:]
        obj[CodingKeys.presentationDefinition.rawValue] = try map(presentationDefinition: presentationDefinition,
                                                                  mapper: mapper)
        return obj
    }
    
    private func map(presentationDefinition: PresentationDefinition?, mapper: Mapping) throws -> Dictionary<String, Any>
    {
        var obj: [String: Any] = [:]
        if let presentationDef = presentationDefinition
        {
            obj[PresentationDefinition.CodingKeys.id.rawValue] = presentationDef.id
            obj[PresentationDefinition.CodingKeys.issuance.rawValue] = presentationDef.issuance
            obj[PresentationDefinition.CodingKeys.inputDescriptors.rawValue] = try presentationDef.inputDescriptors?.compactMap {
                try map(inputDescriptor: $0, mapper: mapper)
            }
        }

        return obj
    }
    
    private func map(inputDescriptor: PresentationInputDescriptor, mapper: Mapping) throws -> Dictionary<String, Any>
    {
        var obj: [String: Any] = [:]
        
        if let constraints = inputDescriptor.constraints
        {
            obj[PresentationInputDescriptor.CodingKeys.constraints.rawValue] = try mapper.map(constraints)
        }
        
        let issuanceMetadata = try inputDescriptor.issuanceMetadata?.compactMap { try mapper.map($0) }
        obj[PresentationInputDescriptor.CodingKeys.issuanceMetadata.rawValue] = issuanceMetadata
        
        let schema = try inputDescriptor.schema?.compactMap { try mapper.map($0) }
        obj[PresentationInputDescriptor.CodingKeys.schema.rawValue] = schema
        
        obj[PresentationInputDescriptor.CodingKeys.id.rawValue] = inputDescriptor.id
        obj[PresentationInputDescriptor.CodingKeys.name.rawValue] = inputDescriptor.name
        obj[PresentationInputDescriptor.CodingKeys.purpose.rawValue] = inputDescriptor.purpose
        
        return obj
    }
}

extension PresentationExchangeConstraints: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any>
    {
        let mappedFields = try fields?.compactMap { try mapper.map($0) }
        return [
            CodingKeys.fields.rawValue: mappedFields as Any
        ]
    }
}

extension PresentationExchangeFilter: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any>
    {
        return [
            CodingKeys.type.rawValue: type as Any,
            CodingKeys.pattern.rawValue: pattern?.pattern as Any
        ]
    }
}

extension IssuanceMetadata: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any>
    {
        return [
            CodingKeys.contract.rawValue: contract as Any,
            CodingKeys.issuerDid.rawValue: issuerDid as Any
        ]
    }
}

extension InputDescriptorSchema: Mappable
{
    typealias T = Dictionary<String, Any>
    
    func map(using mapper: Mapping) throws -> Dictionary<String, Any>
    {
        return [
            CodingKeys.uri.rawValue: uri as Any
        ]
    }
}


