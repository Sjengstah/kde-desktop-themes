import QtQuick
import "."

Text {
    color: StarWars.tan
    font.family: StarWars.font
    font.italic: StarWars.italic
    font.weight: Font.DemiBold
    font.capitalization: Font.AllUppercase
    font.pixelSize: 2.2 * StarWars.u
    elide: Text.ElideRight
    textFormat: Text.PlainText
    lineHeightMode: Text.ProportionalHeight
    lineHeight: 0.9
}
