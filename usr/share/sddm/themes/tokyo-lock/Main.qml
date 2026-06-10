import QtQuick 2.15

Rectangle {
    id: root
    width: 1920
    height: 1080
    color: "#1a1b26"

    property int sessionIndex: sessionModel.lastIndex

    // --- Background: blurred wallpaper + dark overlay ---
    Image {
        anchors.fill: parent
        source: "background.jpg"
        fillMode: Image.PreserveAspectCrop
        cache: true
    }
    Rectangle {
        anchors.fill: parent
        color: "#1a1b26"
        opacity: 0.45
    }

    // --- Clock + date ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.16
        spacing: 4

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#c0caf5"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 110
            font.bold: true
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            id: dateText
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#7aa2f7"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 26
            text: Qt.formatDateTime(new Date(), "dddd, MMMM d")
        }
    }
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: {
            timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
            dateText.text = Qt.formatDateTime(new Date(), "dddd, MMMM d")
        }
    }

    // --- Login (centered, lower) ---
    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: parent.height * 0.14
        spacing: 14
        width: 320

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#c0caf5"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 18
            text: "  " + (userModel.lastUser !== "" ? userModel.lastUser : "user")
        }

        Rectangle {
            id: pwBox
            width: parent.width
            height: 46
            radius: 12
            color: "#24283b"
            border.color: errorText.text !== "" ? "#f7768e" : "#7aa2f7"
            border.width: 2

            TextInput {
                id: password
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                verticalAlignment: TextInput.AlignVCenter
                horizontalAlignment: TextInput.AlignHCenter
                color: "#c0caf5"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 16
                font.letterSpacing: 6
                echoMode: TextInput.Password
                passwordCharacter: "♡"
                clip: true
                focus: true
                onTextChanged: errorText.text = ""
                onAccepted: sddm.login(userModel.lastUser, password.text, root.sessionIndex)

                Text {
                    anchors.centerIn: parent
                    color: "#565f89"
                    font: password.font
                    text: "Password…"
                    visible: password.text === "" && !password.activeFocus
                }
            }
        }

        Text {
            id: errorText
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#f7768e"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            text: ""
        }
    }

    // --- Power options (bottom-right, subtle) ---
    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 26
        spacing: 22

        Text {
            color: "#7aa2f7"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 24
            text: "󰜉"
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.reboot() }
        }
        Text {
            color: "#f7768e"
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 24
            text: "⏻"
            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: sddm.powerOff() }
        }
    }

    // --- SDDM signals ---
    Connections {
        target: sddm
        function onLoginFailed() {
            password.text = ""
            errorText.text = "Wrong password"
        }
        function onLoginSucceeded() {}
    }

    Component.onCompleted: password.forceActiveFocus()
}
