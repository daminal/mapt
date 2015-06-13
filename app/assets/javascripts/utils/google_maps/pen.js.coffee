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

    @_addListeners()

  draw: (latLng) ->
    @isDrawing = true
    if @currentDot? and @listOfDots.length > 1 and @currentDot.latLng == @listOfDots[0].latLng
      @_trigger 'finish_draw', @
      @clear()
      @isDrawing = false
    else
      if @polyline?
        @polyline.remove()

      dot = new G.Dot latLng, @map,
        callbackContext: @
        onDotClicked: @_dotClicked
      @listOfDots.push(dot)

      if @listOfDots.length == 1
        @_trigger 'start_draw', @

      if @listOfDots.length > 1
        _this = this
        @polyline = new G.Line @listOfDots, @map, @color
      @_trigger 'dot_added', dot


  getListOfDots: ->
    @listOfDots

  clear: ->
    $.each @listOfDots, (index, value) ->
      value.remove()
    @listOfDots.length = 0
    if @polyline?
      @polyline.remove()
      @polyline = null

  remove: ->
    @clear()
    @_removeListeners()

    @events = new Array()

  on: (event_name, callback) ->
    @callbacks[event_name] = callback


  _setCurrentDot: (dot) ->
    @currentDot = dot

  _dotClicked: (dot) ->
    @_setCurrentDot dot
    @draw dot.getMarkerObj().getPosition()

  _trigger: () ->
    return if (arguments.length == 0)

    args = []
    Array.prototype.push.apply(args, arguments)

    event_name = args.shift()
    if @callbacks[event_name]?
      return @callbacks[event_name].apply(@callbackContext, args)
    else
      return true

  _addListeners: ->
    @events = new Array()
    _this = @

    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      _this.draw(event.latLng)
    @events.push google.maps.event.addDomListener window, 'keyup', (event) ->
      code = if event.keyCode then event.keyCode else event.which
      switch code
        when 27
          _this._trigger 'cancel_draw'


  _removeListeners: ->
    for event in @events
      google.maps.event.removeListener(event)

G.Pen = Pen