this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Polygon
  listOfDots: null,
  map: null,
  coords: null,
  manager: null,
  polygonObj: null,
  events: null,
  isDragging: false

  constructor: (listOfDots, map, manager, editable=false, color='#FF0000') ->
    @listOfDots = listOfDots
    @map = map
    @manager = manager
    @coords = new Array
    @events = new Array

    _this = this

    $.each @listOfDots, (index, value) ->
      _this.coords.push value.getLatLng()

    @polygonObj = new google.maps.Polygon
      draggable: true
      editable: editable
      paths: @coords
      strokeOpacity: 0.8
      strokeWeight: 2
      fillOpacity: 0.35
      map: @map

    @setColor(color)

    @addListeners()

  addListeners: ->
    _this = @
    path = @polygonObj.getPath()

    @events.push google.maps.event.addListener @polygonObj, 'dragstart', (event) ->
        _this.isDragging = true
        _this.manager.onPolygonChanged(_this, 'remove') if _this.manager.onPolygonChanged?

    @events.push google.maps.event.addListener @polygonObj, 'dragend', (event) ->
      _this.isDragging = false
      _this.manager.onPolygonChanged(_this, 'drag') if _this.manager.onPolygonChanged?

    @events.push google.maps.event.addDomListener @polygonObj, 'click', (event) ->
      unless _this.isDragging
        if _this.isEditable()
          _this.manager.onPolygonClicked(_this, event.latLng, false) if _this.manager.onPolygonClicked?
        else
          _this.manager.deselectAll(false)
          _this.setEditable true
          _this.manager.onPolygonSelected(_this) if _this.manager.onPolygonSelected?

    @events.push google.maps.event.addListener path, 'insert_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'insert') if _this.manager.onPolygonChanged?

    @events.push google.maps.event.addListener path, 'set_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'move') if _this.manager.onPolygonChanged?

    @events.push google.maps.event.addListener path, 'remove_at', (event) ->
      unless _this.isDragging
        _this.manager.onPolygonChanged(_this, 'remove') if _this.manager.onPolygonChanged?

    @events.push google.maps.event.addListener @polygonObj, 'rightclick', (event) ->
      if event.vertex?
        if path.length == 2
          _this.remove()
        else
          path.removeAt(event.vertex)
      else
        _this.manager.onPolygonClicked(_this, event.latLng, true) if _this.manager.onPolygonClicked?


  remove: ->
    @polygonObj.setMap(null)
    for event in @events
      google.maps.event.removeListener event

  getPolygonObj: ->
    @polygonObj

  getListOfDots: ->
    @listOfDots

  getPlots: ->
    @polygonObj.getPaths()

  getColor: ->
    @getPolygonObj().fillColor

  setColor: (color) ->
    @getPolygonObj().setOptions
      fillColor: color
      strokeColor: color
      strokeWeight: 2

  deselect: ->
    if @isEditable()
      @setEditable(false)
      @manager.onPolygonDeselected(@) if @manager.onPolygonDeselected?

  setEditable: (editable) ->
    @getPolygonObj().setOptions
      editable: editable
      draggable: editable

  isEditable: ->
    @getPolygonObj().editable

  getData: ->
    data = []
    paths = @getPlots()
    paths.getAt(0).forEach (value, index) ->
      data.push({lat: value.A, lng: value.F})
    return data

G.Polygon = Polygon