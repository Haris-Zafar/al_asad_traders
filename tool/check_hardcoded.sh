#!/usr/bin/env bash
set -e

# Checks for hardcoded values in lib/ outside lib/core/theme/ and lib/core/strings.dart
# Fails if lib/ outside lib/core/theme/ and lib/core/strings.dart contains:
# Color(0x, Colors., fontSize:, EdgeInsets with numbers, or Text('

ERRORS=0

# Find dart files in lib excluding lib/core/theme/* and lib/core/strings.dart
TARGET_FILES=$(find lib -type f -name "*.dart" ! -path "lib/core/theme/*" ! -path "lib/core/strings.dart" 2>/dev/null || true)

if [ -z "$TARGET_FILES" ]; then
  echo "No target dart files found to check."
  exit 0
fi

echo "Checking for hardcoded design/string values in lib/..."

FOUND_COLOR=$(grep -rn "Color(0x" $TARGET_FILES || true)
if [ -n "$FOUND_COLOR" ]; then
  echo "Error: Hardcoded Color(0x found:"
  echo "$FOUND_COLOR"
  ERRORS=$((ERRORS + 1))
fi

FOUND_COLORS=$(grep -rn "Colors\." $TARGET_FILES || true)
if [ -n "$FOUND_COLORS" ]; then
  echo "Error: Hardcoded Colors. found:"
  echo "$FOUND_COLORS"
  ERRORS=$((ERRORS + 1))
fi

FOUND_FONT_SIZE=$(grep -rn "fontSize:" $TARGET_FILES || true)
if [ -n "$FOUND_FONT_SIZE" ]; then
  echo "Error: Hardcoded fontSize: found:"
  echo "$FOUND_FONT_SIZE"
  ERRORS=$((ERRORS + 1))
fi

FOUND_EDGE_INSETS=$(grep -rnE "EdgeInsets\.[a-zA-Z]+\(.*[0-9]" $TARGET_FILES || true)
if [ -n "$FOUND_EDGE_INSETS" ]; then
  echo "Error: Hardcoded numeric EdgeInsets found:"
  echo "$FOUND_EDGE_INSETS"
  ERRORS=$((ERRORS + 1))
fi

FOUND_TEXT_LITERAL=$(grep -rnE "Text\('" $TARGET_FILES || true)
if [ -n "$FOUND_TEXT_LITERAL" ]; then
  echo "Error: Hardcoded Text(' string literal found:"
  echo "$FOUND_TEXT_LITERAL"
  ERRORS=$((ERRORS + 1))
fi

if [ $ERRORS -ne 0 ]; then
  echo "Hardcoded check failed with $ERRORS violations."
  exit 1
else
  echo "Hardcoded check passed!"
  exit 0
fi
