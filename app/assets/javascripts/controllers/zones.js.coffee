PolygonManager = this.Mapt.Utils.GoogleMaps.PolygonManager

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
    options =
      onNewPolygon: ->
        disableAddZoneButton()

      onCancelPolygon: ->
        enableAddZoneButton()

      onCompletePolygon: (polygon) ->
        data = polygon.getData()
        fieldContainer = $('#dataPanel')
        for point in data
          # latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
          # latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
          latField = $("<input type='text' name='zone[zone_coords_attributes][][lat]' value='#{point.lat}'>")
          lngField = $("<input type='text' name='zone[zone_coords_attributes][][lng]' value='#{point.lng}'>")
          fieldContainer.append(latField)
          fieldContainer.append(lngField)

        enableAddZoneButton()
      onPolygonChanged: (polygon, type) ->
        console.log(polygon);
        console.log(type);

    return new PolygonManager map, options

  enableAddZoneButton = ->
    $('#addZone').removeAttr('disabled')

  disableAddZoneButton = ->
    $('#addZone').attr('disabled','disabled')

this.Mapt.zones= new ZonesController
