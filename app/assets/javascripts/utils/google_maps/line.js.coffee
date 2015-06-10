this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Line
  listOfDots: null,
  map: null,
  coords: null,
  polylineObj: null,
  color: null,

  constructor: (listOfDots, map, color) ->
    @listOfDots = listOfDots
    @map = map
    @color = color
    @coords = new Array

    if @listOfDots.length > 1
      _this = this
      $.each @listOfDots, (index, value) ->
        _this.coords.push value.getLatLng()
      @polylineObj = new google.maps.Polyline
        path: @coords
        strokeColor: @color
        strokeOpacity: 1.0
        strokeWeight: 2
        map: @map

  setColor: (color) ->
    @color = color
    @polylineObj.setOptions
      strokeColor: @color

  remove: ->
    @polylineObj.setMap(null)

G.Line = Line