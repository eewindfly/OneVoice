#!/usr/bin/env python3
"""
OneVoice GUI - Floating window for real-time transcription display
Creates a semi-transparent, always-on-top floating window for macOS
"""

import tkinter as tk
from tkinter import scrolledtext, font
import sys
import threading
import queue
import time
from datetime import datetime
import json
import os
import re

class ANSIParser:
    """Simple ANSI escape sequence cleaner for terminal output"""
    
    def __init__(self):
        # Pattern to match all ANSI escape sequences
        self.ansi_pattern = re.compile(r'\x1b\[[0-9;]*[a-zA-Z]')
    
    def strip_ansi(self, text):
        """Remove all ANSI escape codes from text"""
        return self.ansi_pattern.sub('', text)

class OneVoiceGUI:
    def __init__(self):
        self.running = True  # Initialize running first
        self.root = tk.Tk()
        self.ansi_parser = ANSIParser()  # Initialize ANSI parser
        self.setup_window()
        self.setup_widgets()
        self.setup_input_queue()
        
        # Bind window close event
        self.root.protocol("WM_DELETE_WINDOW", self.on_closing)
        
    def setup_window(self):
        """Configure the floating window properties"""
        self.root.title("OneVoice - Live Transcription")
        
        # Set window size and position
        window_width = 500
        window_height = 300
        
        # Get screen dimensions
        screen_width = self.root.winfo_screenwidth()
        screen_height = self.root.winfo_screenheight()
        
        # Position window at top-right corner
        x = screen_width - window_width - 50
        y = 50
        
        self.root.geometry(f"{window_width}x{window_height}+{x}+{y}")
        
        # Make window always on top and semi-transparent
        self.root.wm_attributes("-topmost", True)
        self.root.wm_attributes("-alpha", 0.9)
        
        # Make window resizable
        self.root.resizable(True, True)
        
        # Set minimum size
        self.root.minsize(300, 200)
        
    def setup_widgets(self):
        """Create and arrange GUI widgets"""
        # Create main frame
        main_frame = tk.Frame(self.root, bg='#2b2b2b')
        main_frame.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        # Title label
        title_label = tk.Label(
            main_frame, 
            text="🎤 OneVoice Live Transcription",
            font=('SF Pro Display', 14, 'bold'),
            fg='#ffffff',
            bg='#2b2b2b'
        )
        title_label.pack(pady=(0, 10))
        
        # Status label
        self.status_label = tk.Label(
            main_frame,
            text="🟡 Waiting for audio...",
            font=('SF Pro Display', 10),
            fg='#ffcc00',
            bg='#2b2b2b'
        )
        self.status_label.pack(pady=(0, 5))
        
        # Scrolled text widget for transcription
        self.text_area = scrolledtext.ScrolledText(
            main_frame,
            wrap=tk.WORD,
            font=('SF Pro Display', 12),
            bg='#1e1e1e',
            fg='#ffffff',
            insertbackground='#ffffff',
            selectbackground='#404040',
            relief=tk.FLAT,
            padx=10,
            pady=10
        )
        self.text_area.pack(fill=tk.BOTH, expand=True, pady=(0, 10))
        
        # Control frame
        control_frame = tk.Frame(main_frame, bg='#2b2b2b')
        control_frame.pack(fill=tk.X)
        
        # Clear button
        clear_btn = tk.Button(
            control_frame,
            text="🗑️ Clear",
            command=self.clear_text,
            font=('SF Pro Display', 10),
            bg='#404040',
            fg='#ffffff',
            relief=tk.FLAT,
            padx=10,
            pady=5,
            cursor='hand2'
        )
        clear_btn.pack(side=tk.LEFT, padx=(0, 10))
        
        # Toggle always on top button
        self.topmost_btn = tk.Button(
            control_frame,
            text="📌 Always On Top",
            command=self.toggle_topmost,
            font=('SF Pro Display', 10),
            bg='#007AFF',
            fg='#ffffff',
            relief=tk.FLAT,
            padx=10,
            pady=5,
            cursor='hand2'
        )
        self.topmost_btn.pack(side=tk.LEFT, padx=(0, 10))
        
        # Transparency control
        transparency_frame = tk.Frame(control_frame, bg='#2b2b2b')
        transparency_frame.pack(side=tk.RIGHT)
        
        tk.Label(
            transparency_frame,
            text="Opacity:",
            font=('SF Pro Display', 9),
            fg='#cccccc',
            bg='#2b2b2b'
        ).pack(side=tk.LEFT)
        
        self.transparency_var = tk.DoubleVar(value=0.9)
        transparency_scale = tk.Scale(
            transparency_frame,
            from_=0.3,
            to=1.0,
            resolution=0.1,
            orient=tk.HORIZONTAL,
            variable=self.transparency_var,
            command=self.update_transparency,
            bg='#2b2b2b',
            fg='#ffffff',
            highlightthickness=0,
            length=100
        )
        transparency_scale.pack(side=tk.LEFT, padx=(5, 0))
        
    def setup_input_queue(self):
        """Setup queue for receiving transcription data"""
        self.input_queue = queue.Queue()
        self.check_queue()
        
    def check_queue(self):
        """Check for new transcription data and update display"""
        try:
            while True:
                text = self.input_queue.get_nowait()
                self.add_transcription(text)
        except queue.Empty:
            pass
        
        if self.running:
            self.root.after(100, self.check_queue)
    
    def add_transcription(self, text):
        """Add new transcription text to the display with ANSI cleaning"""
        if not text.strip():
            return
            
        # Update status to show active transcription
        self.status_label.config(text="🟢 Transcribing...", fg='#00ff00')
        
        # Add timestamp
        timestamp = datetime.now().strftime("%H:%M:%S")
        
        # Strip ANSI codes and insert clean text
        clean_text = self.ansi_parser.strip_ansi(text.strip())
        self.text_area.insert(tk.END, f"[{timestamp}] {clean_text}\n\n")
        
        # Auto-scroll to bottom
        self.text_area.see(tk.END)
        
        # Limit text length to prevent memory issues
        current_text = self.text_area.get("1.0", tk.END)
        lines = current_text.split('\n')
        if len(lines) > 100:  # Keep only last 100 lines
            self.text_area.delete("1.0", f"{len(lines)-100}.0")
    
    def clear_text(self):
        """Clear all transcription text"""
        self.text_area.delete("1.0", tk.END)
        self.status_label.config(text="🟡 Waiting for audio...", fg='#ffcc00')
    
    def toggle_topmost(self):
        """Toggle always on top setting"""
        current_topmost = self.root.wm_attributes("-topmost")
        new_topmost = not current_topmost
        self.root.wm_attributes("-topmost", new_topmost)
        
        if new_topmost:
            self.topmost_btn.config(text="📌 Always On Top", bg='#007AFF')
        else:
            self.topmost_btn.config(text="📌 Normal Window", bg='#404040')
    
    def update_transparency(self, value):
        """Update window transparency"""
        self.root.wm_attributes("-alpha", float(value))
    
    def on_closing(self):
        """Handle window close event"""
        self.running = False
        self.root.quit()
        self.root.destroy()
    
    def run(self):
        """Start the GUI event loop"""
        # Start input thread to read from stdin
        input_thread = threading.Thread(target=self.read_input, daemon=True)
        input_thread.start()
        
        try:
            self.root.mainloop()
        except KeyboardInterrupt:
            self.on_closing()
    
    def read_input(self):
        """Read transcription data from stdin and add to queue"""
        try:
            for line in sys.stdin:
                if self.running:
                    line = line.strip()
                    if line:
                        self.input_queue.put(line)
                else:
                    break
        except EOFError:
            pass
        except Exception as e:
            print(f"Error reading input: {e}", file=sys.stderr)

def main():
    """Main entry point"""
    try:
        app = OneVoiceGUI()
        app.run()
    except KeyboardInterrupt:
        print("\nShutting down OneVoice GUI...")
    except Exception as e:
        print(f"Error starting OneVoice GUI: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
