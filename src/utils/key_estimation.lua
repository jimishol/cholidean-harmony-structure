--- Key Estimation Module for Umbilic-Surface Harmony.
-- Detects the Diatonic Key based on the geometric activation of Dominant and Subdominant surfaces.
-- Uses src.materials as the single source of truth for surface activation physics.
-- WARNING: TOPOLOGICAL BIAS (WESTERN TONALITY)
-- This estimator applies a "Common Practice" filter to the neutral 3D lattice.
-- It assumes a Key is formed by a cluster of 4 adjacent Surfaces.
-- Non-Western or experimental geometries (e.g., Symmetric/Modal) may require
-- their own dedicated estimation modules.
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

--- Helper: Scans the 12 surfaces to find valid Key Candidates.
-- @param surfaces The boolean topology to check.
-- @param notePresent The map of currently active notes (for Veto).
-- @return table foundNames, table foundIndices, boolean conflictDetected
local function detectKeyCandidates(surfaces, notePresent)
  local foundNames = {}
  local foundIndices = {}
  local conflict = false

  for t = 1, 12 do
    -- AXIS 1: MAJOR / JAZZ (Dominant + Subdominant)
    local sDom = wrap12(t - 1)
    local sSub = wrap12(t + 2)
    local axisMajor = surfaces[sDom] and surfaces[sSub]

    -- AXIS 2: HARMONIC MINOR (Relative Tonic + Harmonic Dominant)
    -- CORRECTION: B7 (on B', t=8) is the Dominant of Em (on C', t=1) in Key G (t=12).
    local sMinTonic = wrap12(t + 1)
    local sMinDom   = wrap12(t + 8)
    local axisMinor = surfaces[sMinTonic] and surfaces[sMinDom]

    if axisMajor or axisMinor then
       -- THE HINGE VETO (t-2)
       local hinge = wrap12(t - 2)
       local aug1 = wrap12(hinge + 4)
       local aug2 = wrap12(hinge + 8)

       if not notePresent[aug1] and not notePresent[aug2] then
         table.insert(foundNames, targetToKey[t])
         table.insert(foundIndices, t)
       else
         conflict = true
       end
    end
  end
  return foundNames, foundIndices, conflict
end

--- Resets the internal state of the estimator.
function KeyEstimation.reset()
  ring = {}
  ringSize = 0
  previousState = { notes = {}, surfaceActive = {} }
  silenceTimer = 0
  return "Key:     "
end

--- Estimates the Key based on active notes and surface topology.
function KeyEstimation.estimate(notes, dt)

  -- 1) BUILD CANONICAL NOTE MAP
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

  -- 1.5) SILENCE & DENSITY CHECK
  if #activeNoteIds == 0 then
     if dt then
        silenceTimer = silenceTimer + dt
        if silenceTimer > SILENCE_THRESHOLD then
           KeyEstimation.reset()
           return "Key:     "
        else
           if ringSize > 0 then return ring[0].result else return "Key:     " end
        end
     end
     return "Key:     "

  elseif #activeNoteIds < 2 then
     -- CASE B: MONAD / SINGLE NOTE (Sustain)
     silenceTimer = 0
     if ringSize > 0 then return ring[0].result else return "Key:     " end

  else
     -- CASE C: HARMONIC INPUT (2+ notes)
     silenceTimer = 0
  end

  -- 2) CALCULATE ABSOLUTE SURFACE BOOLEANS
  local currentSurfaceActive = {}
  for i = 1, 12 do
    local state = materials.checkSurfState(i, canonicalNotes)
    currentSurfaceActive[i] = (state ~= "inactive")
  end

  -- 3) FINGERPRINT
  table.sort(activeNoteIds)
  local stateStr = ""
  for i = 1, 12 do stateStr = stateStr .. (currentSurfaceActive[i] and "T" or "F") end
  local key = table.concat(activeNoteIds, ",") .. "|" .. stateStr

  -- 4) CACHE CHECK
  for i = 0, ringSize - 1 do
    if ring[i] and ring[i].fingerprint == key then return ring[i].result end
  end

  -- 5) SURFACE-DRIVEN LOGIC (Strict Priority Strategy)

  local result = "Key:     "
  if ringSize > 0 then result = ring[0].result end

  -- A. Check LOCAL (Current Chord Only)
  local foundLocalNames, foundLocalIndices, conflictLocal = detectKeyCandidates(currentSurfaceActive, notePresent)

  if #foundLocalNames > 0 then
     -- PRIORITY 1: LOCAL SUCCESS
     result = "Key: " .. table.concat(foundLocalNames, "  ")
     previousState.surfaceActive = currentSurfaceActive

  elseif conflictLocal then
     -- PRIORITY 2: LOCAL CONFLICT
     result = "Key: None"
     previousState.surfaceActive = currentSurfaceActive

  else
     -- PRIORITY 3: LOCAL AMBIGUITY -> CHECK GLOBAL

     local accumulatedSurfaces = {}
     for i = 1, 12 do
       accumulatedSurfaces[i] = (previousState.surfaceActive[i] or currentSurfaceActive[i])
     end

     local foundGlobalNames, foundGlobalIndices, conflictGlobal = detectKeyCandidates(accumulatedSurfaces, notePresent)

     if #foundGlobalNames > 0 then
        -- GLOBAL SUCCESS
        result = "Key: " .. table.concat(foundGlobalNames, "  ")

        -- [INTERSECTION FILTER]
        -- Logic: Keep history ONLY if it supports ALL found candidates.
        -- If multiple keys are found (Soup), their intersection is likely empty -> History Wiped.
        -- If 1 key is found, intersection is that key -> History Preserved.

        local commonMask = {}
        for i = 1, 12 do commonMask[i] = true end -- Start assuming everything is valid

        for _, t in ipairs(foundGlobalIndices) do
            local keyMask = {} -- false by default

            -- Mark the 4 defining surfaces of this key
            keyMask[wrap12(t - 1)] = true -- Major Dom
            keyMask[wrap12(t + 2)] = true -- Major Sub
            keyMask[wrap12(t + 1)] = true -- Minor Tonic
            keyMask[wrap12(t + 8)] = true -- Minor Dom

            -- Intersect with common mask
            for i = 1, 12 do
                commonMask[i] = commonMask[i] and keyMask[i]
            end
        end

        -- Rebuild History
        local newHistory = {}
        for i = 1, 12 do
             -- Keep if it is CURRENTLY active
             -- OR if it was historically active AND it is in the common mask
             newHistory[i] = currentSurfaceActive[i] or (previousState.surfaceActive[i] and commonMask[i])
        end
        previousState.surfaceActive = newHistory

     elseif conflictGlobal then
        -- GLOBAL CONFLICT
        result = "Key: ?"
        previousState.surfaceActive = currentSurfaceActive

     else
        -- GLOBAL AMBIGUITY
        previousState.surfaceActive = accumulatedSurfaces
     end
  end

  -- UPDATE HISTORY
  previousState.notes = activeNoteIds

  -- 7) CACHE RESULT
  if ringCapacity > 0 then
    for i = ringCapacity - 1, 1, -1 do ring[i] = ring[i - 1] end
    ring[0] = { fingerprint = key, result = result }
    if ringSize < ringCapacity then ringSize = ringSize + 1 end
  end

  return result
end

return KeyEstimation
