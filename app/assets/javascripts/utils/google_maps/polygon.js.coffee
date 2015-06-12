this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Polygon
  id: null,
  listOfDots: null,
  map: null,
  coords: null,
  callbackContext: null,
  polygonObj: null,
  events: null,
  isDragging: false,
  callbacks: null,
  _defaultColor: '#f00',

  constructor: (listOfDots, options={}) ->
    @listOfDots = listOfDots
    @map = options['map']
    @coords = new Array
    @events = new Array
    @callbackContext = options['callbackContext'] || @
    @id = options['id']
    @callbacks =
      polygon_changed:    options['onPolygonChanged']
      polygon_clicked:    options['onPolygonClicked']
      polygon_selected:   options['onPolygonSelected']
      polygon_deselected: options['onPolygonDeselected']
      polygon_removed:    options['onPolygonRemoved']

    _this = this
    editable = options['editable']
    color = options['color'] || @_defaultColor

    $.each @listOfDots, (index, value) ->
      _this.addDot value

    @polygonObj = new google.maps.Polygon
      draggable: true
      editable: editable
      paths: @coords
      strokeOpacity: 0.8
      strokeWeight: 2
      fillOpacity: 0.35
      fillColor: color
      strokeColor: color
      map: @map

    @_addListeners()

  getData: ->
    data = []
    paths = @getPlots()
    paths.getAt(0).forEach (value, index) ->
      data.push({lat: value.A, lng: value.F})
    return data

  getPolygonObj: ->
    @polygonObj

  getListOfDots: ->
    @listOfDots

  getPlots: ->
    @polygonObj.getPaths()

  isEditable: ->
    @getPolygonObj().editable

  setColor: (color='#f00') ->
    @getPolygonObj().setOptions
      fillColor: color
      strokeColor: color
      strokeWeight: 2

  setEditable: (editable) ->
    @getPolygonObj().setOptions
      editable: editable
      draggable: editable

  setMap: (map) ->
    @map = map
    @getPolygonObj().setMap(@map)

  addDot: (value) ->
    latLng = if (value instanceof G.Dot) then value.latLng else value
    @coords.push(latLng)

  select: ->
    @setEditable(true)
    @_trigger 'polygon_selected', @

  deselect: ->
    @setEditable(false)
    @_trigger 'polygon_deselected', @

  remove: ->
    @polygonObj.setMap(null)
    @_removeListeners()
    @_trigger 'polygon_removed', @

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

  _addListeners: ->
    _this = @
    path = @polygonObj.getPath()

    @events.push google.maps.event.addListener @polygonObj, 'dragstart', (event) ->
      _this.isDragging = true

    @events.push google.maps.event.addListener @polygonObj, 'dragend', (event) ->
      _this.isDragging = false
      _this._trigger 'polygon_changed', _this, 'drag'

    @events.push google.maps.event.addListener path, 'insert_at', (event) ->
      unless _this.isDragging
        _this._trigger 'polygon_changed', _this, 'insert'

    @events.push google.maps.event.addListener path, 'set_at', (event) ->
      unless _this.isDragging
        _this._trigger 'polygon_changed', _this, 'move'

    @events.push google.maps.event.addListener path, 'remove_at', (event) ->
      unless _this.isDragging
        _this._trigger 'polygon_changed', _this, 'remove'

    @events.push google.maps.event.addDomListener @polygonObj, 'click', (event) ->
      unless _this.isDragging
        _this._trigger 'polygon_clicked', _this, event, false

    @events.push google.maps.event.addListener @polygonObj, 'rightclick', (event) ->
      if event.vertex?
        if path.length == 2
          _this.remove()
        else
          path.removeAt(event.vertex)
      else
        _this._trigger 'polygon_clicked', _this, event, true

  _removeListeners: ->
    for event in @events
      google.maps.event.removeListener(event)

    @events = new Array()

G.Polygon = Polygon