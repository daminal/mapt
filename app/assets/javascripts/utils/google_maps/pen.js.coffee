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
  isDrawing: false,
  color: null,
  polygonColor: null,

  constructor: (map, manager, color='#000', polygonColor='#f00') ->
    @map = map
    @manager = manager
    @color = color
    @polygonColor = polygonColor
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
        @manager.onPolygonSelected(@polygon) if @manager.onPolygonSelected?
        @isDrawing = false
      else
        if @polyline?
          @polyline.remove()
        dot = new G.Dot(latLng, @map, this)
        @listOfDots.push(dot)
        if @listOfDots.length > 1
          _this = this
          @polyline = new G.Line @listOfDots, @map, @color

  drawPolygon: (listOfDots, editable) ->
    _this = this
    @polygon = new G.Polygon listOfDots, @manager, @map, editable, @polygonColor
    @manager._polygonCreated(@polygon)
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


G.Pen = Pen