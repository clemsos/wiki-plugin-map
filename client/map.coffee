uniqueId = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

window.plugins.map =

  bind: (div, item) ->
  emit: (div, item) ->
    if (!$("link[href='http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css']").length)
      $('<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css">').appendTo("head")
    wiki.getScript "http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.js", ->
      div.css 'height', '300px'
      mapId = 'map-' + uniqueId()
      div.attr 'id', mapId

      map = L.map(mapId).setView(item.latlng || [40.735383, -73.984655], item.zoom || 13)

      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map)

      map.on 'blur', (e) ->
        item.latlng = map.getCenter()
        item.zoom = map.getZoom()
        plugins.map.save(div, item)
        
  save: (div, item) ->
    wiki.pageHandler.put div.parents('.page:first'),
      type: 'edit',
      id: item.id,
      item: item