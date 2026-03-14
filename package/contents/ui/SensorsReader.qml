import QtQuick

QtObject {
    id: sensorsReader

    signal dataReady(string output)
    signal errorOccurred(string error)

    property bool isRunning: false
    property int simulationCounter: 0

    Timer {
        id: simulationTimer
        interval: 500
        running: false
        repeat: false

        onTriggered: {
            simulationCounter++
            let baseRpm = 1900
            let variation = Math.sin(simulationCounter * 0.1) * 200
            let currentRpm = Math.round(baseRpm + variation)

            let baseTemp = 50
            let tempVariation = Math.sin(simulationCounter * 0.05) * 10
            let currentTemp = Math.round(baseTemp + tempVariation)

            let simulatedOutput = `coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +${currentTemp + 10}.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +${currentTemp}.0°C  (high = +100.0°C, crit = +100.0°C)
Core 1:        +${currentTemp - 1}.0°C  (high = +100.0°C, crit = +100.0°C)

asus-isa-000a
Adapter: ISA adapter
cpu_fan:     ${currentRpm} RPM
pwm1:             N/A

nvme-pci-0200
Adapter: PCI adapter
Composite:    +${currentTemp - 12}.9°C  (low  =  -0.1°C, high = +84.8°C)
                       (crit = +94.8°C)`

            sensorsReader.isRunning = false
            sensorsReader.dataReady(simulatedOutput)
        }
    }

    function readSensors() {
        if (isRunning) {
            return
        }

        isRunning = true
        simulationTimer.start()
    }
}
