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
    // Too wide for its box: shrink (down to 70%) before cutting off with "…". Wrapped text keeps its size.
    fontSizeMode: wrapMode === Text.NoWrap ? Text.HorizontalFit : Text.FixedSize
    minimumPixelSize: Math.max(6, Math.round(font.pixelSize * 0.7))
    textFormat: Text.PlainText
    lineHeightMode: Text.ProportionalHeight
    lineHeight: 0.9
}
