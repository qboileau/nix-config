/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 3 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import SddmComponents 2.0

import "components"

Rectangle {
    id: root

    // ScreenWidth/ScreenHeight are optional overrides; without the Screen fallback
    // a stale hardcoded size leaves the rest of the view unpainted.
    width: config.ScreenWidth ? config.ScreenWidth : Screen.width
    height: config.ScreenHeight ? config.ScreenHeight : Screen.height

    // Never leave the greeter white: an outlined password field (white text,
    // white border, transparent fill) is invisible on it if the wallpaper fails.
    color: "black"

    property string notificationMessage
    property string generalFontColor: "white"
    // Math.max: root.height is still 0 on the first binding pass, and Qt warns on pointSize 0.
    property int generalFontSize: Math.max(1, config.FontPointSize ? config.FontPointSize : root.height / 80)

    // Upstream referenced Plasma's `units.longDuration`, which no SDDM theme provides.
    property int longDuration: 150

    TextConstants { id: textConstants }

    Repeater {
        model: screenModel
        Wallpaper {
            x: geometry.x
            y: geometry.y
            width: geometry.width
            height: geometry.height
            // Resolve here, not in Wallpaper.qml: a relative string assigned through
            // a property alias resolves against the alias target's file (components/).
            imageSource: Qt.resolvedUrl(config.background)
        }
    }

    ColumnLayout {
        id: container
        anchors.fill: parent

        LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
        LayoutMirroring.childrenInherit: true

        RowLayout {
            id: header

            Layout.alignment: Qt.AlignRight
            Layout.fillHeight: false
            Layout.topMargin: generalFontSize
            Layout.rightMargin: generalFontSize * 1.5

            KeyboardLayoutButton {

                Layout.topMargin: -1

                implicitHeight: clockLabel.height * 1.2
                implicitWidth: clockLabel.height * 1.8

            }

            Item {
                id: clock

                Layout.fillHeight: true
                Layout.minimumWidth: clockLabel.width

                Label {
                    id: clockLabel
                    color: generalFontColor
                    font.pointSize: root.generalFontSize
                    renderType: Text.QtRendering
                    function updateTime() {
                        text = new Date().toLocaleString(Qt.locale("en_US"), "ddd dd MMMM,  hh:mm A")
                    }
                }
                Timer {
                    interval: 1000
                    repeat: true
                    running: true
                    onTriggered: {
                        clockLabel.updateTime()
                    }
                }
                Component.onCompleted: {
                    clockLabel.updateTime()
                }
            }
        }


        StackView {
            id: loginFormStack

            Layout.fillHeight: true
            Layout.fillWidth: true
            focus: true // StackView is an implicit focus scope. Therefore focus needs to be passed to its children.

            // Shifted via transform rather than `y`: this item is layout-managed,
            // and Qt6 layouts reject direct geometry writes.
            transform: Translate { id: loginFormShift }

            initialItem: LoginForm {
                id: userListComponent
                focus: true

                userListModel: userModel
                userListCurrentIndex: userModel.lastIndex >= 0 ? userModel.lastIndex : 0
                lastUserName: userModel.lastUser
                usernameFontSize: root.generalFontSize
                usernameFontColor: root.generalFontColor
                faceSize: config.AvatarPixelSize ? config.AvatarPixelSize : root.width / 15

                showUserList: {
                    if ( !userListModel.hasOwnProperty("count") || !userListModel.hasOwnProperty("disableAvatarsThreshold") )
                        return (userList.y + loginFormStack.y + loginFormShift.y) > 0
                    if ( userListModel.count == 0 )
                        return false
                    return userListModel.count <= userListModel.disableAvatarsThreshold && (userList.y + loginFormStack.y + loginFormShift.y) > 0
                }

                notificationMessage: {
                    var text = ""
                    text += root.notificationMessage
                    return text
                }

                actionItems: [
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/suspend.svgz")
                        text: config.translationSuspend ? config.translationSuspend : "Suspend"
                        onClicked: sddm.suspend()
                        enabled: sddm.canSuspend
                        iconSize: root.generalFontSize * 3
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/reboot.svgz")
                        text: config.translationReboot ? config.translationReboot : textConstants.reboot
                        onClicked: sddm.reboot()
                        enabled: sddm.canReboot
                        iconSize: root.generalFontSize * 3
                    },
                    ActionButton {
                        iconSource: Qt.resolvedUrl("assets/shutdown.svgz")
                        text: config.translationPowerOff ? config.translationPowerOff : textConstants.shutdown
                        onClicked: sddm.powerOff()
                        enabled: sddm.canPowerOff
                        iconSize: root.generalFontSize * 3
                    }
                ]

                onLoginRequest: (username, password) => {
                    root.notificationMessage = ""
                    sddm.login(username, password, sessionMenu.currentIndex)
                }
            }


            Behavior on opacity {
                OpacityAnimator {
                    duration: 150
                }
            }

        }

        RowLayout {
            id: footer

            Layout.fillHeight: false
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: generalFontSize
            Layout.leftMargin: generalFontSize * 1.5

            SessionMenu {
                id: sessionMenu

                rootFontSize: root.generalFontSize
                rootFontColor: root.generalFontColor
            }
        }

        Connections {
            target: sddm
            function onLoginFailed() {
                notificationMessage = textConstants.loginFailed
                notificationResetTimer.start();
            }
        }

        Timer {
            id: notificationResetTimer
            interval: 3000
            onTriggered: notificationMessage = ""
        }

    }

    // Deliberately a sibling of `container`, not a child: it anchors and animates
    // its own `y`, which a ColumnLayout child may not do.
    Loader {
        id: inputPanel
        state: "hidden"
        property bool keyboardActive: item ? item.active : false
        onKeyboardActiveChanged: {
            if (keyboardActive) {
                state = "visible"
            } else {
                state = "hidden";
            }
        }
        source: "components/VirtualKeyboard.qml"
        anchors {
            left: parent.left
            right: parent.right
        }

        function showHide() {
            state = state == "hidden" ? "visible" : "hidden";
        }

        states: [
            State {
                name: "visible"
                PropertyChanges {
                    target: loginFormShift
                    y: Math.min(0, root.height - inputPanel.height - userListComponent.visibleBoundary)
                }
                PropertyChanges {
                    target: inputPanel
                    y: root.height - inputPanel.height
                    opacity: 1
                }
            },
            State {
                name: "hidden"
                PropertyChanges {
                    target: loginFormShift
                    y: 0
                }
                PropertyChanges {
                    target: inputPanel
                    y: root.height - root.height/4
                    opacity: 0
                }
            }
        ]
        transitions: [
            Transition {
                from: "hidden"
                to: "visible"
                SequentialAnimation {
                    ScriptAction {
                        script: {
                            inputPanel.item.activated = true;
                            Qt.inputMethod.show();
                        }
                    }
                    ParallelAnimation {
                        NumberAnimation {
                            target: loginFormShift
                            property: "y"
                            duration: root.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: root.longDuration
                            easing.type: Easing.OutQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: root.longDuration
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            },
            Transition {
                from: "visible"
                to: "hidden"
                SequentialAnimation {
                    ParallelAnimation {
                        NumberAnimation {
                            target: loginFormShift
                            property: "y"
                            duration: root.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        NumberAnimation {
                            target: inputPanel
                            property: "y"
                            duration: root.longDuration
                            easing.type: Easing.InQuad
                        }
                        OpacityAnimator {
                            target: inputPanel
                            duration: root.longDuration
                            easing.type: Easing.InQuad
                        }
                    }
                    ScriptAction {
                        script: {
                            Qt.inputMethod.hide();
                        }
                    }
                }
            }
        ]
    }
}
