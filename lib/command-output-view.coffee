{TextEditorView, View} = require 'atom-space-pen-views'
{spawn, exec} = require 'child_process'
ansihtml = require 'ansi-html-stream'
readline = require 'readline'
{addClass, removeClass} = require 'domutil'
{resolve, dirname, extname} = require 'path'
fs = require 'fs'

lastOpenedView = null

module.exports =
class CommandOutputView extends View
  cwd: null
  @content: ->
    @div tabIndex: -1, class: 'panel cli-status panel-bottom', =>
      @div class: 'cli-panel-body', =>
        @pre class: "terminal", outlet: "cliOutput"
      @div class: 'cli-panel-input', =>
        @subview 'cmdEditor', new TextEditorView(mini: true, placeholderText: 'input your command here')
        @div class: 'btn-group', =>
          @button outlet: 'killBtn', click: 'kill', class: 'btn hide', 'kill' # calls the kill method in this class
          @button click: 'destroy', class: 'btn', 'destroy' # calls the destroy method in this class
          @span class: 'icon icon-x', click: 'close' # calls the close method

  initialize: ->
    @userHome = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE # set the home of the user in case folder is not there
    cmd = 'test -e /etc/profile && source /etc/profile;test -e ~/.profile && source ~/.profile; node -pe "JSON.stringify(process.env)"'
    shell = atom.config.get 'terminal-panel.shell' # this is the default value in the config in the main file
    exec cmd, {shell}, (code, stdout, stderr) -> # start a shell process
      try
        process.env = JSON.parse(stdout)
      catch e
    atom.commands.add 'atom-workspace',
      "cli-status:toggle-output": => @toggle()

    atom.commands.add @cmdEditor.element, # in the text box where input is written add commands
      'core:confirm': => # when enter is pressed in the box text editor
        inputCmd = @cmdEditor.getModel().getText() # get the text that was typed
        @cliOutput.append "\n$>#{inputCmd}\n" # append the text typed to the output of the cli which is above input box
        @scrollToBottom() #scroll to the bottom so it always shows the latest info
        args = [] # arguments to the command put in an array
        # support 'a b c' and "foo bar"
        inputCmd.replace /("[^"]*"|'[^']*'|[^\s'"]+)/g, (s) => #replace any escape characters etc with "s"s
          if s[0] != '"' and s[0] != "'"
            s = s.replace /~/g, @userHome # if nothing is there then replace it with the home
          args.push s # push into the array
        cmd = args.shift() # this removes the first arg in the list
        console.log "input command is " + inputCmd
        console.log "cmd is " + cmd
        console.log "args is " + args
        if cmd == 'cd' # call custom cd command
          return @cd args
        if cmd == 'ls' and atom.config.get('terminal-panel.overrideLs') # call custom ls command
          return @ls args
        if cmd == 'clear' # call clear and empty the cli output div and make input box empty by setting it to empty string
          @cliOutput.empty()
          @message '\n'
          return @cmdEditor.setText ''
        @spawn inputCmd, cmd, args

  showCmd: ->
    @cmdEditor.show() #show the input box
    @cmdEditor.css('visibility', '')
    @cmdEditor.getModel().selectAll()
    @cmdEditor.setText('') if atom.config.get('terminal-panel.clearCommandInput') # if cleared input then clear it
    @cmdEditor.focus() # focus on input so user can type in it
    @scrollToBottom() # scroll to bottom of cli so latest results can be seen

  scrollToBottom: -> # scrolls cli to the bottom so latest values can be seen
    @cliOutput.scrollTop 10000000

  flashIconClass: (className, time=100)=>
    addClass @statusIcon, className
    @timer and clearTimeout(@timer)
    onStatusOut = =>
      removeClass @statusIcon, className
    @timer = setTimeout onStatusOut, time

  destroy: -> #destroy the terminal
    _destroy = =>
      if @hasParent()
        @close()
      if @statusIcon and @statusIcon.parentNode
        @statusIcon.parentNode.removeChild(@statusIcon)
      @statusView.removeCommandView this
    if @program # this is the program created by the spawn process at the bottom
      @program.once 'exit', _destroy
      @program.kill()
    else
      _destroy()

  kill: -> # if the process that is running is there then kill it
    if @program
      @program.kill() # calls kill on the variable that holds exec process from the nodejs api

  open: -> # open called when toggled
    @lastLocation = atom.workspace.getActivePane()
    @panel = atom.workspace.addBottomPanel(item: this) unless @hasParent()
    if lastOpenedView and lastOpenedView != this
      lastOpenedView.close()
    lastOpenedView = this
    @scrollToBottom()
    @statusView.setActiveCommandView this
    @cmdEditor.focus()
    @cliOutput.css('font-family', atom.config.get('editor.fontFamily'))
    @cliOutput.css('font-size', atom.config.get('editor.fontSize') + 'px')
    @cliOutput.css('max-height', atom.config.get('terminal-panel.windowHeight') + 'vh')

  close: ->
    @lastLocation.activate()
    @detach()
    @panel.destroy()
    lastOpenedView = null

  toggle: -> # if the terminal has a parent then close else open it
    if @hasParent()
      @close()
    else
      @open()

  cd: (args)-> # custom cd commmand
    args = [atom.project.path] if not args[0]
    dir = resolve @getCwd(), args[0] # get current working dir
    fs.stat dir, (err, stat) =>
      if err
        if err.code == 'ENOENT'
          return @errorMessage "cd: #{args[0]}: No such file or directory"
        return @errorMessage err.message
      if not stat.isDirectory()
        return @errorMessage "cd: not a directory: #{args[0]}"
      @cwd = dir
      @message "cwd: #{@cwd}"

  ls: (args) -> # custom ls command
    files = fs.readdirSync @getCwd() # read the current working directory sync
    filesBlocks = []
    files.forEach (filename) =>
      filesBlocks.push @_fileInfoHtml(filename, @getCwd())
    filesBlocks = filesBlocks.sort (a, b) ->
      aDir = a[1].isDirectory()
      bDir = b[1].isDirectory()
      if aDir and not bDir
        return -1
      if not aDir and bDir
        return 1
      a[2] > b[2] and 1 or -1
    filesBlocks = filesBlocks.map (b) ->
      b[0]
    @message filesBlocks.join('') + '<div class="clear"/>'

  _fileInfoHtml: (filename, parent) -> #custom file info called by custom ls
    classes = ['icon', 'file-info']
    filepath = parent + '/' + filename
    stat = fs.lstatSync filepath
    if stat.isSymbolicLink()
      classes.push 'stat-link'
      stat = fs.statSync filepath
    if stat.isFile()
      if stat.mode & 73 #0111
        classes.push 'stat-program'
      # TODO check extension
      classes.push 'icon-file-text'
    if stat.isDirectory()
      classes.push 'icon-file-directory'
    if stat.isCharacterDevice()
      classes.push 'stat-char-dev'
    if stat.isFIFO()
      classes.push 'stat-fifo'
    if stat.isSocket()
      classes.push 'stat-sock'
    if filename[0] == '.'
      classes.push 'status-ignored'
    ["<span class=\"#{classes.join ' '}\">#{filename}</span>", stat, filename]

  getGitStatusName: (path, gitRoot, repo) ->
    status = (repo.getCachedPathStatus or repo.getPathStatus)(path)
    if status
      if repo.isStatusModified status
        return 'modified'
      if repo.isStatusNew status
        return 'added'
    if repo.isPathIgnore path
      return 'ignored'

  message: (message) -> # append message to cli output
    @cliOutput.append message
    @showCmd() # show the command
    removeClass @statusIcon, 'status-error' # this makes the bottom icon red
    addClass @statusIcon, 'status-success' # this makes the bottom icon for terminal a green

  errorMessage: (message) -> # opposite of the message method
    @cliOutput.append message
    @showCmd()
    removeClass @statusIcon, 'status-success'
    addClass @statusIcon, 'status-error'

  getCwd: -> # get the current working directory
    extFile = extname atom.project.getPaths()[0]

    if extFile == ""
      if atom.project.getPaths()[0]
        projectDir = atom.project.getPaths()[0]
      else
        if process.env.HOME
          projectDir = process.env.HOME
        else if process.env.USERPROFILE
          projectDir = process.env.USERPROFILE
        else
          projectDir = '/'
    else
      projectDir = dirname atom.project.getPaths()[0]

    @cwd or projectDir or @userHome # returns this as one of them have to be true

  spawn: (inputCmd, cmd, args) -> #spawn a command
    @cmdEditor.css('visibility', 'hidden')
    htmlStream = ansihtml()
    htmlStream.on 'data', (data) =>
      @cliOutput.append data # append the data to the cli
      @scrollToBottom() # scroll to the bottom
    shell = atom.config.get 'terminal-panel.shell' # get the default shell from the main file default
    try
      @program = exec inputCmd, stdio: 'pipe', env: process.env, cwd: @getCwd(), shell: shell # call exec on the input cmd and set the current working directory and shell
      @program.stdout.pipe htmlStream
      @program.stderr.pipe htmlStream
      removeClass @statusIcon, 'status-success'
      removeClass @statusIcon, 'status-error'
      addClass @statusIcon, 'status-running' # icon at the bottom shows runnning
      @killBtn.removeClass 'hide' # show the kill button now that the process is running
      @program.once 'exit', (code) => # if process stops then make kill button disappear and log the exit number
        console.log 'exit', code if atom.config.get('terminal-panel.logConsole')
        @killBtn.addClass 'hide'
        removeClass @statusIcon, 'status-running' # change icon
        @program = null # current running process becomes null
        addClass @statusIcon, code == 0 and 'status-success' or 'status-error'
        @showCmd() # this shows the command prompt or cli above input with the output
      @program.on 'error', (err) => # same as above
        console.log 'error' if atom.config.get('terminal-panel.logConsole')
        @cliOutput.append err.message
        @showCmd()
        addClass @statusIcon, 'status-error'
      @program.stdout.on 'data', => # same as above except for when the process is running
        @flashIconClass 'status-info'
        removeClass @statusIcon, 'status-error'
      @program.stderr.on 'data', => # if there is a std error
        console.log 'stderr' if atom.config.get('terminal-panel.logConsole')
        @flashIconClass 'status-error', 300

    catch err
      @cliOutput.append err.message
      @showCmd()
