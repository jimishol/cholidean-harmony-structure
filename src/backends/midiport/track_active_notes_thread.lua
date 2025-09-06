--- Active-notes tracker thread for the midiport backend.
-- Reads raw ALSA MIDI events, maintains a table of currently
-- active notes, and publishes them at ~50 Hz over the
-- `active_notes` channel. Exits cleanly when `"quit"` is
-- received on the `quit` channel.
-- @module src.backends.midiport.track_active_notes_thread

local quit_channel    = love.thread.getChannel("quit")
local notesChannel    = love.thread.getChannel("active_notes")
local midiPortChannel = love.thread.getChannel("midiPort")
local love_timer      = require("love.timer")

---------------------------------------------------------
-- MIDI source selection (default ALSA Midi Through 14:0)
---------------------------------------------------------
local midi_port_str = midiPortChannel:pop() or "14:0"
local src_client, src_port = midi_port_str:match("^(%d+):(%d+)$")
src_client = tonumber(src_client) or 14
src_port   = tonumber(src_port)   or 0

---------------------------------------------------------
-- Utilities for note-file merging
---------------------------------------------------------
local notesFile = "active_notes.lua"

--- Clear the notes file so it returns an empty table.
local function clear_notes_file()
  local f = io.open(notesFile, "w")
  if f then
    f:write("-- Auto-generated active MIDI notes\nreturn {}\n")
    f:close()
  end
end

--- Merge two lists of notes into one sorted, unique list.
-- @tparam table t1 first list of note numbers
-- @tparam table t2 second list of note numbers
-- @treturn table combined unique list of note numbers
local function merge_unique(t1, t2)
  local seen, result = {}, {}
  for _, v in ipairs(t1) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
    end
  end
  for _, v in ipairs(t2) do
    if not seen[v] then
      seen[v] = true
      table.insert(result, v)
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
    unsigned char type;     unsigned char flags;
    unsigned char tag;      unsigned char queue;
    unsigned char dest_client; unsigned char dest_port;
    unsigned char src_client;  unsigned char src_port;
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

  static const int SND_SEQ_OPEN_DUPLEX            = 3;
  static const int SND_SEQ_NONBLOCK               = 1;
  static const int SND_SEQ_EVENT_NOTEON           = 6;
  static const int SND_SEQ_EVENT_NOTEOFF          = 7;
  static const unsigned int SND_SEQ_PORT_CAP_WRITE      = 2;
  static const unsigned int SND_SEQ_PORT_CAP_SUBS_WRITE = 256;
  static const unsigned int SND_SEQ_PORT_TYPE_MIDI_GENERIC = 1;
]]

local C = ffi.load("asound")

-- Open ALSA sequencer
local seqpp = ffi.new("snd_seq_t*[1]")
assert(C.snd_seq_open(seqpp, "default", C.SND_SEQ_OPEN_DUPLEX, 0) == 0)
local seq = seqpp[0]
C.snd_seq_set_client_name(seq, "cholidean-ffi-backend")

-- Create a writable port to receive MIDI
local caps  = bit.bor(C.SND_SEQ_PORT_CAP_WRITE, C.SND_SEQ_PORT_CAP_SUBS_WRITE)
local ptype = C.SND_SEQ_PORT_TYPE_MIDI_GENERIC
local myport = C.snd_seq_create_simple_port(seq, "listen", caps, ptype)
assert(myport >= 0)

local cid = C.snd_seq_client_id(seq)
print(string.format("[midiport] ALSA client:port is %d:0", cid))

assert(C.snd_seq_connect_from(seq, myport, src_client, src_port) == 0)
C.snd_seq_nonblock(seq, C.SND_SEQ_NONBLOCK)

---------------------------------------------------------
-- Real ALSA sniffer
---------------------------------------------------------
local ACTIVE = {}

--- Poll ALSA for note on/off events and update ACTIVE.
-- Returns a sorted list of active note keys.
-- @treturn table sorted list of active notes
local function sniff()
  while true do
    local evpp = ffi.new("snd_seq_event_t*[1]")
    local r = C.snd_seq_event_input(seq, evpp)
    if r < 0 then break end

    local ev  = evpp[0]
    local t   = ev.type
    local ch  = ev.data.note.channel
    local key = ev.data.note.note
    local vel = ev.data.note.velocity

    if (t == C.SND_SEQ_EVENT_NOTEON or t == C.SND_SEQ_EVENT_NOTEOFF)
       and ch ~= 9 then
      if t == C.SND_SEQ_EVENT_NOTEOFF or vel == 0 then
        ACTIVE[key] = nil
      else
        ACTIVE[key] = true
      end
    end

    C.snd_seq_free_event(ev)
  end

  local list = {}
  for k in pairs(ACTIVE) do
    table.insert(list, k)
  end
  table.sort(list)
  return list
end

---------------------------------------------------------
-- Publish merged file + sniff data
---------------------------------------------------------
--- Merge disk data with sniff results and push to notesChannel.
-- @tparam table sniff_list list of newly sniffed notes
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

-- Main loop: sniff & publish ~50 Hz

clear_notes_file()
publish_from_file({})

local last_publish = love_timer.getTime()
while true do
  if quit_channel:peek() == "quit" then break end

  local notes = sniff()
  local now   = love_timer.getTime()
  if now - last_publish >= 0.02 then
    publish_from_file(notes)
    last_publish = now
  end

  love_timer.sleep(0.002)
end
