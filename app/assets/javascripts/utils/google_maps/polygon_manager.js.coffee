this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

#### TODO
# removePolygon(polygon)

class PolygonManager
  map: null,
  pen: null,
  polygons: null,
  selectedPolygon: null,
  events: null,
  onStartDraw: null,
  onFinishDraw: null,
  onCancelDraw: null,
  onPolygonChanged: null,
  onPolygonClicked: null,
  onPolygonSelected: null,
  onPolygonDesected: null,
  onPolygonRemoved: null,
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
    @onPolygonRemoved = options['onPolygonRemoved']
    @onDeselectAll = options['onDeselectAll']

    @addPolygons(options['polygons']) if options['polygons']?

    # Add google maps event listeners
    _this = @
    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      unless _this.pen?
        _this.deselectAll()

  startDraw: (color=null, polygonColor=null) ->
    @deselectAll()
    @pen = new G.Pen(@map, @, color, polygonColor)
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

  setPolygons: (polygons) ->
    @reset()
    @addPolygons(polygons)

  addPolygon: (polygon) ->
    polygon.setMap(@map)
    polygon.manager = @
    @polygons.push(polygon)

  addPolygons: (polygons) ->
    for polygon in polygons
      @addPolygon(polygon)

  removePolygon: (polygon) ->
    polygon.remove()
    i = @polygons.indexOf(polygon)
    if i != -1
      @polygons.splice(i, 1)
    @onPolygonRemoved(polygon) if @onPolygonRemoved?

  reset: ->
    for polygon in @polygons
      if polygon?
        polygon.remove()
    @polygons = []
    @_resetCursor()

  destroy: ->
    @reset()
    for event in @events
      google.maps.event.removeListener event

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
