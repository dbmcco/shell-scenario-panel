#!/bin/bash
# Validate scenario completeness and quality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCENARIO_ID=$1
MIN_WORDS=100

if [ -z "$SCENARIO_ID" ]; then
    echo "Usage: $0 SCENARIO-YYYY-NNN"
    exit 1
fi

SCENARIO_DIR="scenarios/active/$SCENARIO_ID"

if [ ! -d "$SCENARIO_DIR" ]; then
    echo -e "${RED}✗ Scenario directory not found: $SCENARIO_DIR${NC}"
    exit 1
fi

echo "🔍 Validating scenario: $SCENARIO_ID"
echo ""

ERRORS=0
WARNINGS=0

# Function to count words in a file
count_words() {
    if [ -f "$1" ]; then
        wc -w < "$1" | tr -d ' '
    else
        echo "0"
    fi
}

# Function to check if file exists and has minimum words
check_transcript() {
    local file=$1
    local description=$2

    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing: $description${NC}"
        echo "  Expected: $file"
        ((ERRORS++))
        return 1
    fi

    local word_count=$(count_words "$file")

    if [ "$word_count" -lt "$MIN_WORDS" ]; then
        echo -e "${YELLOW}⚠ Insufficient content: $description${NC}"
        echo "  File: $file"
        echo "  Words: $word_count (minimum: $MIN_WORDS)"
        ((WARNINGS++))
        return 1
    fi

    echo -e "${GREEN}✓ Valid: $description ($word_count words)${NC}"
    return 0
}

# Optional transcript check (warns instead of errors)
check_optional_transcript() {
    local file=$1
    local description=$2

    if [ ! -f "$file" ]; then
        echo -e "${YELLOW}⚠ Missing (optional): $description${NC}"
        echo "  Expected: $file"
        ((WARNINGS++))
        return 1
    fi

    local word_count=$(count_words "$file")

    if [ "$word_count" -lt "$MIN_WORDS" ]; then
        echo -e "${YELLOW}⚠ Insufficient content: $description${NC}"
        echo "  File: $file"
        echo "  Words: $word_count (minimum: $MIN_WORDS)"
        ((WARNINGS++))
        return 1
    fi

    echo -e "${GREEN}✓ Valid: $description ($word_count words)${NC}"
    return 0
}

# Check metadata.json exists
echo "━━━ Metadata Validation ━━━"
METADATA_FILE="$SCENARIO_DIR/metadata.json"

if [ ! -f "$METADATA_FILE" ]; then
    echo -e "${RED}✗ metadata.json not found${NC}"
    ((ERRORS++))
else
    echo -e "${GREEN}✓ metadata.json exists${NC}"

    # Validate JSON structure
    if ! jq empty "$METADATA_FILE" 2>/dev/null; then
        echo -e "${RED}✗ metadata.json is not valid JSON${NC}"
        ((ERRORS++))
    else
        echo -e "${GREEN}✓ metadata.json is valid JSON${NC}"

        # Check required fields
        SCENARIO_ID_IN_META=$(jq -r '.scenario_id // ""' "$METADATA_FILE")
        PHASE=$(jq -r '.phase // ""' "$METADATA_FILE")
        STATUS=$(jq -r '.status // ""' "$METADATA_FILE")

        if [ "$SCENARIO_ID_IN_META" != "$SCENARIO_ID" ]; then
            echo -e "${YELLOW}⚠ scenario_id mismatch: expected $SCENARIO_ID, got $SCENARIO_ID_IN_META${NC}"
            ((WARNINGS++))
        fi

        if [ -z "$PHASE" ]; then
            echo -e "${YELLOW}⚠ phase not set in metadata${NC}"
            ((WARNINGS++))
        else
            echo "  Phase: $PHASE"
        fi

        if [ -z "$STATUS" ]; then
            echo -e "${YELLOW}⚠ status not set in metadata${NC}"
            ((WARNINGS++))
        else
            echo "  Status: $STATUS"
        fi
    fi
fi

echo ""

# Check consultations in metadata
echo "━━━ Consultation Records ━━━"
if [ -f "$METADATA_FILE" ]; then
    CONSULTATION_COUNT=$(jq '.consultations | length' "$METADATA_FILE" 2>/dev/null || echo "0")
    echo "Total consultations recorded: $CONSULTATION_COUNT"

    if [ "$CONSULTATION_COUNT" -gt 0 ]; then
        # Verify each consultation has corresponding transcript
        jq -r '.consultations[] | "\(.specialist)|\(.transcript_path)"' "$METADATA_FILE" 2>/dev/null | while IFS='|' read -r specialist transcript_path; do
            full_path="$SCENARIO_DIR/$transcript_path"
            if [ -f "$full_path" ]; then
                word_count=$(count_words "$full_path")
                if [ "$word_count" -ge "$MIN_WORDS" ]; then
                    echo -e "${GREEN}✓ $specialist: $word_count words${NC}"
                else
                    echo -e "${YELLOW}⚠ $specialist: only $word_count words (min: $MIN_WORDS)${NC}"
                    ((WARNINGS++))
                fi
            else
                echo -e "${RED}✗ Missing transcript: $specialist${NC}"
                echo "  Expected: $full_path"
                ((ERRORS++))
            fi
        done
    fi
fi

echo ""

# Check phase documents
echo "━━━ Phase Documents ━━━"

# Phase 0: Worldview Model
check_transcript "$SCENARIO_DIR/worldview_model.md" "Worldview Model (Phase 0)"

# Phase 0a: Internal Baseline
check_transcript "$SCENARIO_DIR/phase_0_discovery/internal_baseline.md" "Internal Baseline (Phase 0a)"

# Phase 0b: Context Packet
check_optional_transcript "$SCENARIO_DIR/phase_0_discovery/context_packet.md" "Context Packet (Phase 0b)"

# Phase 1: Focal Question
check_transcript "$SCENARIO_DIR/focal_question.md" "Focal Question (Phase 1)"

# Phase 2: Predetermined Elements
check_transcript "$SCENARIO_DIR/predetermined_elements.md" "Predetermined Elements (Phase 2)"

# Phase 3: Critical Uncertainties
check_transcript "$SCENARIO_DIR/critical_uncertainties.md" "Critical Uncertainties (Phase 3)"

# Phase 4: Scenarios
if [ -d "$SCENARIO_DIR/scenarios" ]; then
    SCENARIO_COUNT=$(find "$SCENARIO_DIR/scenarios" -name "scenario_*.md" | wc -l | tr -d ' ')
    if [ "$SCENARIO_COUNT" -ge 4 ]; then
        echo -e "${GREEN}✓ Scenario narratives: $SCENARIO_COUNT scenarios${NC}"
    elif [ "$SCENARIO_COUNT" -gt 0 ]; then
        echo -e "${YELLOW}⚠ Only $SCENARIO_COUNT scenarios (target: 4)${NC}"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠ No scenarios directory found${NC}"
fi

# Phase 5: Early Warning Signals (embedded in scenarios)
# Phase 6a: Impact Analysis
if [ -f "$SCENARIO_DIR/impact_analysis.md" ]; then
    check_transcript "$SCENARIO_DIR/impact_analysis.md" "Impact Analysis (Phase 6a)"
fi

# Phase 6: Strategy Analysis
if [ -f "$SCENARIO_DIR/strategy_analysis.md" ]; then
    check_transcript "$SCENARIO_DIR/strategy_analysis.md" "Strategy Analysis (Phase 6b/7)"
fi

# Phase 7/8: Worldview Integration
if [ -f "$SCENARIO_DIR/worldview_integration.md" ]; then
    check_transcript "$SCENARIO_DIR/worldview_integration.md" "Worldview Integration (Final Phase)"
fi

echo ""

# Check for orphaned transcripts (not in metadata)
echo "━━━ Orphaned Files Check ━━━"
if [ -d "$SCENARIO_DIR/conversations" ]; then
    ORPHANED_COUNT=0

    for transcript in "$SCENARIO_DIR/conversations"/*.md; do
        if [ -f "$transcript" ]; then
            transcript_name=$(basename "$transcript")
            relative_path="conversations/$transcript_name"

            # Check if this transcript is referenced in metadata
            if [ -f "$METADATA_FILE" ]; then
                if jq -e ".consultations[] | select(.transcript_path == \"$relative_path\")" "$METADATA_FILE" > /dev/null 2>&1; then
                    # Found in metadata, skip
                    continue
                else
                    echo -e "${YELLOW}⚠ Orphaned transcript: $transcript_name${NC}"
                    echo "  Not referenced in metadata.json"
                    ((ORPHANED_COUNT++))
                    ((WARNINGS++))
                fi
            fi
        fi
    done

    if [ "$ORPHANED_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ No orphaned transcripts${NC}"
    fi
fi

echo ""

# Summary
echo "━━━ Validation Summary ━━━"
if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation completed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    exit 1
fi
