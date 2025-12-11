#!/bin/bash

OUT="asset_pipeline/lib_versions.md"
DATE=$(date +%Y-%m-%d)

echo "📝 Documenting subtree versions..."
echo "# 📚 Library Versions" > "$OUT"
echo "Last updated: $DATE" >> "$OUT"
echo "" >> "$OUT"

# Core
HASH_CORE=$(git log -1 --pretty=format:"%h" -- 3DreamEngine)
echo "## 3DreamEngine (Core)" >> "$OUT"
echo "- 📌 Commit: $HASH_CORE ($DATE)" >> "$OUT"
echo "- 🗂️ Path: 3DreamEngine/" >> "$OUT"
echo "" >> "$OUT"

# Extensions
HASH_EXT=$(git log -1 --pretty=format:"%h" -- extensions)
echo "## 3DreamEngine (Extensions)" >> "$OUT"
echo "- 📌 Commit: $HASH_EXT ($DATE)" >> "$OUT"
echo "- 🗂️ Path: extensions/" >> "$OUT"
echo "" >> "$OUT"

echo "✅ Version log written to $OUT"
