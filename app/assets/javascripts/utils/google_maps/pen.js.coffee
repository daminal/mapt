Utils = this.Mapt.Utils
this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Pen
  map: null,
  listOfDots: null,
  polyline: null,
  polygon: null,
  currentDot: null,
  parent: null,
  onCompletePolygon: null,

  constructor: (map, manager, onCompletePolygon) ->
    @map = map
    @parent = manager
    @onCompletePolygon = onCompletePolygon
    @listOfDots = new Array

  draw: (latLng) ->
    unless @polygon?
      if @currentDot? and @listOfDots.length > 1 and @currentDot == @listOfDots[0]
        @drawPolygon(this.listOfDots)
        @onCompletePolygon(@getData(), @polygon, @parent) if @onCompletePolygon?
      else
        if @polyline?
          @polyline.remove()
        dot = new G.Dot(latLng, @map, this)
        @listOfDots.push(dot)
        if @listOfDots.length > 1
          @polyline = new G.Line(@listOfDots, @map)

  drawPolygon: (listOfDots, color, des, id) ->
    @polygon = new G.Polygon(listOfDots, @map, this, color, des, id)
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
  setCurrentDot: (dot) ->
    @currentDot = dot
  getListOfDots: ->
    @listOfDots
  getData: ->
    if @polygon?
      data = []
      paths = @polygon.getPlots()
      paths.getAt(0).forEach (value, index) ->
        data.push({lat: value.A, lng: value.F})
      return data
    else
      return null
  getDataAsString: ->
    dataStr = ''
    data = @getData()
    if data?
      data.forEach (value, index) ->
        dataStr += "," unless dataStr.length==0
        dataStr += "(lat: #{value['lat']}, lng: #{value['lng']})"
      return data
    else
      return null
  getColor: ->
    if @polygon?
      color = @polygon.getColor()
    else
      return null

G.Pen = Pen