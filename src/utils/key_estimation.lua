--- Key Estimation Module for Umbilic-Surface Harmony.
-- Detects the Diatonic Key based on the geometric activation of Dominant and Subdominant surfaces.
-- Uses src.materials as the single source of truth for surface activation physics.
-- @module src.utils.key_estimation
local materials = require("src.utils.materials")

local KeyEstimation = {}

-- Ring buffer setup for caching results
local ring = {}
local ringSize = 0
local ringCapacity = 3 

--- Wraps an integer into the 1–12 Circle of Fourths range.
-- @local
-- @tparam number n The input index.
-- @treturn number The wrapped index (1=C, 12=G).
local function wrap12(n) return ((n - 1) % 12) + 1 end

--- Mapping of Target Key Index 't' to its display name.
-- @local
local targetToKey = {
  [1]  = "C Major or A minor",    [2]  = "F Major or D minor",
  [3]  = "Bb Major or G minor",   [4]  = "Eb Major or C minor",
  [5]  = "Ab Major or F minor",   [6]  = "Db Major or Bb minor",
  [7]  = "Gb Major or Eb minor",  [8]  = "B Major or G# minor",
  [9]  = "E Major or C# minor",   [10] = "A Major or F# minor",
  [11] = "D Major or B minor",    [12] = "G Major or E minor",
}

--- Estimates the Key based on active notes and surface topology.
-- @tparam table notes The array of Note objects from the NoteSystem.
-- @tparam table _ignoredSurfaceStates Ignored; we calculate states via materials.lua to avoid visual shift errors.
-- @treturn string The estimated key name (e.g., "Key: C Major") or "Key: None".
function KeyEstimation.estimate(notes, _ignoredSurfaceStates)

  -- 1) BUILD CANONICAL NOTE MAP (Absolute Geometry)
  -- We construct a virtual array where Index 1 is ALWAYS C, Index 2 is ALWAYS F.
  -- This neutralizes the user's visual shift/rotation.

  local canonicalNotes = {}
  local activeNoteIds = {}
  local notePresent = {} -- For Veto lookup

  -- Initialize empty slots
  for i = 1, 12 do canonicalNotes[i] = { active = false, index = i } end

  -- Fill with actual data
  for _, n in ipairs(notes) do
    if n then
      local idx = tonumber(n.index)
      if idx then
        canonicalNotes[idx] = n

        if n.active then
          notePresent[idx] = true
          table.insert(activeNoteIds, tostring(idx))
        end
      end
    end
  end

  -- 2) CALCULATE ABSOLUTE SURFACE STATES
  -- We ask materials.lua: "If the notes were arranged like this, which surfaces would glow?"
  local absSurfaceState = {}
  for i = 1, 12 do
    absSurfaceState[i] = materials.checkSurfState(i, canonicalNotes)
  end

  -- 3) FINGERPRINT
  table.sort(activeNoteIds)
  -- Fingerprint the Absolute States to ensure cache validity
  local stateStr = ""
  for i = 1, 12 do stateStr = stateStr .. absSurfaceState[i] end

  local key = table.concat(activeNoteIds, ",") .. "|" .. stateStr

  -- 4) CACHE CHECK
  for i = 0, ringSize - 1 do
    if ring[i] and ring[i].fingerprint == key then return ring[i].result end
  end

  local foundKeys = {}

  -- 5) SURFACE-DRIVEN LOGIC (Absolute Geometry)
  for t = 1, 12 do
    local sDom = wrap12(t - 1) -- Dominant Side
    local sSub = wrap12(t + 2) -- Subdominant Side

    -- Check the Calculated States
    -- We accept "active" or "semiactive" as valid structural brackets
    if absSurfaceState[sDom] ~= "inactive" and absSurfaceState[sSub] ~= "inactive" then

       -- 6) THE HINGE VETO (Absolute Pitch)
       -- If the Supertonic's Augmented Partners are present, the Key is unstable.
       local hinge = wrap12(t - 2)
       local aug1 = wrap12(hinge + 4)
       local aug2 = wrap12(hinge + 8)

       if not notePresent[aug1] and not notePresent[aug2] then
         table.insert(foundKeys, targetToKey[t])
       end
    end
  end

  local result = "Key: None"
  if #foundKeys > 0 then
    result = "Key: " .. table.concat(foundKeys, " + ")
  end

  -- Cache result
  if ringCapacity > 0 then
    for i = ringCapacity - 1, 1, -1 do ring[i] = ring[i - 1] end
    ring[0] = { fingerprint = key, result = result }
    if ringSize < ringCapacity then ringSize = ringSize + 1 end
  end

  return result
end

return KeyEstimation
