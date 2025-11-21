#!/bin/bash
# Post-specialist verification hook
# Runs after Task tool call completes

echo ""
echo "✅ Specialist Task Completed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 Moderator Responsibilities:"
echo ""
echo "  1. Verify specialist created required files:"
echo "     - conversations/<specialist>_roundN_full.md"
echo "     - conversations/<specialist>_roundN_summary.md"
echo ""
echo "  2. Check file quality:"
echo "     - Full transcript: >100 words minimum"
echo "     - Summary: <200 words maximum"
echo "     - Key points: 3-5 bullets"
echo ""
echo "  3. Update metadata.json with consultation record"
echo ""
echo "  4. If files missing: Re-invoke specialist with explicit reminder"
echo ""
echo "  5. Use TodoWrite to track progress"
echo ""

exit 0
