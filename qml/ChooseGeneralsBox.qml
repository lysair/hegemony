// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Fk
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
  id: root

  property var selectedItem: []
  property var cards: []
  property var available_cards: []
  property string prompt
  property string result : ""

  property bool isSearching: false
  
  width: 40 + Math.min(7, Math.max(4, cards.length)) * 100
  height: 80 + Math.min(2.2, Math.ceil(cards.length / 7)) * 140

  Component {
    id: cardDelegate
    GeneralCardItem {
      name: modelData
      selectable: available_cards.includes(name)
      onSelectedChanged: {
        result = modelData;
        close();
      }
      onRightClicked: {
        roomScene.startCheat("GeneralDetail", { generals: [modelData] });
      }
    }
  }

  Rectangle {
    id: cardArea
    anchors.fill: parent
    anchors.topMargin: 60
    anchors.leftMargin: 15
    anchors.rightMargin: 15
    anchors.bottomMargin: 15

    color: "#88EEEEEE"
    radius: 10

    GridView {
      id: generalContainer

      anchors.fill: parent
      anchors.topMargin: 5
      anchors.leftMargin: 5
      anchors.rightMargin: 5
      anchors.bottomMargin: 5

      //contentHeight: gridLayout.implicitHeight
      clip: true
      cellWidth: 93 + 5
      cellHeight: 130 + 5

      model: cards
      delegate: cardDelegate
    }
  }

  Item {
    id : titleArea
    anchors.top: parent.top
    anchors.topMargin: 5
    anchors.horizontalCenter: parent.horizontalCenter

    height: 40
    width: parent.width - 30


    RowLayout {
      anchors.fill: parent

      Text {
        font.pixelSize: 20
        color: "#E4D5A0"
        text: Util.processPrompt(prompt)
        horizontalAlignment: Text.AlignHCenter
        Layout.fillWidth: true
      }
        
    }
  }
}

