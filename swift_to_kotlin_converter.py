#!/usr/bin/env python3
"""
Swift to Kotlin Converter for Entra Verified ID Wallet Library

This script automates the process of converting Swift code from the iOS library to Kotlin code
for the Android library, maintaining the style and patterns of the Android codebase.

Usage:
    python swift_to_kotlin_converter.py --ios-pr <PR_NUMBER> [--dry-run]

Arguments:
    --ios-pr: The PR number from the iOS repository to convert
    --dry-run: Optional flag to run the conversion without creating a PR
"""

import argparse
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Repository URLs
IOS_REPO_URL = "https://github.com/microsoft/entra-verifiedid-wallet-library-ios.git"
ANDROID_REPO_URL = "https://github.com/microsoft/entra-verifiedid-wallet-library-android.git"

# Mapping of Swift file paths to Kotlin file paths
PATH_MAPPING = {
    # Core files
    "WalletLibrary/WalletLibrary/VerifiedIdClient.swift": "walletlibrary/src/main/java/com/microsoft/walletlibrary/VerifiedIdClient.kt",
    "WalletLibrary/WalletLibrary/VerifiedIdClientBuilder.swift": "walletlibrary/src/main/java/com/microsoft/walletlibrary/VerifiedIdClientBuilder.kt",
    
    # Identifier
    "WalletLibrary/WalletLibrary/Identifier/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/identifier/",
    
    # Networking
    "WalletLibrary/WalletLibrary/Networking/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/networking/",
    
    # Requests
    "WalletLibrary/WalletLibrary/Requests/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/requests/",
    
    # VerifiedId
    "WalletLibrary/WalletLibrary/VerifiedId/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/verifiedid/",
    
    # Utilities
    "WalletLibrary/WalletLibrary/Utilities/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/util/",
    
    # Errors
    "WalletLibrary/WalletLibrary/Errors/": "walletlibrary/src/main/java/com/microsoft/walletlibrary/util/",
}

# Swift to Kotlin type mapping
TYPE_MAPPING = {
    "String": "String",
    "Int": "Int",
    "Double": "Double",
    "Float": "Float",
    "Bool": "Boolean",
    "Data": "ByteArray",
    "Dictionary<String, Any>": "Map<String, Any>",
    "Array<String>": "List<String>",
    "Array<": "List<",
    "Dictionary<": "Map<",
    "Any": "Any",
    "Void": "Unit",
    "Error": "Exception",
    "NSError": "Exception",
    "URL": "String",
    "URLSession": "OkHttpClient",
    "URLRequest": "Request",
    "URLResponse": "Response",
    "Result<": "Result<",
    "VerifiedIdResult<": "VerifiedIdResult<",
    "VerifiedIdError": "VerifiedIdException",
    "IdentifierError": "IdentifierException",
    "TokenError": "TokenException",
    "PresentationExchangeError": "PresentationExchangeException",
    "OpenID4VCIValidationError": "OpenID4VCIValidationException",
    "TokenValidationError": "TokenValidationException",
}

# Swift to Kotlin function/method mapping
FUNCTION_MAPPING = {
    "func": "fun",
    "override func": "override fun",
    "public func": "fun",
    "private func": "private fun",
    "internal func": "internal fun",
    "static func": "companion object {",  # Will need special handling
    "class func": "companion object {",   # Will need special handling
    "guard let": "if",  # Will need special handling
    "guard": "if",      # Will need special handling
    "if let": "if",     # Will need special handling
    "switch": "when",
    "case": "->",
    "default": "else ->",
    "extension": "fun",  # Will need special handling
    "typealias": "typealias",
    "enum": "enum class",
    "struct": "data class",
    "protocol": "interface",
    "class": "class",
    "init": "init",
    "deinit": "finalize",
    "return": "return",
    "throw": "throw",
    "throws": "throws",
    "try": "try",
    "catch": "catch",
    "weak self": "this@",  # Will need special handling
    "self": "this",
    "super": "super",
    "nil": "null",
    "true": "true",
    "false": "false",
}

# Swift to Kotlin property mapping
PROPERTY_MAPPING = {
    "var": "var",
    "let": "val",
    "private var": "private var",
    "private let": "private val",
    "internal var": "internal var",
    "internal let": "internal val",
    "public var": "var",
    "public let": "val",
    "static var": "companion object {",  # Will need special handling
    "static let": "companion object {",  # Will need special handling
    "lazy var": "val",  # Will need special handling for lazy initialization
}

# Swift to Kotlin annotation mapping
ANNOTATION_MAPPING = {
    "@available": "@Deprecated",
    "@objc": "",  # Remove @objc annotations
    "@escaping": "",  # Remove @escaping annotations
    "@autoclosure": "",  # Remove @autoclosure annotations
    "@IBOutlet": "",  # Remove @IBOutlet annotations
    "@IBAction": "",  # Remove @IBAction annotations
    "@IBInspectable": "",  # Remove @IBInspectable annotations
    "@IBDesignable": "",  # Remove @IBDesignable annotations
    "@NSManaged": "@Transient",
    "@discardableResult": "",  # Remove @discardableResult annotations
}

def run_command(cmd: List[str], cwd: Optional[str] = None) -> Tuple[int, str, str]:
    """Run a shell command and return the exit code, stdout, and stderr."""
    process = subprocess.Popen(
        cmd, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True
    )
    stdout, stderr = process.communicate()
    return process.returncode, stdout, stderr

def clone_repositories(work_dir: str) -> Tuple[str, str]:
    """Clone both repositories and return their paths."""
    ios_repo_path = os.path.join(work_dir, "ios-repo")
    android_repo_path = os.path.join(work_dir, "android-repo")
    
    print(f"Cloning iOS repository to {ios_repo_path}...")
    run_command(["git", "clone", IOS_REPO_URL, ios_repo_path])
    
    print(f"Cloning Android repository to {android_repo_path}...")
    run_command(["git", "clone", ANDROID_REPO_URL, android_repo_path])
    
    return ios_repo_path, android_repo_path

def get_pr_files(repo_path: str, pr_number: int) -> List[str]:
    """Get the list of files changed in a PR."""
    print(f"Fetching PR #{pr_number}...")
    run_command(["git", "fetch", "origin", f"pull/{pr_number}/head:pr-{pr_number}"], cwd=repo_path)
    run_command(["git", "checkout", f"pr-{pr_number}"], cwd=repo_path)
    
    # Get the base branch
    _, base_branch, _ = run_command(
        ["git", "config", "--get", "remote.origin.url"], cwd=repo_path
    )
    base_branch = "main"  # Default to main if we can't determine
    
    # Get the list of changed files
    _, diff_output, _ = run_command(
        ["git", "diff", "--name-only", f"origin/{base_branch}"], cwd=repo_path
    )
    
    return [file.strip() for file in diff_output.splitlines() if file.strip()]

def map_swift_path_to_kotlin(swift_path: str) -> Optional[str]:
    """Map a Swift file path to its corresponding Kotlin file path."""
    for swift_prefix, kotlin_prefix in PATH_MAPPING.items():
        if swift_path.startswith(swift_prefix):
            # Replace the prefix and change the extension
            kotlin_path = swift_path.replace(swift_prefix, kotlin_prefix)
            if kotlin_path.endswith(".swift"):
                kotlin_path = kotlin_path[:-6] + ".kt"
            return kotlin_path
    return None

def extract_class_name(swift_content: str) -> Optional[str]:
    """Extract the class name from Swift content."""
    class_match = re.search(r'(public |private |internal |)class\s+(\w+)', swift_content)
    if class_match:
        return class_match.group(2)
    
    struct_match = re.search(r'(public |private |internal |)struct\s+(\w+)', swift_content)
    if struct_match:
        return struct_match.group(2)
    
    enum_match = re.search(r'(public |private |internal |)enum\s+(\w+)', swift_content)
    if enum_match:
        return enum_match.group(2)
    
    protocol_match = re.search(r'(public |private |internal |)protocol\s+(\w+)', swift_content)
    if protocol_match:
        return protocol_match.group(2)
    
    return None

def extract_package_name(kotlin_path: str) -> str:
    """Extract the package name from a Kotlin file path."""
    # Example: walletlibrary/src/main/java/com/microsoft/walletlibrary/VerifiedIdClient.kt
    # Package: com.microsoft.walletlibrary
    parts = kotlin_path.split("/")
    if "java" in parts:
        java_index = parts.index("java")
        if java_index + 1 < len(parts):
            return ".".join(parts[java_index + 1:-1])
    return "com.microsoft.walletlibrary"  # Default package

def convert_imports(swift_content: str, class_name: str, package_name: str) -> str:
    """Convert Swift imports to Kotlin imports."""
    kotlin_imports = [f"package {package_name}\n"]
    
    # Extract Swift imports
    swift_imports = re.findall(r'import\s+(\w+)', swift_content)
    
    # Map Swift imports to Kotlin imports
    import_mapping = {
        "Foundation": "",  # No direct equivalent
        "UIKit": "android.content",
        "CoreData": "androidx.room",
        "VCEntities": "com.microsoft.walletlibrary.did.sdk.credential.models",
        "VCToken": "com.microsoft.walletlibrary.did.sdk.credential.service.models",
        "VCCrypto": "com.microsoft.walletlibrary.did.sdk.crypto",
        "VCNetworking": "com.microsoft.walletlibrary.did.sdk.datasource.network",
        "VCServices": "com.microsoft.walletlibrary.did.sdk.credential.service",
    }
    
    for swift_import in swift_imports:
        if swift_import in import_mapping and import_mapping[swift_import]:
            kotlin_imports.append(f"import {import_mapping[swift_import]}.*")
    
    # Add common Kotlin imports
    kotlin_imports.extend([
        "import kotlinx.coroutines.*",
        "import kotlinx.serialization.*",
        "import kotlinx.serialization.json.*",
    ])
    
    return "\n".join(kotlin_imports) + "\n\n"

def convert_properties(swift_content: str) -> str:
    """Convert Swift properties to Kotlin properties."""
    kotlin_content = swift_content
    
    # Convert property declarations
    for swift_keyword, kotlin_keyword in PROPERTY_MAPPING.items():
        pattern = rf'{swift_keyword}\s+(\w+)\s*:\s*([^{{}}=\n]+)(?:\s*=\s*([^{{}};\n]+))?'
        
        def property_replacement(match):
            name = match.group(1)
            type_annotation = match.group(2).strip()
            initial_value = match.group(3)
            
            # Convert the type
            for swift_type, kotlin_type in TYPE_MAPPING.items():
                if swift_type in type_annotation:
                    type_annotation = type_annotation.replace(swift_type, kotlin_type)
            
            # Handle nullable types
            if "?" in type_annotation:
                type_annotation = type_annotation.replace("?", "").strip() + "?"
            
            # Format the property declaration
            if initial_value:
                return f"{kotlin_keyword} {name}: {type_annotation} = {initial_value}"
            else:
                return f"{kotlin_keyword} {name}: {type_annotation}"
        
        kotlin_content = re.sub(pattern, property_replacement, kotlin_content)
    
    return kotlin_content

def convert_functions(swift_content: str) -> str:
    """Convert Swift functions to Kotlin functions."""
    kotlin_content = swift_content
    
    # Convert function declarations
    for swift_keyword, kotlin_keyword in FUNCTION_MAPPING.items():
        if swift_keyword in ["func", "public func", "private func", "internal func"]:
            pattern = rf'{swift_keyword}\s+(\w+)\s*\((.*?)\)(?:\s*->\s*([^{{}}]+))?\s*{{'
            
            def function_replacement(match):
                name = match.group(1)
                params_str = match.group(2)
                return_type = match.group(3)
                
                # Convert parameters
                params = []
                if params_str.strip():
                    param_parts = params_str.split(",")
                    for part in param_parts:
                        # Handle external and internal parameter names
                        param_match = re.match(r'(?:(\w+)\s+)?(\w+)\s*:\s*([^=]+)(?:\s*=\s*(.+))?', part.strip())
                        if param_match:
                            external_name = param_match.group(1)
                            internal_name = param_match.group(2)
                            param_type = param_match.group(3).strip()
                            default_value = param_match.group(4)
                            
                            # Use the internal name if no external name is provided
                            param_name = internal_name if not external_name else internal_name
                            
                            # Convert the type
                            for swift_type, kotlin_type in TYPE_MAPPING.items():
                                if swift_type in param_type:
                                    param_type = param_type.replace(swift_type, kotlin_type)
                            
                            # Handle nullable types
                            if "?" in param_type:
                                param_type = param_type.replace("?", "").strip() + "?"
                            
                            # Format the parameter
                            if default_value:
                                params.append(f"{param_name}: {param_type} = {default_value}")
                            else:
                                params.append(f"{param_name}: {param_type}")
                
                # Convert return type
                kotlin_return_type = ""
                if return_type:
                    kotlin_return_type = return_type.strip()
                    for swift_type, kotlin_type in TYPE_MAPPING.items():
                        if swift_type in kotlin_return_type:
                            kotlin_return_type = kotlin_return_type.replace(swift_type, kotlin_type)
                    
                    # Handle nullable return types
                    if "?" in kotlin_return_type:
                        kotlin_return_type = kotlin_return_type.replace("?", "").strip() + "?"
                
                # Format the function declaration
                if kotlin_return_type:
                    return f"{kotlin_keyword} {name}({', '.join(params)}): {kotlin_return_type} {{"
                else:
                    return f"{kotlin_keyword} {name}({', '.join(params)}) {{"
            
            kotlin_content = re.sub(pattern, function_replacement, kotlin_content)
    
    return kotlin_content

def convert_closures(swift_content: str) -> str:
    """Convert Swift closures to Kotlin lambdas."""
    kotlin_content = swift_content
    
    # Convert completion handlers to suspend functions or callbacks
    completion_pattern = r'completion:\s*@escaping\s*\(\s*(?:Result<([^,]+),\s*([^>]+)>|([^)]+))\s*\)\s*->\s*Void'
    
    def completion_replacement(match):
        success_type = match.group(1)
        error_type = match.group(2)
        single_type = match.group(3)
        
        if success_type and error_type:
            # Convert Result<Success, Error> to suspend function
            for swift_type, kotlin_type in TYPE_MAPPING.items():
                if swift_type in success_type:
                    success_type = success_type.replace(swift_type, kotlin_type)
                if swift_type in error_type:
                    error_type = error_type.replace(swift_type, kotlin_type)
            
            return f"): Result<{success_type}, {error_type}>"
        elif single_type:
            # Convert single type to callback
            for swift_type, kotlin_type in TYPE_MAPPING.items():
                if swift_type in single_type:
                    single_type = single_type.replace(swift_type, kotlin_type)
            
            return f"callback: ({single_type}) -> Unit"
        
        return match.group(0)
    
    kotlin_content = re.sub(completion_pattern, completion_replacement, kotlin_content)
    
    # Convert other closures
    closure_pattern = r'\{\s*\(([^)]*)\)\s*->\s*([^{]+)\s*in'
    
    def closure_replacement(match):
        params = match.group(1)
        return_type = match.group(2).strip()
        
        # Convert parameters
        kotlin_params = []
        if params.strip():
            param_parts = params.split(",")
            for part in param_parts:
                param_match = re.match(r'(\w+)\s*:\s*([^,]+)', part.strip())
                if param_match:
                    param_name = param_match.group(1)
                    param_type = param_match.group(2).strip()
                    
                    # Convert the type
                    for swift_type, kotlin_type in TYPE_MAPPING.items():
                        if swift_type in param_type:
                            param_type = param_type.replace(swift_type, kotlin_type)
                    
                    kotlin_params.append(f"{param_name}: {param_type}")
                else:
                    kotlin_params.append(part.strip())
        
        # Convert return type
        kotlin_return_type = return_type
        for swift_type, kotlin_type in TYPE_MAPPING.items():
            if swift_type in kotlin_return_type:
                kotlin_return_type = kotlin_return_type.replace(swift_type, kotlin_type)
        
        # Format the lambda
        return f"{{ {', '.join(kotlin_params)} -> "
    
    kotlin_content = re.sub(closure_pattern, closure_replacement, kotlin_content)
    
    return kotlin_content

def convert_control_flow(swift_content: str) -> str:
    """Convert Swift control flow statements to Kotlin."""
    kotlin_content = swift_content
    
    # Convert guard statements
    guard_pattern = r'guard\s+let\s+(\w+)\s*=\s*([^,]+)(?:,\s*([^{]+))?\s*else\s*{'
    
    def guard_replacement(match):
        var_name = match.group(1)
        expression = match.group(2)
        additional_condition = match.group(3)
        
        if additional_condition:
            return f"val {var_name} = {expression}\nif ({var_name} == null || !({additional_condition})) {{"
        else:
            return f"val {var_name} = {expression}\nif ({var_name} == null) {{"
    
    kotlin_content = re.sub(guard_pattern, guard_replacement, kotlin_content)
    
    # Convert if let statements
    if_let_pattern = r'if\s+let\s+(\w+)\s*=\s*([^,]+)(?:,\s*([^{]+))?\s*{'
    
    def if_let_replacement(match):
        var_name = match.group(1)
        expression = match.group(2)
        additional_condition = match.group(3)
        
        if additional_condition:
            return f"{expression}?.let {{ {var_name} ->\nif ({additional_condition}) {{"
        else:
            return f"{expression}?.let {{ {var_name} ->"
    
    kotlin_content = re.sub(if_let_pattern, if_let_replacement, kotlin_content)
    
    # Convert switch statements
    switch_pattern = r'switch\s+([^{]+)\s*{'
    
    def switch_replacement(match):
        expression = match.group(1)
        return f"when ({expression}) {{"
    
    kotlin_content = re.sub(switch_pattern, switch_replacement, kotlin_content)
    
    # Convert case statements
    case_pattern = r'case\s+([^:]+):'
    
    def case_replacement(match):
        case_value = match.group(1)
        return f"{case_value} ->"
    
    kotlin_content = re.sub(case_pattern, case_replacement, kotlin_content)
    
    # Convert default statements
    default_pattern = r'default:'
    kotlin_content = re.sub(default_pattern, "else ->", kotlin_content)
    
    return kotlin_content

def convert_annotations(swift_content: str) -> str:
    """Convert Swift annotations to Kotlin annotations."""
    kotlin_content = swift_content
    
    for swift_annotation, kotlin_annotation in ANNOTATION_MAPPING.items():
        if kotlin_annotation:
            kotlin_content = kotlin_content.replace(swift_annotation, kotlin_annotation)
        else:
            # Remove annotations that don't have a Kotlin equivalent
            kotlin_content = re.sub(rf'{swift_annotation}(?:\([^)]*\))?\s*', '', kotlin_content)
    
    return kotlin_content

def convert_swift_to_kotlin(swift_content: str, kotlin_path: str) -> str:
    """Convert Swift code to Kotlin code."""
    # Extract class name and package name
    class_name = extract_class_name(swift_content)
    package_name = extract_package_name(kotlin_path)
    
    # Start with imports
    kotlin_content = convert_imports(swift_content, class_name, package_name)
    
    # Convert annotations
    kotlin_content += convert_annotations(swift_content)
    
    # Convert properties
    kotlin_content = convert_properties(kotlin_content)
    
    # Convert functions
    kotlin_content = convert_functions(kotlin_content)
    
    # Convert closures
    kotlin_content = convert_closures(kotlin_content)
    
    # Convert control flow
    kotlin_content = convert_control_flow(kotlin_content)
    
    # Replace Swift-specific syntax
    kotlin_content = kotlin_content.replace("self.", "this.")
    kotlin_content = kotlin_content.replace("self?.", "this?.")
    kotlin_content = kotlin_content.replace("self", "this")
    kotlin_content = kotlin_content.replace("nil", "null")
    kotlin_content = kotlin_content.replace("true", "true")
    kotlin_content = kotlin_content.replace("false", "false")
    kotlin_content = kotlin_content.replace("guard", "if")
    kotlin_content = kotlin_content.replace("else {", "} else {")
    
    # Clean up any remaining Swift-specific code
    kotlin_content = re.sub(r'//.*', '', kotlin_content)  # Remove single-line comments
    kotlin_content = re.sub(r'/\*.*?\*/', '', kotlin_content, flags=re.DOTALL)  # Remove multi-line comments
    
    # Add the class declaration if it's missing
    if class_name and "class " + class_name not in kotlin_content:
        kotlin_content += f"\nclass {class_name} {{\n\n}}\n"
    
    return kotlin_content

def process_pr_files(ios_repo_path: str, android_repo_path: str, pr_files: List[str], dry_run: bool) -> List[str]:
    """Process the files changed in the PR and convert them to Kotlin."""
    converted_files = []
    
    for swift_path in pr_files:
        if not swift_path.endswith(".swift"):
            continue
        
        # Map the Swift path to a Kotlin path
        kotlin_path = map_swift_path_to_kotlin(swift_path)
        if not kotlin_path:
            print(f"Skipping {swift_path} - no mapping found")
            continue
        
        print(f"Converting {swift_path} to {kotlin_path}...")
        
        # Read the Swift file
        with open(os.path.join(ios_repo_path, swift_path), "r") as f:
            swift_content = f.read()
        
        # Convert Swift to Kotlin
        kotlin_content = convert_swift_to_kotlin(swift_content, kotlin_path)
        
        # Write the Kotlin file
        kotlin_file_path = os.path.join(android_repo_path, kotlin_path)
        os.makedirs(os.path.dirname(kotlin_file_path), exist_ok=True)
        
        with open(kotlin_file_path, "w") as f:
            f.write(kotlin_content)
        
        converted_files.append(kotlin_path)
    
    return converted_files

def create_android_pr(android_repo_path: str, converted_files: List[str], ios_pr_number: int) -> None:
    """Create a PR in the Android repository with the converted files."""
    # Create a new branch
    branch_name = f"ios-to-android-pr-{ios_pr_number}"
    run_command(["git", "checkout", "-b", branch_name], cwd=android_repo_path)
    
    # Add the converted files
    for file_path in converted_files:
        run_command(["git", "add", file_path], cwd=android_repo_path)
    
    # Commit the changes
    commit_message = f"Convert iOS PR #{ios_pr_number} to Android\n\nAutomatically converted Swift code to Kotlin."
    run_command(["git", "commit", "-m", commit_message], cwd=android_repo_path)
    
    # Push the branch
    run_command(["git", "push", "origin", branch_name], cwd=android_repo_path)
    
    # Create the PR using the GitHub CLI (gh)
    pr_title = f"Convert iOS PR #{ios_pr_number} to Android"
    pr_body = f"This PR was automatically generated from iOS PR #{ios_pr_number}.\n\nConverted files:\n" + "\n".join(converted_files)
    
    run_command(
        ["gh", "pr", "create", "--title", pr_title, "--body", pr_body, "--base", "main"],
        cwd=android_repo_path,
    )

def main():
    parser = argparse.ArgumentParser(description="Convert Swift code from iOS PR to Kotlin for Android")
    parser.add_argument("--ios-pr", type=int, required=True, help="iOS PR number to convert")
    parser.add_argument("--dry-run", action="store_true", help="Run conversion without creating PR")
    args = parser.parse_args()
    
    # Create a temporary directory for the repositories
    with tempfile.TemporaryDirectory() as work_dir:
        # Clone the repositories
        ios_repo_path, android_repo_path = clone_repositories(work_dir)
        
        # Get the files changed in the PR
        pr_files = get_pr_files(ios_repo_path, args.ios_pr)
        
        # Process the files
        converted_files = process_pr_files(ios_repo_path, android_repo_path, pr_files, args.dry_run)
        
        if not args.dry_run and converted_files:
            # Create a PR in the Android repository
            create_android_pr(android_repo_path, converted_files, args.ios_pr)
            print(f"Created PR in Android repository for iOS PR #{args.ios_pr}")
        else:
            print(f"Dry run completed. Converted {len(converted_files)} files.")

if __name__ == "__main__":
    main()
