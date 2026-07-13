#!/bin/bash
set -e

FILE="attestations/provenance.json"

echo "🔍 Validating SLSA provenance predicate..."

# Check file exists
if [ ! -f "$FILE" ]; then
  echo "❌ File not found: $FILE"
  echo "💡 Generate it with: ./scripts/generate-provenance.sh supply-chain-app:latest"
  exit 1
fi

# Validate JSON syntax
if ! jq empty "$FILE" 2>/dev/null; then
  echo "❌ Invalid JSON syntax in $FILE"
  exit 1
fi

# Check required predicate fields (this is a SLSA predicate, not a full in-toto statement)
BUILDER_ID=$(jq -r '.runDetails.builder.id // empty' "$FILE")
if [ -z "$BUILDER_ID" ]; then
  echo "❌ Missing builder.id"
  exit 1
fi

STARTED_ON=$(jq -r '.runDetails.metadata.startedOn // empty' "$FILE")
if [ -z "$STARTED_ON" ]; then
  echo "❌ Missing metadata.buildStartedOn"
  exit 1
fi

FINISHED_ON=$(jq -r '.runDetails.metadata.finishedOn // empty' "$FILE")
if [ -z "$FINISHED_ON" ]; then
  echo "❌ Missing metadata.buildFinishedOn"
  exit 1
fi

# Check materials exist
MATERIALS_COUNT=$(jq '.buildDefinition.resolvedDependencies | length' "$FILE")
if [ "$MATERIALS_COUNT" -eq 0 ]; then
  echo "❌ No materials found in provenance"
  exit 1
fi

echo "✅ SLSA provenance predicate is valid"
echo "   Builder: $BUILDER_ID"
echo "   Materials: $MATERIALS_COUNT"
