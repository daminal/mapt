this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

#### TODO
# Accept polygons in constructor
# setPolygons(polygons)
# addPolygon(polygon)
# addPolygons(polygons)


class PolygonManager
  map: null,
  polygons: null,
  pen: null,
  events: null,
  onStartDraw: null,
  onFinishDraw: null,
  onCancelDraw: null,
  onPolygonChanged: null,
  onPolygonClicked: null,
  onPolygonSelected: null,
  onPolygonDesected: null,
  onDeselectAll: null,

  constructor: (map, options={}) ->
    throw "You must pass a google map object as the first argument" unless map?

    @map = map;
    @polygons = new Array
    @events = new Array
    @onStartDraw = options['onStartDraw']
    @onFinishDraw = options['onFinishDraw']
    @onCancelDraw = options['onCancelDraw']
    @onPolygonChanged = options['onPolygonChanged']
    @onPolygonClicked = options['onPolygonClicked']
    @onPolygonSelected = options['onPolygonSelected']
    @onPolygonDeselected = options['onPolygonDeselected']
    @onDeselectAll = options['onDeselectAll']

    # Add google maps event listeners
    _this = @
    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      unless _this.pen?
        _this.deselectAll()

  startDraw: ->
    @deselectAll()
    @pen = new G.Pen(@map, @)
    @map.setOptions({draggableCursor:'pointer'});

    @onStartDraw(@pen) if @onStartDraw?

  cancelDraw: ->
    if @pen?
      @pen.cancel()
      @pen = null
    @_resetCursor()
    @onCancelDraw() if @onCancelDraw?

  deselectAll: (runCallback=true) ->
    for polygon in @polygons
      polygon.deselect()
    @onDeselectAll() if @onDeselectAll? and runCallback

  destroy: ->
    for polygon in @polygons
      polygon.remove() if polygon?

    for event in @events
      google.maps.event.removeListener event

    @_resetCursor()

  _mapClicked: (event) ->
    @pen.draw event.latLng if @pen?

  _polygonCreated: (polygon) ->
    @pen = null
    @polygons.push polygon
    @_resetCursor()
    @onFinishDraw polygon if @onFinishDraw?

  _resetCursor: () ->
    @map.setOptions({draggableCursor:'url(http://maps.gstatic.com/mapfiles/openhand_8_8.cur) 8 8, default '});


G.PolygonManager = PolygonManager
