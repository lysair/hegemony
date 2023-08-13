// SPDX-License-Identifier: GPL-3.0-or-later

import QtQuick
import QtQuick.Layouts
import Fk.Pages
import Fk.RoomElement

GraphicsBox {
  property string mainGeneral:"anjiang"
  property string deputyGeneral:"anjiang"
  id: root

  //ListModel {
    //id: generalList
  //}

  title.text: Backend.translate("#KnownBothGeneral")
  width: generalArea.width + body.anchors.leftMargin + body.anchors.rightMargin
  height: body.implicitHeight + body.anchors.topMargin + body.anchors.bottomMargin

  Column {
    id: body
    anchors.fill: parent
    anchors.margins: 40
    anchors.bottomMargin: 20

    Item {
      id: generalArea
      width: 194
      height: 150
      z: 1

        GeneralCardItem {
          id: mainGeneralCard
          name: mainGeneral
          x: 0
          y: 0
        }

          GeneralCardItem {
            id: deputyGeneralCard
            name: deputyGeneral
            x: 97
            y: 0
          }
    }

    Item {
      id: buttonArea
      width: parent.width
      height: 40

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        spacing: 8

        MetroButton {
          id: fightButton
          text: Backend.translate("OK")
          width: 120
          height: 35
          enabled: true

          onClicked: { 
            close();
            roomScene.state = "notactive";
            ClientInstance.replyToServer("", "");
          }
        }

        MetroButton {
          id: detailBtn
          text: Backend.translate("Show General Detail")
          onClicked: roomScene.startCheat(
            "GeneralDetail",
            { generals: [mainGeneral, deputyGeneral] }
          );
        }
      }
    }
  }



  function loadData(data) {
    //for (let i = 0; i < 2; i++)
      //generalList.append({ "name": data[i] });
      //generalList.push(data[i]);
    mainGeneral = data[0];
    deputyGeneral = data[1];
  }
}
