#!/usr/bin/env zsh
setopt SH_WORD_SPLIT   # so $NOTES splits into words

OUTDIR=./exports
NOTES=(C Db D Eb E F Gb G Ab A Bb B)

# map sub-dir ↔ the show_* flags (space-separated)
typeset -A TARGET_FLAGS
TARGET_FLAGS=(
  joints   "show_joints=true  show_edges=false show_curve=false  show_surfaces=false"
  edges    "show_joints=false show_edges=true  show_curve=false  show_surfaces=false"
  curves   "show_joints=false show_edges=false show_curve=true   show_surfaces=false"
  surfaces "show_joints=false show_edges=false show_curve=false  show_surfaces=true"
)

# create all the output dirs
for sub in ${(@k)TARGET_FLAGS}; do
  mkdir -p "$OUTDIR/$sub"
done

# do the exports
for sub in ${(@k)TARGET_FLAGS}; do
  echo "→ Exporting $sub…"
  flags_str=${TARGET_FLAGS[$sub]}
  for note in ${NOTES[@]}; do
    # build the full list of -D args
    args=(-D exportNote=\"${note}\")
    for f in ${(s: :)flags_str}; do
      args+=(-D $f)
    done

    openscad \
      -o "$OUTDIR/$sub/${sub}_${note}.stl" \
      main.scad \
      $args
  done
done

echo "✅ Done exporting all STL sets!"
