{CompositeDisposable} = require 'atom'
{View} = require 'atom-space-pen-views'

module.exports =
class CliStatusView extends View
  @content: ->
    @div class: 'cli-status inline-block', =>
      @span outlet: 'termStatusContainer', =>
        @span click: 'newTermClick', outlet: 'termStatusAdd', class: "cli-status icon icon-plus"

  commandViews: []
  activeIndex: 0
  toolTipDisposable: null

  initialize: (serializeState) ->
    atom.commands.add 'atom-workspace',
      'terminal-panel:new': => @newTermClick()
      'terminal-panel:toggle': => @toggle()
      'terminal-panel:next': => @activeNextCommandView()
      'terminal-panel:prev': => @activePrevCommandView()
      'terminal-panel:destroy': => @destroyActiveTerm()
      'terminal-panel:activate': => @activateTerminal()

    atom.commands.add '.cli-status',
      'core:cancel': => @toggle()

    @attach()
    @toolTipDisposable?.dispose()
    @toolTipDisposable = atom.tooltips.add @termStatusAdd, title: "Add a terminal panel"


  activateTerminal: ->
    console.log "terminal activated"

  createCommandView: ->
    domify = require 'domify'
    CommandOutputView = require './command-output-view'
    termStatus = domify '<span class="cli-status icon icon-terminal"></span>'
    commandOutputView = new CommandOutputView
    commandOutputView.statusIcon = termStatus
    commandOutputView.statusView = this
    @commandViews.push commandOutputView # push the new command output view in to an array of them.
    termStatus.addEventListener 'click', -> # clicking on the icon should toggle the terminal
      commandOutputView.toggle()
    @termStatusContainer.append termStatus
    return commandOutputView

  activeNextCommandView: -> # gets the next open terminal from the array of them
    @activeCommandView @activeIndex + 1

  activePrevCommandView: -> # gets the previous open terminal from the array of them
    @activeCommandView @activeIndex - 1

  activeCommandView: (index) -> # switches between terminals
    if index >= @commandViews.length
      index = 0
    if index < 0
      index = @commandViews.length - 1
    @commandViews[index] and @commandViews[index].open()

  setActiveCommandView: (commandView) ->
    @activeIndex = @commandViews.indexOf commandView

  removeCommandView: (commandView) -> # remove from array
    index = @commandViews.indexOf commandView
    index >=0 and @commandViews.splice index, 1

  newTermClick: -> # create new command view and toggle it so it open
    commandView = @createCommandView()
    commandView.toggle()
    return commandView

  attach: ->
    document.querySelector("status-bar").addLeftTile(item: this, priority: 100)

  destroyActiveTerm: -> # destroy the terminal by calling the method that removes it from the array
     @commandViews[@activeIndex]?.destroy()

    # Tear down any state and detach
  destroy: ->
    for index in [@commandViews.length .. 0]
      @removeCommandView @commandViews[index]
    @detach()

  toggle: -> # if exists then just show else create one
    @createCommandView() unless @commandViews[@activeIndex]?
    @commandViews[@activeIndex].toggle()
