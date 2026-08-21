/*
 *   Copyright 2018 Marian Alexander Arlt <marianarlt@icloud.com>
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

ToolButton {
    id: root

    property int currentIndex: -1
    property int rootFontSize
    property string rootFontColor

    visible: sessionMenu.count > 1

    opacity: root.activeFocus ? 1 : 0.5

    // Controls 2 has no `style`/`menu`: use contentItem/background and popup() explicitly.
    contentItem: Label {
        id: buttonLabel
        color: rootFontColor
        font.pointSize: Math.max(1, rootFontSize)
        renderType: Text.QtRendering
        text: instantiator.objectAt(root.currentIndex) ? instantiator.objectAt(root.currentIndex).text : ""
        font.underline: root.activeFocus
    }
    background: Rectangle {
        color: "transparent"
    }

    onClicked: sessionMenu.popup()

    Component.onCompleted: {
        currentIndex = sessionModel.lastIndex
    }

    Menu {
        id: sessionMenu
        Instantiator {
            id: instantiator
            model: sessionModel
            onObjectAdded: (index, object) => sessionMenu.insertItem(index, object)
            onObjectRemoved: (index, object) => sessionMenu.removeItem(object)
            delegate: MenuItem {
                text: model.name
                onTriggered: {
                    root.currentIndex = model.index
                }
            }
        }
    }
}
