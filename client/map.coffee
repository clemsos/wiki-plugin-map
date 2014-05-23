uniqueId = (length=8) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length

window.plugins.map =

  bind: (div, item) ->
  emit: (div, item) ->
    if (!$("link[href='http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css']").length)
      $('<link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.css">').appendTo("head")
    if (!$("link[href='/plugins/map/map.css']").length)
      $('<link rel="stylesheet" href="/plugins/map/map.css" type="text/css">').appendTo("head")
    wiki.getScript "http://cdn.leafletjs.com/leaflet-0.7.2/leaflet.js", ->
      mapId = 'map-' + uniqueId()
      figure = $("<figure></figure>")
        .focusout ->
          return if !figure.hasClass 'mapEditing'
          # for some reason we also get here by clicking on the textarea
          #  - need to add something here to ignore clicks on textarea

          if item.latlng isnt map.getCenter() || item.zoom isnt map.getZoom() || item.text isnt $("textarea").val()
            # something has been changed, so lets save
            item.latlng = map.getCenter()
            item.zoom = map.getZoom()
            item.text = $("textarea").val()

            # save the new position, and caption, but only if
            plugins.map.save(div, item)

          figure.find("textarea").replaceWith( "<figcaption>#{wiki.resolveLinks(item.text)}</figcaption>" )

          figure.removeClass 'mapEditing'

          null


        .dblclick ->
          # Double clicking on either map or caption will switch into edit mode.

          # ignore dblclick if we are already editing.
          return if figure.hasClass 'mapEditing'
          figure.addClass 'mapEditing'

          # replace the caption with a textarea
          textarea = $("<textarea>#{original = item.text ? ''}</textarea>")
          figure.find("figcaption").replaceWith( textarea )

          null

        .bind 'keydown', (e) ->
          if (e.altKey || e.ctlKey || e.metaKey) and e.which == 83 #alt-s
            figure.focusout()
            return false
          if (e.altKey || e.ctlKey || e.metaKey) and e.which == 73 #alt-i
            # note: only works if clicked in the textarea 
            e.preventDefault()
            page = $(e.target).parents('.page') unless e.shiftKey
            wiki.doInternalLink "about map plugin", page
            return false

      div.html figure 

      figure.append "<div id='" + mapId + "' style='height: 300px;'></div>"
      
      map = L.map(mapId).setView(item.latlng || [40.735383, -73.984655], item.zoom || 13)

      # disable double click zoom
      map.doubleClickZoom.disable()

      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors'
        }).addTo(map)

      # any old maps will not define item.text, so set a default value
      if !item.text
        item.text = "Map Caption"

      figure.append "<figcaption>#{wiki.resolveLinks(item.text)}</figcaption>"


  save: (div, item) ->
    wiki.pageHandler.put div.parents('.page:first'),
      type: 'edit',
      id: item.id,
      item: item