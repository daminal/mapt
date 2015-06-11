this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Dot
  latLng: null,
  markerObj: null,
  events: null,
  callbackContext: null,
  callbacks: null,

  constructor: (latLng, map, options={}) ->
    @latLng = latLng
    @markerObj = new google.maps.Marker
      position: @latLng
      map: map
    @events = new Array

    @callbackContext = options['callbackContext'] || @
    @callbacks =
      dot_clicked: options['onDotClicked']

    @_addListeners()

  _addListeners: ->
    _this = @

    @events.push google.maps.event.addListener @markerObj, 'click', ->
      _this.trigger 'dot_clicked', _this

  getLatLng: ->
    return @latLng

  getMarkerObj: ->
    return @markerObj

  remove: ->
    @markerObj.setMap(null)
    @_removeListeners()

  _removeListeners: ->
    for event in @events
      google.maps.event.removeListener(event)

    @events = new Array()

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

G.Dot = Dot