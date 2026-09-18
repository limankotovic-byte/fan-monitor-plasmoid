# Changelog

## [1.3.0] - 2026-09-18

### Graph & History
- Fixed graph history being cleared when switching between 2h, 5h, and 8h ranges
- History retention is now independent of the selected viewport and keeps up to 8 hours of one-minute buckets
- Fixed the graph appearing frozen after running for a while by advancing the chart clock independently of sensor changes
- Fixed stale Canvas contents when history becomes empty or is rebuilt
- Manual refresh no longer inserts a duplicate graph point before fresh sensor data arrives

### Sensors & Settings
- Fixed temperature parsing for normal `lm-sensors` lines that include `high`, `crit`, or `low` thresholds on the same line
- Fan RPM parsing is now case-insensitive and accepts generic labelled RPM readings
- Fixed `showTemperature` and `showFanSpeed` boolean defaults so disabling them actually works
- Fixed update interval seconds/milliseconds conversion in the configuration UI

### Maintenance
- Updated version metadata and configuration UI to 1.3.0
- Refreshed README release notes and replaced the inaccurate zero-overhead claim with low-overhead wording
- Removed placeholder author email from plugin metadata

## [1.1] - 2026-03-24

### 🔧 Code Quality & Bug Fixes

#### Critical Fixes
- **Eliminated code duplication**: Extracted `getMaxFanSpeed()` and `getMaxTemperature()` helper functions, replacing 5+ duplicated inline loops throughout the codebase
- **Fixed input validation in `parseSensorData()`**: Added guard clause for empty, null, or non-string input that previously could cause crashes
- **Fixed regex result validation**: Added check for empty `match[1]` results to prevent empty-string keys in `fanData`/`tempData` objects
- **Fixed history leak on time range change**: Added `clearAndResetHistory()` function that properly clears old data points when user switches between 2h/5h/8h views

#### Performance Improvements
- **Canvas render strategy**: Added `renderStrategy: Canvas.Cooperative` to all Canvas elements (`fanCanvasCompact`, `fanCanvasFull`, `gridCanvas`, `chartCanvas`, `textCanvasFull`) for better rendering performance
- **Reduced unnecessary repaints**: Helper functions prevent redundant property evaluation chains

#### Code Style & Maintainability
- **Replaced magic numbers with named constants**:
  - `kMaxRpmScale` (5000) — Y-axis maximum
  - `kAnimationFpsInterval` (100) — animation timer interval
  - `kMaxRpmForSpeedFactor` (4000) — RPM-to-animation speed mapping
  - `kIdleUpdateInterval` (30000) — background polling interval
  - `kChartRefreshInterval` (30000) — chart slide refresh interval
  - `kMinSensorOutputLen` (10) — minimum valid sensor output length
  - `kYAxisSteps` (5) — number of Y-axis grid divisions
- **Fixed inconsistent code formatting**: Standardized spacing in conditions (e.g., `if (fanData[f] > maxSpd)` instead of `if(fanData[f]>maxSpd)`)
- **Added JSDoc-style comments** to all functions: `getMaxFanSpeed()`, `getMaxTemperature()`, `addFanSpeed()`, `clearAndResetHistory()`, `updateSensorData()`, `useSimulatedData()`, `parseSensorData()`
- **Added section header comments** for better code navigation
- **Fixed version inconsistency**: metadata.json previously showed "1.2" while ConfigGeneral.qml showed "1.0" — both now correctly show "1.1"

### 📄 Documentation
- Added this `CHANGELOG.md` file
- Updated `README.md` with version badge, changelog section, and contribution guidelines

---

## [1.0] - 2026-03-07

### Initial Release
- Real-time fan speed and temperature monitoring via `lm-sensors`
- Three visual themes: Utterly Sweet (Solid), Clean Window (Transparent), Utterly Sweet (Translucent)
- Animated fan icon with RPM-proportional speed
- Dynamic RPM chart with configurable time ranges (2h, 5h, 8h)
- Configurable warning and critical thresholds
- Simulated data fallback for testing without hardware sensors
