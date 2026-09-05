import QtQuick
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root

    // CAVA aborts with "window is too narrow for number of bars set" above
    // this; enforced here too since this plugin runs its own CAVA instance.
    readonly property int cavaMaxBars: 512
    readonly property int barCount: Math.min(Math.max(2, root.configuration.BarCount), cavaMaxBars)
    readonly property int barGap: Math.max(0, root.configuration.BarGap)
    // Internal CAVA output resolution (ascii_max_range), independent of
    // screen size - bar height is scaled from this to BarMaxHeight below.
    readonly property int cavaValueRange: 1000
    readonly property int barWidth: Math.max(1, Math.floor((root.width - (barCount - 1) * barGap) / barCount))

    // 0=Solid, 1=Rainbow, 2=Adaptive
    readonly property int colorMode: root.configuration.ColorMode
    readonly property real barOpacity: root.configuration.BarOpacity
    readonly property real adaptiveBaseHue: backgroundSample.averageColor.hslHue

    function withOpacity(c) {
        return Qt.rgba(c.r, c.g, c.b, root.barOpacity);
    }

    function hueColor(hue) {
        const h = ((hue % 1) + 1) % 1;
        return Qt.hsla(h, 0.85, 0.6, root.barOpacity);
    }

    function gradientColor(index) {
        if (root.colorMode === 1) {
            // full spectrum across the row
            return hueColor(index / root.barCount);
        }
        // Adaptive: a gentle spread centered on the background's average hue
        const spread = 0.3;
        const t = root.barCount > 1 ? index / (root.barCount - 1) : 0;
        return hueColor(root.adaptiveBaseHue - spread / 2 + spread * t);
    }

    function colorForTop(index) {
        if (root.colorMode === 0) {
            return withOpacity(root.configuration.BarColorTop);
        }
        return gradientColor(index);
    }

    function colorForBottom(index) {
        if (root.colorMode === 0) {
            return withOpacity(root.configuration.BarColorBottom);
        }
        return gradientColor(index);
    }

    Rectangle {
        anchors.fill: parent
        color: "#101010"
        visible: background.status !== Image.Ready
    }

    Image {
        id: background
        anchors.fill: parent
        source: root.configuration.Image
        fillMode: root.configuration.FillMode
        asynchronous: true
        cache: true
        onStatusChanged: {
            if (status === Image.Ready) {
                backgroundSample.requestPaint();
            }
        }
    }

    // Off-screen sampling canvas used only for "Adaptive" color mode - reads
    // the loaded background image down to a few pixels and averages them to
    // get a base hue. Runs once per image load, not per frame.
    Canvas {
        id: backgroundSample
        x: -1000
        y: -1000
        width: 16
        height: 16
        property color averageColor: "#808080"
        onPaint: {
            if (background.status !== Image.Ready) {
                return;
            }
            const ctx = getContext("2d");
            ctx.drawImage(background, 0, 0, width, height);
            const data = ctx.getImageData(0, 0, width, height).data;
            let r = 0, g = 0, b = 0, n = 0;
            for (let i = 0; i < data.length; i += 4) {
                r += data[i];
                g += data[i + 1];
                b += data[i + 2];
                n++;
            }
            if (n > 0) {
                averageColor = Qt.rgba(r / n / 255, g / n / 255, b / n / 255, 1);
            }
        }
    }

    Cava {
        id: cava
        framerate: root.configuration.Framerate
        barCount: root.barCount
        asciiMaxRange: root.cavaValueRange
        noiseReduction: root.configuration.NoiseReduction
        monstercat: 0
        waves: 0
        autoSensitivity: root.configuration.AutoSensitivity
        sensitivityEnabled: false
        sensitivity: 100
        lowerCutoffFreq: 50
        higherCutoffFreq: 10000
        inputMethod: ""
        inputSource: ""
        sampleRate: 44100
        sampleBits: 16
        inputChannels: 2
        autoconnect: 2
        active: 0
        remix: 1
        virtual: 1
        outputChannels: "mono"
        monoOption: "average"
        reverse: 0
        eqEnabled: false
        eq: [1.0, 1.0, 1.0, 1.0, 1.0]
        idleCheck: false
        idleTimer: 5
        cavaSleepTimer: 5
    }

    BarRow {
        anchors.top: parent.top
        anchors.topMargin: root.configuration.BarTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        values: cava.values
        barCount: root.barCount
        barWidth: root.barWidth
        barGap: root.barGap
        barMaxHeight: root.configuration.BarMaxHeight
        maxValue: root.cavaValueRange
        colorForIndex: root.colorForTop
        alignBottom: false
    }

    BarRow {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.configuration.BarBottomMargin
        anchors.horizontalCenter: parent.horizontalCenter
        values: cava.values
        barCount: root.barCount
        barWidth: root.barWidth
        barGap: root.barGap
        barMaxHeight: root.configuration.BarMaxHeight
        maxValue: root.cavaValueRange
        colorForIndex: root.colorForBottom
        alignBottom: true
    }

    Connections {
        target: Qt.application
        function onAboutToQuit() {
            cava.stop();
        }
    }
}
