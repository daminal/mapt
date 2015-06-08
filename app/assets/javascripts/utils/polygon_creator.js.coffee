class PolygonCreator
  map: null,
  pen: null,
  event: null,

  constructor: (map) ->
    @map = map;
    @pen = new Pen(@map)

    thisPen = @pen
    @event = google.maps.event.addListener @map, 'click', (event) ->
      thisPen.draw(event.latLng)

  showData: ->
    @pen.getData()

  destroy: ->
    @pen.deleteMis()
    @pen.polygon.remove() if @pen.polygon?
    google.maps.event.removeListener(@event)

this.Mapt.Utils.PolygonCreator = PolygonCreator

class Pen
  map: null,
  listOfDots: null,
  polyline: null,
  polygon: null,
  currentDot: null,

  constructor: (map) ->
    @map = map
    @listOfDots = new Array

  draw: (latLng) ->
    if @polygon?
      alert('Click Reset to draw another')
    else
      if @currentDot? and @listOfDots.length > 1 and @currentDot == @listOfDots[0]
        @drawPolygon(this.listOfDots)
      else
        if @polyline?
          @polyline.remove()
        dot = new Dot(latLng, @map, this)
        @listOfDots.push(dot)
        if @listOfDots.length > 1
          @polyline = new Line(@listOfDots, @map)

  drawPolygon: (listOfDots, color, des, id) ->
    @polygon = new Polygon(listOfDots, @map, this, color, des, id)
    @deleteMis()
  deleteMis: ->
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
    @deleteMis()
  setCurrentDot: (dot) ->
    @currentDot = dot
  getListOfDots: ->
    @listOfDots
  getData: ->
    if @polygon?
      data = ''
      paths = @polygon.getPlots()
      paths.getAt(0).forEach (value, index) ->
        data += value.toString()
      return data
    else
      return null
  getColor: ->
    if @polygon?
      color = @polygon.getColor()
    else
      return null

class Dot
  latLng: null,
  parent: null,
  markerObj: null,

  constructor: (latLng, map, pen) ->
    @latLng = latLng
    @parent = pen
    @markerObj = new google.maps.Marker
      position: @latLng
      map: map
    @addListener()

  addListener: ->
    parent = @parent
    thisMarket = @markerObj
    thisDot = this

    google.maps.event.addListener thisMarket, 'click', ->
      parent.setCurrentDot thisDot
      parent.draw thisMarket.getPosition()

  getLatLng: ->
    return @latLng

  getMarketObj: ->
    return @markerObj

  remove: ->
    @markerObj.setMap(null)

class Line
  listOfDots: null,
  map: null,
  coords: null,
  polylineObj: null

  constructor: (listOfDots, map) ->
    @listOfDots = listOfDots
    @map = map
    @coords = new Array

    if @listOfDots.length > 1
      thisObj = this
      $.each @listOfDots, (index, value) ->
        thisObj.coords.push value.getLatLng()
      @polylineObj = new google.maps.Polyline
        path: @coords
        strokeColor: '#FF0000'
        strokeOpacity: 1.0
        strokeWeight: 2
        map: @map

  remove: ->
    @polylineObj.setMap(null)

class Polygon
  listOfDots: null,
  map: null,
  coords: null,
  parent: null,
  polygonObj: null,
  des: 'Hello',
  info: null,

  constructor: (listOfDots, map, pen, color) ->
    @listOfDots = listOfDots
    @map = map
    @parent = pen
    @coords = new Array

    thisObj = this

    $.each @listOfDots, (index, value) ->
      thisObj.coords.push value.getLatLng()

    @polygonObj = new google.maps.Polygon
      paths: @coords
      strokeColor: '#FF0000'
      strokeOpacity: 0.8
      strokeWeight: 2
      fillColor: '#FF0000'
      fillOpacity: 0.35
      map: @map

    @info = new Info(this, @map)

    @addListener()

  addListener: ->
    info = @info
    thisPolygon = @polygonObj
    google.maps.event.addListener thisPolygon, 'rightclick', (event) ->
      info.show event.latLng

  remove: ->
    @info.remove()
    @polygonObj.setMap(null)

  getContent: ->
    @des

  getPolygonObj: ->
    @polygonObj

  getListOfDots: ->
    @listOfDots

  getPlots: ->
    @polygonObj.getPaths()

  getColor: ->
    @getPolygonObj().fillColor

  setColor: (color) ->
    @getPolygonObj().setOptions
      fillColor: color
      strokeColor: color
      strokeWeight: 2


class Info
  parent: null,
  map: null,
  color: null,
  button: null,
  infoWidObj: null,

  constructor: (polygon, map) ->
    @parent = polygon
    @map = map
    @color = document.createElement('input')
    @button = document.createElement('input')

    $(@button).attr('type', 'button')
    $(@button).val('Change Color');

    thisObj = this
    @infoWidObj = new google.maps.InfoWindow
      content: thisObj.getContent()


  changeColor: ->
    @parent.setColor($(@color).val());

  getContent: ->
    thisObj = this
    content = document.createElement('div')

    $(@color).val(@parent.getColor())

    $(@button).click ->
      thisObj.changeColor()

    $(content).append(@color)
    $(content).append(@button)

    return content

  show: (latLng) ->
    @infoWidObj.setPosition(latLng)
    @infoWidObj.open(@map)

  remove: ->
    @infoWidObj.close()
