#!/bin/bash

OUT="asset_pipeline/lib_versions.md"
DATE=$(date +%Y-%m-%d)

echo "🔄 Updating Git subtrees..."

# Safety check: abort if working tree is dirty
if ! git diff-index --quiet HEAD --; then
    echo "❌ Working tree not clean. Commit or stash changes before running."
    exit 1
fi

# 3DreamEngine core
echo "→ 3DreamEngine (core)"
git fetch 3DreamEngine
git subtree pull --prefix=3DreamEngine 3DreamEngine master --squash
HASH_CORE=$(git log -1 --pretty=format:"%h" -- 3DreamEngine)

# 3DreamEngine extensions
echo "→ 3DreamEngine (extensions)"
git subtree pull --prefix=extensions 3DreamEngine master --squash
HASH_EXT=$(git log -1 --pretty=format:"%h" -- extensions)

# Now regenerate the report file AFTER successful pulls
echo "# 📚 Library Versions" > "$OUT"
echo "Last updated: $DATE" >> "$OUT"
echo "" >> "$OUT"

echo "## 3DreamEngine (Core)" >> "$OUT"
echo "- 📌 Commit: $HASH_CORE ($DATE)" >> "$OUT"
echo "- 🗂️ Path: 3DreamEngine/" >> "$OUT"
echo "" >> "$OUT"

echo "## 3DreamEngine (Extensions)" >> "$OUT"
echo "- 📌 Commit: $HASH_EXT ($DATE)" >> "$OUT"
echo "- 🗂️ Path: extensions/" >> "$OUT"
echo "" >> "$OUT"

echo "✅ All subtrees updated and version log written to $OUT"
