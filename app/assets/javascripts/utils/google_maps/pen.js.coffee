Utils = this.Mapt.Utils
this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Pen
  callbackContext: null,
  callbacks: null,
  map: null,
  listOfDots: null,
  polyline: null,
  currentDot: null,
  events: null,
  isDrawing: false,
  color: null,

  constructor: (map, options={}) ->
    @map = map
    @callbackContext = options['callbackContext'] || @
    @color = options['color'] || '#000'
    @listOfDots = new Array

    @callbacks =
      start_draw:  options['onStartDraw']
      finish_draw: options['onFinishDraw']
      cancel_draw: options['onCancelDraw']
      dot_added:   options['onDotAdded']

    @addListeners()

  addListeners: ->
    @events = new Array()
    _this = @

    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      _this.draw(event.latLng)
    @events.push google.maps.event.addDomListener window, 'keyup', (event) ->
      code = if event.keyCode then event.keyCode else event.which
      switch code
        when 27
          _this.trigger 'cancel_draw'

  draw: (latLng) ->
    @isDrawing = true
    if @currentDot? and @listOfDots.length > 1 and @currentDot.latLng == @listOfDots[0].latLng
      @trigger 'finish_draw', @
      @clear()
      @isDrawing = false
    else
      if @polyline?
        @polyline.remove()

      dot = new G.Dot latLng, @map,
        callbackContext: @
        onDotClicked: @dotClicked
      @listOfDots.push(dot)

      if @listOfDots.length == 1
        @trigger 'start_draw', @

      if @listOfDots.length > 1
        _this = this
        @polyline = new G.Line @listOfDots, @map, @color
        @trigger 'dot_added', dot


  dotClicked: (dot) ->
    @setCurrentDot dot
    @draw dot.getMarkerObj().getPosition()

  clear: ->
    $.each @listOfDots, (index, value) ->
      value.remove()
    @listOfDots.length = 0
    if @polyline?
      @polyline.remove()
      @polyline = null

  remove: ->
    @clear()
    @removeListeners()

  removeListeners: ->
    for event in @events
      google.maps.event.removeListener(event)

    @events = new Array()

  setCurrentDot: (dot) ->
    @currentDot = dot

  getListOfDots: ->
    @listOfDots

  trigger: () ->
    return if (arguments.length == 0)

    args = []
    Array.prototype.push.apply(args, arguments)

    event_name = args.shift()
    if @callbacks[event_name]?
      return @callbacks[event_name].apply(@callbackContext, args)
    else
      return true

  on: (event_name, callback) ->
    @callbacks[event_name] = callback

G.Pen = Pen