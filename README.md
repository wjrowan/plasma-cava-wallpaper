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

## Requirements

- KDE Plasma 6
- [`cava`](https://github.com/karlstav/cava)
- Python 3 with the `websockets` package (used to stream CAVA's output into
  QML)

## Install

```bash
git clone https://github.com/wjrowan/plasma-cava-wallpaper.git ~/.local/share/plasma/wallpapers/com.github.willi.cavawallpaper
systemctl --user restart plasma-plasmashell.service
```

Then: right-click Desktop → Configure Desktop and Wallpaper → Wallpaper Type
→ "Cava Top/Bottom Bars".

Note the clone target directory name must stay
`com.github.willi.cavawallpaper` - it has to match the plugin id in
`metadata.json` for Plasma to find it.

Out of the box it uses your system's stock wallpaper with adaptive (background-tinted) bar colors, so it looks reasonable before you configure anything.

## Settings

- Background image + fill mode. Leave the image empty to use a stock system
  wallpaper - several common distro paths are tried in turn, falling back to
  a dark gradient if none are present.
- Beat-reactive background effects: bass-driven zoom pulse, plus
  brightness/saturation pulse driven by overall energy (each with its own
  intensity slider, and a master on/off)
- Framerate, bar count, bar gap, bar max height
- Top/bottom row offset (px) - nudge a row off the screen edge, e.g. so the
  bottom row clears a panel docked there
- Bar color mode: Solid (pick top/bottom colors), Rainbow (full hue spread
  across the row), or Adaptive (hue sampled from the background image, with
  a gentle spread across the row)
- Bar opacity
- Noise reduction, automatic sensitivity

## License

GPL-3.0 - see [LICENSE](LICENSE).

This project incorporates code from
[luisbocanegra/kurve](https://github.com/luisbocanegra/kurve), which is
GPL-3.0, so this derivative work is GPL-3.0 as well.

## Credit

The CAVA process integration (`Cava.qml`, `components/ProcessMonitor.qml`,
`components/RunCommand.qml`, `tools/commandMonitor`) is taken from
[luisbocanegra/kurve](https://github.com/luisbocanegra/kurve) (formerly
`luisbocanegra.audio.visualizer`), an Applet-based CAVA visualizer widget -
`Cava.qml`, `RunCommand.qml` and `commandMonitor` are verbatim copies, and
`ProcessMonitor.qml` is adapted from its `ProcessMonitorFallback.qml`. Those
files carry SPDX headers noting their origin.

The rest - the Wallpaper-plugin structure, bar rendering, color modes and
beat-reactive background effects - is written for this project.
