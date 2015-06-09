PolygonManager = this.Mapt.Utils.GoogleMaps.PolygonManager

### Note:
    Given a polygon, you can get its data points like so:

    data = polygon.getData()     # This returns an array of the data points which you can iterate through to get lat/lng
    for point in data
      lat = point.lat
      lng = point.lng
 ###

class ZonesController
  init: ->
  index: ->
  new: ->
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    manager = createPolygonManager map

    $('#addZone').click ->
      manager.startDraw()
      $(this).attr('disabled','disabled')

    $('#reset').click ->
      manager.destroy()
      manager = null
      manager = createPolygonManager map
      $('#addZone').removeAttr('disabled')

    $('#showData').click ->
      $('#dataPanel').empty()
      if null == manager.showData()
        $('#dataPanel').append 'Please first create a polygon'
      else
        $('#dataPanel').append manager.showData()

  createPolygonManager = (map) ->
    ####
    # The PolygonManager object takes a map as its first argument (required)
    # and an options hash as its second argument (optional)
    #
    # Available options:
    #   onStartDraw: function()                     # called once map is ready for drawing
    #
    #   onCancelDraw: function()                    # called when user cancel's drawing by pressing the ESC key
    #
    #   onFinishDraw: function(polygon)             # called when user has closed the polygon
    #     - polygon    (an instance of Polygon representing the new polygon)
    #
    #   onPolygonChanged: function(polygon, type)   # called when a polygon's points are edited or the entire polygon
    #                                               # is moved
    #     - polygon    (an instance of Polygon representing the changed polygon)
    #     - type       (a string)
    #       - possible values:
    #         - 'insert'    (a new point was inserted on the polygon)
    #         - 'move'      (an existing point was moved)
    #         - 'remove'    (an existing point was removed)
    #         - 'drag'      (the entire polygon was moved)
    #
    #   onPolygonSelected: function(polygon)        # called when user selects a polygon
    #     - polygon     (an instance of Polygon representing the selected polygon)
    #
    #   onPolygonDeselected: function(polygon)          # called when a polygon is deselected either by selecting
    #                                                   # another polygon or clicking the map outside of all polygons
    #     - polygon     (an instance of Polygon representing the polygon that was deselected)
    #
    #   onDeselectAll: function()                       # called when all polygons are deselected by clicking the map
    #                                                   # outside of all polygons or by drawing a new polygon
    #
    #   onPolygonClicked: function(polygon, latLng, rightClick)     # called when user clicks an already selected polygon
    #     - polygon     (an instance of Polygon representing the polygon that was clicked)
    #     - latLng      (a google maps latLng object containing the coordinates at which the user clicked
    #     - rightClick  (a boolean.  true if this was a right click, false if this was a left click)
    ####

    return new PolygonManager map,
      onStartDraw: ->
        disableAddZoneButton()
        console.log('Start Draw')

      onCancelDraw: ->
        enableAddZoneButton()
        console.log('Cancel Draw')

      onFinishDraw: (polygon) ->
        enableAddZoneButton()
        console.log(polygon)
        console.log('Polygon Created')
        # You can hook in here to make a call to the server to save the new zone in the database
        # Or display a notice that they've made a new zone and can click a button to save if you don't want it to
        # autosave

      onPolygonChanged: (polygon, type) ->
        console.log(polygon)
        console.log("Polygon Changed (#{type})")
        # You can hook in here to make a call to the server to update the zone in the database
        # Or use it to display a notice that changes have been made, 'click here' to save if you don't want it to
        # autosave

      onPolygonSelected: (polygon) ->
        console.log(polygon)
        console.log('Polygon selected')
        # You can hook in here to display a form for editing or deleting this polygon

      onPolygonDeselected: (polygon) ->
        console.log(polygon)
        console.log('Polygon deselected')

      onDeselectAll: ->
        console.log('Deselect all')
        # You can hook in here to hide the edit form

      onPolygonClicked: (polygon, latLng, rightClick) ->
        console.log(polygon)
        console.log(latLng)

        if rightClick
          console.log('Polygon right clicked')
        else
          console.log('Polygon left clicked')

  enableAddZoneButton = ->
    $('#addZone').removeAttr('disabled')

  disableAddZoneButton = ->
    $('#addZone').attr('disabled','disabled')

this.Mapt.zones= new ZonesController
