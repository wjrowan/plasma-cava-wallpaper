# Cava Top/Bottom Bars

A KDE Plasma 6 Wallpaper plugin: your background image with CAVA-driven audio
bars pinned to the top and bottom of the screen.

## Why a Wallpaper plugin, not an Applet

Placing an audio visualizer Applet directly on the Desktop (rather than in a
panel) forces Plasma to recomposite the entire desktop + wallpaper on every
frame update - a known upstream Plasma/Qt cost, not something fixable from
QML (see [kurve#40](https://github.com/luisbocanegra/kurve/issues/40) and
[bugs.kde.org #507434](https://bugs.kde.org/show_bug.cgi?id=507434)). A
Wallpaper plugin doesn't have this problem: it *is* the desktop background,
so its own redraws are the expected compositing cost, not an extra layer on
top of a static one underneath it.

CAVA itself is cheap regardless of placement - profiled at ~1% CPU even at
254 bars in [kurve#164](https://github.com/luisbocanegra/kurve/issues/164).

## Install

```bash
git clone <this repo> ~/.local/share/plasma/wallpapers/com.github.willi.cavawallpaper
systemctl --user restart plasma-plasmashell.service
```

Then: right-click Desktop → Configure Desktop and Wallpaper → Wallpaper Type
→ "Cava Top/Bottom Bars".

## Settings

- Background image + fill mode
- Framerate, bar count, bar gap, bar max height
- Top/bottom row offset (px) - nudge a row off the screen edge, e.g. so the
  bottom row clears a panel docked there
- Bar color mode: Solid (pick top/bottom colors), Rainbow (full hue spread
  across the row), or Adaptive (hue sampled from the background image, with
  a gentle spread across the row)
- Bar opacity
- Noise reduction, automatic sensitivity

## Credit

The CAVA process integration (`Cava.qml`, `components/ProcessMonitor.qml`,
`components/RunCommand.qml`, `tools/commandMonitor`) is adapted from
[luisbocanegra/kurve](https://github.com/luisbocanegra/kurve) (formerly
`luisbocanegra.audio.visualizer`), an Applet-based CAVA visualizer widget.
This project is a separate, from-scratch Wallpaper plugin that reuses that
proven process-spawning approach rather than depending on the widget itself.
