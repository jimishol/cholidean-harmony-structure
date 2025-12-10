#!/bin/bash

OUT="asset_pipeline/lib_versions.md"
DATE=$(date +%Y-%m-%d)

echo "🔄 Updating Git subtrees with read-tree..."

# Safety check: abort if working tree is dirty
if ! git diff-index --quiet HEAD --; then
    echo "❌ Working tree not clean. Commit or stash changes before running."
    exit 1
fi

# Core update
echo "→ 3DreamEngine (core)"
git fetch 3DreamEngine master
git read-tree --prefix=3DreamEngine/ -u 3DreamEngine/master:3DreamEngine
git commit -m "Update 3DreamEngine core subtree"
HASH_CORE=$(git log -1 --pretty=format:"%h" -- 3DreamEngine)

# Extensions update
echo "→ 3DreamEngine (extensions)"
git fetch 3DreamEngine master
git read-tree --prefix=extensions/ -u 3DreamEngine/master:extensions
git commit -m "Update 3DreamEngine extensions subtree"
HASH_EXT=$(git log -1 --pretty=format:"%h" -- extensions)

# Report file
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
