--- Null backend stub for the active‐notes tracking thread (Channel + file pass-through).
local quit_channel    = love.thread.getChannel("quit")
local backend_channel = love.thread.getChannel("backend")
local port_channel    = love.thread.getChannel("shellPort")
local host_channel    = love.thread.getChannel("shellHost")
local font_channel    = love.thread.getChannel("soundfont")
local songs_channel   = love.thread.getChannel("songs")
local notesChannel    = love.thread.getChannel("active_notes")

backend_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

local timer     = require("love.timer")
local notesFile = "active_notes.lua"

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
-- Pseudo-sniffer: simulates reading from ALSA port 14:0
---------------------------------------------------------
local active_notes = {} -- keyed by "channel:key"

local function sniff()
    -- Simulate some note events
    -- In real code, this would read from ALSA and update active_notes
    -- Here we just fake a sequence

    -- Example: toggle some notes every call
    local t = os.time() % 4
    if t == 0 then
        active_notes["0:62"] = { channel=0, key=62 } -- D4
        active_notes["0:71"] = { channel=0, key=71 } -- B4
    elseif t == 1 then
        active_notes["0:62"] = nil -- note off D4
        active_notes["0:74"] = { channel=0, key=74 } -- D5
    elseif t == 2 then
        active_notes["0:71"] = nil -- note off B4
    elseif t == 3 then
        active_notes["0:62"] = { channel=0, key=62 }
        active_notes["0:71"] = { channel=0, key=71 }
        active_notes["0:74"] = { channel=0, key=74 }
    end

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
-- Main loop
---------------------------------------------------------
clear_notes_file()
publish_from_file({})

while true do
    if quit_channel:peek() == "quit" then break end
    local sniff_list = sniff() -- get pseudo-active notes
    publish_from_file(sniff_list)
    timer.sleep(0.05)
end
