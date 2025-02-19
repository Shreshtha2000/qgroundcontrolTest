/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                  2.3
import QtQuick.Controls         1.2
import QtQuick.Controls.Styles  1.4
import QtQuick.Dialogs          1.2
import QtQuick.Layouts          1.2

import QGroundControl                       1.0
import QGroundControl.FactSystem            1.0
import QGroundControl.FactControls          1.0
import QGroundControl.Controls              1.0
import QGroundControl.ScreenTools           1.0
import QGroundControl.MultiVehicleManager   1.0
import QGroundControl.Palette               1.0
import QGroundControl.Controllers           1.0
import QGroundControl.SettingsManager       1.0

Rectangle {
    id:                 _root
    color:              qgcPal.window
    anchors.fill:       parent
    anchors.margins:    ScreenTools.defaultFontPixelWidth

    property Fact _savePath:                            QGroundControl.settingsManager.appSettings.savePath
    property Fact _appFontPointSize:                    QGroundControl.settingsManager.appSettings.appFontPointSize
    property Fact _userBrandImageIndoor:                QGroundControl.settingsManager.brandImageSettings.userBrandImageIndoor
    property Fact _userBrandImageOutdoor:               QGroundControl.settingsManager.brandImageSettings.userBrandImageOutdoor
    property Fact _virtualJoystick:                     QGroundControl.settingsManager.appSettings.virtualJoystick
    property Fact _virtualJoystickAutoCenterThrottle:   QGroundControl.settingsManager.appSettings.virtualJoystickAutoCenterThrottle

    property real   _labelWidth:                ScreenTools.defaultFontPixelWidth * 20
    property real   _comboFieldWidth:           ScreenTools.defaultFontPixelWidth * 30
    property real   _valueFieldWidth:           ScreenTools.defaultFontPixelWidth * 10
    property string _mapProvider:               QGroundControl.settingsManager.flightMapSettings.mapProvider.value
    property string _mapType:                   QGroundControl.settingsManager.flightMapSettings.mapType.value
    property Fact   _followTarget:              QGroundControl.settingsManager.appSettings.followTarget
    property real   _panelWidth:                _root.width * _internalWidthRatio
    property real   _margins:                   ScreenTools.defaultFontPixelWidth
    property var    _planViewSettings:          QGroundControl.settingsManager.planViewSettings
    property var    _flyViewSettings:           QGroundControl.settingsManager.flyViewSettings
    property var    _videoSettings:             QGroundControl.settingsManager.videoSettings
    property var    _videoSettingsList:         QGroundControl.settingsManager.videoSettingsList
    property string _videoSource:               _videoSettings.videoSource.rawValue
    property string _videoSourceFrom0:          _videoSettingsList[0].videoSource.rawValue
    property string _videoSourceFrom1:          _videoSettingsList[1].videoSource.rawValue

    property bool   _isGst:                     /*QGroundControl.videoManager.isGStreamer*/true
    property bool   _isUDP264:                  _isGst && _videoSourceFrom0 === _videoSettingsList[0].udp264VideoSource
    property bool   _isUDP265:                  _isGst && _videoSourceFrom0 === _videoSettingsList[0].udp265VideoSource
    property bool   _isRTSP:                    _isGst && _videoSourceFrom0 === _videoSettingsList[0].rtspVideoSource
    property bool   _isTCP:                     _isGst && _videoSourceFrom0 === _videoSettingsList[0].tcpVideoSource
    property bool   _isMPEGTS:                  _isGst && _videoSourceFrom0 === _videoSettingsList[0].mpegtsVideoSource

    property bool   _isGst1:                     /*QGroundControl.videoManager.isGStreamer*/true
    property bool   _isUDP2641:                  _isGst && _videoSourceFrom1 === _videoSettingsList[1].udp264VideoSource
    property bool   _isUDP2651:                  _isGst && _videoSourceFrom1 === _videoSettingsList[1].udp265VideoSource
    property bool   _isRTSP1:                    _isGst && _videoSourceFrom1 === _videoSettingsList[1].rtspVideoSource
    property bool   _isTCP1:                     _isGst && _videoSourceFrom1 === _videoSettingsList[1].tcpVideoSource
    property bool   _isMPEGTS1:                  _isGst && _videoSourceFrom1 === _videoSettingsList[1].mpegtsVideoSource
    property bool   _videoAutoStreamConfig:     QGroundControl.videoManager.autoStreamConfigured
    property bool   _showSaveVideoSettings:     _isGst || _videoAutoStreamConfig
    property bool   _disableAllDataPersistence: QGroundControl.settingsManager.appSettings.disableAllPersistence.rawValue

    property string gpsDisabled: "Disabled"
    property string gpsUdpPort:  "UDP Port"

    readonly property real _internalWidthRatio: 0.8
    Component.onCompleted: {
    console.log("SINGLE",_videoSource)
        console.log("MULTIPLE",_videoSourceFrom0)
    }

        QGCFlickable {
            clip:               true
            anchors.fill:       parent
            contentHeight:      outerItem.height
            contentWidth:       outerItem.width

            Item {
                id:     outerItem
                width:  Math.max(_root.width, settingsColumn.width)
                height: settingsColumn.height

                ColumnLayout {
                    id:                         settingsColumn
                    anchors.horizontalCenter:   parent.horizontalCenter

                    QGCLabel {
                        id:         flyViewSectionLabel
                        text:       qsTr("Fly View")
                        visible:    QGroundControl.settingsManager.flyViewSettings.visible
                    }
                    Rectangle {
                        Layout.preferredHeight: flyViewCol.height + (_margins * 2)
                        Layout.preferredWidth:  flyViewCol.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                flyViewSectionLabel.visible
                        Layout.fillWidth:       true

                        ColumnLayout {
                            id:                         flyViewCol
                            anchors.margins:            _margins
                            anchors.top:                parent.top
                            anchors.horizontalCenter:   parent.horizontalCenter
                            spacing:                    _margins

                            FactCheckBox {
                                id:             useCheckList
                                text:           qsTr("Use Preflight Checklist")
                                fact:           _useChecklist
                                visible:        _useChecklist.visible && QGroundControl.corePlugin.options.preFlightChecklistUrl.toString().length

                                property Fact _useChecklist: QGroundControl.settingsManager.appSettings.useChecklist
                            }

                            FactCheckBox {
                                text:           qsTr("Enforce Preflight Checklist")
                                fact:           _enforceChecklist
                                enabled:        QGroundControl.settingsManager.appSettings.useChecklist.value
                                visible:        useCheckList.visible && _enforceChecklist.visible && QGroundControl.corePlugin.options.preFlightChecklistUrl.toString().length

                                property Fact _enforceChecklist: QGroundControl.settingsManager.appSettings.enforceChecklist
                            }

                            FactCheckBox {
                                text:       qsTr("Keep Map Centered On Vehicle")
                                fact:       _keepMapCenteredOnVehicle
                                visible:    _keepMapCenteredOnVehicle.visible

                                property Fact _keepMapCenteredOnVehicle: QGroundControl.settingsManager.flyViewSettings.keepMapCenteredOnVehicle
                            }

                            FactCheckBox {
                                text:       qsTr("Show Telemetry Log Replay Status Bar")
                                fact:       _showLogReplayStatusBar
                                visible:    _showLogReplayStatusBar.visible

                                property Fact _showLogReplayStatusBar: QGroundControl.settingsManager.flyViewSettings.showLogReplayStatusBar
                            }

                            RowLayout {
                                spacing: ScreenTools.defaultFontPixelWidth

                                FactCheckBox {
                                    text:       qsTr("Virtual Joystick")
                                    visible:    _virtualJoystick.visible
                                    fact:       _virtualJoystick
                                }

                                FactCheckBox {
                                    text:       qsTr("Auto-Center Throttle")
                                    visible:    _virtualJoystickAutoCenterThrottle.visible
                                    enabled:    _virtualJoystick.rawValue
                                    fact:       _virtualJoystickAutoCenterThrottle
                                }
                            }

                            FactCheckBox {
                                text:       qsTr("Use Vertical Instrument Panel")
                                visible:    _alternateInstrumentPanel.visible
                                fact:       _alternateInstrumentPanel

                                property Fact _alternateInstrumentPanel: QGroundControl.settingsManager.flyViewSettings.alternateInstrumentPanel
                            }

                            FactCheckBox {
                                text:       qsTr("Show additional heading indicators on Compass")
                                visible:    _showAdditionalIndicatorsCompass.visible
                                fact:       _showAdditionalIndicatorsCompass

                                property Fact _showAdditionalIndicatorsCompass: QGroundControl.settingsManager.flyViewSettings.showAdditionalIndicatorsCompass
                            }

                            FactCheckBox {
                                text:       qsTr("Lock Compass Nose-Up")
                                visible:    _lockNoseUpCompass.visible
                                fact:       _lockNoseUpCompass

                                property Fact _lockNoseUpCompass: QGroundControl.settingsManager.flyViewSettings.lockNoseUpCompass
                            }

                            FactCheckBox {
                                text:       qsTr("Show simple camera controls (DIGICAM_CONTROL)")
                                visible:    _showDumbCameraControl.visible
                                fact:       _showDumbCameraControl

                                property Fact _showDumbCameraControl: QGroundControl.settingsManager.flyViewSettings.showSimpleCameraControl
                            }

                            FactCheckBox {
                                text:       qsTr("Update home position based on device location. This will affect return to home")
                                fact:       _updateHomePosition
                                visible:    _updateHomePosition.visible
                                property Fact _updateHomePosition: QGroundControl.settingsManager.flyViewSettings.updateHomePosition
                            }

                            FactCheckBox {
                                text:       qsTr("Enable Custom Actions")
                                visible:    _enableCustomActions.visible
                                fact:       _enableCustomActions

                                property Fact _enableCustomActions: QGroundControl.settingsManager.flyViewSettings.enableCustomActions
                            }

                            //-----------------------------------------------------------------
                            //-- CustomAction definition path
                            GridLayout {
                                id: customActions

                                columns:  2
                                visible:  QGroundControl.settingsManager.flyViewSettings.enableCustomActions.rawValue

                                onVisibleChanged: {
                                    if (jsonFile.rawValue === "" && ScreenTools.isMobile) {
                                        jsonFile.rawValue = _defaultFile
                                    }
                                }

                                property Fact   jsonFile:     QGroundControl.settingsManager.flyViewSettings.customActionDefinitions
                                property string _defaultDir:  QGroundControl.settingsManager.appSettings.customActionsSavePath
                                property string _defaultFile: _defaultDir + "/CustomActions.json"

                                QGCLabel {
                                    text: qsTr("Custom Action Definitions")

                                    Layout.columnSpan:  2
                                    Layout.alignment:   Qt.AlignHCenter
                                }

                                QGCTextField {
                                    Layout.fillWidth:   true
                                    readOnly:           true
                                    text:               customActions.jsonFile.rawValue === "" ? qsTr("<not set>") : customActions.jsonFile.rawValue
                                }
                                QGCButton {
                                    visible:    !ScreenTools.isMobile
                                    text:       qsTr("Browse")
                                    onClicked:  customActionPathBrowseDialog.openForLoad()
                                    QGCFileDialog {
                                        id:             customActionPathBrowseDialog
                                        title:          qsTr("Choose the Custom Action Definitions file")
                                        folder:         customActions.jsonFile.rawValue
                                        selectExisting: true
                                        selectFolder:   false
                                        onAcceptedForLoad: customActions.jsonFile.rawValue = file
                                        nameFilters: ["JSON files (*.json)"]
                                    }
                                }
                                // The file loader on Android doesn't work, so we hard code the path to the
                                // JSON file. However, we need a button to force a refresh if the JSON file
                                // is changed.
                                QGCButton {
                                    visible:    ScreenTools.isMobile
                                    text:       qsTr("Reload")
                                    onClicked:  {
                                        customActions.jsonFile.valueChanged(customActions.jsonFile.rawValue)
                                    }
                                }
                            }

                            GridLayout {
                                columns: 2

                                QGCLabel {
                                    text:               qsTr("Guided Command Settings")
                                    Layout.columnSpan:  2
                                    Layout.alignment:   Qt.AlignHCenter
                                }

                                QGCLabel {
                                    text:       qsTr("Minimum Altitude")
                                    visible:    guidedMinAltField.visible
                                }
                                FactTextField {
                                    id:                     guidedMinAltField
                                    Layout.preferredWidth:  _valueFieldWidth
                                    visible:                fact.visible
                                    fact:                   _flyViewSettings.guidedMinimumAltitude
                                }

                                QGCLabel {
                                    text:       qsTr("Maximum Altitude")
                                    visible:    guidedMaxAltField.visible
                                }
                                FactTextField {
                                    id:                     guidedMaxAltField
                                    Layout.preferredWidth:  _valueFieldWidth
                                    visible:                fact.visible
                                    fact:                   _flyViewSettings.guidedMaximumAltitude
                                }

                                QGCLabel {
                                    text:       qsTr("Go To Location Max Distance")
                                    visible:    maxGotoDistanceField.visible
                                }
                                FactTextField {
                                    id:                     maxGotoDistanceField
                                    Layout.preferredWidth:  _valueFieldWidth
                                    visible:                fact.visible
                                    fact:                  _flyViewSettings.maxGoToLocationDistance
                                }
                            }

                            GridLayout {
                                id:         videoGrid
                                columns:    2
                                visible:    _videoSettingsList[0].visible

                                QGCLabel {
                                    text:               qsTr("Video Settings")
                                    Layout.columnSpan:  2
                                    Layout.alignment:   Qt.AlignHCenter
                                }

                                QGCLabel {
                                    id:         videoSourceLabel
                                    text:       qsTr("Source")
                                    visible:    !_videoAutoStreamConfig && _videoSettingsList[0].videoSource.visible
                                }
                                FactComboBox {
                                    id:                     videoSource
                                    Layout.preferredWidth:  _comboFieldWidth
                                    indexModel:             false
                                    fact:                   _videoSettingsList[0].videoSource
                                    visible:                videoSourceLabel.visible
                                }

                                QGCLabel {
                                    id:         udpPortLabel
                                    text:       qsTr("UDP Port")
                                    visible:    !_videoAutoStreamConfig && (_isUDP264 || _isUDP265 || _isMPEGTS) && _videoSettingsList[0].udpPort.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].udpPort
                                    visible:                udpPortLabel.visible
                                }

                                QGCLabel {
                                    id:         rtspUrlLabel
                                    text:       qsTr("RTSP URL")
                                    visible:    !_videoAutoStreamConfig && _isRTSP && _videoSettingsList[0].rtspUrl.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].rtspUrl
                                    visible:                rtspUrlLabel.visible
                                }

                                QGCLabel {
                                    id:         tcpUrlLabel
                                    text:       qsTr("TCP URL")
                                    visible:    !_videoAutoStreamConfig && _isTCP && _videoSettingsList[0].tcpUrl.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].tcpUrl
                                    visible:                tcpUrlLabel.visible
                                }

                                QGCLabel {
                                    text:                   qsTr("Aspect Ratio")
                                    visible:                !_videoAutoStreamConfig && _isGst && _videoSettingsList[0].aspectRatio.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].aspectRatio
                                    visible:                !_videoAutoStreamConfig && _isGst && _videoSettingsList[0].aspectRatio.visible
                                }

                                QGCLabel {
                                    id:         videoFileFormatLabel
                                    text:       qsTr("Record File Format")
                                    visible:    _showSaveVideoSettings && _videoSettingsList[0].recordingFormat.visible
                                }
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].recordingFormat
                                    visible:                videoFileFormatLabel.visible
                                }

                                QGCLabel {
                                    id:         maxSavedVideoStorageLabel
                                    text:       qsTr("Max Storage Usage")
                                    visible:    _showSaveVideoSettings && _videoSettingsList[0].maxVideoSize.visible && _videoSettingsList[0].enableStorageLimit.value
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].maxVideoSize
                                    visible:                _showSaveVideoSettings && _videoSettingsList[0].enableStorageLimit.value && maxSavedVideoStorageLabel.visible
                                }

                                QGCLabel {
                                    id:         videoDecodeLabel
                                    text:       qsTr("Video decode priority")
                                    visible:    forceVideoDecoderComboBox.visible
                                }
                                FactComboBox {
                                    id:                     forceVideoDecoderComboBox
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[0].forceVideoDecoder
                                    visible:                fact.visible
                                    indexModel:             false
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Disable When Disarmed")
                                    fact:       _videoSettingsList[0].disableWhenDisarmed
                                    visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Low Latency Mode")
                                    fact:       _videoSettingsList[0].lowLatencyMode
                                    visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Auto-Delete Saved Recordings")
                                    fact:       _videoSettingsList[0].enableStorageLimit
                                    visible:    _showSaveVideoSettings && fact.visible
                                }
                            }
                            GridLayout {
                                id:         videoGrid1
                                columns:    2
                                visible:    _videoSettingsList[1].visible

                                QGCLabel {
                                    text:               qsTr("Video Settings 1")
                                    Layout.columnSpan:  2
                                    Layout.alignment:   Qt.AlignHCenter
                                }

                                QGCLabel {
                                    id:         videoSourceLabel1
                                    text:       qsTr("Source")
                                    visible:    !_videoAutoStreamConfig && _videoSettingsList[1].videoSource.visible
                                }
                                FactComboBox {
                                    id:                     videoSource1
                                    Layout.preferredWidth:  _comboFieldWidth
                                    indexModel:             false
                                    fact:                   _videoSettingsList[1].videoSource
                                    visible:                videoSourceLabel1.visible
                                }

                                QGCLabel {
                                    id:         udpPortLabel1
                                    text:       qsTr("UDP Port")
                                    visible:    !_videoAutoStreamConfig && (_isUDP2641 || _isUDP2651 || _isMPEGTS1) && _videoSettingsList[1].udpPort.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].udpPort
                                    visible:                udpPortLabel1.visible
                                }

                                QGCLabel {
                                    id:         rtspUrlLabel1
                                    text:       qsTr("RTSP URL")
                                    visible:    !_videoAutoStreamConfig && _isRTSP1 && _videoSettingsList[1].rtspUrl.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].rtspUrl
                                    visible:                rtspUrlLabel1.visible
                                }

                                QGCLabel {
                                    id:         tcpUrlLabel1
                                    text:       qsTr("TCP URL")
                                    visible:    !_videoAutoStreamConfig && _isTCP1 && _videoSettingsList[1].tcpUrl.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].tcpUrl
                                    visible:                tcpUrlLabel1.visible
                                }

                                QGCLabel {
                                    text:                   qsTr("Aspect Ratio")
                                    visible:                !_videoAutoStreamConfig && _isGst1 && _videoSettingsList[1].aspectRatio.visible
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].aspectRatio
                                    visible:                !_videoAutoStreamConfig && _isGst1 && _videoSettingsList[1].aspectRatio.visible
                                }

                                QGCLabel {
                                    id:         videoFileFormatLabel1
                                    text:       qsTr("Record File Format")
                                    visible:    _showSaveVideoSettings && _videoSettingsList[1].recordingFormat.visible
                                }
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].recordingFormat
                                    visible:                videoFileFormatLabel1.visible
                                }

                                QGCLabel {
                                    id:         maxSavedVideoStorageLabel1
                                    text:       qsTr("Max Storage Usage")
                                    visible:    _showSaveVideoSettings && _videoSettingsList[1].maxVideoSize.visible && _videoSettingsList[1].enableStorageLimit.value
                                }
                                FactTextField {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].maxVideoSize
                                    visible:                _showSaveVideoSettings && _videoSettingsList[1].enableStorageLimit.value && maxSavedVideoStorageLabel1.visible
                                }

                                QGCLabel {
                                    id:         videoDecodeLabel1
                                    text:       qsTr("Video decode priority")
                                    visible:    forceVideoDecoderComboBox1.visible
                                }
                                FactComboBox {
                                    id:                     forceVideoDecoderComboBox1
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _videoSettingsList[1].forceVideoDecoder
                                    visible:                fact.visible
                                    indexModel:             false
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Disable When Disarmed")
                                    fact:       _videoSettingsList[1].disableWhenDisarmed
                                    visible:    !_videoAutoStreamConfig && _isGst && fact.visible
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Low Latency Mode")
                                    fact:       _videoSettingsList[1].lowLatencyMode
                                    visible:    !_videoAutoStreamConfig && _isGst1 && fact.visible
                                }

                                Item { width: 1; height: 1}
                                FactCheckBox {
                                    text:       qsTr("Auto-Delete Saved Recordings")
                                    fact:       _videoSettingsList[1].enableStorageLimit
                                    visible:    _showSaveVideoSettings && fact.visible
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: planViewSectionLabel.visible }
                    QGCLabel {
                        id:         planViewSectionLabel
                        text:       qsTr("Plan View")
                        visible:    _planViewSettings.visible
                    }
                    Rectangle {
                        Layout.preferredHeight: planViewCol.height + (_margins * 2)
                        Layout.preferredWidth:  planViewCol.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                planViewSectionLabel.visible
                        Layout.fillWidth:       true

                        ColumnLayout {
                            id:                         planViewCol
                            anchors.margins:            _margins
                            anchors.top:                parent.top
                            anchors.horizontalCenter:   parent.horizontalCenter
                            spacing:                    _margins

                            GridLayout {
                                columns:            2
                                columnSpacing:      ScreenTools.defaultFontPixelWidth
                                visible:            QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude.visible

                                QGCLabel { text: qsTr("Default Mission Altitude") }
                                FactTextField {
                                    Layout.preferredWidth:  _valueFieldWidth
                                    fact:                   QGroundControl.settingsManager.appSettings.defaultMissionItemAltitude
                                }

                                QGCLabel { text: qsTr("VTOL TransitionDistance") }
                                FactTextField {
                                    Layout.preferredWidth:  _valueFieldWidth
                                    fact:                   QGroundControl.settingsManager.planViewSettings.vtolTransitionDistance
                                }
                            }

                            FactCheckBox {
                                text:   qsTr("Use MAV_CMD_CONDITION_GATE for pattern generation")
                                fact:   QGroundControl.settingsManager.planViewSettings.useConditionGate
                            }

                            FactCheckBox {
                                text:       qsTr("Missions Do Not Require Takeoff Item")
                                fact:       _planViewSettings.takeoffItemNotRequired
                                visible:    _planViewSettings.takeoffItemNotRequired.visible
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: unitsSectionLabel.visible }
                    QGCLabel {
                        id:         unitsSectionLabel
                        text:       qsTr("Units")
                        visible:    QGroundControl.settingsManager.unitsSettings.visible
                    }
                    Rectangle {
                        Layout.preferredHeight: unitsGrid.height + (_margins * 2)
                        Layout.preferredWidth:  unitsGrid.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                miscSectionLabel.visible
                        Layout.fillWidth:       true

                        GridLayout {
                            id:                         unitsGrid
                            anchors.topMargin:          _margins
                            anchors.top:                parent.top
                            Layout.fillWidth:           false
                            anchors.horizontalCenter:   parent.horizontalCenter
                            flow:                       GridLayout.TopToBottom
                            rows:                       5

                            Repeater {
                                model: [ qsTr("Horizontal Distance"), qsTr("Vertical Distance"), qsTr("Area"), qsTr("Speed"), qsTr("Temperature") ]
                                QGCLabel { text: modelData }
                            }
                            Repeater {
                                model:  [ QGroundControl.settingsManager.unitsSettings.horizontalDistanceUnits, QGroundControl.settingsManager.unitsSettings.verticalDistanceUnits, QGroundControl.settingsManager.unitsSettings.areaUnits, QGroundControl.settingsManager.unitsSettings.speedUnits, QGroundControl.settingsManager.unitsSettings.temperatureUnits ]
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   modelData
                                    indexModel:             false
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: miscSectionLabel.visible }
                    QGCLabel {
                        id:         miscSectionLabel
                        text:       qsTr("Miscellaneous")
                        visible:    QGroundControl.settingsManager.appSettings.visible
                    }
                    Rectangle {
                        Layout.preferredWidth:  Math.max(comboGrid.width, miscCol.width) + (_margins * 2)
                        Layout.preferredHeight: (pathRow.visible ? pathRow.y + pathRow.height : miscColItem.y + miscColItem.height)  + (_margins * 2)
                        Layout.fillWidth:       true
                        color:                  qgcPal.windowShade
                        visible:                miscSectionLabel.visible

                        Item {
                            id:                 comboGridItem
                            anchors.margins:    _margins
                            anchors.top:        parent.top
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            height:             comboGrid.height

                            GridLayout {
                                id:                         comboGrid
                                anchors.horizontalCenter:   parent.horizontalCenter
                                columns:                    2

                                QGCLabel {
                                    text:           qsTr("Language")
                                    visible: QGroundControl.settingsManager.appSettings.qLocaleLanguage.visible
                                }
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   QGroundControl.settingsManager.appSettings.qLocaleLanguage
                                    indexModel:             false
                                    visible:                QGroundControl.settingsManager.appSettings.qLocaleLanguage.visible
                                }

                                QGCLabel {
                                    text:           qsTr("Color Scheme")
                                    visible: QGroundControl.settingsManager.appSettings.indoorPalette.visible
                                }
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   QGroundControl.settingsManager.appSettings.indoorPalette
                                    indexModel:             false
                                    visible:                QGroundControl.settingsManager.appSettings.indoorPalette.visible
                                }

                                QGCLabel {
                                    text:       qsTr("Map Provider")
                                    width:      _labelWidth
                                }

                                QGCComboBox {
                                    id:             mapCombo
                                    model:          QGroundControl.mapEngineManager.mapProviderList
                                    Layout.preferredWidth:  _comboFieldWidth
                                    onActivated: {
                                        _mapProvider = textAt(index)
                                        QGroundControl.settingsManager.flightMapSettings.mapProvider.value=textAt(index)
                                        QGroundControl.settingsManager.flightMapSettings.mapType.value=QGroundControl.mapEngineManager.mapTypeList(textAt(index))[0]
                                    }
                                    Component.onCompleted: {
                                        var index = mapCombo.find(_mapProvider)
                                        if(index < 0) index = 0
                                        mapCombo.currentIndex = index
                                    }
                                }
                                QGCLabel {
                                    text:       qsTr("Map Type")
                                    width:      _labelWidth
                                }
                                QGCComboBox {
                                    id:             mapTypeCombo
                                    model:          QGroundControl.mapEngineManager.mapTypeList(_mapProvider)
                                    Layout.preferredWidth:  _comboFieldWidth
                                    onActivated: {
                                        _mapType = textAt(index)
                                        QGroundControl.settingsManager.flightMapSettings.mapType.value=textAt(index)
                                    }
                                    Component.onCompleted: {
                                        var index = mapTypeCombo.find(_mapType)
                                        if(index < 0) index = 0
                                        mapTypeCombo.currentIndex = index
                                    }
                                }

                                QGCLabel {
                                    text:                   qsTr("Stream GCS Position")
                                    visible:                _followTarget.visible
                                }
                                FactComboBox {
                                    Layout.preferredWidth:  _comboFieldWidth
                                    fact:                   _followTarget
                                    indexModel:             false
                                    visible:                _followTarget.visible
                                }
                                QGCLabel {
                                    text:                           qsTr("UI Scaling")
                                    visible:                        _appFontPointSize.visible
                                    Layout.alignment:               Qt.AlignVCenter
                                }
                                Item {
                                    width:                          _comboFieldWidth
                                    height:                         baseFontEdit.height * 1.5
                                    visible:                        _appFontPointSize.visible
                                    Layout.alignment:               Qt.AlignVCenter
                                    Row {
                                        spacing:                    ScreenTools.defaultFontPixelWidth
                                        anchors.verticalCenter:     parent.verticalCenter
                                        QGCButton {
                                            width:                  height
                                            height:                 baseFontEdit.height * 1.5
                                            text:                   "-"
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: {
                                                if (_appFontPointSize.value > _appFontPointSize.min) {
                                                    _appFontPointSize.value = _appFontPointSize.value - 1
                                                }
                                            }
                                        }
                                        QGCLabel {
                                            id:                     baseFontEdit
                                            width:                  ScreenTools.defaultFontPixelWidth * 6
                                            text:                   (QGroundControl.settingsManager.appSettings.appFontPointSize.value / ScreenTools.platformFontPointSize * 100).toFixed(0) + "%"
                                            horizontalAlignment:    Text.AlignHCenter
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        Text {

                                        }

                                        QGCButton {
                                            width:                  height
                                            height:                 baseFontEdit.height * 1.5
                                            text:                   "+"
                                            anchors.verticalCenter: parent.verticalCenter
                                            onClicked: {
                                                if (_appFontPointSize.value < _appFontPointSize.max) {
                                                    _appFontPointSize.value = _appFontPointSize.value + 1
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Item {
                            id:                 miscColItem
                            anchors.margins:    _margins
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        comboGridItem.bottom
                            anchors.topMargin:  ScreenTools.defaultFontPixelHeight
                            height:             miscCol.height

                            ColumnLayout {
                                id:                         miscCol
                                anchors.horizontalCenter:   parent.horizontalCenter
                                spacing:                    _margins

                                FactCheckBox {
                                    text:       qsTr("Use Vehicle Pairing")
                                    fact:       _usePairing
                                    visible:    _usePairing.visible && QGroundControl.supportsPairing
                                    property Fact _usePairing: QGroundControl.settingsManager.appSettings.usePairing
                                }

                                FactCheckBox {
                                    text:       qsTr("Mute all audio output")
                                    fact:       _audioMuted
                                    visible:    _audioMuted.visible
                                    property Fact _audioMuted: QGroundControl.settingsManager.appSettings.audioMuted
                                }

                                FactCheckBox {
                                    text:       qsTr("Save application data to SD Card")
                                    fact:       _androidSaveToSDCard
                                    visible:    _androidSaveToSDCard.visible
                                    property Fact _androidSaveToSDCard: QGroundControl.settingsManager.appSettings.androidSaveToSDCard
                                }

                                FactCheckBox {
                                    text:       qsTr("Check for Internet connection")
                                    fact:       _checkInternet
                                    visible:    _checkInternet && _checkInternet.visible
                                    property Fact _checkInternet: QGroundControl.settingsManager.appSettings.checkInternet
                                }

                                QGCCheckBox {
                                    id:         clearCheck
                                    text:       qsTr("Clear all settings on next start")
                                    checked:    false
                                    onClicked: {
                                        checked ? clearDialog.visible = true : QGroundControl.clearDeleteAllSettingsNextBoot()
                                    }
                                    MessageDialog {
                                        id:                 clearDialog
                                        visible:            false
                                        icon:               StandardIcon.Warning
                                        standardButtons:    StandardButton.Yes | StandardButton.No
                                        title:              qsTr("Clear Settings")
                                        text:               qsTr("All saved settings will be reset the next time you start %1. Is this really what you want?").arg(QGroundControl.appName)
                                        onYes: {
                                            QGroundControl.deleteAllSettingsNextBoot()
                                            clearDialog.visible = false
                                        }
                                        onNo: {
                                            clearCheck.checked  = false
                                            clearDialog.visible = false
                                        }
                                    }
                                }

                                // Check box to show/hide Remote ID submenu in App settings
                                FactCheckBox {
                                    text:       qsTr("Enable Remote ID")
                                    fact:       _remoteIDEnable
                                    visible:    _remoteIDEnable.visible
                                    property Fact _remoteIDEnable: QGroundControl.settingsManager.remoteIDSettings.enable
                                }
                            }
                        }

                        RowLayout {
                            id:                 pathRow
                            anchors.margins:    _margins
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            anchors.top:        miscColItem.bottom
                            visible:            _savePath.visible && !ScreenTools.isMobile

                            QGCLabel { text: qsTr("Application Load/Save Path") }
                            QGCTextField {
                                Layout.fillWidth:   true
                                readOnly:           true
                                text:               _savePath.rawValue === "" ? qsTr("<not set>") : _savePath.value
                            }
                            QGCButton {
                                text:       qsTr("Browse")
                                onClicked:  savePathBrowseDialog.openForLoad()
                                QGCFileDialog {
                                    id:             savePathBrowseDialog
                                    title:          qsTr("Choose the location to save/load files")
                                    folder:         _savePath.rawValue
                                    selectExisting: true
                                    selectFolder:   true
                                    onAcceptedForLoad: _savePath.rawValue = file
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: telemetryLogSectionLabel.visible }
                    QGCLabel {
                        id:         telemetryLogSectionLabel
                        text:       qsTr("Telemetry Logs from Vehicle")
                        visible:    telemetryRect.visible
                    }
                    Rectangle {
                        id:                     telemetryRect
                        Layout.preferredHeight: loggingCol.height + (_margins * 2)
                        Layout.preferredWidth:  loggingCol.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        Layout.fillWidth:       true
                        visible:                promptSaveLog._telemetrySave.visible || logIfNotArmed._telemetrySaveNotArmed.visible || promptSaveCsv._saveCsvTelemetry.visible
                        ColumnLayout {
                            id:                         loggingCol
                            anchors.margins:            _margins
                            anchors.top:                parent.top
                            anchors.horizontalCenter:   parent.horizontalCenter
                            spacing:                    _margins
                            FactCheckBox {
                                id:         promptSaveLog
                                text:       qsTr("Save log after each flight")
                                fact:       _telemetrySave
                                visible:    _telemetrySave.visible
                                enabled:    !_disableAllDataPersistence
                                property Fact _telemetrySave: QGroundControl.settingsManager.appSettings.telemetrySave
                            }
                            FactCheckBox {
                                id:         logIfNotArmed
                                text:       qsTr("Save logs even if vehicle was not armed")
                                fact:       _telemetrySaveNotArmed
                                visible:    _telemetrySaveNotArmed.visible
                                enabled:    promptSaveLog.checked && !_disableAllDataPersistence
                                property Fact _telemetrySaveNotArmed: QGroundControl.settingsManager.appSettings.telemetrySaveNotArmed
                            }
                            FactCheckBox {
                                id:         promptSaveCsv
                                text:       qsTr("Save CSV log of telemetry data")
                                fact:       _saveCsvTelemetry
                                visible:    _saveCsvTelemetry.visible
                                enabled:    !_disableAllDataPersistence
                                property Fact _saveCsvTelemetry: QGroundControl.settingsManager.appSettings.saveCsvTelemetry
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: autoConnectSectionLabel.visible }
                    QGCLabel {
                        id:         autoConnectSectionLabel
                        text:       qsTr("AutoConnect to the following devices")
                        visible:    QGroundControl.settingsManager.autoConnectSettings.visible
                    }
                    Rectangle {
                        Layout.preferredWidth:  autoConnectCol.width + (_margins * 2)
                        Layout.preferredHeight: autoConnectCol.height + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                autoConnectSectionLabel.visible
                        Layout.fillWidth:       true

                        ColumnLayout {
                            id:                 autoConnectCol
                            anchors.margins:    _margins
                            anchors.left:       parent.left
                            anchors.top:        parent.top
                            spacing:            _margins

                            RowLayout {
                                spacing: _margins

                                Repeater {
                                    id:     autoConnectRepeater
                                    model:  [ QGroundControl.settingsManager.autoConnectSettings.autoConnectPixhawk,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectSiKRadio,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectPX4Flow,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectLibrePilot,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectUDP,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectRTKGPS,
                                        QGroundControl.settingsManager.autoConnectSettings.autoConnectZeroConf,
                                    ]

                                    property var names: [ qsTr("Pixhawk"), qsTr("SiK Radio"), qsTr("PX4 Flow"), qsTr("LibrePilot"), qsTr("UDP"), qsTr("RTK GPS"), qsTr("Zero-Conf") ]

                                    FactCheckBox {
                                        text:       autoConnectRepeater.names[index]
                                        fact:       modelData
                                        visible:    modelData.visible
                                    }
                                }
                            }

                            GridLayout {
                                Layout.fillWidth:   false
                                Layout.alignment:   Qt.AlignHCenter
                                columns:            2
                                visible:            !ScreenTools.isMobile
                                                    && QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaPort.visible
                                                    && QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaBaud.visible

                                QGCLabel {
                                    text: qsTr("NMEA GPS Device")
                                }
                                QGCComboBox {
                                    id:                     nmeaPortCombo
                                    Layout.preferredWidth:  _comboFieldWidth

                                    model:  ListModel {
                                    }

                                    onActivated: {
                                        if (index != -1) {
                                            QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaPort.value = textAt(index);
                                        }
                                    }
                                    Component.onCompleted: {
                                        model.append({text: gpsDisabled})
                                        model.append({text: gpsUdpPort})

                                        for (var i in QGroundControl.linkManager.serialPorts) {
                                            nmeaPortCombo.model.append({text:QGroundControl.linkManager.serialPorts[i]})
                                        }
                                        var index = nmeaPortCombo.find(QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaPort.valueString);
                                        nmeaPortCombo.currentIndex = index;
                                        if (QGroundControl.linkManager.serialPorts.length === 0) {
                                            nmeaPortCombo.model.append({text: "Serial <none available>"})
                                        }
                                    }
                                }

                                QGCLabel {
                                    visible:          nmeaPortCombo.currentText !== gpsUdpPort && nmeaPortCombo.currentText !== gpsDisabled
                                    text:             qsTr("NMEA GPS Baudrate")
                                }
                                QGCComboBox {
                                    visible:                nmeaPortCombo.currentText !== gpsUdpPort && nmeaPortCombo.currentText !== gpsDisabled
                                    id:                     nmeaBaudCombo
                                    Layout.preferredWidth:  _comboFieldWidth
                                    model:                  [1200, 2400, 4800, 9600, 19200, 38400, 57600, 115200, 230400, 460800, 921600]

                                    onActivated: {
                                        if (index != -1) {
                                            QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaBaud.value = textAt(index);
                                        }
                                    }
                                    Component.onCompleted: {
                                        var index = nmeaBaudCombo.find(QGroundControl.settingsManager.autoConnectSettings.autoConnectNmeaBaud.valueString);
                                        nmeaBaudCombo.currentIndex = index;
                                    }
                                }

                                QGCLabel {
                                    text:       qsTr("NMEA stream UDP port")
                                    visible:    nmeaPortCombo.currentText === gpsUdpPort
                                }
                                FactTextField {
                                    visible:                nmeaPortCombo.currentText === gpsUdpPort
                                    Layout.preferredWidth:  _valueFieldWidth
                                    fact:                   QGroundControl.settingsManager.autoConnectSettings.nmeaUdpPort
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: rtkSectionLabel.visible }
                    QGCLabel {
                        id:         rtkSectionLabel
                        text:       qsTr("RTK GPS")
                        visible:    QGroundControl.settingsManager.rtkSettings.visible
                    }
                    Rectangle {
                        Layout.preferredHeight: rtkGrid.height + (_margins * 2)
                        Layout.preferredWidth:  rtkGrid.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                rtkSectionLabel.visible
                        Layout.fillWidth:       true

                        GridLayout {
                            id:                         rtkGrid
                            anchors.topMargin:          _margins
                            anchors.top:                parent.top
                            Layout.fillWidth:           true
                            anchors.horizontalCenter:   parent.horizontalCenter
                            columns:                    3

                            property var  rtkSettings:      QGroundControl.settingsManager.rtkSettings
                            property bool useFixedPosition: rtkSettings.useFixedBasePosition.rawValue
                            property real firstColWidth:    ScreenTools.defaultFontPixelWidth * 3

                            QGCRadioButton {
                                text:               qsTr("Perform Survey-In")
                                visible:            rtkGrid.rtkSettings.useFixedBasePosition.visible
                                checked:            rtkGrid.rtkSettings.useFixedBasePosition.value === false
                                Layout.columnSpan:  3
                                onClicked:          rtkGrid.rtkSettings.useFixedBasePosition.value = false
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:               rtkGrid.rtkSettings.surveyInAccuracyLimit.shortDescription
                                visible:            rtkGrid.rtkSettings.surveyInAccuracyLimit.visible
                                enabled:            !rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.surveyInAccuracyLimit
                                visible:            rtkGrid.rtkSettings.surveyInAccuracyLimit.visible
                                enabled:            !rtkGrid.useFixedPosition
                                Layout.preferredWidth:  _valueFieldWidth
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:               rtkGrid.rtkSettings.surveyInMinObservationDuration.shortDescription
                                visible:            rtkGrid.rtkSettings.surveyInMinObservationDuration.visible
                                enabled:            !rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.surveyInMinObservationDuration
                                visible:            rtkGrid.rtkSettings.surveyInMinObservationDuration.visible
                                enabled:            !rtkGrid.useFixedPosition
                                Layout.preferredWidth:  _valueFieldWidth
                            }

                            QGCRadioButton {
                                text:               qsTr("Use Specified Base Position")
                                visible:            rtkGrid.rtkSettings.useFixedBasePosition.visible
                                checked:            rtkGrid.rtkSettings.useFixedBasePosition.value === true
                                onClicked:          rtkGrid.rtkSettings.useFixedBasePosition.value = true
                                Layout.columnSpan:  3
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:               rtkGrid.rtkSettings.fixedBasePositionLatitude.shortDescription
                                visible:            rtkGrid.rtkSettings.fixedBasePositionLatitude.visible
                                enabled:            rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.fixedBasePositionLatitude
                                visible:            rtkGrid.rtkSettings.fixedBasePositionLatitude.visible
                                enabled:            rtkGrid.useFixedPosition
                                Layout.fillWidth:   true
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:               rtkGrid.rtkSettings.fixedBasePositionLongitude.shortDescription
                                visible:            rtkGrid.rtkSettings.fixedBasePositionLongitude.visible
                                enabled:            rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.fixedBasePositionLongitude
                                visible:            rtkGrid.rtkSettings.fixedBasePositionLongitude.visible
                                enabled:            rtkGrid.useFixedPosition
                                Layout.fillWidth:   true
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:           rtkGrid.rtkSettings.fixedBasePositionAltitude.shortDescription
                                visible:        rtkGrid.rtkSettings.fixedBasePositionAltitude.visible
                                enabled:        rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.fixedBasePositionAltitude
                                visible:            rtkGrid.rtkSettings.fixedBasePositionAltitude.visible
                                enabled:            rtkGrid.useFixedPosition
                                Layout.fillWidth:   true
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCLabel {
                                text:           rtkGrid.rtkSettings.fixedBasePositionAccuracy.shortDescription
                                visible:        rtkGrid.rtkSettings.fixedBasePositionAccuracy.visible
                                enabled:        rtkGrid.useFixedPosition
                            }
                            FactTextField {
                                fact:               rtkGrid.rtkSettings.fixedBasePositionAccuracy
                                visible:            rtkGrid.rtkSettings.fixedBasePositionAccuracy.visible
                                enabled:            rtkGrid.useFixedPosition
                                Layout.fillWidth:   true
                            }

                            Item { width: rtkGrid.firstColWidth; height: 1 }
                            QGCButton {
                                text:               qsTr("Save Current Base Position")
                                enabled:            QGroundControl.gpsRtk && QGroundControl.gpsRtk.valid.value
                                Layout.columnSpan:  2
                                onClicked: {
                                    rtkGrid.rtkSettings.fixedBasePositionLatitude.rawValue =    QGroundControl.gpsRtk.currentLatitude.rawValue
                                    rtkGrid.rtkSettings.fixedBasePositionLongitude.rawValue =   QGroundControl.gpsRtk.currentLongitude.rawValue
                                    rtkGrid.rtkSettings.fixedBasePositionAltitude.rawValue =    QGroundControl.gpsRtk.currentAltitude.rawValue
                                    rtkGrid.rtkSettings.fixedBasePositionAccuracy.rawValue =    QGroundControl.gpsRtk.currentAccuracy.rawValue
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: adsbSectionLabel.visible }
                    QGCLabel {
                        id:         adsbSectionLabel
                        text:       qsTr("ADSB Server")
                        visible:    QGroundControl.settingsManager.adsbVehicleManagerSettings.visible
                    }
                    Rectangle {
                        Layout.preferredHeight: adsbGrid.y + adsbGrid.height + _margins
                        Layout.preferredWidth:  adsbGrid.width + (_margins * 2)
                        color:                  qgcPal.windowShade
                        visible:                adsbSectionLabel.visible
                        Layout.fillWidth:       true

                        QGCLabel {
                            id:                 warningLabel
                            anchors.margins:    _margins
                            anchors.top:        parent.top
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            font.pointSize:     ScreenTools.smallFontPointSize
                            wrapMode:           Text.WordWrap
                            text:               qsTr("Note: These setting are not meant for use with an ADSB transponder which is situated on the vehicle.")
                        }

                        GridLayout {
                            id:                         adsbGrid
                            anchors.topMargin:          _margins
                            anchors.top:                warningLabel.bottom
                            Layout.fillWidth:           true
                            anchors.horizontalCenter:   parent.horizontalCenter
                            columns:                    2

                            property var  adsbSettings:    QGroundControl.settingsManager.adsbVehicleManagerSettings

                            FactCheckBox {
                                text:                   adsbGrid.adsbSettings.adsbServerConnectEnabled.shortDescription
                                fact:                   adsbGrid.adsbSettings.adsbServerConnectEnabled
                                visible:                adsbGrid.adsbSettings.adsbServerConnectEnabled.visible
                                Layout.columnSpan:      2
                            }

                            QGCLabel {
                                text:               adsbGrid.adsbSettings.adsbServerHostAddress.shortDescription
                                visible:            adsbGrid.adsbSettings.adsbServerHostAddress.visible
                            }
                            FactTextField {
                                fact:                   adsbGrid.adsbSettings.adsbServerHostAddress
                                visible:                adsbGrid.adsbSettings.adsbServerHostAddress.visible
                                Layout.fillWidth:       true
                            }

                            QGCLabel {
                                text:               adsbGrid.adsbSettings.adsbServerPort.shortDescription
                                visible:            adsbGrid.adsbSettings.adsbServerPort.visible
                            }
                            FactTextField {
                                fact:                   adsbGrid.adsbSettings.adsbServerPort
                                visible:                adsbGrid.adsbSettings.adsbServerPort.visible
                                Layout.preferredWidth:  _valueFieldWidth
                            }
                        }
                    }

                    Item { width: 1; height: _margins; visible: brandImageSectionLabel.visible }
                    QGCLabel {
                        id:         brandImageSectionLabel
                        text:       qsTr("Brand Image")
                        visible:    QGroundControl.settingsManager.brandImageSettings.visible && !ScreenTools.isMobile
                    }
                    Rectangle {
                        Layout.preferredWidth:  brandImageGrid.width + (_margins * 2)
                        Layout.preferredHeight: brandImageGrid.height + (_margins * 2)
                        Layout.fillWidth:       true
                        color:                  qgcPal.windowShade
                        visible:                brandImageSectionLabel.visible

                        GridLayout {
                            id:                 brandImageGrid
                            anchors.margins:    _margins
                            anchors.top:        parent.top
                            anchors.left:       parent.left
                            anchors.right:      parent.right
                            columns:            3

                            QGCLabel {
                                text:           qsTr("Indoor Image")
                                visible:        _userBrandImageIndoor.visible
                            }
                            QGCTextField {
                                readOnly:           true
                                Layout.fillWidth:   true
                                text:               _userBrandImageIndoor.valueString.replace("file:///","")
                            }
                            QGCButton {
                                text:       qsTr("Browse")
                                onClicked:  userBrandImageIndoorBrowseDialog.openForLoad()
                                QGCFileDialog {
                                    id:                 userBrandImageIndoorBrowseDialog
                                    title:              qsTr("Choose custom brand image file")
                                    folder:             _userBrandImageIndoor.rawValue.replace("file:///","")
                                    selectExisting:     true
                                    selectFolder:       false
                                    onAcceptedForLoad:  _userBrandImageIndoor.rawValue = "file:///" + file
                                }
                            }

                            QGCLabel {
                                text:       qsTr("Outdoor Image")
                                visible:    _userBrandImageOutdoor.visible
                            }
                            QGCTextField {
                                readOnly:           true
                                Layout.fillWidth:   true
                                text:                _userBrandImageOutdoor.valueString.replace("file:///","")
                            }
                            QGCButton {
                                text:       qsTr("Browse")
                                onClicked:  userBrandImageOutdoorBrowseDialog.openForLoad()
                                QGCFileDialog {
                                    id:                 userBrandImageOutdoorBrowseDialog
                                    title:              qsTr("Choose custom brand image file")
                                    folder:             _userBrandImageOutdoor.rawValue.replace("file:///","")
                                    selectExisting:     true
                                    selectFolder:       false
                                    onAcceptedForLoad:  _userBrandImageOutdoor.rawValue = "file:///" + file
                                }
                            }
                            QGCButton {
                                text:               qsTr("Reset Default Brand Image")
                                Layout.columnSpan:  3
                                Layout.alignment:   Qt.AlignHCenter
                                onClicked:  {
                                    _userBrandImageIndoor.rawValue = ""
                                    _userBrandImageOutdoor.rawValue = ""
                                }
                            }
                        }
                    }

                    Item { width: 1; height: _margins }
                    QGCLabel {
                        text:               qsTr("%1 Version").arg(QGroundControl.appName)
                        Layout.alignment:   Qt.AlignHCenter
                    }
                    QGCLabel {
                        text:               QGroundControl.qgcVersion
                        Layout.alignment:   Qt.AlignHCenter
                    }
                } // settingsColumn
            }
    }
}
