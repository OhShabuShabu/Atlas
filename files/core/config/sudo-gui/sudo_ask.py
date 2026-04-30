#!/usr/bin/env python3
import sys
import os
import json
from pathlib import Path

from PyQt6.QtWidgets import (
    QApplication, QDialog, QVBoxLayout, QHBoxLayout,
    QLabel, QPushButton, QComboBox, QFrame
)
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QFont

CACHE_FILE = Path.home() / ".local/share/sudo-gui/yes_to_all.json"


def load_yes_to_all_cache():
    try:
        CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
        if CACHE_FILE.exists():
            with open(CACHE_FILE, 'r') as f:
                return json.load(f)
    except Exception:
        pass
    return {}


def save_yes_to_all_cache(cache):
    try:
        CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(CACHE_FILE, 'w') as f:
            json.dump(cache, f)
    except Exception:
        pass


def is_process_running(pid):
    try:
        os.kill(pid, 0)
        return True
    except OSError:
        return False


def cleanup_dead_processes(cache):
    dead = [pid for pid in cache if not is_process_running(int(pid))]
    for pid in dead:
        del cache[pid]
    return cache


class SudoGUIDialog(QDialog):
    def __init__(self, cmd, parent_pid, executable, parent=None):
        super().__init__(parent)
        self.cmd = cmd
        self.parent_pid = parent_pid
        self.executable = executable
        self.yes_to_all = False

        self.yes_to_all_cache = cleanup_dead_processes(load_yes_to_all_cache())

        if str(parent_pid) in self.yes_to_all_cache:
            print("YES")
            self.accept()
            return

        self.setup_ui()
        self.setModal(True)
        self.show()
        self.raise_()
        self.activateWindow()

    def setup_ui(self):
        self.setWindowTitle("sudo access requested")
        self.setMinimumWidth(500)
        self.setStyleSheet("""
            QDialog {
                background-color: #1e1e1e;
            }
            QLabel {
                color: #ffffff;
            }
            QPushButton {
                background-color: #3a3a3a;
                color: #ffffff;
                border: none;
                padding: 10px 20px;
                border-radius: 6px;
                font-weight: bold;
            }
            QPushButton:hover {
                background-color: #4a4a4a;
            }
            QPushButton#yesButton {
                background-color: #2d5a2d;
            }
            QPushButton#yesButton:hover {
                background-color: #3d7a3d;
            }
            QPushButton#noButton {
                background-color: #5a2d2d;
            }
            QPushButton#noButton:hover {
                background-color: #7a3d3d;
            }
            QComboBox {
                background-color: #3a3a3a;
                color: #ffffff;
                border: none;
                padding: 8px;
                border-radius: 6px;
            }
            QComboBox::drop-down {
                border: none;
            }
            QComboBox::down-arrow {
                image: none;
                border-left: 5px solid transparent;
                border-right: 5px solid transparent;
                border-top: 5px solid #ffffff;
                margin-right: 10px;
            }
        """)

        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(24, 24, 24, 24)
        main_layout.setSpacing(16)

        header = QLabel("sudo access requested")
        header_font = QFont()
        header_font.setPointSize(14)
        header_font.setBold(True)
        header.setFont(header_font)
        main_layout.addWidget(header)

        separator = QFrame()
        separator.setFrameShape(QFrame.Shape.HLine)
        separator.setStyleSheet("background-color: #3a3a3a;")
        separator.setFixedHeight(1)
        main_layout.addWidget(separator)

        icon_label = QLabel("⚠️")
        icon_label.setStyleSheet("font-size: 32px;")
        icon_label.setAlignment(Qt.AlignmentFlag.AlignCenter)

        cmd_label = QLabel(self.cmd)
        cmd_label.setTextInteractionFlags(Qt.TextInteractionFlag.TextSelectableByMouse)
        cmd_label.setWordWrap(True)
        cmd_label.setStyleSheet("""
            background-color: #2a2a2a;
            padding: 12px;
            border-radius: 6px;
            font-family: monospace;
            font-size: 13px;
        """)

        main_layout.addWidget(icon_label)
        main_layout.addWidget(cmd_label)

        main_layout.addStretch()

        button_layout = QHBoxLayout()
        button_layout.setSpacing(8)

        self.yes_combo = QComboBox()
        self.yes_combo.setFixedWidth(50)
        self.yes_combo.addItems(["✓", "▼"])
        self.yes_combo.setCurrentIndex(0)
        self.yes_combo.currentIndexChanged.connect(self.on_combo_changed)

        self.yes_button = QPushButton("Yes")
        self.yes_button.setObjectName("yesButton")
        self.yes_button.setFixedWidth(100)
        self.yes_button.clicked.connect(self.on_yes)

        self.no_button = QPushButton("No")
        self.no_button.setObjectName("noButton")
        self.no_button.setFixedWidth(100)
        self.no_button.clicked.connect(self.on_no)
        self.no_button.setDefault(True)

        button_layout.addStretch()
        button_layout.addWidget(self.yes_combo)
        button_layout.addWidget(self.yes_button)
        button_layout.addWidget(self.no_button)

        main_layout.addLayout(button_layout)
        self.setLayout(main_layout)

    def on_combo_changed(self, index):
        if index == 1:
            self.yes_to_all = True
            self.yes_combo.setCurrentIndex(0)
            self.on_yes()

    def on_yes(self):
        if self.yes_to_all:
            self.yes_to_all_cache[str(self.parent_pid)] = True
            save_yes_to_all_cache(self.yes_to_all_cache)
        print("YES")
        self.accept()

    def on_no(self):
        print("NO")
        self.reject()


def main():
    if len(sys.argv) < 3:
        sys.exit(1)

    cmd = sys.argv[1]
    parent_pid = sys.argv[2]
    executable = sys.argv[3] if len(sys.argv) > 3 else ""

    app = QApplication(sys.argv)
    app.setStyle("Fusion")

    dialog = SudoGUIDialog(cmd, parent_pid, executable)

    sys.exit(0 if dialog.exec() == QDialog.DialogCode.Accepted else 1)


if __name__ == "__main__":
    main()