import QtQuick
import QtQuick.Shapes
import ".."

// Coin inversé : raccorde le bord haut de l'écran au flanc de l'island par un
// arc concave. Le remplissage occupe le carré moins le quart de disque.
Item {
    id: root

    property real radius: Theme.cornerRadius
    property color fillColor: Theme.crust
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
            // Arc centré sur (0, radius) : concave vers l'island
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
