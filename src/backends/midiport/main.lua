-- test_alsa_sniff.lua (run with: love . in this folder)

local ok_ffi, ffi = pcall(require, "ffi")
assert(ok_ffi, "LuaJIT FFI required")
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

static const int SND_SEQ_OPEN_INPUT  = 1;
static const int SND_SEQ_OPEN_OUTPUT = 2;
static const int SND_SEQ_OPEN_DUPLEX = 3;
static const int SND_SEQ_NONBLOCK    = 1;

static const int SND_SEQ_EVENT_NOTEON  = 6;
static const int SND_SEQ_EVENT_NOTEOFF = 7;

static const unsigned int SND_SEQ_PORT_CAP_WRITE      = 2;
static const unsigned int SND_SEQ_PORT_CAP_SUBS_WRITE = 256;
static const unsigned int SND_SEQ_PORT_TYPE_MIDI_GENERIC = 1;
]]

local C = ffi.load("asound")

-- ALSA init
local seqpp = ffi.new("snd_seq_t*[1]")
assert(C.snd_seq_open(seqpp, "default", C.SND_SEQ_OPEN_DUPLEX, 0) == 0, "snd_seq_open failed")
local seq = seqpp[0]
C.snd_seq_set_client_name(seq, "cholidean-ffi-test")

local caps  = bit.bor(C.SND_SEQ_PORT_CAP_WRITE, C.SND_SEQ_PORT_CAP_SUBS_WRITE)
local ptype = C.SND_SEQ_PORT_TYPE_MIDI_GENERIC
local myport = C.snd_seq_create_simple_port(seq, "listen", caps, ptype)
assert(myport >= 0, "create_simple_port failed")

-- Show our client:port so you can check in `aconnect -l`
local cid = C.snd_seq_client_id(seq)
print(string.format("Our ALSA client:port is %d:0", cid))

-- Connect from 14:0 (Midi Through)
assert(C.snd_seq_connect_from(seq, myport, 14, 0) == 0, "connect_from 14:0 failed")
C.snd_seq_nonblock(seq, C.SND_SEQ_NONBLOCK)

print("ALSA FFI running: listening on 14:0 (ALSA channels 0-15; 9 = MIDI ch 10)")

-- On-screen log buffer
local lines = {}
local function log(msg)
    print(msg)
    table.insert(lines, msg)
    if #lines > 40 then table.remove(lines, 1) end
end

-- Read all pending events once (non-blocking)
local function read_once()
    while true do
        local evpp = ffi.new("snd_seq_event_t*[1]")
        local r = C.snd_seq_event_input(seq, evpp)
        if r < 0 then break end -- no more events queued now

        local ev = evpp[0]
        local t  = ev.type
        local ch  = ev.data.note.channel
        local key = ev.data.note.note
        local vel = ev.data.note.velocity

        -- Always dump raw event info
        log(string.format("RAW type=%d ch=%d key=%d vel=%d", t, ch, key, vel))

        -- Filter for note on/off
        if t == C.SND_SEQ_EVENT_NOTEON or t == C.SND_SEQ_EVENT_NOTEOFF then
            if ch ~= 9 then
                if t == C.SND_SEQ_EVENT_NOTEOFF or vel == 0 then
                    log(string.format("OFF ch=%d key=%d", ch, key))
                else
                    log(string.format("ON  ch=%d key=%d vel=%d", ch, key, vel))
                end
            end
        end

        C.snd_seq_free_event(ev)
    end
end

-- LÖVE callbacks
function love.update(dt)
    read_once()
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Listening on ALSA 14:0 — Esc to quit", 10, 10)

    local y = 30
    local start = math.max(1, #lines - 34)
    for i = start, #lines do
        love.graphics.print(lines[i], 10, y)
        y = y + 16
    end
end

function love.keypressed(key)
    if key == "escape" then love.event.quit() end
end
