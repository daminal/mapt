PolygonManager = this.Mapt.Utils.GoogleMaps.PolygonManager
Polygon = this.Mapt.Utils.GoogleMaps.Polygon

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
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    # PolygonManager accepts an array of Polygon objects to show immediately
    # You can use this to display existing zones loaded from the db when the page loads
    # For now, I'm just creating one polygon here, wrapping it in an array, and passing
    # it to createPolygonManager.  The result is that you see that polygon on the map
    # when you load the page.

    coords = [
      new google.maps.LatLng(40.399605, -80.020731),
      new google.maps.LatLng(40.590709, -79.862879),
      new google.maps.LatLng(40.718521, -80.098347),
      new google.maps.LatLng(40.525592, -80.22322)
    ]
    initialPolygons = [
      new Polygon(coords, id: '123')
    ]

    manager = createPolygonManager map, initialPolygons

    $('#addZone').click ->
      manager.enableDraw()
      $(this).attr('disabled','disabled')

    $('#removeZone').click ->
      manager.removePolygons(manager.getSelectedPolygons())

    $('#reset').click ->
      manager.reset()
      $('#addZone').removeAttr('disabled')

  createPolygonManager = (map, initialPolygons) ->
    ###
     The PolygonManager object takes a google.maps.Mao as its first argument (required)
     and an options hash as its second argument (optional)

     Available options:
       polygons:  Array                            # an Array of Polygon objects to render immediately
       drawColor: String                           # Color used for line while drawing
       newPolygonColor: String                     # Color used for newly created polygons
       ready: function(manager)                    # called once PolygonManager has finished construction
                                                   # and rendered initial polygons
        - manager             (an instance of the PolygonManager)

       onStartDraw: function()                     # called once map is ready for drawing

       onCancelDraw: function()                    # called when user cancel's drawing by pressing the ESC key

       onFinishDraw: function(polygon)             # called when user has closed the polygon
                                                   # If you define this callback, the return value is important
                                                   # Returning true will result in the polygon being added to the map
                                                   #    and the onPolygonAdded() callback being fired
                                                   # Returning false will result in the polygon not being added to the
                                                   #    map and onPolygonAdded() callback will not be called until you
                                                   #    manually add the polygon
         - polygon    (an instance of Polygon representing the new polygon)

       onDotAdded:   function(dot)                 # called each time user clicks to add a point to the map.  This is
                                                   # only fired during drawing.

       onPolygonAdded: function(polygon)           # called when a new polygon is added to the map
         - polygon    (an instance of Polygon representing the newly added polygon)

       onPolygonChanged: function(polygon, type)   # called when a polygon's points are edited or the entire polygon
                                                   # is moved
         - polygon    (an instance of Polygon representing the changed polygon)
         - type       (a string)
           - possible values:
             - 'insert'    (a new point was inserted on the polygon)
             - 'move'      (an existing point was moved)
             - 'remove'    (an existing point was removed)
             - 'drag'      (the entire polygon was moved)

       onPolygonSelected: function(polygon)        # called when user selects a polygon
         - polygon     (an instance of Polygon representing the selected polygon)

       onPolygonDeselected: function(polygon)      # called when a polygon is deselected either by selecting
                                                   # another polygon or clicking the map outside of all polygons
         - polygon     (an instance of Polygon representing the polygon that was deselected)

       onPolygonClicked: function(polygon, latLng, rightClick)     # called when user clicks an already selected polygon
         - polygon     (an instance of Polygon representing the polygon that was clicked)
         - latLng      (a google maps latLng object containing the coordinates at which the user clicked
         - rightClick  (a boolean.  true if this was a right click, false if this was a left click)
    ###

    return new PolygonManager map,
      polygons: initialPolygons
      drawColor: '#0f0'
      newPolygonColor: '#000'
      selectMultiple: true
      onReady: (manager) ->
        console.log('PolygonManager is ready')

      onStartDraw: ->
        enableButton('#addZone')
        console.log('Start Draw')

      onCancelDraw: ->
        enableButton('#addZone')
        console.log('Cancel Draw')

      onFinishDraw: (polygon) ->
        enableButton('#addZone')
        console.log(polygon.getData())
        console.log('Polygon Created')

        # You can hook in here to make a call to the server to save the new zone in the database
        # Or display a notice that they've made a new zone and can click a button to save if you don't want it to
        # autosave

        # Return true if ok to add polygon to the map.  Return false to avoid adding the polygon to the map
        return true

      onDotAdded: (dot) ->
        console.log(dot)
        console.log('Dot added')

      onPolygonChanged: (polygon, type) ->
        console.log(polygon.getData())
        console.log("Polygon Changed (#{type})")
        # You can hook in here to make a call to the server to update the zone in the database
        # Or use it to display a notice that changes have been made, 'click here' to save if you don't want it to
        # autosave

      onPolygonSelected: (polygon) ->
        enableButton('#removeZone')
        console.log(polygon)
        console.log('Polygon selected')
        # You can hook in here to display a form for editing or deleting this polygon

      onPolygonDeselected: (polygon) ->
        disableButton('#removeZone')
        console.log(polygon.getData())
        console.log('Polygon deselected')

      onPolygonClicked: (polygon, latLng, rightClick) ->
        console.log(polygon)
        console.log(latLng)

        if rightClick
          console.log('Polygon right clicked')
        else
          console.log('Polygon left clicked')

      onPolygonAdded: (polygon) ->
        console.log(polygon)
        console.log('Polygon added')

      onPolygonRemoved: (polygon) ->
        disableButton('#removeZone')
        console.log(polygon)
        console.log('Polygon removed')

  enableButton = (selector) ->
    $(selector).removeAttr('disabled')

  disableButton = (selector) ->
    $(selector).attr('disabled','disabled')

this.Mapt.zones= new ZonesController
