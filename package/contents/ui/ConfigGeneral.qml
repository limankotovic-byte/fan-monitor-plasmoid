import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page
    
    property alias cfg_updateInterval: updateIntervalSpinBox.value
    property alias cfg_showTemperature: showTemperatureCheckBox.checked
    property alias cfg_showFanSpeed: showFanSpeedCheckBox.checked
    property alias cfg_fanSpeedUnit: fanSpeedUnitField.text
    property alias cfg_warningThreshold: warningThresholdSpinBox.value
    property alias cfg_criticalThreshold: criticalThresholdSpinBox.value
    property alias cfg_enableNotifications: enableNotificationsCheckBox.checked
    property alias cfg_themeIndex: themeComboBox.currentIndex
    property alias cfg_enableAnimation: enableAnimationCheckBox.checked
    property alias cfg_temperatureWarning: temperatureWarningSpinBox.value
    property alias cfg_temperatureCritical: temperatureCriticalSpinBox.value

    Kirigami.FormLayout {
        anchors.fill: parent
        
        // General Settings
        Kirigami.Separator {
            Kirigami.FormData.label: "General Settings"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.SpinBox {
            id: updateIntervalSpinBox
            Kirigami.FormData.label: "Update Interval (sec):"
            from: 1
            to: 60
            value: 2
            stepSize: 1
            
            textFromValue: function(value, locale) {
                return value + " sec"
            }
            
            valueFromText: function(text, locale) {
                return parseInt(text)
            }
            
            onValueChanged: {
                cfg_updateInterval = value * 1000 // Конвертируем в миллиsecунды
            }
            
            Component.onCompleted: {
                value = cfg_updateInterval / 1000
            }
        }
        
        // Display данных
        Kirigami.Separator {
            Kirigami.FormData.label: "Display"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.CheckBox {
            id: showFanSpeedCheckBox
            Kirigami.FormData.label: "Show Fan Speeds:"
            checked: true
        }
        
        QQC2.CheckBox {
            id: showTemperatureCheckBox
            Kirigami.FormData.label: "Show Temperatures:"
            checked: true
        }
        
        QQC2.TextField {
            id: fanSpeedUnitField
            Kirigami.FormData.label: "Fan Speed Unit:"
            text: "RPM"
            placeholderText: "RPM"
        }
        
        // Fan Thresholds
        Kirigami.Separator {
            Kirigami.FormData.label: "Fan Thresholds"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.SpinBox {
            id: warningThresholdSpinBox
            Kirigami.FormData.label: "Warning Threshold (RPM):"
            from: 500
            to: 10000
            value: 3000
            stepSize: 100
            
            textFromValue: function(value, locale) {
                return value + " RPM"
            }
            
            valueFromText: function(text, locale) {
                return parseInt(text)
            }
        }
        
        QQC2.SpinBox {
            id: criticalThresholdSpinBox
            Kirigami.FormData.label: "Critical Threshold (RPM):"
            from: 1000
            to: 15000
            value: 4000
            stepSize: 100
            
            textFromValue: function(value, locale) {
                return value + " RPM"
            }
            
            valueFromText: function(text, locale) {
                return parseInt(text)
            }
        }
        
        // Temperature Thresholds
        Kirigami.Separator {
            Kirigami.FormData.label: "Temperature Thresholds"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.SpinBox {
            id: temperatureWarningSpinBox
            Kirigami.FormData.label: "Warning Threshold (°C):"
            from: 40
            to: 100
            value: 70
            stepSize: 5
            
            textFromValue: function(value, locale) {
                return value + "°C"
            }
            
            valueFromText: function(text, locale) {
                return parseInt(text)
            }
        }
        
        QQC2.SpinBox {
            id: temperatureCriticalSpinBox
            Kirigami.FormData.label: "Critical Threshold (°C):"
            from: 50
            to: 120
            value: 80
            stepSize: 5
            
            textFromValue: function(value, locale) {
                return value + "°C"
            }
            
            valueFromText: function(text, locale) {
                return parseInt(text)
            }
        }
        
        // Notifications
        Kirigami.Separator {
            Kirigami.FormData.label: "Notifications"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.CheckBox {
            id: enableNotificationsCheckBox
            Kirigami.FormData.label: "Enable Notifications:"
            checked: true
        }
        
        // Appearance
        Kirigami.Separator {
            Kirigami.FormData.label: "Appearance"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.ComboBox {
            id: themeComboBox
            Kirigami.FormData.label: "Widget Theme:"
            model: ["Utterly Sweet (Solid)", "Clean Window (Transparent)", "Utterly Sweet (Translucent)"]
        }
        
        QQC2.CheckBox {
            id: enableAnimationCheckBox
            Kirigami.FormData.label: "Fan Animation:"
            text: "Enabled"
            checked: false
        }
        
        // Information
        Kirigami.Separator {
            Kirigami.FormData.label: "Information"
            Kirigami.FormData.isSection: true
        }
        
        QQC2.Label {
            Kirigami.FormData.label: "Version:"
            text: "1.0"
        }
        
        QQC2.Label {
            Kirigami.FormData.label: "Author:"
            text: "Liman"
        }
        
        QQC2.Label {
            text: "The widget uses the 'sensors' command to fetch fan and temperature data.\nEnsure the lm-sensors package is installed and configured."
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            color: Kirigami.Theme.disabledTextColor
        }
    }
}
