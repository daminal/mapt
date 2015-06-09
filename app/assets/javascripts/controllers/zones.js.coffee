PolygonCreator = this.Mapt.Utils.PolygonCreator

class ZonesController
  init: ->
  index: ->
  new: ->
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    polygonCreatorOptions =
      onNewPolygon: ->
        $('#addZone').attr('disabled','disabled')

      onCompletePolygon: (data) ->
        fieldContainer = $('#dataPanel')
        for point in data
          # latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
          # latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
          latField = $("<input type='text' name='zone[zone_coords_attributes][][lat]' value='#{point.lat}'>")
          lngField = $("<input type='text' name='zone[zone_coords_attributes][][lng]' value='#{point.lng}'>")
          fieldContainer.append(latField)
          fieldContainer.append(lngField)

        $('#addZone').removeAttr('disabled')

    creator = new PolygonCreator map, polygonCreatorOptions

    $('#addZone').click ->
      creator.newPen()
      $(this).attr('disabled','disabled')
    $('#reset').click ->
      creator.destroy()
      creator = null
      creator = new PolygonCreator map, polygonCreatorOptions
      $('#addZone').removeAttr('disabled')

    $('#showData').click ->
      $('#dataPanel').empty()
      if null == creator.showData()
        $('#dataPanel').append 'Please first create a polygon'
      else
        $('#dataPanel').append creator.showData()

this.Mapt.zones= new ZonesController
