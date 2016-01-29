Are you looking for a way to pass commands to the terminal via code? Do you want to run long processes with the ability to
kill or destroy them? Do you want to ensure your code can create a command line/terminal in all operating systems? Do you want
to use the terminal and enter commands while in atom?

If so, then this package is for you. Even if you do not need the API, you can use the GUI.

terminal-panel-uoa
==============

 A terminal interface and status icon. Fork of terminal-panel.

 Added API that allows any package to make a terminal, pass it a command
 and see the output (all via code).

 Works for Windows,Linux and OSX. No Dependencies.

###### Please do not hesitate to send any queries on github or at ades597@aucklanduni.ac.nz

#### NOTE : You must go the this package and "activate terminal panel" when atom is started. If you do not then you will receive a error when you call it from your package.

## Example

I have used this package for research at University of Auckland (hence the uoa at the end of the name).

Download the "sysj" package in atom or go to https://github.com/arrayoutofbounds/sysj to see an example of a package using the API.

As you can see, I have a running process. At the bottom you can see the blue icon that shows the currently open terminal which
you can toggle or destroy.


![A screenshot of your package](http://i.imgur.com/NMCKks0.png)


## How to use the API

The package.json supplies the services provided. Consume the service (after reading the services API atom documentation).
Then use the service and be able to add a terminal from your package programatically.

The service gives a Cli-status-view object. That has the methods to create new terminals, toggle between them etc
Each Cli-status-view object has a command-output-view object that actually runs the processes and displays the output.
The code has been commented, so please read it before using it.  


##### Consuming the service in package.json:

```json
"consumedServices": {
  "terminal-panel-uoa": {
    "versions": {
      "^1.2.3": "consumeCommandOutputView"
    }
  }
}
```

##### In your main file for the package you are building, add the following method:

```coffee
consumeCommandOutputView: (commandOutputView) ->
  @commandOutputView = commandOutputView # assigns a instance variable
  console.log "API consumed" # lets you know you have used the API
  console.log @commandOutputView # prints the command output view object in the log
  console.log "New terminal created" # lets you know a new terminal has been created
```

##### Then you can use the command output view to make a new terminal by adding the following method to your code:

```coffee
createTerminal: ->
  terminal = @commandOutputView.newTermClick() #create new terminal
  terminal
```

##### Example of using the method shown above

Spawning the terminal will create a new terminal with the command you pass into it. Please beware of the path
being different in the OS. Use path.sep to ensure it works on windows and linux/MacOSX.

The GUI will be created and the result of the command will be shown.

```coffee
terminal = @createTerminal()
terminal.spawn(jdkPath + " -classpath " + pathToJar + @pathToClass + " com.systemj.SystemJRunner " + filePath,"java",["-classpath", "" + pathToJar + @pathToClass , 'com.systemj.SystemJRunner',"" + filePath])
```


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
