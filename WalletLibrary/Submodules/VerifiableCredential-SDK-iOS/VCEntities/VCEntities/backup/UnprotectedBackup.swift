/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import Foundation

/// This protocol serves as the interface for any kind of backup that may hold any kind of data.
/// This way the implementations of backups can evolve without the APIs changing.
public protocol UnprotectedBackup : Codable { }
