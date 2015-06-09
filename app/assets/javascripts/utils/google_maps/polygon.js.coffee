this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

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


G.Polygon = Polygon