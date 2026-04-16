--- Utility module for the F1 Help Overlay.
-- @module src.utils.help_overlay
local Help = { active = false }

local unpack = unpack or table.unpack

-- 1. CENTRAL CONFIGURATION
local config = {
    boxW = 760,          		-- Total width of the black window
    boxH = 540,		 		-- Total height of the black window
    opacity = 0.85,	 		-- Total height of the black window
    x = 40,              		-- Left-most position of the window
    y = 40,              		-- Top-most position of the window
    col2_x_offset = 380, 		-- Horizontal gap between left and right columns
    desc_indent = 120,   		-- Tab space from Key to the ":" colon
    line_height = 20,    		-- Vertical spacing between text lines
    row1_y = 70,         		-- Vertical start for the top sections
    row2_y = 340,        		-- Vertical start for the bottom sections
    titles_alignment = "center",	-- Change to "center" to center headers over columns
    padding = 50	 		-- We subtract a small padding to account for the internal margin in center alignment
}

-- 2. DATA STRUCTURE
local sections = {
    system = {
        title = "* SYSTEM & MIDI *",
        color = {0.4, 0.7, 1},
        x_pos = config.x + 30,
        y_pos = config.y + config.row1_y,
        list = {
            {"F1",          "Toggle Help Overlay"},
            {"Ctrl+Q",    "Quit Application"},
            {"F10 (Linux)", "Hot-Reload (via run.sh)"},
            {":",           "Backend Command Menu"},
            {"", ""},
            {"Tab",         "Restart Current Song"},
            {"Return",      "Next Song (Advance)"},
            {"Shift+Return", "Stop Playback (Midi Live)"},
            {"P",           "Freeze Engine (No Live)"},
        }
    },
    visuals = {
        title = "* MESH & VISUALS *",
        color = {0.4, 1, 0.7},
        x_pos = config.x + 30 + config.col2_x_offset,
        y_pos = config.y + config.row1_y,
        list = {
            {"l", "Toggle Note Labels"},
            {"j", "Toggle Joint Notes"},
            {"e", "Toggle Edge Tubes"},
            {"c", "Toggle Curve Tubes"},
            {"s", "Toggle Major 7th Surfaces"},
            {"", ""},
            {"b", "Flashlight (Current Cam Pos)"},
            {"k", "Toggle Key Estimation"},
            {"h", "Toggle 'instant' vs 'offset' note-off"},
            {"- / +", "Simulate Time of Day"},
        }
    },
    mouse = {
        title = "[ MOUSE CONTROLS ]",
        color = {1, 0.6, 0.6},
        x_pos = config.x + 30,
        y_pos = config.y + config.row2_y,
        list = {
            {"Right + Drag",  "Rotate View (Yaw/Pitch)"},
            {"Middle + Drag", "Pan Forward / Back (Up/Down)"},
        }
    },
    camera = {
        title = "[ CAMERA MOVEMENT ]",
        color = {1, 0.6, 0.6},
        x_pos = config.x + 30 + config.col2_x_offset,
        y_pos = config.y + config.row2_y,
        list = {
            {"Space",      "Reset View Orientation"},
            {"F",          "Reset Field of View"},
            {"Arrows",     "Rotate / Pitch Camera"},
            {"Ctrl+Up/Dn", "Zoom In / Out"},
            {"Shift+Up/Dn",  "Move Forward / Backward"},
            {"Shift+Left/Right",  "Rotate 12-Note Map"},
        }
    }
}

function Help:toggle()
    self.active = not self.active
end

function Help:draw()
    if not self.active then return end

    love.graphics.push("all")
    love.graphics.origin()

    -- Backdrop
    love.graphics.setColor(0, 0, 0, config.opacity)
    love.graphics.rectangle("fill", config.x, config.y, config.boxW, config.boxH, 15, 15)
    love.graphics.setLineWidth(2)
    love.graphics.setColor(1, 1, 1, 0.15)
    love.graphics.rectangle("line", config.x, config.y, config.boxW, config.boxH, 15, 15)

    -- Centered Main Title
    love.graphics.setColor(1, 0.8, 0)
    local font = love.graphics.getFont()
    local main_title = "CHOLIDEAN HARMONY STRUCTURE REFERENCE"
    love.graphics.print(main_title, config.x + (config.boxW - font:getWidth(main_title)) / 2, config.y + 20)

        for _, s in pairs(sections) do
            -- 1. Calculate Title Position
            local title_x = s.x_pos
            if config.titles_alignment == "center" then
                -- We treat each column as having a width of (boxW / 2)
                local column_width = config.boxW / 2
                local text_width = font:getWidth(s.title)

                -- Center the text within that half-width, then add the global window X
                -- We subtract a small padding (30) to account for the internal margin
                title_x = s.x_pos + (column_width / 2) - (text_width / 2) - config.padding
            end

            love.graphics.setColor(unpack(s.color))
            love.graphics.print(s.title, title_x, s.y_pos)

        -- 2. Draw Items
        for i, item in ipairs(s.list) do
            local key, desc = item[1], item[2]
            local item_y = s.y_pos + 30 + ((i - 1) * config.line_height)

            if key ~= "" then
                love.graphics.setColor(0.7, 0.7, 0.7)
                love.graphics.print(key, s.x_pos, item_y)
                love.graphics.setColor(1, 1, 1)
                love.graphics.print(": " .. desc, s.x_pos + config.desc_indent, item_y)
            end
        end
    end

    love.graphics.pop()
end

return Help
