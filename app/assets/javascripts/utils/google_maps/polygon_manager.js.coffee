this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

#### TODO
# Clean up public vs private APIs

class PolygonManager
  map: null,
  pen: null,
  polygons: null,
  selectedPolygons: null,
  selectMultiple: null,
  events: null,
  drawColor: null,
  newPolygonColor: null,
  editable: null,
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
    @editable = if options['editable']? then options['editable'] else true

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

    @_trigger 'ready', @

  enableDraw: (color=null, newPolygonColor=null) ->
    return unless @editable
    @deselectAll()
    @pen = new G.Pen @map,
      color: color || @drawColor,
      callbackContext: @,
      onStartDraw: @callbacks['start_draw']
      onFinishDraw: @_finishDraw
      onCancelDraw: @_cancelDraw
      onDotAdded: @callbacks['dot_added']

    @map.setOptions({draggableCursor:'pointer'});

  setPolygons: (polygons) ->
    @reset()
    @addPolygons(polygons)

  addPolygon: (polygon_or_object, runCallback=true) ->
    polygon = if polygon_or_object instanceof G.Polygon then polygon_or_object else @_objectToPolygon(polygon_or_object)

    if @_trigger 'before_add_polygon', polygon
      polygon.setMap(@map)
      polygon.callbackContext = @
      polygon.on 'polygon_changed', @callbacks['polygon_changed']
      polygon.on 'polygon_clicked', @_polygonClicked
      polygon.on 'polygon_selected', @callbacks['polygon_selected']
      polygon.on 'polygon_deselected', @callbacks['polygon_deselected']
      polygon.on 'polygon_removed', @callbacks['polygon_removed']
      @polygons.push(polygon)
      @_trigger 'polygon_added', polygon if runCallback
      return polygon

  addPolygons: (polygons) ->
    for polygon in polygons
      @addPolygon(polygon, false)

  getPolygonById: (id) ->
    for polygon in @polygons
      return polygon if polygon.id == id

  getSelectedPolygon: ->
    @selectedPolygons[0]

  getSelectedPolygons: ->
    @selectedPolygons

  deselectPolygon: (polygon) ->
    polygon.deselect()
    _removeFromArray(@selectedPolygons, polygon)

  deselectPolygons: (polygonArr) ->
    polygons = polygonArr.slice(0)
    for polygon in polygons
      @deselectPolygon(polygon)

  deselectAll: ->
    @deselectPolygons(@selectedPolygons)

  selectPolygon: (polygon, deselectOthers=true) ->
    return polygon unless @editable
    @deselectAll() if deselectOthers
    polygon.select()
    @selectedPolygons.push(polygon)
    polygon

  selectPolygons: (polygons) ->
    return unless @selectMultiple
    @deselectAll()
    for polygon in polygons
      @selectPolygon(polygon, false)
    @_trigger 'polygons_selected', polygons
    polygons

  removePolygon: (polygon) ->
    @deselectPolygon(polygon)
    polygon.remove()
    _removeFromArray(@polygons, polygon)

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

  destroy: ->
    @reset()
    for event in @events
      google.maps.event.removeListener event

  on: (event_name, callback) ->
    @callbacks[event_name] = callback

  _trigger: () ->
    return if (arguments.length == 0)

    args = []
    Array.prototype.push.apply(args, arguments)

    event_name = args.shift()
    if @callbacks[event_name]?
      return @callbacks[event_name].apply(@callbackContext, args)
    else
      return true

  _removeFromArray = (array, obj) ->
    i = array.indexOf(obj)
    res = []
    if i != -1
      res = array.splice(i, 1)
    return res[0]

  _cancelDraw: (pen) ->
    if @pen?
      @pen.remove()
      @pen = null
    @_resetCursor()
    @_trigger 'cancel_draw'

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
      @_trigger 'polygon_clicked', polygon, event.latLng, right_click
    else
      selectMultiple = @selectMultiple && (event.eb.metaKey || event.eb.shiftKey || event.eb.ctrlKey)
      @selectPolygon(polygon, !selectMultiple)

  _mapClicked: (event) ->
    @pen.draw event.latLng if @pen?

  _resetCursor: () ->
    @map.setOptions({draggableCursor:'url(http://maps.gstatic.com/mapfiles/openhand_8_8.cur) 8 8, default '});

  _objectToPolygon: (obj) ->
    new G.Polygon obj['coords'], {id: obj['id'], color: obj['color']}
G.PolygonManager = PolygonManager
