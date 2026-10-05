import QtQuick
import "."

Text {
    color: Feyenoord.tan
    font.family: Feyenoord.font
    font.italic: Feyenoord.italic
    font.weight: Font.DemiBold
    font.capitalization: Font.AllUppercase
    font.pixelSize: 2.2 * Feyenoord.u
    elide: Text.ElideRight
    // Too wide for its box: shrink (down to 70%) before cutting off with "…". Wrapped text keeps its size.
    fontSizeMode: wrapMode === Text.NoWrap ? Text.HorizontalFit : Text.FixedSize
    minimumPixelSize: Math.max(6, Math.round(font.pixelSize * 0.7))
    textFormat: Text.PlainText
    lineHeightMode: Text.ProportionalHeight
    lineHeight: 0.9
}
