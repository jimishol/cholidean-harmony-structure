--- midiport backend stub for the active‐notes tracking thread (Channel + file pass-through).
local quit_channel    = love.thread.getChannel("quit")
local backend_channel = love.thread.getChannel("backend")
local port_channel    = love.thread.getChannel("shellPort")
local host_channel    = love.thread.getChannel("shellHost")
local font_channel    = love.thread.getChannel("soundfont")
local songs_channel   = love.thread.getChannel("songs")
local notesChannel    = love.thread.getChannel("active_notes")

-- Clear startup chatter
backend_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

local timer     = require("love.timer")
local notesFile = "active_notes.lua"

-- Clear the file at startup
local function clear_notes_file()
    local f = io.open(notesFile, "w")
    if f then
        f:write("-- Auto‐generated active MIDI notes\nreturn {}\n")
        f:close()
    end
end

-- Merge two lists without duplicates
local function merge_unique(t1, t2)
    local seen, result = {}, {}
    for _, v in ipairs(t1) do
        if not seen[v] then
            table.insert(result, v)
            seen[v] = true
        end
    end
    for _, v in ipairs(t2) do
        if not seen[v] then
            table.insert(result, v)
            seen[v] = true
        end
    end
    return result
end

---------------------------------------------------------
-- Pseudo-sniffer: continuous looping simulation
---------------------------------------------------------
local active_notes = {} -- keyed by "channel:key"

-- Define a repeating pattern of events: {step, channel, key, velocity}
local events = {
    {0, 0, 62, 100}, {0, 0, 71, 100}, -- D4, B4 on
    {1, 0, 62,   0}, {1, 0, 67, 100}, -- D4 off, G4 on
    {2, 0, 71,   0},                   -- B4 off
    {3, 0, 67, 100}, {3, 0, 60, 100}, {3, 0, 53, 100}, -- chord
}

local step = 0
local max_step = 3 -- highest step index in events

local function sniff()
    -- Apply all events for this step
    for _, ev in ipairs(events) do
        local ev_step, ch, key, vel = ev[1], ev[2], ev[3], ev[4]
        if ev_step == step and ch ~= 9 then
            if vel > 0 then
                active_notes[ch..":"..key] = { channel = ch, key = key }
            else
                active_notes[ch..":"..key] = nil
            end
        end
    end

    -- Advance step, loop back to 0
    step = (step + 1) % (max_step + 1)

    -- Deduplicate by key and return sorted list
    local set, list = {}, {}
    for _, note in pairs(active_notes) do
        set[note.key] = true
    end
    for k in pairs(set) do table.insert(list, k) end
    table.sort(list)
    return list
end

---------------------------------------------------------
-- Publish merged file + sniff data
---------------------------------------------------------
local function publish_from_file(sniff_list)
    local ok, data = pcall(dofile, notesFile)
    if ok and type(data) == "table" then
        data = merge_unique(data, sniff_list)
    else
        data = sniff_list
    end
    notesChannel:clear()
    notesChannel:push(data)
end

---------------------------------------------------------
-- Main loop: fast sniff, throttled publish
---------------------------------------------------------
clear_notes_file()
publish_from_file({})

local last_publish = 0
while true do
    if quit_channel:peek() == "quit" then break end

    -- Always sniff quickly
    local sniff_list = sniff()

    -- Publish only if enough time has passed
    local now = love.timer.getTime()
    if now - last_publish >= 0.02 then -- ~50 Hz publish
        publish_from_file(sniff_list)
        last_publish = now
    end

    -- Small sleep to avoid pegging CPU
    timer.sleep(0.002) -- ~500 Hz sniff
end
