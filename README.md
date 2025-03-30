# WarpMouse.spoon

When the mouse cursor reaches the edge of a display, warp the mouse cursor to
the edge of the next display in a list. This makes it appear as if the displays
were physically side by side, no matter what their arrangement is in the MacOS
display settings.

Example config:
```lua

WarpMouse = hs.loadSpoon("WarpMouse")
WarpMouse:start()
```
