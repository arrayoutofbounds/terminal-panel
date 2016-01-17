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
    console.log "clit-status-view initialize"

    atom.commands.add 'atom-workspace',
      'terminal-panel:new': => @newTermClick()
      'terminal-panel:toggle': => @toggle()
      'terminal-panel:next': => @activeNextCommandView()
      'terminal-panel:prev': => @activePrevCommandView()
      'terminal-panel:destroy': => @destroyActiveTerm()

    atom.commands.add '.cli-status',
      'core:cancel': => @toggle()

    @attach()
    @toolTipDisposable?.dispose()
    @toolTipDisposable = atom.tooltips.add @termStatusAdd, title: "Add a terminal panel"



  createCommandView: ->
    console.log "clit-status-view createCommandView"
    domify = require 'domify'
    CommandOutputView = require './command-output-view'
    termStatus = domify '<span class="cli-status icon icon-terminal"></span>'
    commandOutputView = new CommandOutputView
    commandOutputView.statusIcon = termStatus
    commandOutputView.statusView = this
    @commandViews.push commandOutputView
    termStatus.addEventListener 'click', ->
      commandOutputView.toggle()
    @termStatusContainer.append termStatus
    return commandOutputView

  activeNextCommandView: ->
    console.log "clit-status-view activeNextCommandView"
    @activeCommandView @activeIndex + 1

  activePrevCommandView: ->
    console.log "clit-status-view activePrevCommandView"
    @activeCommandView @activeIndex - 1

  activeCommandView: (index) ->
    console.log "clit-status-view activeCommandView"
    if index >= @commandViews.length
      index = 0
    if index < 0
      index = @commandViews.length - 1
    @commandViews[index] and @commandViews[index].open()

  setActiveCommandView: (commandView) ->
    console.log "clit-status-view setActiveCommandView"
    @activeIndex = @commandViews.indexOf commandView

  removeCommandView: (commandView) ->
    console.log "clit-status-view removeCommandView"
    index = @commandViews.indexOf commandView
    index >=0 and @commandViews.splice index, 1

  newTermClick: ->
    console.log "clit-status-view newTermClick"
    @createCommandView().toggle()

  attach: ->
    console.log "clit-status-view attach"
    document.querySelector("status-bar").addLeftTile(item: this, priority: 100)

  destroyActiveTerm: ->
    console.log "clit-status-view destroyActiveTerm"
     @commandViews[@activeIndex]?.destroy()

  # Tear down any state and detach
  destroy: ->
    console.log "clit-status-view destroy"
    for index in [@commandViews.length .. 0]
      @removeCommandView @commandViews[index]
    @detach()

  toggle: ->
    console.log "clit-status-view toggle"
    @createCommandView() unless @commandViews[@activeIndex]?
    @commandViews[@activeIndex].toggle()
