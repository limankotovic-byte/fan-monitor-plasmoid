# Changelog

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
