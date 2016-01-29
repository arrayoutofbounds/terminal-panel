terminal-panel-uoa
==============

 A terminal interface and status icon. Fork of terminal-panel. Added API that allows any package to make a terminal in all OS.

## How to use the API
---

The package.json supplies the services provided. Consume the service (after reading the services API atom documentation).
Then use the service and be able to add a terminal from your package programatically.

The service gives a Cli-status-view object. That has the methods to create new terminals, toggle between them etc

Each Cli-status-view object has a command-output-view object that actually runs the processes and displays the output.

The code has been commented, so please read it before using it.  

## What you can do with the terminal GUI

Terminal-panel executes your commands and displays the output. This means you can do all sorts of useful stuff right inside Atom, like:
* run build scripts
* start servers
* npm/apm (install, publish, etc)
* grunt
* etc. etc.

Some things it can't do (yet):
* The "terminal" isn't interactive so it can't do tab-autocomplete
* Or ask for a commit message
* ... stuff like that.

## Usage
Just press ``ctrl-` ``.

## Screenshot

![A screenshot of terminal-status package](https://raw.githubusercontent.com/thedaniel/terminal-panel/master/terminal-demo.gif)

## Feature

* multiple terminals
* status icon
* kill long running processes
* optional fancy ls

## Extra info

Processes are killed via the node js api. You can check via "tasklist" for windows or "top/htop" for unix/linux/OSX.
When the process running is killed the pid of the process ceases to exist.

## Hotkeys

* ``ctrl-` `` toggle current terminal
* `command-shift-t` new terminal
* `command-shift-j` next terminal
* `command-shift-k` prev terminal
* `command-shift-x` destroy terminal
* `up` and `down` for "command history"

---
A fork of [guileen/terminal-status](https://github.com/guileen/terminal-status).
