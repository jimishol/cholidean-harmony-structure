-- test_fundamental.lua
local Gnoez = dofile("../src/systems/fundamental.lua")

-- Some test chords (MIDI note numbers)
local tests = {
  {62,67,71,64},
  {72,75,78},
  {60,66},
  {66,60},
  {67,71,64,74},
  {55,71,64,74},
  {43,71,64,74},
  {60,64,67},
  {12,16,19},   -- edge: bass at C0
  {11,15,18},   -- edge: below C0
  {84,88,91},   -- edge: high bass
  {61,67},      -- edge: tritone
  {60,72},      -- edge: octave
  {60},         -- edge: single note
  {60,61,62,63},-- edge: cluster
  {29,68,72}
}

for _,chord in ipairs(tests) do
  local res = Gnoez.G_noez_from_midi(chord)
  print("Chord:", table.concat(chord,","))
  print(" -> y:", res.y, "fundamental:", res.fundamental)
end
