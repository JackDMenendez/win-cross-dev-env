#!/bin/bash
# export-vscode-extensions.sh - Export the current VS Code extension manifest to a file for reproducibility.

set -euo pipefail

# Default to current directory if not specified
TARGET_REPO="${1:-.}"

# Resolve to absolute path
if [[ "$TARGET_REPO" != /* ]]; then
    TARGET_REPO="$(cd "$TARGET_REPO" && pwd)"
fi

# Verify the target is a directory
if [[ ! -d "$TARGET_REPO" ]]; then
    echo "Error: Target repository not found: $TARGET_REPO" >&2
    exit 1
fi

# Create .vscode directory if it doesn't exist
VSCODE_DIR="$TARGET_REPO/.vscode"
mkdir -p "$VSCODE_DIR"

# Check if code command is available
if ! command -v code >/dev/null 2>&1; then
    echo "Error: VS Code 'code' command not found in PATH." >&2
    echo "Make sure VS Code is installed and added to your PATH." >&2
    exit 1
fi

# Export extensions with versions
EXTENSIONS_FILE="$VSCODE_DIR/extensions.txt"
echo "Exporting VS Code extensions to $EXTENSIONS_FILE..."
code --list-extensions --show-versions > "$EXTENSIONS_FILE"

if [[ ! -s "$EXTENSIONS_FILE" ]]; then
    echo "Warning: No extensions found or extensions list is empty."
fi

# Count extensions
EXTENSION_COUNT=$(wc -l < "$EXTENSIONS_FILE")
echo "✓ Exported $EXTENSION_COUNT extensions"

echo ""
echo "Extension list saved to: $EXTENSIONS_FILE"
echo ""
echo "To restore extensions from this file:"
echo "  cat $EXTENSIONS_FILE | xargs -n 1 code --install-extension"
echo ""
echo "Or commit the file for project release:"
echo "  git add $EXTENSIONS_FILE"
echo "  git commit -m 'Freeze VS Code extensions for reproducible development'"
