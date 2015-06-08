PolygonCreator = this.Mapt.Utils.PolygonCreator

class ZonesController
  init: ->
  index: ->
  new: ->
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    creator = new PolygonCreator map, polygonCreated

    $('#reset').click ->
      creator.destroy()
      creator = null
      creator = new PolygonCreator map, polygonCreated

    $('#showData').click ->
      $('#dataPanel').empty()
      if null == creator.showData()
        $('#dataPanel').append 'Please first create a polygon'
      else
        $('#dataPanel').append creator.showData()

  polygonCreated = (data) ->
    fieldContainer = $('#dataPanel')
    data.forEach (value, index) ->
#      latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
#      latField = $("<input type='hidden' name='zone[zone_coords_attributes][lat]' value='#{value.lat}'>")
      latField = $("<input type='text' name='zone[zone_coords_attributes][][lat]' value='#{value.lat}'>")
      lngField = $("<input type='text' name='zone[zone_coords_attributes][][lng]' value='#{value.lng}'>")
      fieldContainer.append(latField)
      fieldContainer.append(lngField)


this.Mapt.zones= new ZonesController
