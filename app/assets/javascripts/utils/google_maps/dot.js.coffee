this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

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
    thisPen = @parent
    thisMarker = @markerObj
    thisDot = this

    google.maps.event.addListener thisMarker, 'click', ->
      thisPen.setCurrentDot thisDot
      thisPen.draw thisMarker.getPosition()

  getLatLng: ->
    return @latLng

  getMarketObj: ->
    return @markerObj

  remove: ->
    @markerObj.setMap(null)

G.Dot = Dot