-- midiport backend thread: active-notes tracking via ALSA FFI

---------------------------------------------------------
-- Thread channels
---------------------------------------------------------
local quit_channel    = love.thread.getChannel("quit")
local backend_channel = love.thread.getChannel("backend")
local port_channel    = love.thread.getChannel("shellPort")
local host_channel    = love.thread.getChannel("shellHost")
local font_channel    = love.thread.getChannel("soundfont")
local songs_channel   = love.thread.getChannel("songs")
local notesChannel    = love.thread.getChannel("active_notes")
local midiPortChannel = love.thread.getChannel("midiPort")

-- Clear startup chatter
backend_channel:pop()
port_channel:pop()
host_channel:pop()
font_channel:pop()
songs_channel:pop()

-- Get desired MIDI source port from main (e.g. "14:0"), default to ALSA Midi Through
local midi_port_str = midiPortChannel:pop() or "14:0"
local src_client, src_port = midi_port_str:match("^(%d+):(%d+)$")
src_client, src_port = tonumber(src_client) or 14, tonumber(src_port) or 0

---------------------------------------------------------
-- Utilities
---------------------------------------------------------
local timer     = require("love.timer")
local notesFile = "active_notes.lua"

local function clear_notes_file()
    local f = io.open(notesFile, "w")
    if f then
        f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
        f:close()
    end
end

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
-- ALSA FFI setup
---------------------------------------------------------
local ffi = require("ffi")
local bit = require("bit")

ffi.cdef[[
typedef struct _snd_seq snd_seq_t;
typedef struct _snd_seq_event snd_seq_event_t;

typedef struct {
    unsigned char channel;
    unsigned char note;
    unsigned char velocity;
    unsigned char off_velocity;
    unsigned int  duration;
} snd_seq_ev_note_t;

typedef union {
    snd_seq_ev_note_t note;
    unsigned char raw8[12];
    unsigned int  raw32[3];
} snd_seq_event_data_t;

struct _snd_seq_event {
    unsigned char type;
    unsigned char flags;
    unsigned char tag;
    unsigned char queue;
    unsigned char dest_client;
    unsigned char dest_port;
    unsigned char src_client;
    unsigned char src_port;
    unsigned char reserved[8];
    snd_seq_event_data_t data;
};

int snd_seq_open(snd_seq_t **handle, const char *name, int streams, int mode);
int snd_seq_set_client_name(snd_seq_t *handle, const char *name);
int snd_seq_create_simple_port(snd_seq_t *handle, const char *name,
                               unsigned int caps, unsigned int type);
int snd_seq_connect_from(snd_seq_t *handle, int myport, int src_client, int src_port);
int snd_seq_event_input(snd_seq_t *handle, snd_seq_event_t **ev);
int snd_seq_nonblock(snd_seq_t *handle, int nonblock);
void snd_seq_free_event(snd_seq_event_t *ev);
int snd_seq_client_id(snd_seq_t *handle);

static const int SND_SEQ_OPEN_DUPLEX = 3;
static const int SND_SEQ_NONBLOCK    = 1;

static const int SND_SEQ_EVENT_NOTEON  = 6;
static const int SND_SEQ_EVENT_NOTEOFF = 7;

static const unsigned int SND_SEQ_PORT_CAP_WRITE      = 2;
static const unsigned int SND_SEQ_PORT_CAP_SUBS_WRITE = 256;
static const unsigned int SND_SEQ_PORT_TYPE_MIDI_GENERIC = 1;
]]

local C = ffi.load("asound")

-- Open ALSA sequencer in duplex mode
local seqpp = ffi.new("snd_seq_t*[1]")
assert(C.snd_seq_open(seqpp, "default", C.SND_SEQ_OPEN_DUPLEX, 0) == 0, "snd_seq_open failed")
local seq = seqpp[0]
C.snd_seq_set_client_name(seq, "cholidean-ffi-backend")

-- Create a writable port to receive from source
local caps  = bit.bor(C.SND_SEQ_PORT_CAP_WRITE, C.SND_SEQ_PORT_CAP_SUBS_WRITE)
local ptype = C.SND_SEQ_PORT_TYPE_MIDI_GENERIC
local myport = C.snd_seq_create_simple_port(seq, "listen", caps, ptype)
assert(myport >= 0, "create_simple_port failed")

-- Show our client:port for debugging
local cid = C.snd_seq_client_id(seq)
print(string.format("[midiport backend] ALSA client:port is %d:0", cid))

-- Connect from requested source port
assert(C.snd_seq_connect_from(seq, myport, src_client, src_port) == 0,
       string.format("connect_from %d:%d failed", src_client, src_port))
C.snd_seq_nonblock(seq, C.SND_SEQ_NONBLOCK)

---------------------------------------------------------
-- Real ALSA sniffer
---------------------------------------------------------
local ACTIVE = {}

local function sniff()
    while true do
        local evpp = ffi.new("snd_seq_event_t*[1]")
        local r = C.snd_seq_event_input(seq, evpp)
        if r < 0 then break end
        local ev = evpp[0]
        local t  = ev.type
        local ch = ev.data.note.channel
        local key = ev.data.note.note
        local vel = ev.data.note.velocity
        if t == C.SND_SEQ_EVENT_NOTEON or t == C.SND_SEQ_EVENT_NOTEOFF then
            if ch ~= 9 then
                if t == C.SND_SEQ_EVENT_NOTEOFF or vel == 0 then
                    ACTIVE[key] = nil
                else
                    ACTIVE[key] = true
                end
            end
        end
        C.snd_seq_free_event(ev)
    end
    local list = {}
    for k in pairs(ACTIVE) do table.insert(list, k) end
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
