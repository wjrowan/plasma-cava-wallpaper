import QtQuick

// One row of solid bars, driven by a shared CAVA values array. Rendered with
// plain Rectangles (GPU-batched by the scenegraph) rather than a Canvas, so
// there's no per-frame software rasterization.
Item {
    id: root

    required property list<int> values
    required property int barCount
    required property int barWidth
    required property int barGap
    required property int barMaxHeight
    required property int maxValue
    // function(index: int): color - lets the caller do solid/rainbow/adaptive
    // coloring without this component knowing about color modes.
    required property var colorForIndex
    property bool alignBottom: false

    implicitWidth: barCount * barWidth + Math.max(0, barCount - 1) * barGap
    implicitHeight: barMaxHeight

    Repeater {
        model: root.barCount
        delegate: Rectangle {
            id: bar
            required property int index
            readonly property int barHeight: Math.max(1, Math.round(((root.values[index] ?? 0) / root.maxValue) * root.barMaxHeight))
            x: index * (root.barWidth + root.barGap)
            y: root.alignBottom ? (root.height - barHeight) : 0
            width: root.barWidth
            height: barHeight
            color: root.colorForIndex(index)
        }
    }
}
