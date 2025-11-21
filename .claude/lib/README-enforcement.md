# File Placement Enforcement System

## Problem

Relying on prompts to tell specialists where to create files is unreliable. Specialists may:
- Create files in wrong locations
- Use incorrect filenames
- Skip file creation entirely
- Create undersized files

## Solution: Programmatic Enforcement

Three-layer enforcement system:

### Layer 1: Explicit Path Generation

**Script:** `.claude/lib/generate-specialist-prompt.sh`

Generates specialist invocation with EXACT file paths pre-calculated.

**Usage in moderator:**
```bash
PROMPT=$(.claude/lib/generate-specialist-prompt.sh \
    SCENARIO-2025-001 \
    phase_2 \
    1 \
    economist \
    "Identify predetermined economic elements")

# Then invoke specialist with $PROMPT
Task("economist", "$PROMPT")
```

**Output includes:**
- Exact file paths specialist must create
- File requirements (word counts, formats)
- Warning that validation will check these paths

### Layer 2: Post-Invocation Validation

**Script:** `.claude/lib/validate-specialist-output.sh`

Validates files after specialist returns.

**Usage in moderator:**
```bash
# After specialist invocation completes
VALIDATION_RESULT=$(.claude/lib/validate-specialist-output.sh \
    SCENARIO-2025-001 \
    phase_2 \
    1 \
    economist)

if [ $? -ne 0 ]; then
    # Validation failed - re-invoke specialist
    echo "Validation failed. Re-invoking with explicit reminder."
fi
```

**Checks:**
- All expected files exist
- Files are at correct paths
- Files meet minimum size (500 bytes ≈ 100 words)
- Returns detailed error report if validation fails

### Layer 3: Blocking Progression

**Moderator workflow:**
1. Generate prompt with explicit paths
2. Invoke specialist
3. Validate output
4. **If validation fails: BLOCK progression**
   - Do NOT synthesize
   - Do NOT present to user
   - Re-invoke specialist immediately
5. Only proceed after validation passes

## File Path Registry

**Script:** `.claude/lib/file-paths.sh`

Centralized registry of all expected file paths by phase/round/specialist.

**Functions:**
- `get_specialist_paths SCENARIO_ID PHASE ROUND SPECIALIST` - Returns expected transcript paths
- `get_phase_outputs SCENARIO_ID PHASE` - Returns expected phase synthesis outputs

**Supported phases:**
- `phase_0_discovery` - Discovery transcripts in `phase_0_discovery/research/`
- `phase_2` / `predetermined` - Full + summary in `conversations/`
- `phase_3` / `uncertainties` - Full + summary in `conversations/`
- `phase_4` / `scenarios` - Full + summary (rounds 1-2), final only (round 3)
- `phase_5` / `signals` - Signals file in `conversations/`
- `phase_6` / `strategy` - Strategy file in `conversations/`

## Integration with Moderator

### Current Pattern (Unreliable)
```
Moderator → Task("specialist", "Create file at path X") → Hope it works
```

### New Pattern (Enforced)
```
Moderator → Generate paths
         → Task("specialist", paths)
         → Validate files
         → [PASS] Continue
         → [FAIL] Re-invoke with reminder
```

### Example Moderator Workflow

```bash
# 1. Generate explicit prompt
SCENARIO_ID="SCENARIO-2025-001"
PHASE="phase_2"
ROUND="1"
SPECIALIST="economist"

PROMPT=$(.claude/lib/generate-specialist-prompt.sh \
    "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST" \
    "Identify predetermined economic elements from your domain.")

# 2. Invoke specialist
Task("economist", "$PROMPT")

# 3. Validate output
if ! .claude/lib/validate-specialist-output.sh "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST"; then
    # Validation failed
    echo "❌ Validation failed for economist. Re-invoking with explicit reminder."

    # Get the exact paths that were expected
    EXPECTED=$(.claude/lib/file-paths.sh get_specialist_paths "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST")

    # Re-invoke with strong reminder
    Task("economist", "CRITICAL: Your previous response did not create required files.

You MUST create these EXACT files:
$EXPECTED

Please recreate your analysis and ensure these files exist.")

    # Validate again (only retry once)
    .claude/lib/validate-specialist-output.sh "$SCENARIO_ID" "$PHASE" "$ROUND" "$SPECIALIST"
fi

# 4. Only proceed if validation passed
echo "✅ Validation passed. Proceeding to synthesis."
```

## Benefits

1. **Deterministic paths** - No ambiguity about where files go
2. **Automatic validation** - Catch missing/incorrect files immediately
3. **Blocking behavior** - Can't proceed with bad data
4. **Clear error messages** - Tells specialist exactly what's missing
5. **One retry** - Give specialist one chance to fix, then escalate

## Limitations

1. **Specialist must still cooperate** - Scripts can't force file creation, only validate
2. **One-shot validation** - Checks at completion, not during execution
3. **Size heuristic** - 500 bytes is approximate, not true word count
4. **No content validation** - Checks existence/size, not quality

## Future Enhancements

1. **Template enforcement** - Provide empty templates specialists fill in
2. **Streaming validation** - Check files as they're created
3. **Content structure validation** - Check for required sections/headers
4. **Automated correction** - Move misplaced files to correct locations
5. **Sandbox execution** - Run specialists in environments that only allow writing to specific paths
