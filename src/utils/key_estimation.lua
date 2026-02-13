--- Key Estimation Module for Umbilic-Surface Harmony.
-- Detects the Diatonic Key based on the geometric activation of Dominant and Subdominant surfaces.
-- Uses src.materials as the single source of truth for surface activation physics.
-- @module src.utils.key_estimation
local materials = require("src.utils.materials")

local KeyEstimation = {}

-- Ring buffer setup for caching results (Vertical States only)
local ring = {}
local ringSize = 0
local ringCapacity = 1

-- Silence Detection
local silenceTimer = 0
local SILENCE_THRESHOLD = 2.0 -- Seconds before hard reset

-- Module-level storage for the LAST DISTINCT harmonic event
local previousState = {
  notes = {},
  surfaceActive = {}
}

--- Wraps an integer into the 1–12 Circle of Fourths range.
local function wrap12(n) return ((n - 1) % 12) + 1 end

--- Compact Mapping of Target Key Index 't'.
local targetToKey = {
  [1]  = "C|Am",    [2]  = "F|Dm",
  [3]  = "Bb|Gm",   [4]  = "Eb|Cm",
  [5]  = "Ab|Fm",   [6]  = "Db|Bbm",
  [7]  = "Gb|Ebm",  [8]  = "B|G#m",
  [9]  = "E|C#m",   [10] = "A|F#m",
  [11] = "D|Bm",    [12] = "G|Em",
}

--- Estimates the Key based on active notes and surface topology.
-- @tparam table notes The array of Note objects.
-- @tparam number dt Delta time for silence detection.
-- @treturn string The estimated key name.
function KeyEstimation.estimate(notes, dt)

  -- 1) BUILD CANONICAL NOTE MAP (Absolute Geometry)
  local canonicalNotes = {}
  local activeNoteIds = {}
  local notePresent = {}

  for i = 1, 12 do canonicalNotes[i] = { active = false, index = i } end

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

-- 1.5) SILENCE & HARMONIC SUSTAIN
  if #activeNoteIds == 0 then
     if dt then
        silenceTimer = silenceTimer + dt

        if silenceTimer > SILENCE_THRESHOLD then
           -- HARD RESET: Long Silence -> Clear Memory
           ringSize = 0
           previousState = { notes = {}, surfaceActive = {} }
           silenceTimer = 0
           return "Key:     "
        else
           -- SHORT SILENCE: Harmonic Sustain
           -- Return the last known stable result from the Ring
           if ringSize > 0 then
              return ring[0].result
           else
              return "Key:     "
           end
        end
     end
     -- Fallback if dt is missing
     return "Key:     "
  else
     -- Notes are present -> Reset Timer
     silenceTimer = 0
  end

  -- 2) CALCULATE ABSOLUTE SURFACE BOOLEANS
  local surfaceActive = {}
  for i = 1, 12 do
    local state = materials.checkSurfState(i, canonicalNotes)
    surfaceActive[i] = (state ~= "inactive")
  end

  -- 3) FINGERPRINT
  table.sort(activeNoteIds)
  local stateStr = ""
  for i = 1, 12 do
    stateStr = stateStr .. (surfaceActive[i] and "T" or "F")
  end

  local key = table.concat(activeNoteIds, ",") .. "|" .. stateStr

  -- 4) CACHE CHECK (Vertical Optimization)
  for i = 0, ringSize - 1 do
    if ring[i] and ring[i].fingerprint == key then return ring[i].result end
  end

local foundKeys = {}
  local conflictDetected = false -- Flag to track Veto failures

  -- 5) SURFACE-DRIVEN LOGIC (Absolute Geometry)
  for t = 1, 12 do
    local sDom = wrap12(t - 1)
    local sSub = wrap12(t + 2)

    -- Check if the Axis exists (Dominant + Subdominant surfaces active)
    if surfaceActive[sDom] and surfaceActive[sSub] then

       -- 6) THE HINGE VETO
       local hinge = wrap12(t - 2)
       local aug1 = wrap12(hinge + 4)
       local aug2 = wrap12(hinge + 8)

       if not notePresent[aug1] and not notePresent[aug2] then
         -- SUCCESS: Clean Diatonic Key
         table.insert(foundKeys, targetToKey[t])
       else
         -- FAILURE: Axis exists, but Geometry is "Dirty" (Modulation/Conflict)
         conflictDetected = true
       end
    end
  end

  -- FINAL RESULT CONSTRUCTION
  -- Priority 1: We found a valid key.
  -- Priority 2: We found a conflict (Axis but Vetoed) -> "Key: None"
  -- Priority 3: We found nothing (No Axis) -> "Key:     "

  local result = "Key:     " -- Default (Ambiguity)

  if #foundKeys > 0 then
    result = "Key: " .. table.concat(foundKeys, "  ")
  elseif conflictDetected then
    result = "Key: None"     -- Conflict detected
  end
  ---------------------------------------------------------
  -- 6.5) HORIZONTAL LOGIC PLACEHOLDER
  ---------------------------------------------------------
  local extendedResult = result

  if previousState.surfaceActive[1] ~= nil then
     -- [[ FUTURE LOGIC INSERTION POINT ]]
     -- Compare previousState vs. surfaceActive
  end

  -- UPDATE HISTORY
  previousState.notes = activeNoteIds
  previousState.surfaceActive = surfaceActive

  ---------------------------------------------------------
  -- 7) CACHE RESULT
  ---------------------------------------------------------
  if ringCapacity > 0 then
    for i = ringCapacity - 1, 1, -1 do ring[i] = ring[i - 1] end
    ring[0] = { fingerprint = key, result = result }
    if ringSize < ringCapacity then ringSize = ringSize + 1 end
  end

  return extendedResult
end

return KeyEstimation
