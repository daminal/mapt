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
      manager.newPen()
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
    return new PolygonManager map,
      onStartDraw: ->
        disableAddZoneButton()
        console.log('Start Draw')

      onCancelDraw: ->
        enableAddZoneButton()
        console.log('Cancel Draw')

      onCompletePolygon: (polygon) ->
        console.log(polygon)
        enableAddZoneButton()
        console.log('Polygon Created')

      onPolygonChanged: (polygon, type) ->
        console.log(polygon)
        console.log("Polygon Changed (#{type})")

      onPolygonClicked: (polygon, latLng, rightClick) ->
        console.log(polygon)
        console.log(latLng)
        if rightClick
          console.log('Polygon right clicked')
        else
          console.log('Polygon left clicked')

      onPolygonSelected: (polygon) ->
        console.log(polygon)
        console.log('Polygon selected')

  enableAddZoneButton = ->
    $('#addZone').removeAttr('disabled')

  disableAddZoneButton = ->
    $('#addZone').attr('disabled','disabled')

this.Mapt.zones= new ZonesController
