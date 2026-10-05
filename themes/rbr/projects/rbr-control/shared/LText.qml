import QtQuick
import "."

Text {
    color: Rbr.tan
    font.family: Rbr.font
    font.italic: true
    font.weight: Font.DemiBold
    font.capitalization: Font.AllUppercase
    font.pixelSize: 2.2 * Rbr.u
    elide: Text.ElideRight
    textFormat: Text.PlainText
    lineHeightMode: Text.ProportionalHeight
    lineHeight: 0.9
}
