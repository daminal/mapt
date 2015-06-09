this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Polygon
  listOfDots: null,
  map: null,
  coords: null,
  manager: null,
  polygonObj: null,
  des: 'Hello',
  info: null,
  events: null,
  isDragging: false,

  constructor: (listOfDots, map, manager, color) ->
    @listOfDots = listOfDots
    @map = map
    @manager = manager
    @coords = new Array
    @events = new Array

    _this = this

    $.each @listOfDots, (index, value) ->
      _this.coords.push value.getLatLng()

    @polygonObj = new google.maps.Polygon
      draggable: true
      editable: true
      paths: @coords
      strokeColor: '#FF0000'
      strokeOpacity: 0.8
      strokeWeight: 2
      fillColor: '#FF0000'
      fillOpacity: 0.35
      map: @map

    path = @polygonObj.getPath()
    @events.push google.maps.event.addListener path, 'insert_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'insert') if _this.manager.onPolygonChanged?
    @events.push google.maps.event.addListener path, 'set_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'move') if _this.manager.onPolygonChanged?
    @events.push google.maps.event.addListener path, 'remove_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'remove') if _this.manager.onPolygonChanged?
    @events.push google.maps.event.addListener @polygonObj, 'dragstart', (event) ->
      _this.isDragging = true
      _this.manager.onPolygonChanged(_this, 'remove') if _this.manager.onPolygonChanged?
    @events.push google.maps.event.addListener @polygonObj, 'dragend', (event) ->
      _this.isDragging = false
      _this.manager.onPolygonChanged(_this, 'drag') if _this.manager.onPolygonChanged?

    @info = new G.Info(this, @map)

    @addListener()

  addListener: ->
    info = @info
    thisPolygon = @polygonObj
    google.maps.event.addListener thisPolygon, 'rightclick', (event) ->
      info.show event.latLng

  remove: ->
    @info.remove()
    @polygonObj.setMap(null)
    for event in @events
      google.maps.event.removeListener event

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

  getData: ->
    data = []
    paths = @getPlots()
    paths.getAt(0).forEach (value, index) ->
      data.push({lat: value.A, lng: value.F})
    return data

G.Polygon = Polygon