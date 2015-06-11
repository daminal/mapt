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

  constructor: (listOfDots, manager, map, editable=false, color='#FF0000') ->
    @listOfDots = listOfDots
    @map = map
    @manager = manager
    @coords = new Array
    @events = new Array

    _this = this

    $.each @listOfDots, (index, value) ->
      _this.addDot value

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
        _this.manager.trigger 'polygon_changed', _this, 'remove'

    @events.push google.maps.event.addListener @polygonObj, 'dragend', (event) ->
      _this.isDragging = false
      _this.manager.trigger 'polygon_changed', _this, 'drag'

    @events.push google.maps.event.addListener path, 'insert_at', (event) ->
      unless _this.isDragging
        _this.manager.trigger 'polygon_changed', _this, 'insert'

    @events.push google.maps.event.addListener path, 'set_at', (event) ->
      unless _this.isDragging
        _this.manager.trigger 'polygon_changed', _this, 'move'

    @events.push google.maps.event.addListener path, 'remove_at', (event) ->
      unless _this.isDragging
        _this.manager.trigger 'polygon_changed', _this, 'remove'

    @events.push google.maps.event.addDomListener @polygonObj, 'click', (event) ->
      unless _this.isDragging
        if _this.isEditable()
          _this.manager.trigger 'polygon_clicked', _this, event.latLng, false
        else
          _this.manager.deselectAll(false)
          _this.select()

    @events.push google.maps.event.addListener @polygonObj, 'rightclick', (event) ->
      if event.vertex?
        if path.length == 2
          _this.remove()
        else
          path.removeAt(event.vertex)
      else
        _this.manager.trigger 'polygon_clicked', _this, event.latLng, true


  remove: ->
    @polygonObj.setMap(null)
    for event in @events
      google.maps.event.removeListener event

  addDot: (value) ->
    latLng = if (value instanceof G.Dot) then value.latLng else value
    @coords.push(latLng)

  getPolygonObj: ->
    @polygonObj

  getListOfDots: ->
    @listOfDots

  getPlots: ->
    @polygonObj.getPaths()

  setColor: (color) ->
    @getPolygonObj().setOptions
      fillColor: color
      strokeColor: color
      strokeWeight: 2

  setMap: (map) ->
    @map = map
    @getPolygonObj().setMap(@map)

  select: ->
    @manager.selectedPolygon = @
    @setEditable(true)
    @manager.trigger 'polygon_selected', @

  deselect: ->
    @manager.selectedPolygon = null
    if @isEditable()
      @setEditable(false)
      @manager.trigger 'polygon_deselected', @

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