import json
import re
import unittest
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
MAIN = (ROOT / "package/contents/ui/main.qml").read_text(encoding="utf-8")
CONFIG = (ROOT / "package/contents/config/main.xml").read_text(encoding="utf-8")
META = json.loads((ROOT / "package/metadata.json").read_text(encoding="utf-8"))

FAN_RE = re.compile(r"^(.+?):\s*(\d+)\s*RPM\b", re.I)
TEMP_RE = re.compile(r"^(.+?):\s*\+?(-?\d+(?:\.\d+)?)\s*°C\b", re.I)


def parse_fixture(text):
    fans, temps = {}, {}
    for raw in text.splitlines():
        line = raw.strip()
        m = FAN_RE.match(line)
        if m:
            fans[m.group(1).strip()] = int(m.group(2))
        m = TEMP_RE.match(line)
        if m:
            temps[m.group(1).strip()] = float(m.group(2))
    return fans, temps


class SensorParserRegressionTests(unittest.TestCase):
    def test_lm_sensors_threshold_suffix_is_accepted(self):
        sample = """coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +65.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +55.0°C  (high = +100.0°C, crit = +100.0°C)
cpu_fan:       2387 RPM
Fan 1:         1200 RPM
"""
        fans, temps = parse_fixture(sample)
        self.assertEqual(fans, {"cpu_fan": 2387, "Fan 1": 1200})
        self.assertEqual(temps, {"Package id 0": 65.0, "Core 0": 55.0})

    def test_negative_temperature_is_accepted(self):
        _, temps = parse_fixture("temp1: -3.5°C")
        self.assertEqual(temps["temp1"], -3.5)

    def test_qml_contains_the_regression_fixed_patterns(self):
        self.assertIn(r'line.match(/^(.+?):\s*(\d+)\s*RPM\b/i)', MAIN)
        self.assertIn(r'line.match(/^(.+?):\s*\+?(-?\d+(?:\.\d+)?)\s*°C\b/i)', MAIN)


class CompactUiRegressionTests(unittest.TestCase):
    def test_compact_rpm_text_uses_same_gradient_palette_as_fan(self):
        compact = re.search(
            r"compactRepresentation: Item \{(.*?)// ==========================================\n    // FULL REPRESENTATION",
            MAIN,
            re.S,
        )
        self.assertIsNotNone(compact)
        block = compact.group(1)
        self.assertIn("id: textCanvasCompact", block)
        text_canvas = block.split("id: textCanvasCompact", 1)[1]
        self.assertIn("var gradient = ctx.createLinearGradient(0, 0, width, 0)", text_canvas)
        self.assertIn("gradient.addColorStop(0, colorAccentCyan.toString())", block)
        self.assertIn("gradient.addColorStop(0.5, colorAccentPurple.toString())", block)
        self.assertIn("gradient.addColorStop(1, colorAccentPink.toString())", block)
        self.assertIn("ctx.fillText(parent.rpmText, 0, height / 2)", block)


class GraphRegressionTests(unittest.TestCase):
    def test_history_is_independent_of_selected_viewport(self):
        self.assertIn("readonly property int kMaxHistoryHours: 8", MAIN)
        self.assertIn("readonly property int kMaxHistoryPoints: 480", MAIN)
        self.assertIn("let cutoff = now - (kMaxHistoryHours * 3600 * 1000)", MAIN)

    def test_range_switch_does_not_clear_history(self):
        block = re.search(r"onCurrentIndexChanged:\s*\{(.*?)\n\s*\}", MAIN, re.S)
        self.assertIsNotNone(block)
        self.assertNotIn("fanHistory = []", block.group(1))
        self.assertNotIn("clearAndResetHistory", MAIN)

    def test_chart_clock_is_reactive(self):
        self.assertIn("property real chartNow: Date.now()", MAIN)
        self.assertIn("let now = chartNow", MAIN)
        self.assertIn("let d = new Date(chartNow)", MAIN)
        self.assertIn("chartNow = Date.now()", MAIN)

    def test_canvas_clears_before_short_history_return(self):
        clear_pos = MAIN.index('ctx.clearRect(0, 0, width, height)', MAIN.index('id: chartCanvas'))
        return_pos = MAIN.index('if (fanHistory.length < 2) return', MAIN.index('id: chartCanvas'))
        self.assertLess(clear_pos, return_pos)

    def test_history_uses_one_minute_buckets(self):
        self.assertIn("readonly property int kHistoryBucketMs: 60000", MAIN)


class PackageSanityTests(unittest.TestCase):
    def test_metadata_version(self):
        self.assertEqual(META["KPlugin"]["Version"], "1.3.0")

    def test_config_xml_is_well_formed(self):
        ET.fromstring(CONFIG)

    def test_removed_notifications_setting_stays_removed(self):
        self.assertNotIn("enableNotifications", CONFIG)
        self.assertNotIn("enableNotifications", MAIN)


if __name__ == "__main__":
    unittest.main(verbosity=2)
