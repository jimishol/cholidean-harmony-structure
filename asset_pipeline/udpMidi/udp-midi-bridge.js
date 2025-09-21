// udp-midi-bridge.js
// Streams MIDI input events over UDP in a compact binary format

const dgram = require('dgram');
const easymidi = require('easymidi');

const UDP_HOST = '127.0.0.1';
const UDP_PORT = 49160;

// Create UDP socket
const sock = dgram.createSocket('udp4');

// List available MIDI inputs
const inputs = easymidi.getInputs();
console.log('Available MIDI inputs:', inputs);

if (!inputs.length) {
  console.error('No MIDI inputs found.');
  process.exit(1);
}

// Open the first MIDI input (change index if needed)
const input = new easymidi.Input(inputs[0], true);
console.log(`Listening on MIDI input: ${inputs[0]}`);

// Helper to send a 4-byte packet: [status, note/ctrl, value, channel]
function sendMidi(statusByte, data1, data2, channel) {
  const buf = Buffer.alloc(4);
  buf[0] = statusByte;
  buf[1] = data1;
  buf[2] = data2;
  buf[3] = channel;
  sock.send(buf, UDP_PORT, UDP_HOST);
}

// Map easymidi events to raw MIDI status bytes
input.on('noteon',  m => sendMidi(0x90, m.note, m.velocity, m.channel));
input.on('noteoff', m => sendMidi(0x80, m.note, m.velocity, m.channel));
input.on('cc',      m => sendMidi(0xB0, m.controller, m.value, m.channel));
input.on('pitch',   m => {
  // Pitch bend is 14-bit: split into two 7-bit values
  const lsb = m.value & 0x7F;
  const msb = (m.value >> 7) & 0x7F;
  sendMidi(0xE0, lsb, msb, m.channel);
});

console.log(`Streaming UDP to ${UDP_HOST}:${UDP_PORT} ...`);
