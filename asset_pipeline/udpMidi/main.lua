-- main.lua - LÖVE UDP MIDI receiver test
-- Receives 4-byte packets: [status, data1, data2, channel]

local socket = require("socket") -- works in LÖVE without extra install
local bit = require("bit")       -- for bitwise operations in LuaJIT/LÖVE

local UDP_HOST = "127.0.0.1"
local UDP_PORT = 49160

local udp
local messages = {}

function love.load()
    love.window.setTitle("UDP MIDI Receiver Test")
    udp = assert(socket.udp())
    assert(udp:setsockname(UDP_HOST, UDP_PORT))
    udp:settimeout(0) -- non-blocking
    table.insert(messages, string.format("Listening on %s:%d", UDP_HOST, UDP_PORT))
end

function love.update(dt)
    while true do
        local data, ip, port = udp:receive()
        if not data then break end
        if #data >= 4 then
            local status = data:byte(1)
            local d1     = data:byte(2)
            local d2     = data:byte(3)
            local chan   = data:byte(4)

            local highNibble = bit.band(status, 0xF0)
            local msgType
            if     highNibble == 0x90 then msgType = "noteon"
            elseif highNibble == 0x80 then msgType = "noteoff"
            elseif highNibble == 0xB0 then msgType = "cc"
            elseif highNibble == 0xE0 then msgType = "pitchbend"
            else   msgType = string.format("0x%X", status)
            end

            local line = string.format("%s | data1=%d data2=%d chan=%d",
                                       msgType, d1, d2, chan)
            table.insert(messages, line)
            if #messages > 25 then table.remove(messages, 1) end
        end
    end
end

function love.draw()
    love.graphics.setFont(love.graphics.newFont(14))
    for i, line in ipairs(messages) do
        love.graphics.print(line, 10, 10 + (i-1)*18)
    end
end
