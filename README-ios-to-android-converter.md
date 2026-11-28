# iOS to Android Code Converter

This tool automatically converts Swift code from the Entra Verified ID Wallet Library iOS repository to Kotlin code for the Android repository, and creates a pull request with the converted code.

## Overview

When you create or update a pull request in the iOS repository, this workflow:

1. Detects changes in Swift files
2. Converts the Swift code to Kotlin following the Android repository's style and patterns
3. Creates a pull request in the Android repository with the converted code

This helps maintain feature parity between the iOS and Android libraries with minimal manual effort.

## Setup

### Prerequisites

1. GitHub Actions enabled on your repository
2. Access to both iOS and Android repositories
3. GitHub Personal Access Token with appropriate permissions

### Configuration

1. Add the GitHub Actions workflow file (`.github/workflows/ios-to-android-converter.yml`) to your iOS repository
2. Add the converter script (`swift_to_kotlin_converter.py`) to your iOS repository
3. Set up the following GitHub secrets:
   - `GITHUB_TOKEN`: A personal access token with permissions to create pull requests in the Android repository

## Usage

### Automatic Conversion

The workflow automatically triggers when:
- A pull request is opened, synchronized, or reopened in the iOS repository
- The PR contains changes to Swift files in the `WalletLibrary/WalletLibrary` directory

### Manual Conversion

You can also manually trigger the workflow:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "iOS to Android Converter" workflow
3. Click "Run workflow"
4. Enter the PR number you want to convert
5. Click "Run workflow"

## Limitations and Considerations

### Code Conversion Limitations

The converter handles many Swift-to-Kotlin conversions, but some patterns may require manual adjustment:

- Complex Swift-specific features (e.g., property wrappers, associated types)
- Custom operators
- Objective-C interoperability
- Platform-specific code

### Path Mapping

The converter uses a predefined mapping between Swift and Kotlin file paths. If you add new directories or files that don't follow the existing structure, you may need to update the `PATH_MAPPING` dictionary in the converter script.

### Type Mapping

The converter includes mappings for common Swift and Kotlin types. If you use custom types or types not included in the mapping, you may need to update the `TYPE_MAPPING` dictionary.

## Extending the Converter

### Adding New Mappings

To add support for new file paths, types, or patterns:

1. Edit the `swift_to_kotlin_converter.py` file
2. Update the appropriate mapping dictionary:
   - `PATH_MAPPING`: File path mappings
   - `TYPE_MAPPING`: Type mappings
   - `FUNCTION_MAPPING`: Function/method mappings
   - `PROPERTY_MAPPING`: Property mappings
   - `ANNOTATION_MAPPING`: Annotation mappings

### Improving Conversion Logic

The converter uses regular expressions to transform Swift code to Kotlin. If you encounter patterns that aren't handled correctly:

1. Identify the pattern in the Swift code
2. Add or modify the appropriate conversion function in the script
3. Test the changes with a sample PR

## Workflow

1. iOS developer creates a PR with new features or bug fixes
2. The workflow automatically converts the Swift code to Kotlin
3. The workflow creates a PR in the Android repository
4. Android developers review the generated code
5. After any necessary adjustments, the Android PR can be merged

This approach ensures that features and fixes are consistently implemented across both platforms while respecting the idioms and patterns of each language.
