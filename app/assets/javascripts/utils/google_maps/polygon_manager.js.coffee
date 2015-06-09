this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class PolygonManager
  map: null,
  polygons: null,
  pen: null,
  events: null,
  onNewPolygon: null,
  onCompletePolygon: null,

  constructor: (map, options={}) ->
    throw "You must pass a google map object as the first argument" unless map?

    @map = map;
    @polygons = new Array
    @events = new Array
    @onNewPolygon = options['onNewPolygon']
    @onCompletePolygon = options['onCompletePolygon']

    # Add google maps event listeners
    _this = @
    events.push google.maps.event.addListener @map, 'click', (event) ->
      _this.mapClicked(event)

  newPen: ->
    @pen = new G.Pen(@map, @, @polygonCreated)
    @onNewPolygon(@pen) if @onNewPolygon?

  setPen: (pen) ->
    @pen = pen

  getData: ->
    @pen.getData()

  mapClicked: (event) ->
    @pen.draw event.latLng if @pen?

  polygonCreated: (data, polygon, manager) ->
    @pen = null
    manager.polygons.push(polygon)
    manager.onCompletePolygon data

  destroy: ->
    for polygon in @polygons
      polygon.remove() if polygon?

    for event in @events
      google.maps.event.removeListener(event)

G.PolygonManager = PolygonManager
