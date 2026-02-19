--- Key Estimation Module for Umbilic-Surface Harmony.
-- Detects the Diatonic Key based on the geometric activation of Dominant and Subdominant surfaces.
-- Uses src.materials as the single source of truth for surface activation physics.
--
-- WARNING: TOPOLOGICAL BIAS (WESTERN TONALITY)
-- This estimator applies a "Common Practice" filter to the neutral 3D lattice.
-- It assumes a Key is formed by a cluster of 4 adjacent Surfaces.
-- Non-Western or experimental geometries (e.g., Symmetric/Modal) may require
-- their own dedicated estimation modules.
--
-- @module src.utils.key_estimation
local materials = require("src.utils.materials")

local KeyEstimation = {}

-- Ring buffer setup for caching results (Vertical States only)
local ring = {}
local ringSize = 0
local ringCapacity = 1

-- Timers
local silenceTimer = 0
local SILENCE_THRESHOLD = 2.0 -- Seconds before hard reset
local conflictTimer = 0       -- Tracks how long a conflict has persisted
local CONFLICT_GRACE = 0.15   -- 150ms grace period for finger slips/legato

-- Module-level storage for the LAST DISTINCT harmonic event
local previousState = {
  notes = {},
  surfaceActive = {}
}

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
-- Uses Strict Topological Axis (t-1, t+2) to ensure Torque is present.
-- @param surfaces The boolean topology to check (Active Surfaces).
-- @param notePresent The map of currently active notes (Accumulated Notes).
-- @return table foundNames, table foundIndices, boolean conflictDetected
local function detectKeyCandidates(surfaces, notePresent)
  local foundNames = {}
  local foundIndices = {}
  local conflict = false

  -- Helper: Wrap 1-based index to 1..12
  local function wrap12(n) return (n - 1) % 12 + 1 end

  for t = 1, 12 do
    -- 1. TOPOLOGICAL AXIS CHECK
    -- We require the Dominant Surface (t-1) AND the Torque Surface (t+2).
    -- For C (t=1):
    --   sDom = G' (12). Contains G, B.
    --   sSub = Bb' (3). Contains Bb, D, F, A. (Holds the Supertonic D and Subdominant F).

    local sDom = wrap12(t - 1)
    local sSub = wrap12(t + 2)

    local axisActive = surfaces[sDom] and surfaces[sSub]

    -- 2. THE VETO (Material Check)
    if axisActive then
       -- Map relative notes using Circle Offsets from Candidate 't'
       local function has(steps) return notePresent[wrap12(t + steps)] end

       -- The Walls (Vetoes)
       -- Lydian (#4) pulls to V. Mixolydian (b7) pulls to IV. Neapolitan (b2) destabilizes.
       local Lydian     = has(6)  -- e.g., F# in C
       local Mixolydian = has(2)  -- e.g., Bb in C
       local Neapolitan = has(5)  -- e.g., Db in C

       if not Lydian and not Mixolydian and not Neapolitan then
          -- Valid Candidate found
          table.insert(foundNames, targetToKey[t])
          table.insert(foundIndices, t)
       else
          -- Axis was active, but contradicted by Wall notes.
          -- This flags a "Conflict" (e.g., Whole Tone scale), distinct from "Silence".
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
  conflictTimer = 0
  return "Key:     "
end

--- Estimates the Key based on active notes and surface topology.
function KeyEstimation.estimate(notes, dt)
  local dt = dt or 0.016 -- Fallback if dt is missing

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
    if ring[i] and ring[i].fingerprint == key then
        conflictTimer = 0 -- Reset conflict timer on stable state match
        return ring[i].result
    end
  end

  -- 5) SURFACE-DRIVEN LOGIC (Strict Priority Strategy)

  -- Helper: Wrap 1-based index to 1..12
  local function wrap12(n) return (n - 1) % 12 + 1 end

  local result = "Key:     "
  if ringSize > 0 then result = ring[0].result end

  -- A. Check LOCAL (Current Chord Only)
  local foundLocalNames, foundLocalIndices, conflictLocal = detectKeyCandidates(currentSurfaceActive, notePresent)

  if #foundLocalNames > 0 then
     -- PRIORITY 1: LOCAL SUCCESS
     result = "Key: " .. table.concat(foundLocalNames, "  ")
     previousState.surfaceActive = currentSurfaceActive
     conflictTimer = 0

  else
     -- PRIORITY 3: LOCAL AMBIGUITY -> CHECK GLOBAL
     -- Note: We skip "Local Conflict" output to allow for transient clashes (legato).

     local accumulatedSurfaces = {}
     for i = 1, 12 do
       accumulatedSurfaces[i] = (previousState.surfaceActive[i] or currentSurfaceActive[i])
     end

     local foundGlobalNames, foundGlobalIndices, conflictGlobal = detectKeyCandidates(accumulatedSurfaces, notePresent)

     if #foundGlobalNames > 0 then
        -- GLOBAL SUCCESS
        result = "Key: " .. table.concat(foundGlobalNames, "  ")
        conflictTimer = 0

        -- [INTERSECTION FILTER]
        local commonMask = {}
        for i = 1, 12 do commonMask[i] = true end

        for _, t in ipairs(foundGlobalIndices) do
            local keyMask = {}
            keyMask[wrap12(t - 1)] = true -- Major Dom
            keyMask[wrap12(t + 2)] = true -- Major Sub (Torque)
            keyMask[wrap12(t + 1)] = true -- Minor Tonic
            keyMask[wrap12(t + 8)] = true -- Minor Dom
            for i = 1, 12 do commonMask[i] = commonMask[i] and keyMask[i] end
        end

        local newHistory = {}
        for i = 1, 12 do
             newHistory[i] = currentSurfaceActive[i] or (previousState.surfaceActive[i] and commonMask[i])
        end
        previousState.surfaceActive = newHistory

     elseif conflictGlobal then
        -- GLOBAL CONFLICT (The Real "None")
        -- Only output "None" if the conflict persists longer than the grace period.

        conflictTimer = conflictTimer + dt

        if conflictTimer > CONFLICT_GRACE then
            result = "Key: None"
        else
            -- Ghosting: Keep previous result during finger slip
            if ringSize > 0 then result = ring[0].result end
        end

        previousState.surfaceActive = currentSurfaceActive

     else
        -- GLOBAL AMBIGUITY
        -- Ghosting: Keep previous result
        conflictTimer = 0
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
