import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Effects
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    property int updateInterval: plasmoid.configuration.updateInterval || 5000
    property bool showTemperature: plasmoid.configuration.showTemperature || true
    property bool showFanSpeed: plasmoid.configuration.showFanSpeed || true
    property string fanSpeedUnit: plasmoid.configuration.fanSpeedUnit || "RPM"
    property int warningThreshold: plasmoid.configuration.warningThreshold || 3000
    property int criticalThreshold: plasmoid.configuration.criticalThreshold || 4000
    property int temperatureWarning: plasmoid.configuration.temperatureWarning || 70
    property int temperatureCritical: plasmoid.configuration.temperatureCritical || 80
    
    property var fanData: ({})
    property var tempData: ({})
    property bool hasData: false
    property string lastError: ""

    property var fanHistory: []
    property int maxHistoryPoints: 120
    property real _lastHistoryTime: 0

    property int timeRange: plasmoid.configuration.timeRange || 2  // in hours
    property int themeIndex: plasmoid.configuration.themeIndex !== undefined ? plasmoid.configuration.themeIndex : 0
    property bool enableAnimation: plasmoid.configuration.enableAnimation === true
    property var timeRangeOptions: [
        { "value": 2, "text": "2 hours", "points": 120 },
        { "value": 5, "text": "5 hours", "points": 300 },
        { "value": 8, "text": "8 hours", "points": 480 }
    ]
    
    // Theme colors matching "Utterly Sweet" style
    property color colorBgStart: "#2a1b3d"
    property color colorBgEnd: "#1a0b2e"
    property color colorAccentPink: "#ff75da"
    property color colorAccentPurple: "#a05bff"
    property color colorAccentCyan: "#00e8ff"
    property color colorWarning: "#ffb84d"
    property color colorCritical: "#ff4757"
    property color colorTextMuted: "#a89fbb"
    
    property string currentIcon: {
        if (!hasData) return "computer"

        let maxFanSpeed = 0
        for (let fan in fanData) {
            if (fanData[fan] > maxFanSpeed) maxFanSpeed = fanData[fan]
        }

        if (maxFanSpeed >= criticalThreshold) return "computer-fail"
        if (maxFanSpeed >= warningThreshold) return "computer-laptop"
        return "computer"
    }

    Plasmoid.icon: currentIcon
    
    toolTipMainText: "Fan & Temp Monitor 🎀"
    toolTipSubText: {
        if (!hasData) return "Loading data..."

        let tooltip = ""
        if (showFanSpeed) {
            for (let fan in fanData) tooltip += `${fan}: ${fanData[fan]} ${fanSpeedUnit}\n`
        }
        if (showTemperature) {
            for (let temp in tempData) tooltip += `${temp}: ${tempData[temp]}°C\n`
        }
        return tooltip.trim()
    }
    
    // ==========================================
    // COMPACT REPRESENTATION
    // ==========================================
    compactRepresentation: Item {
        Layout.minimumWidth: 90
        Layout.minimumHeight: Kirigami.Units.iconSizes.small
        Layout.preferredWidth: 90
        Layout.preferredHeight: Layout.minimumHeight
        Layout.margins: 4

        Row {
            anchors.centerIn: parent
            spacing: 6

            Item {
                width: 22
                height: 22
                anchors.verticalCenter: parent.verticalCenter

                property real currentRpm: {
                    let rpm = 0
                    for (let f in fanData) {
                        if (fanData[f] > rpm) rpm = fanData[f]
                    }
                    return rpm
                }

                Canvas {
                    id: fanCanvasCompact
                    anchors.fill: parent
                    renderStrategy: Canvas.Cooperative
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)

                        var gradient = ctx.createLinearGradient(0, 0, width, height)
                        gradient.addColorStop(0, colorAccentCyan.toString())
                        gradient.addColorStop(0.5, colorAccentPurple.toString())
                        gradient.addColorStop(1, colorAccentPink.toString())

                        var cx = width / 2
                        var cy = height / 2
                        var r = width / 2

                        ctx.fillStyle = gradient

                        for (var i = 0; i < 5; i++) {
                            var a1 = i * (Math.PI * 2 / 5)
                            var a2 = a1 + (Math.PI * 2 / 9)
                            ctx.beginPath()
                            ctx.moveTo(cx, cy)
                            ctx.arc(cx, cy, r, a1, a2)
                            ctx.lineTo(cx, cy)
                            ctx.fill()
                        }
                        ctx.beginPath()
                        ctx.arc(cx, cy, r * 0.2, 0, 2 * Math.PI)
                        ctx.fillStyle = colorBgEnd.toString() || "#1a0b2e"
                        ctx.fill()
                    }
                }

                Timer {
                    interval: 100
                    running: enableAnimation && parent.currentRpm > 0 && parent.visible
                    repeat: true
                    onTriggered: {
                        let speedFactor = Math.min(1.0, parent.currentRpm / 4000)
                        parent.rotation = (parent.rotation + 5 + (25 * speedFactor)) % 360
                    }
                }
            }

            Text {
                width: 45
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!hasData) return "---"
                    let maxFanSpeed = 0
                    for (let fan in fanData) {
                        if (fanData[fan] > maxFanSpeed) maxFanSpeed = fanData[fan]
                    }
                    return maxFanSpeed > 0 ? maxFanSpeed.toString() : "---"
                }
                font.pixelSize: 14
                font.bold: true
                color: colorAccentCyan
                verticalAlignment: Text.AlignVCenter
            }
        }

        // Blink animation removed for CPU efficiency

        MouseArea {
            anchors.fill: parent
            onClicked: root.expanded = !root.expanded
            cursorShape: Qt.PointingHandCursor
        }
    }
    
    // ==========================================
    // FULL REPRESENTATION
    // ==========================================
    fullRepresentation: Item {
        Layout.minimumWidth: 500
        Layout.minimumHeight: 400
        Layout.preferredWidth: 550
        Layout.preferredHeight: 450

        // Backdrop gradient to match Utterly Sweet
        Rectangle {
            anchors.fill: parent
            radius: 16
            visible: themeIndex !== 1
            gradient: Gradient {
                GradientStop { position: 0.0; color: colorBgStart }
                GradientStop { position: 1.0; color: colorBgEnd }
            }
            border.color: Qt.rgba(colorAccentPink.r, colorAccentPink.g, colorAccentPink.b, 0.3)
            border.width: 1
            opacity: themeIndex === 0 ? 0.9 : 0.5
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // HEADER
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Item {
                    width: 32
                    height: 32

                    property real currentRpm: {
                        let rpm = 0
                        for (let f in fanData) {
                            if (fanData[f] > rpm) rpm = fanData[f]
                        }
                        return rpm
                    }

                    Canvas {
                        id: fanCanvasFull
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)

                            var gradient = ctx.createLinearGradient(0, 0, width, height)
                            gradient.addColorStop(0, colorAccentCyan)
                            gradient.addColorStop(0.5, colorAccentPurple)
                            gradient.addColorStop(1, colorAccentPink)

                            var cx = width / 2
                            var cy = height / 2
                            var r = width / 2

                            ctx.fillStyle = gradient

                            for (var i = 0; i < 5; i++) {
                                var a1 = i * (Math.PI * 2 / 5)
                                var a2 = a1 + (Math.PI * 2 / 9)
                                ctx.beginPath()
                                ctx.moveTo(cx, cy)
                                ctx.arc(cx, cy, r, a1, a2)
                                ctx.lineTo(cx, cy)
                                ctx.fill()
                            }
                            ctx.beginPath()
                            ctx.arc(cx, cy, r * 0.2, 0, 2 * Math.PI)
                            ctx.fillStyle = colorBgEnd || "#1a0b2e"
                            ctx.fill()
                        }
                    }

                    Timer {
                        interval: 100 // 10 FPS
                        running: enableAnimation && parent.currentRpm > 0 && parent.visible
                        repeat: true
                        onTriggered: {
                            // Map 0-4000 RPM into 5-30 degrees of rotation per tick
                            let speedFactor = Math.min(1.0, parent.currentRpm / 4000)
                            parent.rotation = (parent.rotation + 5 + (25 * speedFactor)) % 360
                        }
                    }
                }

                Text {
                    text: "Fan Monitor"
                    font.pixelSize: 20
                    font.bold: true
                    font.family: "Inter, Noto Sans, sans-serif"
                    color: colorAccentPink
                    Layout.fillWidth: true
                }
                
                // Status Badge
                Rectangle {
                    color: hasData ? Qt.rgba(colorAccentCyan.r, colorAccentCyan.g, colorAccentCyan.b, 0.15) 
                                   : Qt.rgba(colorCritical.r, colorCritical.g, colorCritical.b, 0.15)
                    border.color: hasData ? colorAccentCyan : colorCritical
                    border.width: 1
                    radius: 12
                    Layout.preferredWidth: statusText.width + 24
                    Layout.preferredHeight: 28
                    
                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: hasData ? "Connected" : "No Data"
                        font.pixelSize: 12
                        font.bold: true
                        color: hasData ? colorAccentCyan : colorCritical
                    }
                }
            }

            // CONTROLS
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Range:"
                    font.pixelSize: 13
                    color: colorAccentPurple
                    font.bold: true
                }

                PlasmaComponents3.ComboBox {
                    id: timeRangeCombo
                    Layout.preferredWidth: 140
                    model: timeRangeOptions.map(option => option.text)

                    currentIndex: {
                        for (let i = 0; i < timeRangeOptions.length; i++) {
                            if (timeRangeOptions[i].value === timeRange) return i
                        }
                        return 0
                    }

                    onCurrentIndexChanged: {
                        if (currentIndex >= 0 && currentIndex < timeRangeOptions.length) {
                            timeRange = timeRangeOptions[currentIndex].value
                            plasmoid.configuration.timeRange = timeRange
                            // Update max points and clear history for proper scaling
                            maxHistoryPoints = timeRangeOptions[currentIndex].points
                        }
                    }
                }

                Item { Layout.fillWidth: true }
                
                PlasmaComponents3.Button {
                    text: "Refresh"
                    icon.name: "view-refresh"
                    onClicked: {
                        updateSensorData()
                        // manual point plot
                        if(Object.keys(fanData).length > 0) {
                            let maxSpd = 0;
                            for (let f in fanData) if(fanData[f]>maxSpd) maxSpd=fanData[f];
                            addFanSpeed(maxSpd, true);
                        }
                    }
                }
            }
            
            // MAIN CHART AREA
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 250
                color: themeIndex === 1 ? "transparent" : Qt.rgba(0,0,0,0.2)
                border.color: Qt.rgba(colorAccentPurple.r, colorAccentPurple.g, colorAccentPurple.b, 0.4)
                border.width: themeIndex === 1 ? 0 : 1
                radius: 12

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Fan Speed Graph (Max RPM)"
                            font.pixelSize: 14
                            font.bold: true
                            color: colorAccentPurple
                            Layout.fillWidth: true
                        }
                        Item {
                            width: 70
                            height: 20

                            property string rpmText: {
                                if (!hasData) return "--- RPM"
                                let maxFanSpeed = 0
                                for (let fan in fanData) {
                                    if (fanData[fan] > maxFanSpeed) maxFanSpeed = fanData[fan]
                                }
                                return maxFanSpeed + " RPM"
                            }

                            onRpmTextChanged: textCanvasFull.requestPaint()

                            Canvas {
                                id: textCanvasFull
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    var gradient = ctx.createLinearGradient(0, 0, width, 0)
                                    gradient.addColorStop(0, colorAccentCyan)
                                    gradient.addColorStop(0.5, colorAccentPurple)
                                    gradient.addColorStop(1, colorAccentPink)
                                    
                                    ctx.fillStyle = gradient
                                    ctx.font = "bold 16px sans-serif"
                                    ctx.textBaseline = "middle"
                                    ctx.fillText(parent.rpmText, 0, height / 2)
                                }
                            }
                        }
                    }

                    // CHART COMPONENT
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        // Y-AXIS LABELS
                        Item {
                            width: 45
                            anchors.left: parent.left
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 20

                            Repeater {
                                model: 6  // 5000, 4000, 3000, 2000, 1000, 0
                                Text {
                                    text: (5000 - index * 1000)
                                    font.pixelSize: 11
                                    font.bold: true
                                    y: (parent.height / 5) * index - height/2
                                    anchors.right: parent.right
                                    anchors.rightMargin: 8
                                    color: {
                                        let rpm = 5000 - index * 1000
                                        if (rpm >= criticalThreshold) return colorCritical
                                        if (rpm >= warningThreshold) return colorWarning
                                        return colorAccentCyan
                                    }
                                }
                            }
                        }

                        // CHART CANVAS
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 45
                            anchors.bottomMargin: 20

                            Canvas {
                                id: gridCanvas
                                anchors.fill: parent
                                onPaint: {
                                    let ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)

                                    // Y grid lines
                                    ctx.strokeStyle = Qt.rgba(colorAccentPurple.r, colorAccentPurple.g, colorAccentPurple.b, 0.2)
                                    ctx.lineWidth = 1
                                    for (let i = 0; i <= 5; i++) {
                                        let y = (height / 5) * i
                                        ctx.beginPath()
                                        ctx.moveTo(0, y)
                                        ctx.lineTo(width, y)
                                        ctx.stroke()
                                    }

                                    // X grid lines (for hours blocks based on timeRange)
                                    let timeDivisors = timeRange * 2 // half-hour blocks
                                    for (let i = 0; i <= timeDivisors; i++) {
                                        let x = (width / timeDivisors) * i
                                        ctx.beginPath()
                                        ctx.moveTo(x, 0)
                                        ctx.lineTo(x, height)
                                        ctx.stroke()
                                    }
                                }
                            }

                            Canvas {
                                id: chartCanvas
                                anchors.fill: parent
                                onPaint: {
                                    if (fanHistory.length < 2) return

                                    let ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)

                                    let gradient = ctx.createLinearGradient(0, height, 0, 0)
                                    gradient.addColorStop(0, colorAccentCyan)    
                                    gradient.addColorStop(0.6, colorAccentPurple)  
                                    gradient.addColorStop(1, colorAccentPink)

                                    ctx.strokeStyle = gradient
                                    ctx.lineWidth = 3
                                    ctx.lineJoin = "round"

                                    ctx.beginPath()

                                    let maxRpm = 5000
                                    let now = Date.now()
                                    let rangeMs = timeRange * 3600 * 1000

                                    for (let i = 0; i < fanHistory.length; i++) {
                                        let pt = fanHistory[i]
                                        let ageMs = now - pt.time
                                        // calculate X position based on exact time relative to now!
                                        let x = width - (ageMs / rangeMs) * width
                                        // clamp x
                                        if(x < 0) x = 0;
                                        
                                        let normalizedRpm = Math.max(0, Math.min(maxRpm, pt.rpm))
                                        let y = height - (normalizedRpm / maxRpm) * height

                                        if (i === 0) {
                                            ctx.moveTo(x, y)
                                        } else {
                                            ctx.lineTo(x, y)
                                        }
                                    }
                                    ctx.stroke()

                                    // Area fill
                                    let fillGradient = ctx.createLinearGradient(0, height, 0, 0)
                                    fillGradient.addColorStop(0, Qt.rgba(colorAccentCyan.r, colorAccentCyan.g, colorAccentCyan.b, 0.0))
                                    fillGradient.addColorStop(1, Qt.rgba(colorAccentPink.r, colorAccentPink.g, colorAccentPink.b, 0.3))
                                    
                                    ctx.lineTo(width, height)
                                    // Start of graph could be anywhere, close it to X of first element, Y=height
                                    if (fanHistory.length > 0) {
                                        let firstPt = fanHistory[0]
                                        let firstX = width - ((now - firstPt.time) / rangeMs) * width
                                        if(firstX < 0) firstX = 0;
                                        ctx.lineTo(firstX, height)
                                    } else {
                                        ctx.lineTo(0, height)
                                    }
                                    
                                    ctx.closePath()
                                    ctx.fillStyle = fillGradient
                                    ctx.fill()
                                }

                                Connections {
                                    target: root
                                    function onFanHistoryChanged() { chartCanvas.requestPaint() }
                                }
                                Connections {
                                    target: timeRangeCombo
                                    function onCurrentIndexChanged() { 
                                        gridCanvas.requestPaint()
                                        chartCanvas.requestPaint() 
                                    }
                                }
                            }
                        }

                        // X-AXIS TIME LABELS (Dynamically generated)
                        Item {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.leftMargin: 45
                            height: 20

                            Repeater {
                                model: timeRange + 1
                                Text {
                                    text: {
                                        let d = new Date()
                                        d.setHours(d.getHours() - (timeRange - index))
                                        return ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2)
                                    }
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: colorTextMuted
                                    x: {
                                        if (index === 0) return 0
                                        if (index === timeRange) return parent.width - width
                                        return (parent.width / timeRange) * index - width/2
                                    }
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 0
                                }
                            }
                        }
                    }

                    PlasmaComponents3.Label {
                        text: lastError
                        color: colorCritical
                        visible: lastError !== ""
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
    
    Timer {
        id: updateTimer
        interval: expanded ? updateInterval : 30000
        repeat: true
        running: true
        onTriggered: updateSensorData()
    }

    P5Support.DataSource {
        id: executableDataSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource("sensors")
            if (data.stdout && data.stdout.length > 10) {
                root.parseSensorData(data.stdout)
            } else {
                root.lastError = "Sensors command failed"
            }
            root.isUpdating = false
        }
    }
    
    // Time refresh timer mostly for correctly sliding the chart horizontally and updating times
    Timer {
        interval: 30000 // refresh chart shifting every 30s
        repeat: true
        running: expanded
        onTriggered: {
            if(expanded && Object.keys(fanData).length > 0) {
                // Ensure chart redraws so things slide left
                let maxSpd = 0;
                for (let f in fanData) if(fanData[f]>maxSpd) maxSpd=fanData[f];
                addFanSpeed(maxSpd, false)
            }
        }
    }

    property bool isUpdating: false
    property int simulationCounter: 0

    function addFanSpeed(speed, forceNewPoint = false) {
        let selectedRange = timeRangeOptions.find(option => option.value === timeRange)
        if (selectedRange) maxHistoryPoints = selectedRange.points

        let now = Date.now()
        let bucketMs = (timeRange * 3600 * 1000) / maxHistoryPoints

        if (fanHistory.length === 0 || forceNewPoint || (now - _lastHistoryTime) >= bucketMs) {
            fanHistory.push({rpm: speed, time: now})
            
            // Limit points and remove points older than timeRange
            let cutoff = now - (timeRange * 3600 * 1000)
            while (fanHistory.length > 0 && fanHistory[0].time < cutoff) {
                fanHistory.shift()
            }
            if (fanHistory.length > maxHistoryPoints) {
                fanHistory.shift()
            }
            
            _lastHistoryTime = now
        } else {
            // update existing latest point for accurate max
            let lastIdx = fanHistory.length - 1
            if(speed > fanHistory[lastIdx].rpm) {
                fanHistory[lastIdx].rpm = speed
            }
            fanHistory[lastIdx].time = now
        }
        
        fanHistoryChanged()
    }

    function updateSensorData() {
        if (isUpdating) return
        isUpdating = true

        try {
            executableDataSource.connectSource("sensors")
        } catch (error) {
            useSimulatedData()
            isUpdating = false
        }
    }

    function useSimulatedData() {
        simulationCounter++
        let baseRpm = 2000
        let variation = Math.sin(simulationCounter * 0.1) * 800
        let currentRpm = Math.round(baseRpm + variation)

        let baseTemp = 55
        let tempVariation = Math.sin(simulationCounter * 0.05) * 15
        let currentTemp = Math.round(baseTemp + tempVariation)

        let simulatedOutput = `coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +${currentTemp + 10}.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +${currentTemp}.0°C  (high = +100.0°C, crit = +100.0°C)

asus-isa-000a
Adapter: ISA adapter
cpu_fan:     ${currentRpm} RPM
pwm1:             N/A`

        parseSensorData(simulatedOutput)
        isUpdating = false
    }
    
    function parseSensorData(output) {
        try {
            let newFanData = {}
            let newTempData = {}

            let lines = output.split('\n')

            for (let line of lines) {
                line = line.trim()
                if (line.includes('fan') && line.includes('RPM')) {
                    let match = line.match(/(.+?):\s*(\d+)\s*RPM/)
                    if (match) newFanData[match[1].trim()] = parseInt(match[2])
                }
                if (line.includes('°C') && !line.includes('high') && !line.includes('crit') && !line.includes('low')) {
                    let match = line.match(/(.+?):\s*\+?(-?\d+(?:\.\d+)?)\s*°C/)
                    if (match) {
                        let tempName = match[1].trim()
                        if (tempName.includes('Core') || tempName.includes('Package') || tempName.includes('Composite') || tempName.includes('temp')) {
                            newTempData[tempName] = parseFloat(match[2])
                        }
                    }
                }
            }

            fanData = newFanData
            tempData = newTempData
            hasData = Object.keys(newFanData).length > 0 || Object.keys(newTempData).length > 0
            lastError = ""

            if (Object.keys(newFanData).length > 0) {
                let maxFanSpeed = 0
                for (let fan in newFanData) {
                    if (newFanData[fan] > maxFanSpeed) maxFanSpeed = newFanData[fan]
                }
                addFanSpeed(maxFanSpeed)
            }
        } catch (error) {
            lastError = "Error parsing data: " + error.toString()
            hasData = false
        }
    }
    
    Component.onCompleted: {
        updateSensorData()
    }
}
