local WarpMouse                = {}
WarpMouse.__index              = WarpMouse

-- Metadata
WarpMouse.name                 = "WarpMouse"
WarpMouse.version              = "0.2"
WarpMouse.author               = "Michael Mogenson"
WarpMouse.homepage             = "https://github.com/mogenson/WarpMouse.spoon"
WarpMouse.license              = "MIT - https://opensource.org/licenses/MIT"

local getCurrentScreen <const> = hs.mouse.getCurrentScreen
local absolutePosition <const> = hs.mouse.absolutePosition
local screenFind <const>       = hs.screen.find
local isPointInRect <const>    = hs.geometry.isPointInRect
WarpMouse.logger               = hs.logger.new(WarpMouse.name)
WarpMouse.margin               = 2

-- a global variable that PaperWM can use to disable the eventtap while Mission Control is open
_WarpMouseEventTap             = nil

local function relative_y(y, current_frame, new_frame)
    return new_frame.h * (y - current_frame.y) / current_frame.h + new_frame.y
end

local function warp(from, to, current_frame, new_frame)
    absolutePosition(current_frame.center)
    absolutePosition(new_frame.center)
    absolutePosition(to)
    if WarpMouse.logger.getLogLevel() < 5 then
        WarpMouse.logger.df("Warping mouse from %s to %s", hs.inspect(from), hs.inspect(to))
    end
end

local function get_screen(cursor, frames)
    for index, frame in ipairs(frames) do
        if isPointInRect(cursor, frame) then
            return index, frame
        end
    end
    assert("cursor is not in any screen")
end

function WarpMouse:start()
    self.screens = hs.screen.allScreens()

    table.sort(self.screens, function(a, b)
        -- sort list by screen postion top to bottom
        return select(2, a:position()) < select(2, b:position())
    end)

    for i, screen in ipairs(self.screens) do
        self.screens[i] = screen:fullFrame()
    end

    self.logger.f("Starting with screens from left to right: %s",
        hs.inspect(self.screens))

    _WarpMouseEventTap = hs.eventtap.new({
        hs.eventtap.event.types.mouseMoved,
        hs.eventtap.event.types.leftMouseDragged,
        hs.eventtap.event.types.rightMouseDragged,
    }, function(event)
        local cursor = event:location()
        local index, frame = get_screen(cursor, self.screens)
        if cursor.x == frame.x then
            local left_frame = self.screens[index - 1]
            if left_frame then
                warp(cursor, { x = left_frame.x2 - self.margin, y = relative_y(cursor.y, frame, left_frame) }, frame,
                    left_frame)
            end
        elseif cursor.x > frame.x2 - 0.5 and cursor.x <= frame.x2 then
            local right_frame = self.screens[index + 1]
            if right_frame then
                warp(cursor, { x = right_frame.x + self.margin, y = relative_y(cursor.y, frame, right_frame) }, frame,
                    right_frame)
            end
        end
    end):start()

    self.screen_watcher = hs.screen.watcher.new(function()
        self.logger.d("Screen layout change")
        self:stop()
        self:start()
    end):start()
end

function WarpMouse:stop()
    self.logger.i("Stopping")

    if _WarpMouseEventTap then
        _WarpMouseEventTap:stop()
        _WarpMouseEventTap = nil
    end

    if self.screen_watcher then
        self.screen_watcher:stop()
        self.screen_watcher = nil
    end

    self.screens = nil
end

return WarpMouse
