this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

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
      _this = this
      $.each @listOfDots, (index, value) ->
        _this.coords.push value.getLatLng()
      @polylineObj = new google.maps.Polyline
        path: @coords
        strokeColor: '#FF0000'
        strokeOpacity: 1.0
        strokeWeight: 2
        map: @map

  remove: ->
    @polylineObj.setMap(null)

G.Line = Line