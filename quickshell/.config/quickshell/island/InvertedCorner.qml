import QtQuick
import QtQuick.Shapes
import ".."

Item {
    id: root

    property real radius: Theme.cornerRadius
    property color fillColor: Theme.bgDeep
    property bool mirrored: false

    implicitWidth: radius
    implicitHeight: radius
    width: radius
    height: radius

    visible: radius > 0

    Shape {
        anchors.fill: parent
        antialiasing: true
        preferredRendererType: Shape.CurveRenderer

        transform: Scale {
            xScale: root.mirrored ? -1 : 1
            origin.x: root.width / 2
        }

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: -1

            startX: 0
            startY: 0

            PathLine {
                x: root.radius
                y: 0
            }
            PathLine {
                x: root.radius
                y: root.radius
            }

            PathArc {
                x: 0
                y: 0
                radiusX: root.radius
                radiusY: root.radius
                direction: PathArc.Counterclockwise
            }
        }
    }
}
