CliStatusView = require './cli-status-view'

module.exports =
  cliStatusView: null

  activate: (state) ->
    console.log "state is " + state
    atom.packages.onDidActivateInitialPackages =>
      createStatusEntry = =>
        @cliStatusView = new CliStatusView(state.cliStatusViewState)
      createStatusEntry()

  deactivate: ->
    @cliStatusView.destroy()

  provideCommandOutputView: -> # send the command output view so it can make a new terminal etc.
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
          'cmd.exe'
        else
          process.env.SHELL ? '/bin/bash'
