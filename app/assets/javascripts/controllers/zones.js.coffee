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
    manager = null
    myStyles = [ {
      featureType: 'poi'
      elementType: 'labels'
      stylers: [ { visibility: 'off' } ]
    } ]
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP
      styles: myStyles


    manager = createPolygonManager(gmapsSimplePolygon.PolygonManager, map, window.zones_json)
    $('#addZone').click ->
      manager.enableDraw()
      $(this).attr('disabled','disabled')

    $('#removeZone').click ->
      manager.removePolygons(manager.getSelectedPolygons())

    $('#reset').click ->
      manager.reset()
      $('#addZone').removeAttr('disabled')

#    manager = createPolygonManager map, initialPolygons



  createPolygonManager = (PolygonManager, map, initialPolygons) ->
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
      editable: true # false
      onReady: (manager) ->
        $('#side input[type=button]').attr('disabled','disabled') unless manager.editable
        console.log('PolygonManager is ready')

      onStartDraw: ->
        console.log('Start Draw')

      onCancelDraw: ->
        enableButton('#addZone')
        console.log('Cancel Draw')

      beforePolygonAdded: (polygon) ->
        console.log('Before Polygon Added')
        return true

      onPolygonAdded: (polygon) ->
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
        updateCoordinates(polygon)
        console.log(polygon.getData())
        console.log("Polygon Changed (#{type})")
        # You can hook in here to make a call to the server to update the zone in the database
        # Or use it to display a notice that changes have been made, 'click here' to save if you don't want it to
        # autosave

      onPolygonSelected: (polygon) ->
        enableButton('#removeZone')
        if(polygon.id?)
          # existing one, show the edit form
          showEditForm(polygon)
        else
          # new one, show the new form
          showNewForm(polygon)
        console.log(polygon)
        console.log('Polygon selected')
        # You can hook in here to display a form for editing or deleting this polygon

      onPolygonDeselected: (polygon) ->
        disableButton('#removeZone')
        $('#newForm').hide()
        console.log(polygon.getData())
        console.log('Polygon deselected')

      onPolygonClicked: (polygon, latLng, rightClick) ->
        console.log(polygon)
        console.log(latLng)

        if rightClick
          console.log('Polygon right clicked')
        else
          console.log('Polygon left clicked')

      onPolygonRemoved: (polygon) ->
        disableButton('#removeZone')
        console.log(polygon)
        console.log('Polygon removed')

  enableButton = (selector) ->
    $(selector).removeAttr('disabled')

  disableButton = (selector) ->
    $(selector).attr('disabled','disabled')

  showNewForm = (polygon) ->
    formWrapper = $('#newForm')
    $('#zone_name', formWrapper).val('')
    updateCoordinates(polygon)

    formWrapper.show()

  showEditForm = (polygon) ->
    formWrapper = $('#editForm')
    $('#zone_name', formWrapper).val(polygon.getMeta('name'))
    updateCoordinates(polygon)

    submitUrl = formWrapper.data('url')
    $('form', formWrapper).attr('action', submitUrl.replace('-1', polygon.id))
    formWrapper.show()

  updateCoordinates = (polygon) ->
    formWrapper = if polygon.id? then $('#editForm') else $('#newForm')
    coordsWrapper = $('#coords', formWrapper)
    coords = polygon.getData()
    generateCoordinateFields(coordsWrapper, coords)

  generateCoordinateFields = (coordsWrapper, coords) ->
    coordsWrapper.html('')
    i = 0
    for coord in coords
      coord_lat_field = $("<input type='hidden' name='zone[coords_attributes][#{i}][lat]' value='#{coord.lat}'>")
      coord_lng_field = $("<input type='hidden' name='zone[coords_attributes][#{i}][lng]' value='#{coord.lng}'>")
      coordsWrapper.append(coord_lat_field).append(coord_lng_field)
      i = i + 1

this.Mapt.zones= new ZonesController
