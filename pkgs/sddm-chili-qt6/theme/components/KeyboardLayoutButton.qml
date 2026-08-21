/*
 *   Copyright 2018 Marian Arlt <marianarlt@icloud.com>
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

import QtQml
import QtQuick
import QtQuick.Controls

Button {
    id: keyboardLayoutButton

    property int currentIndex

    visible: keyboard.layouts.length > 1

    // Controls 2 has no `style`/`menu`: use contentItem/background and popup() explicitly.
    contentItem: Image {
        id: buttonLabel
        source: "../assets/keyboard.svgz"
        fillMode: Image.PreserveAspectFit
        transform: Translate { x: 5 }
        smooth: false
    }
    background: Rectangle {
        radius: 3
        color: keyboardLayoutButton.activeFocus ? "white" : "transparent"
        opacity: keyboardLayoutButton.activeFocus ? 0.3 : 1
    }

    onClicked: keyboardLayoutMenu.popup()

    Menu {
        id: keyboardLayoutMenu
        Instantiator {
            id: instantiator
            model: keyboard.layouts
            onObjectAdded: (index, object) => keyboardLayoutMenu.insertItem(index, object)
            onObjectRemoved: (index, object) => keyboardLayoutMenu.removeItem(object)
            delegate: MenuItem {
                text: modelData.longName
                property string shortName: modelData.shortName
                onTriggered: {
                    keyboard.currentLayout = model.index
                }
            }
        }
    }

    Component.onCompleted: currentIndex = Qt.binding(function() {
        return keyboard.currentLayout
    });

}
