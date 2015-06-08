PolygonCreator = this.Mapt.Utils.PolygonCreator

class ZonesController
  init: ->
  index: ->
  new: ->
    map = new google.maps.Map document.getElementById('map-canvas'),
      zoom: 10
      center: new google.maps.LatLng(40.4503037, -79.95035596)
      mapTypeId: google.maps.MapTypeId.ROADMAP

    creator = new PolygonCreator map

    $('#reset').click ->
      creator.destroy()
      creator = null
      creator = new PolygonCreator(map)

    $('#showData').click ->
      $('#dataPanel').empty()
      if null == creator.showData()
        $('#dataPanel').append 'Please first create a polygon'
      else
        $('#dataPanel').append creator.showData()

this.Mapt.zones= new ZonesController

