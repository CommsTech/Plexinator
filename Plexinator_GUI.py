import os
import subprocess
import tkinter as tk
from tkinter import filedialog, messagebox

class PlexinatorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Plexinator GUI")

        self.output_dir_var = tk.StringVar()
        self.handbrake_cli_var = tk.StringVar()
        self.ffmpeg_var = tk.StringVar()
        self.ffprobe_var = tk.StringVar()
        self.filebot_var = tk.StringVar()

        self.create_widgets()

    def create_widgets(self):
        tk.Label(self.root, text="Plexinator GUI", font=("Helvetica", 16)).pack(pady=10)

        tk.Label(self.root, text="Video Output Directory:").pack()
        tk.Entry(self.root, textvariable=self.output_dir_var).pack()

        tk.Label(self.root, text="HandBrakeCLI Location:").pack()
        tk.Entry(self.root, textvariable=self.handbrake_cli_var).pack()

        tk.Label(self.root, text="FFmpeg Location:").pack()
        tk.Entry(self.root, textvariable=self.ffmpeg_var).pack()

        tk.Label(self.root, text="FFprobe Location:").pack()
        tk.Entry(self.root, textvariable=self.ffprobe_var).pack()

        tk.Label(self.root, text="FileBot Location:").pack()
        tk.Entry(self.root, textvariable=self.filebot_var).pack()

        tk.Button(self.root, text="Browse", command=self.browse_output_dir).pack()

        tk.Button(self.root, text="Run Plexinator", command=self.run_plexinator).pack(pady=10)

    def browse_output_dir(self):
        selected_dir = filedialog.askdirectory()
        self.output_dir_var.set(selected_dir)

    def run_plexinator(self):
        output_dir = self.output_dir_var.get()
        handbrake_cli = self.handbrake_cli_var.get()
        ffmpeg = self.ffmpeg_var.get()
        ffprobe = self.ffprobe_var.get()
        filebot = self.filebot_var.get()

        script_path = os.path.join(os.path.dirname(__file__), "Plexinator_GUI.bat")
        command = ["cmd", "/c", script_path]

        if output_dir:
            command.append(output_dir)
        if handbrake_cli:
            command.append(handbrake_cli)
        if ffmpeg:
            command.append(ffmpeg)
        if ffprobe:
            command.append(ffprobe)
        if filebot:
            command.append(filebot)

        subprocess.run(command)

if __name__ == "__main__":
    root = tk.Tk()
    app = PlexinatorGUI(root)
    root.mainloop()
