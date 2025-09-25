// udp-midi-bridge.js
// Streams MIDI input events over UDP in a compact binary format

const dgram = require('dgram');
const easymidi = require('easymidi');

// Parse command-line arguments
const DEBUG = process.argv.includes('--debug');

const UDP_HOST = process.argv[2] || '127.0.0.1';
const UDP_PORT = 49160;

// Create UDP socket
const sock = dgram.createSocket('udp4');

// List available MIDI inputs
const inputs = easymidi.getInputs();
if (DEBUG) console.log('Available MIDI inputs:', inputs);

if (!inputs.length) {
  console.error('No MIDI inputs found.');
  process.exit(1);
}

// Select MIDI input port
let selectedInput = 'midiBridgePort';
if (!inputs.includes(selectedInput)) {
  const isLinux = process.platform === 'linux';
  const fallbackLinux = 'Midi Through:Midi Through Port-0 14:0';
  if (isLinux && inputs.includes(fallbackLinux)) {
    selectedInput = fallbackLinux;
  } else {
    selectedInput = inputs[0];
  }
}

// Open the selected MIDI input
const input = new easymidi.Input(selectedInput);
console.log(`Listening on MIDI input: ${selectedInput}`);
console.log(`Streaming UDP to ${UDP_HOST}:${UDP_PORT} ...`);

// Helper to send a 4-byte packet: [status, note/ctrl, value, channel]
function sendMidi(statusByte, data1, data2, channel, type) {
  const buf = Buffer.alloc(4);
  buf[0] = statusByte;
  buf[1] = data1;
  buf[2] = data2;
  buf[3] = channel;
  sock.send(buf, UDP_PORT, UDP_HOST);

  if (DEBUG) {
    console.log(`${type} → [${statusByte.toString(16)} ${data1} ${data2} ch${channel}]`);
  }
}

// Map easymidi events to raw MIDI status bytes
input.on('noteon',  m => sendMidi(0x90, m.note, m.velocity, m.channel, 'noteon'));
input.on('noteoff', m => sendMidi(0x80, m.note, m.velocity, m.channel, 'noteoff'));
input.on('cc',      m => sendMidi(0xB0, m.controller, m.value, m.channel, 'cc'));
input.on('pitch',   m => {
  const lsb = m.value & 0x7F;
  const msb = (m.value >> 7) & 0x7F;
  sendMidi(0xE0, lsb, msb, m.channel, 'pitch');
});
