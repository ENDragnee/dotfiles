import Quickshell
import Quickshell.Io // for Process
import QtQuick

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 30

    Text {
        // give the text an ID we can refer to elsewhere in the file
        id: clock

        anchors.centerIn: parent

        // create a process management object
        Process {
            id: dateProc
            // the command it will run, every argument is its own string
            command: ["date"]

            // run the command immediately
            running: true

            stdout: StdioCollector {
                // Listen for the streamFinished signal, which is sent
                // when the process closes stdout or exits.
                onStreamFinished: clock.text = this.text // `this` can be omitted
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: dateProc.running = true
    }
}
