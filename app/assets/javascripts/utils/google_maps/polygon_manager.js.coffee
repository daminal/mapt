this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class PolygonManager
  map: null,
  polygons: null,
  pen: null,
  events: null,
  onNewPolygon: null,
  onCompletePolygon: null,
  onCancelPolygon: null

  constructor: (map, options={}) ->
    throw "You must pass a google map object as the first argument" unless map?

    @map = map;
    @polygons = new Array
    @events = new Array
    @onNewPolygon = options['onNewPolygon']
    @onCompletePolygon = options['onCompletePolygon']
    @onCancelPolygon = options['onCancelPolygon']

    # Add google maps event listeners
    _this = @
    @events.push google.maps.event.addDomListener @map, 'click', (event) ->
      _this.mapClicked(event)
    @events.push google.maps.event.addDomListener window, 'keyup', (event) ->
      code = if event.keyCode then event.keyCode else event.which
      switch code
        when 27
          _this.destroyPen()

  newPen: ->
    @pen = new G.Pen(@map, @, @polygonCreated)
    @onNewPolygon(@pen) if @onNewPolygon?

  setPen: (pen) ->
    @pen = pen

  destroyPen: ->
    if @pen?
      @pen.clear()
      @pen = null
    @onCancelPolygon() if @onCancelPolygon?

  getData: ->
    @pen.getData()

  mapClicked: (event) ->
    @pen.draw event.latLng if @pen?

  polygonCreated: (data, polygon, manager) ->
    @pen = null
    manager.polygons.push(polygon)
    manager.onCompletePolygon data if manager.onCompletePolygon?

  destroy: ->
    for polygon in @polygons
      polygon.remove() if polygon?

    for event in @events
      google.maps.event.removeListener(event)

G.PolygonManager = PolygonManager
