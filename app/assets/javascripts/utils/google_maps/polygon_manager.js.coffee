this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

#### TODO
# retrieveJsonFromUrl
#

class PolygonManager
  map: null,
  pen: null,
  polygons: null,
  selectedPolygon: null,
  events: null,
  drawColor: null,
  newPolygonColor: null,
  callbacks: null,

  constructor: (map, options={}) ->
    throw "You must pass a google map object as the first argument" unless map?

    @map = map;
    @polygons = new Array
    @events = new Array
    @drawColor = options['drawColor'] if options['drawColor']?
    @newPolygonColor = options['newPolygonColor'] if options['newPolygonColor']?

    # Define callbacks
    @callbacks =
      ready:              options['onReady']
      start_draw:         options['onStartDraw']
      finish_draw:        options['onFinishDraw']
      cancel_draw:        options['onCancelDraw']
      dot_added:          options['onDrawPoint']
      polygon_added:      options['onPolygonAdded']
      polygon_changed:    options['onPolygonChanged']
      polygon_clicked:    options['onPolygonClicked']
      polygon_selected:   options['onPolygonSelected']
      polygon_deselected: options['onPolygonDeselected']
      polygon_removed:    options['onPolygonRemoved']
      deselect_all:       options['onDeselectAll']

    @addPolygons(options['polygons']) if options['polygons']?

    # Add google maps event listeners
    _this = @
    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      unless _this.pen?
        _this.deselectAll()

    @trigger 'ready', @

  startDraw: (color=null, newPolygonColor=null) ->
    @deselectAll()
    @pen = new G.Pen(@map, @, color || @drawColor, newPolygonColor || @newPolygonColor)
    @map.setOptions({draggableCursor:'pointer'});

    @trigger 'start_draw', @pen

  cancelDraw: ->
    if @pen?
      @pen.cancel()
      @pen = null
    @_resetCursor()
    @trigger 'cancel_draw'

  finishDraw: (polygon) ->
    @_resetCursor()
    @pen = null
    add_polygon = @trigger 'finish_draw', polygon
    if add_polygon
      @addPolygon(polygon)
      @trigger 'polygon_added', polygon
      polygon.select()

  deselectAll: (runCallback=true) ->
    for polygon in @polygons
      polygon.deselect()
    @trigger 'deselect_all' if runCallback

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
    @trigger 'polygon_removed', polygon

  reset: ->
    for polygon in @polygons
      if polygon?
        polygon.remove()
    @polygons = []
    @_resetCursor()

  trigger: () ->
    return if (arguments.length == 0)

    args = []
    Array.prototype.push.apply(args, arguments)

    event_name = args.shift()
    if @callbacks[event_name]?
      return @callbacks[event_name].apply(this, args)
    else
      return true

  on: (event_name, callback) ->
    @callbacks[event_name] = callback

  destroy: ->
    @reset()
    for event in @events
      google.maps.event.removeListener event

  _mapClicked: (event) ->
    @pen.draw event.latLng if @pen?

  _resetCursor: () ->
    @map.setOptions({draggableCursor:'url(http://maps.gstatic.com/mapfiles/openhand_8_8.cur) 8 8, default '});


G.PolygonManager = PolygonManager
