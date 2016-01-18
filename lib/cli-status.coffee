CliStatusView = require './cli-status-view'

module.exports =
  cliStatusView: null

  activate: (state) ->
    console.log "Activating terminal panel"
    console.log state
    @cliStatusView = new CliStatusView(state.cliStatusViewState)
    #atom.packages.onDidActivateInitialPackages =>
    #  @cliStatusView = new CliStatusView(state.cliStatusViewState)
    #  @cliStatusView


  deactivate: ->
    @cliStatusView.destroy()

  provideCommandOutputView: -> # send the command output view so it can make a new terminal etc.
    console.log "API will be returned"
    console.log "status view is " + @cliStatusView
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
