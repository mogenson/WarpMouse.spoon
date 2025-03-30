local WarpMouse        = {}
WarpMouse.__index      = WarpMouse

-- Metadata
WarpMouse.name         = "WarpMouse"
WarpMouse.version      = "0.1"
WarpMouse.author       = "Michael Mogenson"
WarpMouse.homepage     = "https://github.com/mogenson/WarpMouse.spoon"
WarpMouse.license      = "MIT - https://opensource.org/licenses/MIT"

local getCurrentScreen = hs.mouse.getCurrentScreen
local absolutePosition = hs.mouse.absolutePosition
local screenFind       = hs.screen.find
WarpMouse.logger       = hs.logger.new(WarpMouse.name)

local function relative_y(y, current_frame, new_frame)
    return new_frame.h * (y - current_frame.y) / current_frame.h + new_frame.y
end

function WarpMouse:start()
    self.screens = hs.screen.allScreens()

    table.sort(self.screens, function(a, b)
        -- sort list by screen postion top to bottom
        return select(2, a:position()) < select(2, b:position())
    end)

    for i, screen in ipairs(self.screens) do
        local uuid = screen:getUUID()
        self.screens[i] = uuid -- replace hs.screen with uuid
        self.screens[uuid] = i -- also create a mapping from uuid to index
    end

    self.logger.df("Starting with screens from left to right: %s",
        hs.inspect(self.screens))

    self.mouse_watcher = hs.eventtap.new({
        hs.eventtap.event.types.mouseMoved,
        hs.eventtap.event.types.leftMouseDragged,
        hs.eventtap.event.types.rightMouseDragged,
    }, function(event)
        local cursor = event:location()
        local screen = getCurrentScreen()
        local frame = screen:fullFrame()
        if cursor.x == frame.x then
            local uuid = screen:getUUID()
            local left_uuid = self.screens[self.screens[uuid] - 1]
            self.logger.df("cursor.x %f frame.x %f screen %s left_screen %s",
                cursor.x, frame.x, uuid, left_uuid)
            if left_uuid then
                local left_frame = screenFind(left_uuid):fullFrame()
                local y = relative_y(cursor.y, frame, left_frame)
                absolutePosition({ x = left_frame.x2 - 3, y = y })
            end
        elseif cursor.x > frame.x2 - 0.5 then
            local uuid = screen:getUUID()
            local right_uuid = self.screens[self.screens[uuid] + 1]
            self.logger.df("cursor.x %f frame.x %f screen %s right_screen %s",
                cursor.x, frame.x, uuid, right_uuid)
            if right_uuid then
                local right_frame = screenFind(right_uuid):fullFrame()
                local y = relative_y(cursor.y, frame, right_frame)
                absolutePosition({ x = right_frame.x + 2, y = y })
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
    self.logger.d("Stopping")

    if self.mouse_watcher then
        self.mouse_watcher:stop()
        self.mouse_watcher = nil
    end

    if self.screen_watcher then
        self.screen_watcher:stop()
        self.screen_watcher = nil
    end

    self.screens = nil
end

return WarpMouse
