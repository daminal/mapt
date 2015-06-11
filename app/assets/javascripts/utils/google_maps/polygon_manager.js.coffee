this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

#### TODO
# select multiple
# allow passing polygon(s) or json to addPolygon/addPolygons methods and polygons option

class PolygonManager
  map: null,
  pen: null,
  polygons: null,
  selectedPolygons: null,
  selectMultiple: null,
  events: null,
  drawColor: null,
  newPolygonColor: null,
  callbackContext: null,
  callbacks: null,

  constructor: (map, options={}) ->
    throw "You must pass a google map object as the first argument" unless map?

    @map = map;
    @polygons = new Array
    @selectedPolygons = new Array
    @events = new Array
    @drawColor = options['drawColor'] if options['drawColor']?
    @newPolygonColor = options['newPolygonColor'] || '#f00'
    @selectMultiple = options['selectMultiple'] || false


    @callbackContext = options['callbackContext'] || @

    # Define callbacks
    @callbacks =
      ready:              options['onReady']
      start_draw:         options['onStartDraw']
      finish_draw:        options['onFinishDraw']
      cancel_draw:        options['onCancelDraw']
      dot_added:          options['onDotAdded']
      before_add_polygon: options['beforeAddPolygon']
      polygon_added:      options['onPolygonAdded']
      polygon_changed:    options['onPolygonChanged']
      polygon_clicked:    options['onPolygonClicked']
      polygon_selected:   options['onPolygonSelected']
      polygon_deselected: options['onPolygonDeselected']
      polygon_removed:    options['onPolygonRemoved']

    @addPolygons(options['polygons']) if options['polygons']?

    # Add google maps event listeners
    _this = @
    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      unless _this.pen?
        _this.deselectAll()

    @trigger 'ready', @

  enableDraw: (color=null, newPolygonColor=null) ->
    @deselectAll()
    @pen = new G.Pen @map,
      color: color || @drawColor,
      callbackContext: @,
      onStartDraw: @callbacks['start_draw']
      onFinishDraw: @_finishDraw
      onCancelDraw: @_cancelDraw
      onDotAdded: @callbacks['dot_added']

    @map.setOptions({draggableCursor:'pointer'});

    @trigger 'enable_draw', @pen

  _cancelDraw: (pen) ->
    if @pen?
      @pen.remove()
      @pen = null
    @_resetCursor()
    @trigger 'cancel_draw'

  _finishDraw: (pen) ->
    @_resetCursor()
    polygon = new G.Polygon @pen.listOfDots,
      color: @newPolygonColor

    @addPolygon polygon
    @selectPolygon(polygon)
    @pen.remove()
    @pen = null

  _polygonClicked: (polygon, event, right_click) ->
    if polygon.isEditable() || right_click
      @trigger 'polygon_clicked', polygon, event.latLng, right_click
    else
      selectMultiple = @selectMultiple && event.eb.metaKey
      @selectPolygon(polygon, !selectMultiple)

  deselectPolygon: (polygon) ->
    polygon.deselect()
    removeFromArray(@selectedPolygons, polygon)

  deselectAll: ->
    polygons = @selectedPolygons.slice(0)

    for polygon in polygons
      @deselectPolygon(polygon)

  setPolygons: (polygons) ->
    @reset()
    @addPolygons(polygons)

  addPolygon: (polygon, runCallback=true) ->
    if @trigger 'before_add_polygon', polygon
      polygon.setMap(@map)
      polygon.callbackContext = @
      polygon.on 'polygon_changed', @callbacks['polygon_changed']
      polygon.on 'polygon_clicked', @_polygonClicked
      polygon.on 'polygon_selected', @callbacks['polygon_selected']
      polygon.on 'polygon_deselected', @callbacks['polygon_deselected']
      polygon.on 'polygon_removed', @callbacks['polygon_removed']
      @polygons.push(polygon)
      @trigger 'polygon_added', polygon if runCallback
      return polygon

  addPolygons: (polygons) ->
    for polygon in polygons
      @addPolygon(polygon, false)

  getPolygonById: (id) ->
    for polygon in @polygons
      return polygon if polygon.id == id

  selectPolygon: (polygon, deselectOthers=true) ->
    @deselectAll() if deselectOthers
    polygon.select()
    @selectedPolygons.push(polygon)
    polygon

  selectPolygons: (polygons) ->
    return unless @selectMultiple
    @deselectAll()
    for polygon in polygons
      @selectPolygon(polygon, false)
    @trigger 'polygons_selected', polygons
    polygons

  getSelectedPolygon: ->
    @selectedPolygons[0]

  getSelectedPolygons: ->
    @selectedPolygons

  removePolygon: (polygon) ->
    @deselectPolygon(polygon)
    polygon.remove()
    removeFromArray(@polygons, polygon)

  removePolygons: (polygons) ->
    the_polygons = polygons.slice(0)

    for polygon in the_polygons
      @removePolygon(polygon)

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
      return @callbacks[event_name].apply(@callbackContext, args)
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

  removeFromArray = (array, obj) ->
    i = array.indexOf(obj)
    res = []
    if i != -1
      res = array.splice(i, 1)
    return res[0]


G.PolygonManager = PolygonManager
