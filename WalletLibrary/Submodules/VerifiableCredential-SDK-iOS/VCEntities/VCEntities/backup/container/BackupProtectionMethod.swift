/*---------------------------------------------------------------------------------------------
*  Copyright (c) Microsoft Corporation. All rights reserved.
*  Licensed under the MIT License. See License.txt in the project root for license information.
*--------------------------------------------------------------------------------------------*/

/// This protocol serves as the interface for a family of objects which can apply different kinds of protection
/// (typically, encryption) to backup data
public protocol BackupProtectionMethod {
    func wrap(unprotectedBackupData: UnprotectedBackupData) throws -> ProtectedBackupData
    func unwrap(protectedBackupData: ProtectedBackupData) throws -> UnprotectedBackupData
}
