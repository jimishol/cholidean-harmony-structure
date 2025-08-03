#!/bin/bash

OUT="asset_pipeline/lib_versions.md"
DATE=$(date +%Y-%m-%d)

echo "🔄 Updating Git subtrees..."
echo "# 📚 Library Versions" > "$OUT"
echo "Last updated: $DATE" >> "$OUT"
echo "" >> "$OUT"

# 3DreamEngine core
echo "→ 3DreamEngine (core)"
git fetch 3DreamEngine
git subtree pull --prefix=3DreamEngine/3DreamEngine 3DreamEngine master --squash
HASH=$(git log -1 --pretty=format:"%h" 3DreamEngine/3DreamEngine)
echo "## 3DreamEngine (Core)" >> "$OUT"
echo "- 📌 Commit: $HASH ($DATE)" >> "$OUT"
echo "- 🗂️ Path: 3DreamEngine/3DreamEngine/" >> "$OUT"
echo "" >> "$OUT"

# 3DreamEngine extensions
echo "→ 3DreamEngine (extensions)"
git subtree pull --prefix=3DreamEngine/extensions 3DreamEngine master --squash
HASH=$(git log -1 --pretty=format:"%h" 3DreamEngine/extensions)
echo "## 3DreamEngine (Extensions)" >> "$OUT"
echo "- 📌 Commit: $HASH ($DATE)" >> "$OUT"
echo "- 🗂️ Path: 3DreamEngine/extensions/" >> "$OUT"
echo "" >> "$OUT"

echo "✅ All subtrees updated and version log written to $OUT"
