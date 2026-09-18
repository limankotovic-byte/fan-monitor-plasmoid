# Fan Monitor (KDE Plasma 6 Widget)

![Version](https://img.shields.io/badge/version-1.3.0-blue)
![Plasma](https://img.shields.io/badge/KDE%20Plasma-6.0%2B-green)
![License](https://img.shields.io/badge/license-GPL%20v3.0-orange)

![Screenshot](preview_en.png)

A beautiful, translucent fan and temperature monitoring widget for KDE Plasma 6. Designed to blend perfectly with neon and translucent themes (like *"Utterly Sweet"*), while offering custom aesthetic adjustments and a deliberately low-overhead animation and polling design.

## Features
- **Real-time Monitoring:** Keep track of your system temperatures and fan speeds.
- **Three Themes:**
  1. `Utterly Sweet (Solid)` — Neon cyberpunk gradients.
  2. `Clean Window (Transparent)` — Borderless, relying purely on KWin's system blur effects.
  3. `Utterly Sweet (Translucent)` — Lighter backdrop, allowing background windows and wallpapers to bleed through.
- **Optimized Animation Engine:** Animations use QtQuick timers capped at 10 FPS to keep CPU/GPU overhead low. The animation pace dynamically scales with the RPM of your fans!
- **On/Off Toggle:** Optionally freeze animations altogether for 100% peace of mind.
- **Dynamic Graphical Chart:** Visualize heat fluctuations over the last chosen timeframe (e.g., 2, 5, or 8 hours).
- **Responsive Status Alerts:** Colors elegantly shift to orange and critical red thresholds.

## Requirements
* KDE Plasma 6 (`org.kde.plasma.core 6.0+`)
* `lm-sensors` installed on the host system to provide real sensory data.

## Installation

### From Source/Manual:
Clone the repository and install using `kpackagetool6`:
```bash
git clone https://github.com/limankotovic-byte/fan-monitor-plasmoid.git
cd fan-monitor-plasmoid
kpackagetool6 -t Plasma/Applet -i package
```

*(To upgrade an existing installation: `kpackagetool6 -t Plasma/Applet -u package`)*

After installation, "Fan Monitor" will appear in your "Add Widgets" panel in KDE Plasma.

## Setup (Sensors)
Run the `sensors-detect` command once to ensure your kernel is reading all available fan speeds and diodes correctly:
```bash
sudo sensors-detect
```

## What's New in v1.3.0

See [CHANGELOG.md](CHANGELOG.md) for the full list of changes.

**Highlights:**
- 📈 Graph history now keeps up to 8 hours of data regardless of the selected viewport
- 🔁 Switching between 2h / 5h / 8h no longer wipes the graph
- 🕒 Time labels and chart position advance automatically instead of visually freezing
- 🧹 The chart canvas is cleared correctly when history is empty or rebuilding
- 🌡️ Temperature parsing now accepts normal `lm-sensors` lines containing high/crit limits
- 🌀 Fan parsing is case-insensitive and works with generic RPM labels
- ⚙️ Fixed the seconds ↔ milliseconds conversion in the update interval setting
- ✅ Fixed boolean display settings so disabled really means disabled

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License
Provided under the GNU GPL v3.0 License.
