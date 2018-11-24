import QtQuick 2.11

Text {
    font.pixelSize: root.fontSize
    onTextChanged: {
        if (text.length === 0) { this.text = "-" }
    }
}
