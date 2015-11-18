#!/usr/bin/env python

# Requires python-mpd2, python-pillow, tk
from tkinter import Tk, Frame, Label
from PIL import ImageTk, Image
from threading import Thread
import mpd, sys
import glob, re

# Required variables
MUSICDIR = "/home/shn/music/"
PATTERN = "folder.*"
PATTERN = "cover.*"
DEFAULTIMG = "/home/shn/.icons/default.png"
BGCOLOR = "#1c1e21"

# Frame class that draws an image and zooms it to the window size
class ImageFrame(Frame):
  def __init__(self, master, imgPath, *pargs):
    Frame.__init__(self, master, *pargs)

    self.img = Image.open(imgPath)
    self.origImg = self.img.copy()

    self.bgImg = ImageTk.PhotoImage(self.img)

    self.bg = Label(self, image=self.bgImg, background=BGCOLOR)
    self.bg.pack(fill="both", expand="yes")
    self.bg.bind('<Configure>', self._resize_image)

  def _resize_image(self, event):
    s = min(event.width, event.height)
    self.img = self.origImg.resize((s, s), Image.ANTIALIAS)
    self.bgImg = ImageTk.PhotoImage(self.img)
    self.bg.configure(image=self.bgImg)

  def change_image(self, imgPath):
    self.img = Image.open(imgPath)
    self.origImg = self.img.copy()
    self.bg.event_generate('<Configure>', width=self.winfo_width(), height=self.winfo_height())


# Connect with mpd server
try:
  client = mpd.MPDClient()
  client.connect("localhost", 6600)
except(mpd.ConnectionError):
  print("Could not connect to MPD. Exiting.")
  sys.exit(1)

# Function to look for albumart according to PATTERN in MUSICDIR/<song's directory>/
def get_albumart(song):
  albumArt = DEFAULTIMG
  if(song != "STOPPED"):
    aaDir = re.sub(r"[^/]*$", "", song["file"])
    for albumArt in glob.glob(glob.escape(MUSICDIR + aaDir) + PATTERN):
      break
  return(albumArt)

# The window
root = Tk()
root.title("album art")
imgFrame = ImageFrame(root, get_albumart(client.currentsong()))
imgFrame.pack(fill="both", expand="yes")

# Function that monitors mpd for changes and if so, makes the ImageFrame redraw
def poll():
  currentSong = client.currentsong()
  while True:
    client.idle("player")
    previousSong = currentSong
    currentSong = client.currentsong()
    if(client.status()["state"] == "stop"):
      currentSong = "STOPPED"
    if(previousSong != currentSong):
      imgFrame.change_image(get_albumart(currentSong))

# Start shit up
Thread(target=poll, daemon=True).start()
root.mainloop()
