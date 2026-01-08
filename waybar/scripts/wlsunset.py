import sys
import os
from PyQt5.QtWidgets import QApplication, QSystemTrayIcon, QMenu, QAction, QInputDialog, QMessageBox
from PyQt5.QtGui import QIcon
from PyQt5.QtCore import QProcess, QTimer
from datetime import datetime, time, timedelta


class WLSunsetTrayApp:
    def __init__(self):
        self.app = QApplication(sys.argv)

        self.icons = {
            "day": os.path.expanduser("~/.config/waybar/scripts/day-mode.svg"),
            "night": os.path.expanduser("~/.config/waybar/scripts/night-mode-light.svg")
        }

        self.tray_icon = QSystemTrayIcon(QIcon(self.icons["day"]), self.app)

        self.timer = QTimer()
        self.timer.timeout.connect(self.update_icon_and_timer)

        # --- Location and Temperature ---
        self.latitude = "9.0192"
        self.longitude = "38.7525"
        self.temperature = "4500"

        # --- Menu Setup ---
        self.menu = QMenu()
        self.change_location_action = QAction("Change Location (Lat/Lon)")
        self.change_temperature_action = QAction("Change Temperature")
        self.exit_action = QAction("Exit")

        self.change_location_action.triggered.connect(self.change_location)
        self.change_temperature_action.triggered.connect(self.change_temperature)
        self.exit_action.triggered.connect(self.exit_app)

        self.menu.addAction(self.change_location_action)
        self.menu.addAction(self.change_temperature_action)
        self.menu.addSeparator()
        self.menu.addAction(self.exit_action)
        self.tray_icon.setContextMenu(self.menu)

        # Show the tray icon
        self.tray_icon.show()

        # Start wlsunset process
        self.process = None
        self.start_wlsunset()
        
        # Perform the initial setup for the icon and start the first timer
        self.update_icon_and_timer()

    def update_icon_and_timer(self):
        now = datetime.now()

        sunrise_time = time(6, 0)
        sunset_time = time(18, 0)

        today_sunrise = datetime.combine(now.date(), sunrise_time)
        today_sunset = datetime.combine(now.date(), sunset_time)

        if today_sunrise <= now < today_sunset:
            self.tray_icon.setIcon(QIcon(self.icons["day"]))
            self.tray_icon.setToolTip(f"Day Mode. Next change at {sunset_time.strftime('%H:%M')}")
            next_transition = today_sunset
        else:
            self.tray_icon.setIcon(QIcon(self.icons["night"]))

            if now < today_sunrise:
                self.tray_icon.setToolTip(f"Night Mode. Next change at {sunrise_time.strftime('%H:%M')}")
                next_transition = today_sunrise
            else:
                tomorrow_sunrise = today_sunrise + timedelta(days=1)
                self.tray_icon.setToolTip(f"Night Mode. Next change at {sunrise_time.strftime('%H:%M')} tomorrow")
                next_transition = tomorrow_sunrise

        time_difference = next_transition - now

        delay_ms = int(time_difference.total_seconds() * 1000) + 1000 

        self.timer.start(delay_ms)

    def start_wlsunset(self):
        if self.process is not None and self.process.state() == QProcess.Running:
            self.process.terminate()
            self.process.waitForFinished(3000)

        self.process = QProcess(self.app)
        command = f"wlsunset -l {self.latitude} -L {self.longitude} -t {self.temperature}"
        self.process.start(command)

    def change_location(self):
        lat, ok_lat = QInputDialog.getText(None, "Change Latitude", "Enter Latitude:", text=self.latitude)
        if ok_lat and lat:
            lon, ok_lon = QInputDialog.getText(None, "Change Longitude", "Enter Longitude:", text=self.longitude)
            if ok_lon and lon:
                self.latitude = lat
                self.longitude = lon
                self.start_wlsunset()

    def change_temperature(self):
        temp, ok_temp = QInputDialog.getText(None, "Change Temperature", "Enter Temperature (Kelvin):", text=self.temperature)
        if ok_temp and temp:
            self.temperature = temp
            self.start_wlsunset()

    def exit_app(self):
        self.timer.stop()
        if self.process is not None and self.process.state() == QProcess.Running:
            self.process.terminate()
            self.process.waitForFinished(3000)

        self.tray_icon.hide()
        self.app.quit()

    def run(self):
        sys.exit(self.app.exec_())


if __name__ == "__main__":
    app = WLSunsetTrayApp()
    app.run()
