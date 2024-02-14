/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import XCTest
@testable import WalletLibrary

class AE2ETests: XCTestCase 
{
    func testEndToEnd() async throws 
    {
        let builder = VerifiedIdClientBuilder().with(previewFeatureFlags: [PreviewFeatureFlags.OpenID4VCIAccessToken])
        let client = builder.build()
        
        let url = VerifiedIdRequestURL(url: URL(string: "openid-vc://?request_uri=https://staging.did.msidentity.com/v1.0/tenants/e1f66f2e-c050-4308-81b3-3d7ea7ef3b1b/verifiableCredentials/issuanceRequests/bcd1a029-aaef-4f3b-bffe-ab858b312b3e")!)
        let request = try await client.createRequest(from: url).get()
        print(request)
        
        (request.requirement as? AccessTokenRequirement)?.fulfill(with: accessToken)
        
        let vc = try await (request as? any VerifiedIdIssuanceRequest)?.complete().get()
        print(vc)
    }
    
    let accessToken = "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm5BdyIsImtpZCI6ImtXYmthYTZxczh3c1RuQndpaU5ZT2hIYm5BdyJ9.eyJhdWQiOiJhNjE4Y2U0MC1hMGRkLTQyZWItOTc0Yi1mMjY2MTUwYWUwZDYiLCJpc3MiOiJodHRwczovL3N0cy53aW5kb3dzLm5ldC9lMWY2NmYyZS1jMDUwLTQzMDgtODFiMy0zZDdlYTdlZjNiMWIvIiwiaWF0IjoxNzA3OTI1NTI0LCJuYmYiOjE3MDc5MjU1MjQsImV4cCI6MTcwNzkyOTQyNCwiYWlvIjoiRTJWZ1lQQmNQcUg0OXAzOUY5YitjVHo0Sk16a0dRQT0iLCJhcHBpZCI6ImRiZjVhZDNiLWU1YjUtNDJhMC1hOTNhLTFiMGEwM2JkYThlMiIsImFwcGlkYWNyIjoiMSIsImlkcCI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0L2UxZjY2ZjJlLWMwNTAtNDMwOC04MWIzLTNkN2VhN2VmM2IxYi8iLCJvaWQiOiJkMjYxMjVhYS03YTNjLTQyMTctODg4MS03YWE3MDUwYWQ2YmEiLCJyaCI6IjAuQVh3QUxtXzI0VkRBQ0VPQnN6MS1wLTg3RzBET0dLYmRvT3RDbDB2eVpoVUs0Tlo4QUFBLiIsInN1YiI6ImQyNjEyNWFhLTdhM2MtNDIxNy04ODgxLTdhYTcwNTBhZDZiYSIsInRpZCI6ImUxZjY2ZjJlLWMwNTAtNDMwOC04MWIzLTNkN2VhN2VmM2IxYiIsInV0aSI6IkUxVlN1NUY1Z1VPRUdLbGNPQlhtQUEiLCJ2ZXIiOiIxLjAifQ.poXFdEjs_SywmOBsCAB_AX4yVj6av_KqZXjtChLs6zYFrmaTA_-SP-KT248xdlefWp7Vu1w8naGEbgxnm9sBz2ZRiauKYGkH7y8hN54_37MQM3W_uAYXUY8ebgIEUf5v-j1dKwr4wdThYA7ZnrgwY8aHF5kT5negXDC-p3dcfds94Fg4WgYB9cqC3WbH1aAO2JDHj1WSzz11ajzU1DpakTMC_jFGs8xJ0DPGflXAYJj57hd2jdRJmaR7BR2LYYA2D0fWUgcaLhGgp3lFusI_Mchc1QqckLdcPaVtHe5vLE2hjv4LJnrXo0Nccux4oQ4_Smb2aZobqRCBDOI-1RWhCA"
}
