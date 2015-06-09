Utils = this.Mapt.Utils
this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Pen
  map: null,
  listOfDots: null,
  polyline: null,
  polygon: null,
  currentDot: null,
  manager: null,
  events: null,
  isDrawing: false

  constructor: (map, manager) ->
    @map = map
    @manager = manager
    @listOfDots = new Array

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
          _this.manager.cancelDraw()

  draw: (latLng) ->
    unless @polygon?
      @isDrawing = true
      if @currentDot? and @listOfDots.length > 1 and @currentDot.latLng == @listOfDots[0].latLng
        @drawPolygon(this.listOfDots, true)
        @isDrawing = false
        @manager._polygonCreated(@polygon)
      else
        if @polyline?
          @polyline.remove()
        dot = new G.Dot(latLng, @map, this)
        @listOfDots.push(dot)
        if @listOfDots.length > 1
          _this = this
          @polyline = new G.Line @listOfDots, @map

  drawPolygon: (listOfDots, editable, color) ->
    _this = this
    @polygon = new G.Polygon listOfDots, @map, @manager, editable, color
    @clear()

  clear: ->
    $.each @listOfDots, (index, value) ->
      value.remove()
    @listOfDots.length = 0
    if @polyline?
      @polyline.remove()
      @polyline = null

  cancel: ->
    if @polygon?
      @polygon.remove()
    @polygon = null

    @clear()

    for event in @events
      google.maps.event.removeListener(event)

  setCurrentDot: (dot) ->
    @currentDot = dot

  getListOfDots: ->
    @listOfDots

  getColor: ->
    if @polygon?
      color = @polygon.getColor()
    else
      return null

G.Pen = Pen