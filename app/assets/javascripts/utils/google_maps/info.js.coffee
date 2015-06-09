this.Mapt.Utils.GoogleMaps ?= {}
G = this.Mapt.Utils.GoogleMaps

class Info
  parent: null,
  map: null,
  color: null,
  button: null,
  infoWidObj: null,

  constructor: (polygon, map) ->
    @parent = polygon
    @map = map
    @color = document.createElement('input')
    @button = document.createElement('input')

    $(@button).attr('type', 'button')
    $(@button).val('Change Color');

    _this = this
    @infoWidObj = new google.maps.InfoWindow
      content: _this.getContent()


  changeColor: ->
    @parent.setColor($(@color).val());

  getContent: ->
    _this = this
    content = document.createElement('div')

    $(@color).val(@parent.getColor())

    $(@button).click ->
      _this.changeColor()

    $(content).append(@color)
    $(content).append(@button)

    return content

  show: (latLng=null) ->
    @infoWidObj.setPosition(latLng) if latLng?
    @infoWidObj.open(@map)

  remove: ->
    @infoWidObj.close()

G.Info = Info