# 💡 Developer Integration Guide

This file outlines the geometric modeling pipeline, asset preparation steps, and Git subtree integrations used to build the **Cholidean Harmony Structure** — a spatial-musical framework rendered in Love2D using 3DreamEngine.

---

## 🧭 Geometry Design Pipeline

### Overview

This project visualizes harmonic relationships in 12-tone equal temperament (12ET) using parametric 3D geometry and dynamic rendering. Geometry generation and refinement are handled with OpenSCAD, MeshLab, Blender, and finally consumed by Love2D.

### Workflow

1. ✳️ **OpenSCAD**  
   - Scripts: `main.scad`, `prims.scad`  
   - Models parametric dodecahedra, joints, ribbon surfaces, and curves arranged in a toroidal helix.

2. 🎛️ **Export**  
   - Use `export_tones_and_surfaces.sh` to batch export `.stl` files.

3. 🧽 **MeshLab**  
   - Apply smoothing using `smoothing_objects.mlx` script.

4. 🎨 **Blender**  
   - Import `.obj` files (`Up Axis: Z`)  
   - Assign materials & HDRI (from [ambientCG](https://ambientcg.com/))  
   - Use `.hdr` backgrounds (converted from `.exr` via GIMP)  
   - For normals, `.png` files are used with `Roughness = 1`  
   - Export `.obj` files (`Up Axis: Y`)  
   - **Final Renaming for 3DreamEngine Compatibility:**  
     To allow correct asset linking and indexing inside the engine, all objects were renamed based on their tonal label following the **circle of perfect fourths**:
     ```
     joints_C      → joint_00
     edges_F       → edge_01
     curves_Bb     → curve_02
     surfaces_Eb   → surface_03
     ...
     ```
     This mapping continues cyclically for all 12 tones, assigning suffixes `00–11` and preserving type prefixes (`joint_`, `edge_`, `curve_`, `surface_`).
     Materials in textures/ subfolder of blender is copied in assets/materials_gl/materials/ subfolder and renamed accordingly with the exception that ...Color.png renamed as albedo.png

5. 🎮 **Love2D + 3DreamEngine**  
   - Load processed models and render with real-time shading and interactive behavior.

---

## 🎶 Harmony Structure Notes

- Each tone represented by a **dodecahedron** on a toroidal helix (Circle of Fourths)
- **Modulatory pathways** represented by curves and edges
- Entire system is parametric and customizable

Learn more about the theory at [Cholidean Harmony Structure blog post](https://jimishol.github.io/post/tonality/)

---

## 📦 Git Subtree Integrations

To keep the project self‑contained and updatable, key third‑party libraries are included using Git subtrees.

---

### 3DreamEngine

**🗂️ Paths:**

- Core: `3DreamEngine/3DreamEngine/`
- Extensions: `3DreamEngine/extensions/`

---

#### 1. **Initial Integration (Core)**

```bash
git remote add -f 3DreamEngine https://github.com/3dreamengine/3DreamEngine.git
git fetch 3DreamEngine master
git merge -s ours --no-commit --allow-unrelated-histories 3DreamEngine/master
git read-tree --prefix=3DreamEngine/ -u 3DreamEngine/master:3DreamEngine
git commit -m "Merge in 3DreamEngine subtree (upstream 3DreamEngine/ folder) into local 3DreamEngine/"
```

#### 2. **Initial Integration (Extensions)**

```bash
git fetch 3DreamEngine master
git merge -s ours --no-commit --allow-unrelated-histories 3DreamEngine/master
git read-tree --prefix=extensions/ -u 3DreamEngine/master:extensions
git commit -m "Import 3DreamEngine extensions into root/extensions/"
```

---

#### 🔄 Update Procedure (Combined)

When upstream changes need to be pulled in, we do **not** merge into existing folders. Instead, we always delete the old subtree folders and re‑import them fresh. This guarantees a clean snapshot and avoids index overlap errors.

**Steps:**

```bash
# 1. Remove old subtree folders
rm -rf 3DreamEngine extensions
git rm -r --cached 3DreamEngine extensions || true
git commit -m "Clear old 3DreamEngine and extensions subtree folders before re-import"

# 2. Fetch latest upstream
git fetch 3DreamEngine master

# 3. Re-import fresh snapshots
git read-tree --prefix=3DreamEngine/ -u 3DreamEngine/master:3DreamEngine
git read-tree --prefix=extensions/ -u 3DreamEngine/master:extensions
git commit -m "Re-import 3DreamEngine core and extensions subtrees from latest master"
```

---

### 🧾 Notes

- This procedure produces **two commits**:  
  1. One clearing the old folders.  
  2. One re‑importing the new snapshots.  
- Keeps history clean and predictable.  
- After running, you can regenerate `asset_pipeline/lib_versions.md` with your script to document the new commit hashes.

---

### 🧰 Tips for Development & Branching

- Use feature branches (e.g. `insert_mats`) to test integrations before merging to `main`.  
- All subtree operations should be committed with descriptive messages.  
- Always commit or stash local changes before running subtree operations.  
- From the project’s root directory, you can run:

```bash
./asset_pipeline/update-libs.sh
```

This automates library documentation. You’ll see the subtrees update, followed by:

```
✅ All subtrees updated and version log written to asset_pipeline/lib_versions.md
```

---

### ⚠️ Caution

Using Git LFS with an embedded 3DreamEngine can easily push your repository beyond **5 GB** due to ~4+ GB of unnecessary history blobs. Review your workflow carefully — certain commands that add large binaries or rewrite history can trigger a data flood.

---

This version keeps everything consistent: headings, spacing, code blocks, and lists are aligned. Would you like me to also add a **table of commands vs commit messages** at the end, so developers can quickly see which commit message to use for each step?
