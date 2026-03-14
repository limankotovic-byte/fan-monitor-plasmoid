import QtQuick
import QtQuick.Layouts

Item {
    id: root
    
    property string sensorName: ""
    property real currentTemp: 0
    property real maxTemp: 100
    property var historyData: []
    
    property color colorAccentPink: "#ff75da"
    property color colorAccentPurple: "#a05bff"
    property color colorAccentCyan: "#00e8ff"
    
    // Scale temp between 40 and 80 for display (standard operation range)
    property real displayMinY: 40
    property real displayMaxY: 80
    
    Layout.fillWidth: true
    Layout.minimumHeight: 60
    
    // Text values overlay
    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        
        Text {
            text: sensorName
            color: colorAccentCyan
            font.pixelSize: 12
            font.bold: true
            Layout.alignment: Qt.AlignLeft | Qt.AlignTop
        }
        
        Item { Layout.fillWidth: true }
        
        Text {
            text: currentTemp + "°C"
            color: currentTemp > 80 ? "red" : (currentTemp > 70 ? "orange" : colorAccentPink)
            font.pixelSize: 18
            font.bold: true
            Layout.alignment: Qt.AlignRight | Qt.AlignTop
        }
    }
    
    Canvas {
        id: chartCanvas
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 5
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            
            if (historyData.length < 2) return
            
            // Grid lines
            ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.1)
            ctx.beginPath()
            ctx.moveTo(0, height / 2)
            ctx.lineTo(width, height / 2)
            ctx.stroke()
            
            // Draw chart line
            ctx.beginPath()
            
            var gradient = ctx.createLinearGradient(0, height, 0, 0)
            gradient.addColorStop(0, colorAccentCyan)
            gradient.addColorStop(1, colorAccentPink)
            
            ctx.strokeStyle = gradient
            ctx.lineWidth = 2
            
            var pointWidth = width / Math.max(1, historyData.length - 1)
            
            for (var i = 0; i < historyData.length; i++) {
                var x = i * pointWidth
                var val = Math.max(displayMinY, Math.min(displayMaxY, historyData[i]))
                // Map val to y
                var yParams = (val - displayMinY) / (displayMaxY - displayMinY)
                var y = height - (yParams * height)
                
                if (i === 0) ctx.moveTo(x, y)
                else ctx.lineTo(x, y)
            }
            ctx.stroke()
            
            // Fill under graph
            var fillGrad = ctx.createLinearGradient(0, height, 0, 0)
            fillGrad.addColorStop(0, Qt.rgba(colorAccentCyan.r, colorAccentCyan.g, colorAccentCyan.b, 0))
            fillGrad.addColorStop(1, Qt.rgba(colorAccentPink.r, colorAccentPink.g, colorAccentPink.b, 0.4))
            
            ctx.lineTo(width, height)
            ctx.lineTo(0, height)
            ctx.closePath()
            
            ctx.fillStyle = fillGrad
            ctx.fill()
        }
        
        Connections {
            target: root
            function onHistoryDataChanged() { chartCanvas.requestPaint() }
        }
    }
}
