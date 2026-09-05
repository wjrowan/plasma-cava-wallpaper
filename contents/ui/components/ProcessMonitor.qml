// SPDX-License-Identifier: GPL-3.0
//
// Derived from ProcessMonitorFallback.qml in luisbocanegra/kurve (GPL-3.0):
// https://github.com/luisbocanegra/kurve
// Adapted to drop the Plasmoid.configuration-based logger, which isn't
// available inside a Wallpaper's QML context.

import QtQuick
import QtWebSockets

// Runs a long-lived command and streams its stdout back over a local
// WebSocket, via tools/commandMonitor (Python). Ported from kurve's
// ProcessMonitorFallback.qml: there's no compiled native Qt process module
// available on this system, so kurve already runs through this same path.
// The Plasmoid.configuration-based debug logger was dropped since Plasmoid
// isn't available inside a Wallpaper's QML context.
Item {
    id: root

    property string command: ""
    property string stdout: ""
    property string stderr: ""
    property bool running: stdout !== ""
    property string pid: ""
    property bool pendingRestart: false

    // Cava.qml reads these; kept as constants since this component only
    // implements the WebSocket-relay path.
    readonly property bool usingFallback: true
    readonly property bool loadingFailed: false
    readonly property list<string> loadingErrors: []

    readonly property string toolsDir: Qt.resolvedUrl("../tools").toString().substring(7) + "/"
    readonly property string commandMonitorTool: "'" + toolsDir + "commandMonitor'"
    readonly property string monitorCommand: `${commandMonitorTool} ${server.url} "${command}"`

    RunCommand {
        id: runCommand
        onExited: (cmd, exitCode, exitStatus, stdout, stderr) => {
            if (exitCode !== 0) {
                console.error("cavawallpaper ProcessMonitor:", cmd, "exitCode:", exitCode, "stderr:", stderr);
                root.stderr = stderr;
            }
            root.stdout = "";
            root.pid = "";
        }
    }

    WebSocketServer {
        id: server
        listen: true
        onClientConnected: webSocket => {
            webSocket.onTextMessageReceived.connect(function (message) {
                if (!message) {
                    return;
                }
                if (message.includes("ERROR:")) {
                    root.stderr = message;
                    root.stdout = "";
                    root.pid = "";
                    return;
                }
                if (message.includes("PID:")) {
                    root.pid = message.trim().split(" ")[1];
                    root.stderr = "";
                    root.pendingRestart = false;
                    return;
                }
                root.stdout = message.trim().replace(/"/g, "");
            });
        }
    }

    Timer {
        id: startDelay
        interval: 100
        onTriggered: runCommand.run(root.monitorCommand)
    }

    function start() {
        pendingRestart = true;
        startDelay.restart();
    }

    function stop() {
        if (pid) {
            runCommand.run(`kill -TERM ${pid}`);
        }
    }

    function restart() {
        if (pendingRestart) {
            return;
        }
        stop();
        start();
    }

    onCommandChanged: {
        if (command === "") {
            return;
        }
        restart();
    }
}
