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

import QtQuick
import QtQuick.Effects

FocusScope {
    id: backgroundComponent

    property alias imageSource: backgroundImage.source
    property bool configBlur: config.blur == "true"

    Image {
        id: backgroundImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop

        clip: true
        focus: true
        smooth: true
        visible: !configBlur
    }

    // Qt6-native MultiEffect instead of Qt5Compat's RecursiveBlur: one downsampled
    // pass rather than `loops` sequential passes through 8-bit FBOs, and it is the
    // supported Qt6 path. Note that heavy blur on a smooth dark gradient can band
    // regardless of implementation -- blurring removes the source noise that was
    // dithering the 8-bit steps. If banding persists, lower the radius or dither.
    MultiEffect {
        id: backgroundBlur

        anchors.fill: backgroundImage
        source: backgroundImage
        visible: configBlur

        blurEnabled: configBlur
        blur: 1.0
        // recursiveBlurRadius/Loops are kept as the tuning knobs for continuity
        // with upstream theme.conf; they map onto MultiEffect's kernel controls.
        blurMax: Math.max(2, Math.min(64, Math.round(config.recursiveBlurRadius * 2)))
        blurMultiplier: Math.max(0, config.recursiveBlurLoops - 1)
    }

    MouseArea {
        anchors.fill: parent
        onClicked: container.focus = true
    }
}
