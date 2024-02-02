/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/**
 * The Wallet Library specific network operation.
 */
protocol WalletLibraryNetworkOperation: InternalNetworkOperation
{
    init(urlSession: URLSession,
         urlRequest: URLRequest,
         correlationVector: VerifiedIdCorrelationHeader?)
}
