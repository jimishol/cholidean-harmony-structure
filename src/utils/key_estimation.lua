--- Key Estimation Module for Umbilic-Surface Harmony.
-- Detects the Diatonic Key based on the geometric activation of Dominant and Subdominant surfaces.
-- Uses src.materials as the single source of truth for surface activation physics.
--
-- [[ GEOMETRIC LOGIC ]]
-- 1. TOPOLOGICAL AXIS: A Key is a container defined by the activation of its Dominant (t-1)
--    and Torque/Supertonic (t+2) surfaces.
-- 2. GEOMETRIC ID: To claim a Key, a set of notes must provide either:
--    - STABILITY: The Edge (Major 3rd, t+8). Anchors the Tonic.
--    - TENSION: The Vector (Leading Tone, t+7). Points to the Tonic.
-- 3. HARMONIC RESOLUTION (EXPERIMENTAL: SUBTRACTION LOGIC):
--    - The "Minor" label is forced only if the Harmonic Dominant (t+8) was present in History
--      but is NOT present in the Current frame (Resolution of Tension).
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
  [1]  = { major = "C",  minor = "Am" },
  [2]  = { major = "F",  minor = "Dm" },
  [3]  = { major = "Bb", minor = "Gm" },
  [4]  = { major = "Eb", minor = "Cm" },
  [5]  = { major = "Ab", minor = "Fm" },
  [6]  = { major = "Db", minor = "Bbm" },
  [7]  = { major = "Gb", minor = "Ebm" },
  [8]  = { major = "B",  minor = "G#m" },
  [9]  = { major = "E",  minor = "C#m" },
  [10] = { major = "A",  minor = "F#m" },
  [11] = { major = "D",  minor = "Bm" },
  [12] = { major = "G",  minor = "Em" },
}

--- Helper: Scans the 12 surfaces to find valid Key Candidates.
-- Uses a Dual-Axis strategy to detect both static tonal centers and dynamic resolutions.
--
-- **Axis 1 (Standard Topology):** Checks for the "Container" (Dominant + Torque surfaces) in the accumulated history.
-- Applies strict vetoes for Lydian/Mixolydian notes and a "Ghostbuster" check to prevent Relative Minor chords
-- from triggering Parallel Major keys.
--
-- **Axis 2 (Minor Resolution):** Checks for the specific dynamic movement of V -> i.
-- If the Harmonic Minor Dominant (t+8) existed in history but has resolved (is absent in current),
-- and the Minor Tonic (t+1) is currently active, the system forces the Minor label.
--
-- **Axis 3 (Major Resolution):** Checks for V -> I resolution in the ABSENCE of Minor history.
-- Distinguishes C Major (G->C, no E) from A Minor (G->C, E exists in history).
--
-- @param surfaces table The boolean topology of Accumulated History (Ring Buffer).
-- @param currentSurfaces table The boolean topology of the CURRENT frame only.
-- @param notePresent table The map of currently active notes (Accumulated).
-- @return table foundNames List of detected key labels (e.g., "C | Am" or "Am").
-- @return table foundIndices List of detected key indices (1-12).
-- @return boolean conflictDetected True if a valid axis was found but vetoed by conflicting notes.
local function detectKeyCandidates(surfaces, currentSurfaces, notePresent)
  local foundNames = {}
  local foundIndices = {}
  local conflict = false

  -- Helper: Wrap 1-based index to 1..12
  local function wrap12(n) return (n - 1) % 12 + 1 end

  for t = 1, 12 do
    local labelPair = targetToKey[t]
    local candidateAccepted = false
    local forcedMinor = false

    -- ============================================================
    -- AXIS 1: STANDARD TOPOLOGY (Major / Relative)
    -- Checks the static container using Accumulated History.
    -- ============================================================
    local sDom = wrap12(t - 1)
    local sSub = wrap12(t + 2)

    if surfaces[sDom] and surfaces[sSub] then
       -- Map relative notes
       local function has(steps) return notePresent[wrap12(t + steps)] end

       -- Vetoes
       local Lydian     = has(6)
       local Mixolydian = has(2)

       -- [[ THE GHOSTBUSTER VETO ]]
       -- If the Parallel Minor 3rd (t+3) is present, but the Major 3rd (t+8) is MISSING,
       -- we reject the Major Key. (Fixes "Am" appearing as "A Major").
       -- Example: Input "Am" (A C E). Candidate "A Major".
       -- has(3)=C (True). has(8)=C# (False). -> REJECT.
       local ParallelMinorClash = has(3) and not has(8)

       -- [[ MODE-AGNOSTIC ACCEPTANCE ]]
       -- We allow candidates without strict ID checks to support Modes (Dorian/Mixolydian).
       if not Lydian and not Mixolydian and not ParallelMinorClash then
           candidateAccepted = true

           -- [[ HARMONIC RESOLUTION (SUBTRACTION LOGIC) ]]
           -- We force Minor ONLY if the Harmonic Dominant (t+8) was in History
           -- but has now RESOLVED (is missing from Current).
           local sMinorDom = wrap12(t + 8)
           local isHarmonicResolution = surfaces[sMinorDom] and not currentSurfaces[sMinorDom]

           if isHarmonicResolution then
               forcedMinor = true
           end
       else
           -- Only flag conflict if we fail the Vetoes
           if not ParallelMinorClash then conflict = true end
       end
    end

    -- ============================================================
    -- AXIS 2: MINOR RESOLUTION (The "Second Axis")
    -- Checks for the dynamic resolution V -> i.
    -- Logic: V was in History but resolved (Gone in Current) + i is Active in Current.
    -- ============================================================
    local sMinorDom   = wrap12(t + 8) -- The V (e.g., E' for Am)
    local sMinorTonic = wrap12(t + 1) -- The i Container (e.g., F' for Am)

    local v_resolved = surfaces[sMinorDom] and not currentSurfaces[sMinorDom]
    local i_active   = currentSurfaces[sMinorTonic]

    if v_resolved and i_active then
        candidateAccepted = true
        forcedMinor = true
    end

    -- ============================================================
    -- FINAL DECISION & AXIS 3 (MAJOR SPLIT)
    -- ============================================================
    if candidateAccepted then
        local resolvedName

        if forcedMinor then
            -- Axis 2 or Harmonic Subtraction detected Minor
            resolvedName = labelPair.minor
        else
            -- Check for "Pure Major" (Axis 3)
            -- Logic:
            -- 1. Major Dominant (t-1) Resolved: Was in History, Gone in Current.
            -- 2. Major Tonic (t) Arrived: Active in Current.
            -- 3. NO MINOR HISTORY: The Minor Dominant (t+8) must be completely absent from History.
            --    (This distinguishes V->I from VII->III in Relative Minor).

            local sMajorDom = wrap12(t - 1)
            local major_V_resolved = surfaces[sMajorDom] and not currentSurfaces[sMajorDom]
            local major_I_active   = currentSurfaces[t]
            local no_minor_history = not surfaces[sMinorDom] -- Crucial Filter

            if major_V_resolved and major_I_active and no_minor_history then
                resolvedName = labelPair.major
            else
                -- Default: Diatonic Ambiguity (C | Am)
                resolvedName = labelPair.major .. "|" .. labelPair.minor
            end
        end

        table.insert(foundNames, resolvedName)
        table.insert(foundIndices, t)
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
function KeyEstimation.estimate(notes, dt, speed_factor)
  local dt = dt or 0.016 -- Fallback if dt is missing
  -- [[ GEOMETRIC INJECTION ]] --
  local s = speed_factor or 1.0
  if s < 0.1 then s = 0.1 end

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
        if silenceTimer > SILENCE_THRESHOLD / s then
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
  -- Note: For Local check, Accumulated == Current, so (Acc - Curr) is always False.
  -- This means Local checks will NEVER detect Minor (always Ambiguous).
  local foundLocalNames, foundLocalIndices, conflictLocal = detectKeyCandidates(currentSurfaceActive, currentSurfaceActive, notePresent)

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

     -- Pass both Accumulated and Current to enable the subtraction logic
     local foundGlobalNames, foundGlobalIndices, conflictGlobal = detectKeyCandidates(accumulatedSurfaces, currentSurfaceActive, notePresent)

     if #foundGlobalNames > 0 then
        -- GLOBAL SUCCESS
        result = "Key: " .. table.concat(foundGlobalNames, "  ")
        conflictTimer = 0

	-- [UNION FILTER]
        -- We keep a surface if it belongs to ANY of the valid candidates.
        -- This prevents "Intersection Death" (where a surface is killed because it fits Candidate A but not B).

        local unionMask = {}
        for i = 1, 12 do unionMask[i] = false end -- Start empty

        for _, t in ipairs(foundGlobalIndices) do
            local keyMask = {}

            -- Standard Diatonic Habitat (4 Surfaces)
            keyMask[wrap12(t)]     = true -- Tonic (e.g., C')
            keyMask[wrap12(t - 1)] = true -- Major Dom (e.g., G')
            keyMask[wrap12(t + 1)] = true -- Subdominant (e.g., F')
            keyMask[wrap12(t + 2)] = true -- Torque/Supertonic (e.g., Bb')

            -- Harmonic Minor Extension
            keyMask[wrap12(t + 8)] = true -- Minor Dom (e.g., E' for Am)

            -- Accumulate into Union
            for i = 1, 12 do
                unionMask[i] = unionMask[i] or keyMask[i]
            end
        end

        local newHistory = {}
        for i = 1, 12 do
             -- Keep if it is currently active OR (it was in history AND it fits the Union of candidates)
             newHistory[i] = currentSurfaceActive[i] or (previousState.surfaceActive[i] and unionMask[i])
        end
        previousState.surfaceActive = newHistory

     elseif conflictGlobal then
        -- GLOBAL CONFLICT (The Real "None")
        -- Only output "None" if the conflict persists longer than the grace period.

        conflictTimer = conflictTimer + dt

        if conflictTimer > CONFLICT_GRACE / s then
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
