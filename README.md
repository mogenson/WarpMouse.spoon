# WarpMouse.spoon

Warp the mouse cursor from the edge of one screen to the edge of another screen to simulate external monitors being placed side by side.

This is most useful for [PaperWM.spoon](https;//github.com/mogenson/PaperWM.spoon), which need to arrange screens vertically to avoid off-screen windows overlapping with adjacent screens.

# Usage

In the MacOS display settings, arrange the screens vertically. WarpMouse.spoon will transform the direction of screens from vertical (top to bottom) to horizontal (left to right).

<img width="607" alt="vertical_displays" src="https://github.com/user-attachments/assets/1f8e6b4b-4bea-4082-bf63-03b605961484" />

In the above example, screen 1 will be to the left of screen 2 and screen 3 will be to the right of screen 2.

When you move the mouse to the left edge of screen 2, the cursor will warp to the right edge of screen 1. When you move the mouse to the right edge of screen 2, the cursor will warp to the left edge of screen 3. The cursor will not be warped when the mouse is moved to an edge at an end display (eg the left edge of screen 1 or the right edge of screen 3).

You can also drag floating windows to a new screen through a warped edge.

You can still move the mouse between screens through the top and bottom edges. PaperWM needs to be able to drag windows between screens when using the hotkey to move a window to a new space.

WarpMouse.spoon will hot reload it's screen arangement without intervention when a screen is added / removed or the layout in the display settings is changed.

Example Hammerspoon config:
```lua
WarpMouse = hs.loadSpoon("WarpMouse")
WarpMouse:start()
```
