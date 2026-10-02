# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# VALIDATION & COMPLIANCE
#
# Imported by ../../Justfile via `import? "build/just/validate.just"`.
# Recipes here check that this repo conforms to the RSR (Rhodium Standard
# Repository) skeleton: required files, METAdata, AI install guide
# completeness, etc. Run via `just validate`.

# Validate RSR compliance
validate-rsr:
    #!/usr/bin/env bash
    cd "{{justfile_directory()}}"
    echo "=== RSR Compliance Check ==="
    MISSING=""
    for f in .editorconfig .gitignore Justfile README.adoc LICENSE; do
        [ -f "$f" ] || MISSING="$MISSING $f"
    done
    # The repo deed's filename carries the repo slug (<stem>_chora.deed), so
    # this is a glob. It is the single machine-readable record of the repo.
    ls *_chora.deed >/dev/null 2>&1 || MISSING="$MISSING repo-deed (*_chora.deed)"
    for f in docs/legal/EXHIBIT-A-ETHICAL-USE.txt docs/legal/EXHIBIT-B-QUANTUM-SAFE.txt LICENSES/MPL-2.0.txt; do
        [ -f "$f" ] || MISSING="$MISSING $f"
    done
    if [ ! -d "src/interface/abi" ] && [ ! -d "src/interface/Abi" ]; then
        MISSING="$MISSING src/interface/abi"
    fi
    for f in src/interface/ffi src/interface/generated; do
        [ -d "$f" ] || MISSING="$MISSING $f"
    done
    CHECKLIST=docs/governance/MAINTENANCE-CHECKLIST.adoc
    APPROACH=docs/governance/SOFTWARE-DEVELOPMENT-APPROACH.adoc
    for f in "$CHECKLIST" "$APPROACH"; do
        [ -f "$f" ] || MISSING="$MISSING $f"
    done
    # The three maintenance axes are stated in the governance documents.
    if [ -f "$CHECKLIST" ]; then
        grep -q 'must > intend > like' "$CHECKLIST" || MISSING="$MISSING MAINTENANCE-CHECKLIST:axis-1"
        grep -q 'corrective > adaptive > perfective' "$CHECKLIST" || MISSING="$MISSING MAINTENANCE-CHECKLIST:axis-2"
        grep -q 'systems > compliance > effects' "$CHECKLIST" || MISSING="$MISSING MAINTENANCE-CHECKLIST:axis-3"
        grep -q 'Axis 1 Scoping Pass' "$CHECKLIST" || MISSING="$MISSING MAINTENANCE-CHECKLIST:scoping-first"
        grep -q 'panic-attack' "$CHECKLIST" || MISSING="$MISSING MAINTENANCE-CHECKLIST:compliance-tooling"
    fi
    if [ -f "$APPROACH" ]; then
        grep -q 'believe_me' "$APPROACH" || MISSING="$MISSING SOFTWARE-DEVELOPMENT-APPROACH:idris-unsound-scan"
        grep -q 'sustainabot' "$APPROACH" || MISSING="$MISSING SOFTWARE-DEVELOPMENT-APPROACH:effects-tooling"
    fi
    if [ -n "$MISSING" ]; then
        echo "MISSING:$MISSING"
        exit 1
    fi
    echo "RSR compliance: PASS"

# Check the repo deed carries a schema version and a status phase
validate-state:
    @cd "{{justfile_directory()}}" && f=$(ls *_chora.deed 2>/dev/null | head -1); \
        if [ -z "$f" ]; then echo "FAIL: no repo deed (*_chora.deed)" >&2; exit 1; fi; \
        grep -q ':schema-version "' "$f" && grep -qE '^ *:phase [a-z]' "$f" \
        && echo "$f: schema-version and phase present" \
        || { echo "FAIL: $f lacks :schema-version or a status :phase" >&2; exit 1; }

# Validate AI installation guide completeness (finishbot pre-release check)
validate-ai-install:
    #!/usr/bin/env bash
    cd "{{justfile_directory()}}"
    echo "=== AI Installation Guide Check ==="
    GUIDE="docs/AI_INSTALLATION_GUIDE.adoc"
    README="README.adoc"
    ERRORS=0

    # Check guide exists
    if [ ! -f "$GUIDE" ]; then
        echo "MISSING: $GUIDE (create from template: docs/AI_INSTALLATION_GUIDE.adoc)"
        ERRORS=$((ERRORS + 1))
    else
        # Check for unfilled TODO markers
        TODOS=$(grep -c '\[TODO-AI-INSTALL' "$GUIDE" 2>/dev/null || true)
        if [ "$TODOS" -gt 0 ]; then
            echo "INCOMPLETE: $GUIDE has $TODOS unfilled [TODO-AI-INSTALL] markers:"
            grep -n '\[TODO-AI-INSTALL' "$GUIDE" | head -10
            ERRORS=$((ERRORS + 1))
        else
            echo "$GUIDE: complete (no TODO markers)"
        fi

        # Check AI implementation section exists
        if ! grep -q 'ai-implementation' "$GUIDE" 2>/dev/null; then
            echo "MISSING: [[ai-implementation]] anchor in $GUIDE"
            ERRORS=$((ERRORS + 1))
        fi

        # Check privacy notice exists
        if ! grep -qi 'privacy' "$GUIDE" 2>/dev/null; then
            echo "MISSING: Privacy notice in $GUIDE"
            ERRORS=$((ERRORS + 1))
        fi

        # Check install commands exist (not just placeholders)
        if ! grep -q 'git clone' "$GUIDE" 2>/dev/null; then
            echo "WARNING: No git clone command found in $GUIDE -- install commands may be incomplete"
        fi
    fi

    # Check README has AI install section
    if [ -f "$README" ]; then
        if ! grep -qi 'AI-Assisted Installation' "$README" 2>/dev/null; then
            echo "MISSING: AI-Assisted Installation section in $README"
            echo "  Copy from docs/AI-INSTALL-README-SECTION.adoc"
            ERRORS=$((ERRORS + 1))
        fi

        # Check README for unfilled TODO markers
        README_TODOS=$(grep -c '\[TODO-AI-INSTALL' "$README" 2>/dev/null || true)
        if [ "$README_TODOS" -gt 0 ]; then
            echo "INCOMPLETE: $README has $README_TODOS unfilled [TODO-AI-INSTALL] markers"
            ERRORS=$((ERRORS + 1))
        fi
    fi

    # The rest of the provisioning set's AI and manual-setup documents. Their
    # locations come from the provisioning engine, so this check and `just doctor`
    # agree on where the warm-ups live (root, docs/onboarding/ or docs/).
    if [ -f build/just/provision-lib.sh ]; then
        for d in $(bash build/just/provision-lib.sh set-files | grep -E '(^|/)(SETUP|llm-warmup-[a-z]+)\.adoc$'); do
            if [ ! -f "$d" ]; then
                echo "MISSING: $d"
                ERRORS=$((ERRORS + 1))
            fi
        done
        if ! grep -q '^\[\[ai-install\]\]' "$README" 2>/dev/null; then
            echo "MISSING: [[ai-install]] anchor in $README (see build/just/provision.just ai-setup)"
            ERRORS=$((ERRORS + 1))
        fi
    fi

    if [ "$ERRORS" -gt 0 ]; then
        echo ""
        echo "AI install guide: FAIL ($ERRORS issues)"
        exit 1
    fi
    echo "AI install guide: PASS"

# Full validation suite
validate: validate-rsr validate-state validate-ai-install
    @echo "All validations passed!"

# Check for template placeholders that haven't been replaced
verify-template:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Checking for unreplaced template placeholders..."
    FOUND=0

    # Check for double-brace placeholder patterns
    HITS=$(grep -rn '{{'{{'}}[A-Z_]*{{'}}'}}' --include="*.adoc" --include="*.md" --include="*.deed" \
           --include="*.scm" --include="*.toml" --include="*.yml" --include="*.yaml" \
           . 2>/dev/null | grep -v 'node_modules\|\.git/' | grep -v 'PLACEHOLDERS.adoc' || true)
    if [ -n "$HITS" ]; then
        echo ""
        echo "⚠ Unreplaced placeholders found:"
        echo "$HITS" | head -20
        FOUND=1
    fi

    # Check for template defaults still present
    if grep -q 'ZeroInflatedCounts.jl' Justfile 2>/dev/null; then
        echo "⚠ Justfile still references 'ZeroInflatedCounts.jl' — update project name"
        FOUND=1
    fi

    # Check the repo deed and the praxis deed for unreplaced placeholders
    for f in *_chora.deed .machine_readable/descriptiles/*_praxis.deed; do
        if [ -f "$f" ] && grep -q '{{'{{'}}' "$f" 2>/dev/null; then
            echo "⚠ $f still has template placeholders"
            FOUND=1
        fi
    done

    if [ $FOUND -eq 0 ]; then
        echo "✓ No template placeholders found — project is properly customised."
    else
        echo ""
        echo "Replace the placeholders by hand."
        exit 1
    fi
