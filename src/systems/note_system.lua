-- src/systems/note_system.lua

local constants = require("src.constants")
local Colors = require("src.utils.colors")

-- Single-note abstraction
local Note = {}
Note.__index = Note
function Note:new(idx, name, jointObj)
  return setmetatable({
    index     = idx,      -- 1..12
    name      = name,     -- e.g. "C"
    joint     = jointObj, -- the mesh object for this joint
    active    = false,    -- future MIDI on/off
    midiProps = {},       -- placeholder
  }, Note)
end

-- Manages all 12 Notes + circular shifts
local NoteSystem = {}
NoteSystem.__index = NoteSystem

function NoteSystem:new(scene)
  local self = setmetatable({ scene = scene, notes = {} }, NoteSystem)

  -- Instantiate notes & bind to joint_00..joint_11
  for i, name in ipairs(constants.NOTE_ORDER) do
    local jointID = string.format("joint_%02d", i-1)

    -- find the actual mesh object in scene.joints
    local jointObj
    for _, obj in ipairs(scene.joints) do
      if obj.id == jointID then jointObj = obj; break end
    end

    self.notes[i] = Note:new(i, name, jointObj)
    self:_applyToGeometry(i)
  end
  return self
end

-- Shift all notes by offset (+1 = right, -1 = left)
function NoteSystem:shift(offset)
  local n = #self.notes
  local tmp = {}

  for i, note in ipairs(self.notes) do
    -- compute new slot
    local j = ((i-1 + offset) % n) + 1
    tmp[j] = note
  end
  self.notes = tmp

  -- rebind and reapply
  for i, note in ipairs(self.notes) do
    local jointID = string.format("joint_%02d", i-1)
    for _, obj in ipairs(self.scene.joints) do
      if obj.id == jointID then note.joint = obj; break end
    end
    self:_applyToGeometry(i)
  end
end

-- Propagate note info into matching edge/curve/surface/label objects
function NoteSystem:_applyToGeometry(i)
  local note   = self.notes[i]
  local suffix = string.format("%02d", i-1)
  local targets = {
    "joint_"   .. suffix,
    "edge_"    .. suffix,
    "curve_"   .. suffix,
    "surface_" .. suffix,
    "label_"   .. suffix,
  }

  for _, name in ipairs(targets) do
    -- search in all lists
    for _, list in ipairs{ self.scene.edges,
                           self.scene.curves,
                           self.scene.surfaces,
                           self.scene.joints } do

	for _, obj in ipairs(list) do
	  if obj.id == name then
	    obj.noteName  = note.name
	    obj.noteIndex = note.index
	    obj.active    = note.active

	    local shiftedIndex = note.index

	    -- Apply shifted coloring logic based on mesh type
	    if string.find(name, "^curve_") then
	      shiftedIndex = ((note.index % 12) + 1)         -- Curve: +1
	    elseif string.find(name, "^edge_") then
	      shiftedIndex = ((note.index + 4 - 1) % 12) + 1 -- Edge: +4
	    end

	    -- assign color based on shifted index
	    local color = Colors.getNoteColor(shiftedIndex)
	    obj.noteColor = color  -- store for reference

	    if obj.material then
	      local mat       = obj.material
	      local cat       = name:match("^(%a+)_")       -- e.g. "joint", "edge", etc.

	      -- set tint
	      mat:setColor        (color)
	      mat:setEmission(color)

	      -- compute emission factor using emissionLevels table
	      local levels      = constants.emissionLevels[cat] or { active = 0, inactive = 0 }
	      local activeState = note.active    -- already boolean
	      local factor      = activeState and levels.active or levels.inactive

	      mat:setEmissionFactor(factor)

	      -- scale joint geometry on activation
	      if cat == "joint" then
		if activeState then
		  obj:scale(constants.scaleFactor,
			    constants.scaleFactor,
			    constants.scaleFactor)
		else
		  obj:scale(1, 1, 1)
		end
	      end
	    end
	  end
	end
    end
  end
end

return NoteSystem
