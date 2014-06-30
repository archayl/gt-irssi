#!/bin/zsh

# Start IRSSI with Niclist Fifo
# Author: Mohamad Elrashidin Bin Sajeli
# E-mail: archayl@gmail.com
# License: MIT
# Date: 29 June 2014
#
# This is the script to start IRSSI with nicklist FIFO
# 
# Things to note:
# --------------
#
# - I made this script to run on my own Ubuntu 14.04
# - I use irssi and bitlbee from apt-get
# - Im using zsh as my shell
# - I build this without much research,
#   this script can be improved a whole lot more
#   to be efficient and wider compatibility
#
# Required software
# -----------------
#
# - xprop
# - xwinfo
# - grep
# - awk
# - sed
# - cut
# - sleep
# - gnome-terminal
# - irssi

# Get the active window ID
WIN_ID=$(xprop -root | awk '/_NET_ACTIVE_WINDOW\(WINDOW\)/{print $NF}')

# Get raw X window properties (xwinfo)
RAW=$(xwininfo -id $WIN_ID)

# Get raw X window properties (xprop) - for windows decoration
RAW_XPROP=$(xprop -id  $WIN_ID)

# Get current window ID (this is X windows ID)
XDO_WIN_ID=$(xdotool getactivewindow)

# Extract windows information
# Coordinate in pixels, north west origin
UPPER_X=$(echo $RAW | grep -i 'absolute upper-left X')
UPPER_Y=$(echo $RAW | grep -i 'absolute upper-left Y')

# Window width in pixels
WIDTH=$(echo $RAW | grep -i '  width')

# Window geometry in pixels
GEOMETRY=$(echo $RAW | grep -i 'geometry')

# Extract current window info and calculate child origin coordinate
PARENT_X=$(echo $UPPER_X | cut -d: -f2 | sed 's/^[ \t]*//;s/[ \t]*$//') # X origin
PARENT_Y=$(echo $UPPER_Y | cut -d: -f2 | sed 's/^[ \t]*//;s/[ \t]*$//') # Y origin
SHIFTX=$(echo $WIDTH | cut -d: -f2 | sed 's/^[ \t]*//;s/[ \t]*$//') # how much pixel to shift on X
TITLE_BAR=$(echo $RAW_XPROP | awk '/_NET_FRAME_EXTENTS\(CARDINAL\)/{print $0}' | awk 'BEGIN{FS=","}{print $3}' | sed 's/^[ \t]*//;s/[ \t]*$//') # consider window decoration by Window Manager
HEIGHT=$(echo $GEOMETRY | awk 'BEGIN{FS="[\t x+-]+"}{print $4}' | sed 's/^[ \t]*//;s/[ \t]*$//') # current window heigh in pixels

# This is the parameter to create the new child window
NL_X=$(echo $PARENT_X+$SHIFTX | awk 'BEGIN{FS="+"}{print $1+$2}')
NL_Y=$(echo $PARENT_Y+$TITLE_BAR | awk 'BEGIN{FS="+"}{print $1-$2}')
NL_W=24 # this is entered by hand! might as well be automated, sufficient for me
NL_H=$HEIGHT

# Create child window
gnome-terminal --geometry=$NL_W\x$NL_H+$NL_X+$NL_Y -t "Nick List" -e "cat .irssi/nicklistfifo" --working-directory=$HOME & # also loads nicklist file

# Write startup items to irssi startup file
echo "/SCRIPT load nicklist" > $HOME/.irssi/startup
echo "/NICKLIST fifo" >> $HOME/.irssi/startup
echo "/SET nicklist_width=$NL_W" >> $HOME/.irssi/startup
echo "/SET nicklist_height=$NL_H" >> $HOME/.irssi/startup
echo "/BIND ^[[5\;3~ command nicklist scroll -$NL_H" >> $HOME/.irssi/startup
echo "/BIND ^[[6\;3~ command nicklist scroll +$NL_H" >> $HOME/.irssi/startup

# Wait for startup file fully written
sleep 2 # might be any value that you think suitable

# Change the irssi window title
echo -en "\033]0;IRSSI\a"

# ... and activate it, set focus
xdotool search --name "IRSSI" windowactivate

# Run irssi!
irssi

exit 0

# When you quit IRSSI, the child window will automatically close
# Somebody might explain that. I don't know.
