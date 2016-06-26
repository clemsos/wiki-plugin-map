###
 * Federated Wiki : Map Plugin
 *
 * Licensed under the MIT license.
 * https://github.com/fedwiki/wiki-plugin-map/blob/master/LICENSE.txt
###


escape = (line) ->
  line
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')

resolve = (text) ->
  if wiki?
    wiki.resolveLinks(text, escape)
  else
    escape(text)
      .replace(/\[\[.*?\]\]/g,'<internal>')
      .replace(/\[.*?\]/g,'<external>')

marker = (text) ->
  deg = (m) ->
    num = +m[0] + m[1]/60 + (m[2]||0)/60/60
    if m[3].match /[SW]/i then -num else num
  decimal = /^(-?\d{1,3}\.\d*),? *(-?\d{1,3}\.\d*)\s*(.*)$/
  nautical = /^(\d{1,3})°(\d{1,2})'(\d*\.\d*)?"?([NS]) (\d{1,3})°(\d{1,2})'(\d*\.\d*)?"?([EW]) (.*)$/i
  return {lat: +m[1], lon: +m[2], label: resolve(m[3])} if m = decimal.exec text
  return {lat: deg(m[1..4]), lon: deg(m[5..8]), label: resolve(m[9])} if m = nautical.exec text
  null

parse = (text) ->
  captions = []
  markers = []
  for line in text.split /\n/
    if m = marker line
      markers.push m
    else
      captions.push resolve(line)
  {markers, caption: captions.join('<br>')}

emit = ($item, item) ->

  if (!$("link[href='http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css']").length)
    $('<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css">').appendTo("head")
  if (!$("link[href='/plugins/map/map.css']").length)
    $('<link rel="stylesheet" href="/plugins/map/map.css" type="text/css">').appendTo("head")

  wiki.getScript "http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.js", ->

    mapId = "map-#{Math.floor(Math.random()*1000000)}"

    {caption, markers} = parse item.text

    $item.append """
      <figure style="padding: 8px;">
        <div id="#{mapId}" style='height: 300px;'></div>
        <p class="caption">#{caption}</p>
      </figure>
    """

    map = L.map(mapId).setView(item.latlng || [40.735383, -73.984655], item.zoom || 13)

    # disable double click zoom - so we can use double click to start edit
    map.doubleClickZoom.disable()

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
      attribution: '<a href="http://osm.org/copyright">OSM</a>'
      }).addTo(map)

    # add markers on the map
    for p in markers
      L.marker([p.lat, p.lon])
        .bindPopup(p.label)
        .openPopup()
        .addTo(map);


bind = ($item, item) ->
  $item.dblclick ->
    wiki.textEditor $item, item


window.plugins.map = {emit, bind} if window?
module.exports = {marker} if module?
