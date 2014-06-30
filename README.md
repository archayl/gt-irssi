gt-irssi
========

ZSH script to run irssi with nicklist fifo

INSTALL
=======

Put it anywhere you want. Create an alias to make your life easier.

    alias irc="TERM=gnome-256color $HOME/irc.sh"

like so.

USAGE
=====

Type

    irc

and press Enter. Chat away.

You can use ALT+PG_DOWN and ALT+PG_UP to scroll the nick list.
The nick list height is specified in the $NL_H variable in the script.
I'm using the standand 80x24 terminal, so I put in 24. It's up to you
how much you wanted to. The scroll amount per keypress is in the
keybind settings. Change it to your taste.

It's a very simple script. You might as well tune it up yourself to
suit your needs.
