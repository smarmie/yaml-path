{CompositeDisposable} = require 'atom'
YamlPathView = require './yaml-path-view'

module.exports = YamlPath =
  config:
    activateOnStart:
      type: 'string'
      default: 'Remember last setting'
      enum: ['Remember last setting', 'Show on start', 'Don\'t show on start']

  active: false

  activate: (state) ->
    console.log 'Yaml-path was activated'

    @state = state

    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'yaml-path:toggle': => @toggle()

    @yamlPathView = new YamlPathView()
    @yamlPathView.init()

  deactivate: ->
    console.log 'Yaml-path was deactivated'
    @subscriptions.dispose()
    @yamlPathView.destroy()
    @statusBarTile?.destroy()

  serialize:->
    {
      activateOnStart: atom.config.get('yaml-path.activateOnStart'),
      active: @active
    }

  toggle: (active = undefined) ->
    active = ! !!@active if !active?

    if active
      console.log 'Yaml-path was activated'
      @yamlPathView.activate()
      @statusBarTile = @statusBar.addLeftTile
        item: @yamlPathView, priority: -1
    else
      console.log 'Yaml-path was deactivated'
      @statusBarTile?.destroy()
      @yamlPathView?.deactivate()

    @active = active

  consumeStatusBar: (statusBar) ->
    @statusBar = statusBar
    # auto activate as soon as status bar activates based on configuration
    @activateOnStart(@state)

  consumeLinter: (linter) ->
    @linter = linter

  activateOnStart: (state) ->
    switch state.activateOnStart
      when 'Remember last setting' then @toggle state.active
      when 'Show on start' then @toggle true
      else @toggle false
