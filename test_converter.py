#!/usr/bin/env python3
"""
Test Script for Swift to Kotlin Converter

This script allows you to test the Swift to Kotlin converter on a single file
without creating a PR. It's useful for testing conversion logic and debugging.

Usage:
    python test_converter.py --swift-file <PATH_TO_SWIFT_FILE>

Arguments:
    --swift-file: Path to the Swift file to convert
"""

import argparse
import os
import sys
from swift_to_kotlin_converter import (
    convert_swift_to_kotlin,
    map_swift_path_to_kotlin,
    extract_class_name,
    extract_package_name,
)

def main():
    parser = argparse.ArgumentParser(description="Test Swift to Kotlin conversion on a single file")
    parser.add_argument("--swift-file", required=True, help="Path to the Swift file to convert")
    args = parser.parse_args()
    
    swift_file = args.swift_file
    
    # Check if the file exists
    if not os.path.isfile(swift_file):
        print(f"Error: File {swift_file} does not exist")
        sys.exit(1)
    
    # Check if the file is a Swift file
    if not swift_file.endswith(".swift"):
        print(f"Error: File {swift_file} is not a Swift file")
        sys.exit(1)
    
    # Read the Swift file
    with open(swift_file, "r") as f:
        swift_content = f.read()
    
    # Map the Swift path to a Kotlin path
    kotlin_path = map_swift_path_to_kotlin(swift_file)
    if not kotlin_path:
        print(f"Warning: No mapping found for {swift_file}")
        # Try to infer a Kotlin path
        base_name = os.path.basename(swift_file)
        kotlin_name = base_name[:-6] + ".kt"  # Replace .swift with .kt
        kotlin_path = f"walletlibrary/src/main/java/com/microsoft/walletlibrary/{kotlin_name}"
        print(f"Using inferred path: {kotlin_path}")
    
    # Convert Swift to Kotlin
    kotlin_content = convert_swift_to_kotlin(swift_content, kotlin_path)
    
    # Print the result
    print("\n" + "=" * 80)
    print(f"CONVERTED: {swift_file} -> {kotlin_path}")
    print("=" * 80 + "\n")
    print(kotlin_content)
    
    # Optionally save the result
    save_result = input("\nSave the result to a file? (y/n): ").lower()
    if save_result == "y":
        output_file = input(f"Enter output file path (default: {kotlin_path}): ")
        if not output_file:
            output_file = kotlin_path
        
        # Create directories if they don't exist
        os.makedirs(os.path.dirname(output_file), exist_ok=True)
        
        # Write the Kotlin file
        with open(output_file, "w") as f:
            f.write(kotlin_content)
        
        print(f"Saved to {output_file}")

if __name__ == "__main__":
    main()
