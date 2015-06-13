define('gmaps-polygon-manager/dot', ['exports', 'module'], function (exports, module) {
	'use strict';

	var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

	var Dot = (function () {
		function Dot(latLng, map) {
			var options = arguments[2] === undefined ? {} : arguments[2];

			_classCallCheck(this, Dot);

			this.latLng = latLng;
			this.markerObj = new google.maps.Marker({ position: this.latLng, map: map });
			this.events = new Array();

			this.callbackContext = options['callbackContext'] || this;
			this.callbacks = {
				dot_clicked: options['onDotClicked']
			};

			this._addListeners();
		}

		_createClass(Dot, [{
			key: 'getLatLng',
			value: function getLatLng() {
				return this.latLng;
			}
		}, {
			key: 'getMarketObj',
			value: function getMarketObj() {
				return this.markerObj;
			}
		}, {
			key: 'remove',
			value: function remove() {
				this.markerObj.setMap(null);
				this._removeListeners();
			}
		}, {
			key: 'on',
			value: function on(event_name, callback) {
				this.callbacks[event_name] = callback;
			}
		}, {
			key: '_trigger',
			value: function _trigger() {
				if (arguments.length == 0) {
					return true;
				}

				var args = new Array();
				Array.prototype.push.apply(args, arguments);

				var event_name = args.shift();
				if (this.callbacks[event_name] !== null && this.callbacks[event_name] !== undefined) {
					return this.callbacks[event_name].apply(this.callbackContext, args);
				} else {
					return true;
				}
			}
		}, {
			key: '_addListeners',
			value: function _addListeners() {
				var _this = this;

				this.events.push(google.maps.event.addListener(this.markerObj, 'click', function () {
					_this._trigger('dot_clicked', _this);
				}));
			}
		}, {
			key: '_removeListeners',
			value: function _removeListeners() {
				this.events.forEach(function (event) {
					google.maps.event.removeListener(event);
				});

				this.events = new Array();
			}
		}]);

		return Dot;
	})();

	module.exports = Dot;
});
define('gmaps-polygon-manager', ['exports', 'module', 'gmaps-polygon-manager/pen', 'gmaps-polygon-manager/polygon'], function (exports, module, _gmapsPolygonManagerPen, _gmapsPolygonManagerPolygon) {
  'use strict';

  var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

  function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

  function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

  var _Pen = _interopRequireDefault(_gmapsPolygonManagerPen);

  var _Polygon = _interopRequireDefault(_gmapsPolygonManagerPolygon);

  var PolygonManager = (function () {
    function PolygonManager(map) {
      var _this = this;

      var options = arguments[1] === undefined ? {} : arguments[1];

      _classCallCheck(this, PolygonManager);

      if (map === null || map === undefined) {
        throw 'You must pass a google map object as the first argument';
      }

      this.map = map;
      this.polygons = new Array();
      this.selectedPolygons = new Array();
      this.events = new Array();
      this.drawColor = options['drawColor'] || '#000';
      this.newPolygonColor = options['newPolygonColor'];
      this.selectMultiple = options['selectMultiple'] || false;
      if (options['editable'] !== null && options['editable'] !== undefined) {
        this.editable = options['editable'];
      } else {
        this.editable = true;
      }

      this.callbackContext = options['callbackContext'] || this;
      this.callbacks = {
        ready: options['onReady'],
        start_draw: options['onStartDraw'],
        finish_draw: options['onFinishDraw'],
        cancel_draw: options['onCancelDraw'],
        dot_added: options['onDotAdded'],
        before_add_polygon: options['beforeAddPolygon'],
        polygon_added: options['onPolygonAdded'],
        polygon_changed: options['onPolygonChanged'],
        polygon_clicked: options['onPolygonClicked'],
        polygon_selected: options['onPolygonSelected'],
        polygon_deselected: options['onPolygonDeselected'],
        polygon_removed: options['onPolygonRemoved']
      };

      if (options['polygons'] !== null && options['polygons'] !== undefined) {
        this.addPolygons(options['polygons']);
      }

      if (!this.editable) {
        this.polygons.forEach(function (polygon) {
          polygon.setEditable(false);
        });
      }

      this.events.push(google.maps.event.addDomListener(this.map, 'click', function (event) {
        if (_this.pen === null || _this.pen === undefined) {
          _this.deselectAll();
        }
      }));

      this._trigger('ready', this);
    }

    _createClass(PolygonManager, [{
      key: 'enableDraw',
      value: function enableDraw() {
        var color = arguments[0] === undefined ? null : arguments[0];
        var newPolygonColor = arguments[1] === undefined ? null : arguments[1];

        if (!this.editable) {
          return;
        }

        this.deselectAll();

        this.pen = new _Pen['default'](this.map, {
          color: color || this.drawColor,
          callbackContext: this,
          onStartDraw: this.callbacks['start_draw'],
          onFinishDraw: this._finishDraw,
          onCancelDraw: this._cancelDraw,
          onDotAdded: this.callbacks['dot_added']
        });

        this.map.setOptions({ draggableCursor: 'pointer' });
      }
    }, {
      key: 'setPolygons',
      value: function setPolygons(polygons) {
        this.reset();
        this.addPolygons(polygons);
      }
    }, {
      key: 'addPolygon',
      value: function addPolygon(polygon_or_object) {
        var runCallback = arguments[1] === undefined ? true : arguments[1];

        var polygon = polygon_or_object instanceof _Polygon['default'] ? polygon_or_object : this._objectToPolygon(polygon_or_object);

        if (this._trigger('before_add_polygon', polygon)) {
          polygon.setMap(this.map);
          polygon.callbackContext = this;
          polygon.on('polygon_changed', this.callbacks['polygon_changed']);
          polygon.on('polygon_clicked', this._polygonClicked);
          polygon.on('polygon_selected', this.callbacks['polygon_selected']);
          polygon.on('polygon_deselected', this.callbacks['polygon_deselected']);
          polygon.on('polygon_removed', this.callbacks['polygon_removed']);
          this.polygons.push(polygon);

          if (runCallback) {
            this._trigger('polygon_added', polygon);
          }

          return polygon;
        }
      }
    }, {
      key: 'addPolygons',
      value: function addPolygons(polygons) {
        var _this2 = this;

        var runIndividualCallbacks = arguments[1] === undefined ? true : arguments[1];

        polygons.forEach(function (polygon) {
          _this2.addPolygon(polygon, runIndividualCallbacks);
        });
      }
    }, {
      key: 'getPolygonById',
      value: function getPolygonById(id) {
        this.polygons.forEach(function (polygon) {
          if (polygon.id === id) {
            return polygon;
          }
        });
      }
    }, {
      key: 'getSelectedPolygon',
      value: function getSelectedPolygon() {
        return this.selectedPolygons[0];
      }
    }, {
      key: 'getSelectedPolygons',
      value: function getSelectedPolygons() {
        return this.selectedPolygons;
      }
    }, {
      key: 'deselectPolygon',
      value: function deselectPolygon(polygon) {
        polygon.deselect();
        this._removeFromArray(this.selectedPolygons, polygon);
      }
    }, {
      key: 'deselectPolygons',
      value: function deselectPolygons(polygonArr) {
        var _this3 = this;

        var polygons = polygonArr.slice(0);
        polygons.forEach(function (polygon) {
          _this3.deselectPolygon(polygon);
        });
      }
    }, {
      key: 'deselectAll',
      value: function deselectAll() {
        this.deselectPolygons(this.selectedPolygons);
      }
    }, {
      key: 'selectPolygon',
      value: function selectPolygon(polygon) {
        var deselectOthers = arguments[1] === undefined ? true : arguments[1];

        if (!this.editable) {
          return polygon;
        }

        if (deselectOthers) {
          this.deselectAll();
        }

        polygon.select();
        this.selectedPolygons.push(polygon);
        return polygon;
      }
    }, {
      key: 'selectPolygons',
      value: function selectPolygons(polygons) {
        var _this4 = this;

        if (!this.selectMultiple) {
          return;
        }

        this.deselectAll();
        polygons.forEach(function (polygon) {
          _this4.selectPolygon(polygon);
        });
        return polygons;
      }
    }, {
      key: 'removePolygon',
      value: function removePolygon(polygon) {
        this.deselectPolygon(polygon);
        polygon.remove();
        this._removeFromArray(this.polygons, polygon);
      }
    }, {
      key: 'removePolygons',
      value: function removePolygons(polygonArr) {
        var _this5 = this;

        var polygons = polygonArr.slice(0);

        polygons.forEach(function (polygon) {
          _this5.removePolygon(polygon);
        });
      }
    }, {
      key: 'reset',
      value: function reset() {
        this.polygons.forEach(function (polygon) {
          if (polygon !== null && polygon !== undefined) {
            polygon.remove();
          }
        });
        this.polygons = new Array();
        this._resetCursor();
      }
    }, {
      key: 'destroy',
      value: function destroy() {
        this.reset();
        this.events.forEach(function (event) {
          google.maps.event.removeListener(event);
        });
      }
    }, {
      key: 'on',
      value: function on(event_name, callback) {
        this.callbacks[event_name] = callback;
      }
    }, {
      key: '_trigger',
      value: function _trigger() {
        if (arguments.length == 0) {
          return true;
        }

        var args = new Array();
        Array.prototype.push.apply(args, arguments);

        var event_name = args.shift();

        if (this.callbacks[event_name] !== null && this.callbacks[event_name] !== undefined) {
          return this.callbacks[event_name].apply(this.callbackContext, args);
        } else {
          return true;
        }
      }
    }, {
      key: '_removeFromArray',
      value: function _removeFromArray(array, obj) {
        var i = array.indexOf(obj);
        var res = new Array();
        if (i != -1) {
          res = array.splice(i, 1);
        }
        return res[0];
      }
    }, {
      key: '_cancelDraw',
      value: function _cancelDraw(pen) {
        if (this.pen !== null && this.pen !== undefined) {
          this.pen.remove();
          this.pen = null;
        }
      }
    }, {
      key: '_finishDraw',
      value: function _finishDraw(pen) {
        this._resetCursor();
        var polygon = new _Polygon['default'](this.pen.listOfDots, {
          color: this.newPolygonColor
        });

        this.addPolygon(polygon);
        this.selectPolygon(polygon);
        this.pen.remove();
        this.pen = null;
      }
    }, {
      key: '_polygonClicked',
      value: function _polygonClicked(polygon, event, rightClick) {
        if (polygon.isEditable() || rightClick) {
          this._trigger('polygon_clicked', this, event.latLng, rightClick);
        } else {
          var selectMultiple = this.selectMultiple && (event.eb.metaKey || event.eb.shiftKey || event.eb.ctrlKey);
          this.selectPolygon(polygon, !selectMultiple);
        }
      }
    }, {
      key: '_mapClicked',
      value: function _mapClicked(event) {
        if (this.pen !== null && this.pen !== undefined) {
          this.pen.draw(event.latLng);
        }
      }
    }, {
      key: '_resetCursor',
      value: function _resetCursor() {
        this.map.setOptions({ draggableCursor: 'url(http://maps.gstatic.com/mapfiles/openhand_8_8.cur) 8 8, default ' });
      }
    }, {
      key: '_objectToPolygon',
      value: function _objectToPolygon(obj) {
        return new _Polygon['default'](obj['coords'], { id: obj['id'], color: obj['color'] });
      }
    }]);

    return PolygonManager;
  })();

  module.exports = PolygonManager;
});
define("gmaps-polygon-manager/line", ["exports", "module"], function (exports, module) {
	"use strict";

	var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

	var Line = (function () {
		function Line(listOfDots, map, color) {
			var _this = this;

			_classCallCheck(this, Line);

			this.listOfDots = listOfDots;
			this.map = map;
			this.color = color;
			this.coords = new Array();

			if (this.listOfDots.length > 1) {
				this.listOfDots.forEach(function (dot) {
					_this.coords.push(dot.getLatLng());
				});
				this.polylineObj = new google.maps.Polyline({
					path: this.coords,
					strokeColor: this.color,
					strokeOpacity: 1,
					strokeWeight: 2,
					map: this.map
				});
			}
		}

		_createClass(Line, [{
			key: "setColor",
			value: function setColor(color) {
				this.color = color;
				this.polylineObj.setOptions({ strokeColor: this.color });
			}
		}, {
			key: "remove",
			value: function remove() {
				this.polylineObj.setMap(null);
			}
		}]);

		return Line;
	})();

	module.exports = Line;
});
define('gmaps-polygon-manager/pen', ['exports', 'module', 'gmaps-polygon-manager/dot', 'gmaps-polygon-manager/line'], function (exports, module, _gmapsPolygonManagerDot, _gmapsPolygonManagerLine) {
	'use strict';

	var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

	var _Dot = _interopRequireDefault(_gmapsPolygonManagerDot);

	var _Line = _interopRequireDefault(_gmapsPolygonManagerLine);

	var Pen = (function () {
		function Pen(map) {
			var options = arguments[1] === undefined ? {} : arguments[1];

			_classCallCheck(this, Pen);

			this.map = map;
			this.callbackContext = options['callbackContext'] || this;
			this.color = options['color'] || '#000';
			this.listOfDots = new Array();
			this.isDrawing = false;

			this.callbacks = {
				start_draw: options['onStartDraw'],
				finish_draw: options['onFinishDraw'],
				cancel_draw: options['onCancelDraw'],
				dot_added: options['onDotAdded']
			};

			this._addListeners();
		}

		_createClass(Pen, [{
			key: 'draw',
			value: function draw(latLng) {
				this.isDrawing = true;
				if (this.currentDot !== null && this.currentDot !== undefined && this.listOfDots.length > 1 && this.currentDot.latLng == this.listOfDots[0].latLng) {
					this._trigger('finish_draw', this);
					this.clear();
					this.isDrawing = false;
				} else {
					if (this.polyline !== null && this.polyline !== undefined) {
						this.polyline.remove();
					}

					var dot = new _Dot['default'](latLng, this.map, {
						callbackContext: this,
						onDotClicked: this._dotClicked
					});

					this.listOfDots.push(dot);

					if (this.listOfDots.length == 1) {
						this._trigger('start_draw', this);
					}

					if (this.listOfDots.length > 1) {
						var _this = this;
						this.polyline = new _Line['default'](this.listOfDots, this.map, this.color);
					}
					this._trigger('dot_added', dot);
				}
			}
		}, {
			key: 'getListOfDots',
			value: function getListOfDots() {
				this.listOfDots;
			}
		}, {
			key: 'clear',
			value: function clear() {
				this.listOfDots.forEach(function (dot) {
					dot.remove();
				});

				this.listOfDots = new Array();

				if (this.polyline !== null && this.polyline !== undefined) {
					this.polyline.remove();
					this.polyline = null;
				}
			}
		}, {
			key: 'remove',
			value: function remove() {
				this.clear();
				this._removeListeners();

				this.events = new Array();
			}
		}, {
			key: 'on',
			value: function on(event_name, callback) {
				this.callbacks[event_name] = callback;
			}
		}, {
			key: '_trigger',
			value: function _trigger() {
				if (arguments.length == 0) {
					return true;
				}

				var args = new Array();
				Array.prototype.push.apply(args, arguments);

				var event_name = args.shift();
				if (this.callbacks[event_name] !== null && this.callbacks[event_name] !== undefined) {
					return this.callbacks[event_name].apply(this.callbackContext, args);
				} else {
					return true;
				}
			}
		}, {
			key: '_setCurrentDot',
			value: function _setCurrentDot(dot) {
				this.currentDot = dot;
			}
		}, {
			key: '_dotClicked',
			value: function _dotClicked(dot) {
				this._setCurrentDot(dot);
				this.draw(dot.getMarketObj().getPosition());
			}
		}, {
			key: '_addListeners',
			value: function _addListeners() {
				var _this2 = this;

				this.events = new Array();

				this.events.push(google.maps.event.addDomListener(this.map, 'click', function (event) {
					_this2.draw(event.latLng);
				}));
				this.events.push(google.maps.event.addDomListener(this.map, 'keyup', function (event) {
					var code = event.keyCode ? event.keyCode : event.which;
					switch (code) {
						case 27:
							_this2._trigger('cancel_draw');
					}
				}));
			}
		}, {
			key: '_removeListeners',
			value: function _removeListeners() {
				this.events.forEach(function (event) {
					google.maps.event.removeListener(event);
				});
			}
		}]);

		return Pen;
	})();

	module.exports = Pen;
});
define('gmaps-polygon-manager/polygon', ['exports', 'module', 'gmaps-polygon-manager/dot'], function (exports, module, _gmapsPolygonManagerDot) {
	'use strict';

	var _createClass = (function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ('value' in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

	function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError('Cannot call a class as a function'); } }

	var _Dot = _interopRequireDefault(_gmapsPolygonManagerDot);

	var Polygon = (function () {
		function Polygon(listOfDots) {
			var _this = this;

			var options = arguments[1] === undefined ? {} : arguments[1];

			_classCallCheck(this, Polygon);

			this.coords = new Array();
			this.events = new Array();
			this.listOfDots = listOfDots;
			this.map = options['map'];
			this.id = options['id'];
			this.isDragging = false;
			this.callbackContext = options['callbackContext'] || this;
			this.callbacks = {
				polygon_changed: options['onPolygonChanged'],
				polygon_clicked: options['onPolygonClicked'],
				polygon_selected: options['onPolygonSelected'],
				polygon_deselected: options['onPolygonDeselected'],
				polygon_removed: options['onPolygonRemoved']
			};

			var color = options['color'] || '#f00';

			this.listOfDots.forEach(function (dot) {
				_this.addDot(dot);
			});

			this.polygonObj = new google.maps.Polygon({
				draggable: true,
				editable: options['editable'] || false,
				paths: this.coords,
				strokeOpacity: options['strokeOpacity'] || 0.8,
				strokeWeight: options['strokeWeight'] || 2,
				fillOpacity: options['fillOpacity'] || 0.35,
				fillColor: color,
				strokeColor: color,
				map: this.map
			});

			this._addListeners();
		}

		_createClass(Polygon, [{
			key: 'getData',
			value: function getData() {
				var data = new Array();
				var paths = this.getPlots();

				paths.getAt(0).forEach(function (path) {
					data.push({ lat: path.A, lng: path.F });
				});
				return data;
			}
		}, {
			key: 'getPolygonObj',
			value: function getPolygonObj() {
				return this.polygonObj;
			}
		}, {
			key: 'getListOfDots',
			value: function getListOfDots() {
				return this.listOfDots;
			}
		}, {
			key: 'getPlots',
			value: function getPlots() {
				return this.polygonObj.getPaths();
			}
		}, {
			key: 'isEditable',
			value: function isEditable() {
				return this.polygonObj.editable;
			}
		}, {
			key: 'setColor',
			value: function setColor() {
				var color = arguments[0] === undefined ? '#f00' : arguments[0];

				this.polygonObj.setOptions({
					fillColor: color,
					strokeColor: color
				});
			}
		}, {
			key: 'setEditable',
			value: function setEditable(editable) {
				this.polygonObj.setOptions({
					editable: editable,
					draggable: editable
				});
			}
		}, {
			key: 'setMap',
			value: function setMap(map) {
				this.map = map;
				this.polygonObj.setMap(this.map);
			}
		}, {
			key: 'addDot',
			value: function addDot(value) {
				var latLng = value instanceof _Dot['default'] ? value.latLng : value;
				this.coords.push(latLng);
			}
		}, {
			key: 'select',
			value: function select() {
				this.setEditable(true);
				this._trigger('polygon_selected', this);
			}
		}, {
			key: 'deselect',
			value: function deselect() {
				this.setEditable(false);
				this._trigger('polygon_deselected', this);
			}
		}, {
			key: 'remove',
			value: function remove() {
				this.polygonObj.setMap(null);
				this._removeListeners();
				this._trigger('polygon_removed', this);
			}
		}, {
			key: 'on',
			value: function on(event_name, callback) {
				this.callbacks[event_name] = callback;
			}
		}, {
			key: '_trigger',
			value: function _trigger() {
				if (arguments.length == 0) {
					return true;
				}

				var args = [];
				Array.prototype.push.apply(args, arguments);

				var event_name = args.shift();
				if (this.callbacks[event_name] !== null && this.callbacks[event_name] !== undefined) {
					return this.callbacks[event_name].apply(this.callbackContext, args);
				} else {
					return true;
				}
			}
		}, {
			key: '_addListeners',
			value: function _addListeners() {
				var _this2 = this;

				var polygonPath = this.polygonObj.getPath();

				this.events.push(google.maps.event.addListener(polygonPath, 'insert_at', function (event) {
					if (!_this2.isDragging) {
						_this2._trigger('polygon_changed', _this2, 'insert');
					}
				}));

				this.events.push(google.maps.event.addListener(polygonPath, 'set_at', function (event) {
					if (!_this2.isDragging) {
						_this2._trigger('polygon_changed', _this2, 'move');
					}
				}));

				this.events.push(google.maps.event.addListener(polygonPath, 'remove_at', function (event) {
					if (!_this2.isDragging) {
						_this2._trigger('polygon_changed', _this2, 'remove');
					}
				}));

				this.events.push(google.maps.event.addListener(this.polygonObj, 'dragstart', function (event) {
					_this2.isDragging = true;
				}));

				this.events.push(google.maps.event.addListener(this.polygonObj, 'dragend', function (event) {
					_this2.isDragging = false;
					_this2._trigger('polygon_changed', _this2, 'drag');
				}));

				this.events.push(google.maps.event.addDomListener(this.polygonObj, 'click', function (event) {
					if (!_this2.isDragging) {
						_this2._trigger('polygon_clicked', _this2, event, false);
					}
				}));

				this.events.push(google.maps.event.addDomListener(this.polygonObj, 'rightclick', function (event) {
					if (event.vertex !== null && event.vertex !== undefined) {
						if (polygonPath.length == 2) {
							_this2.remove();
						} else {
							polygonPath.removeAt(event.vertex);
						}
					} else {
						_this2._trigger('polygon_clicked', _this2, event, true);
					}
				}));
			}
		}, {
			key: '_removeListeners',
			value: function _removeListeners() {
				this.events.forEach(function (event) {
					google.maps.event.removeListener(event);
				});

				this.events = new Array();
			}
		}]);

		return Polygon;
	})();

	module.exports = Polygon;
});