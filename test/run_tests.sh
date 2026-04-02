#!/bin/bash
# Run Jest SDK GUT tests headless
# Requires: Godot 4.x in PATH, GUT addon installed in addons/gut/
#
# Usage:
#   ./test/run_tests.sh
#   GODOT_BIN=/path/to/godot ./test/run_tests.sh

set -e

GODOT_BIN="${GODOT_BIN:-godot}"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Running Jest SDK tests..."
echo "Project: $PROJECT_DIR"
echo "Godot: $GODOT_BIN"

# Check GUT is installed
if [ ! -d "$PROJECT_DIR/addons/gut" ]; then
    echo "ERROR: GUT addon not found at addons/gut/"
    echo "Install GUT: https://github.com/bitwes/Gut"
    echo "  1. Download from Godot AssetLib or GitHub releases"
    echo "  2. Copy addons/gut/ into this project's addons/ directory"
    exit 1
fi

# Run tests headless
"$GODOT_BIN" --headless --path "$PROJECT_DIR" -s addons/gut/gut_cmdln.gd -gexit 2>&1

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "All tests passed!"
else
    echo "Tests failed with exit code $EXIT_CODE"
fi

exit $EXIT_CODE
