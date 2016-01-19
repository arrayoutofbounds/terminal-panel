CliStatusView = require './cli-status-view'

module.exports =
  cliStatusView: null
  state: null

  activate: (state) ->
    @state = state
    console.log "Activating Terminal "
    atom.packages.onDidActivateInitialPackages =>
      CliStatusView = require './cli-status-view'
      createStatusEntry = =>
        console.log "Creating Status Entry"
        @cliStatusView = new CliStatusView(state.cliStatusViewState)
      createStatusEntry()


  deactivate: ->
    @cliStatusView.destroy()

  provideCommandOutputView: -> # send the command output view so it can make a new terminal etc.
    console.log "API will be returned"
    if @cliStatusView == null
      console.log "cliStatusView is null so creating again"
      @cliStatusView = new CliStatusView(@state.cliStatusViewState)
      @cliStatusView
    else
      @cliStatusView


  config:
    'windowHeight':
      type: 'integer'
      default: 30
      minimum: 0
      maximum: 80
    'clearCommandInput':
      type: 'boolean'
      default: true
    'logConsole':
      type: 'boolean'
      default: false
    'overrideLs':
      title: 'Override ls'
      type: 'boolean'
      default: true
    'shell':
      type: 'string'
      default: if process.platform is 'win32'
          process.env.SystemRoot, 'System32', 'WindowsPowerShell', 'v1.0', 'powershell.exe'
        else
          process.env.SHELL ? '/bin/bash'
