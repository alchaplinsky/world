lastPoint = [0, 0]
currentCountryId = ''
lastCountryId = ''
countryBoxFadeOut = false

@WorldMap = (selector) ->
  config=
    id: 'map1'
    inactiveCountryOpacity: 1.0
    inactiveCountryFill: '#bbb'
    inactiveCountryStroke: '#fff'
    inactiveCountryStrokeWidth: 3
    selector: '#svgWorldMap1'
    scale: 0.45
    activeCountryOpacity: 1.0
    activeCountryFill: '#0098D8'
    activeCountryStroke: '#fff'
    activeCountryStrokeWidth: 3

    showCountryBoxOnMouserEnter: true
    onCountryMouseClick: (countryId)->
      id = countryId

    margin: '0'
    height: '620'
    width: '100%'
    
    svg: $(selector).svg('get')

  $(selector).css('margin', config.margin)
  $(selector).css('height', config.height)
  $(selector).css('width', config.width)

  config.countryId = 0 if (!config.countryId)
      
  $(config.selector).svg 
    id: 'worldMap'
    onLoad: (svg) ->
      createPaths(svg, config)
        
@createPaths = (svg, config) ->
  createSouthAmerica(svg, config)
  createCentralAmerica(svg, config)
  createNorthAmerica(svg, config)
  createAfrica(svg, config, [29.90172, 45.07447])
  createAsia(svg, config, [29.90172, 45.07447])
  createEurope(svg, config, [29.90172, 45.07447])
  createOceania(svg, config)
  createTextBox(config, svg)

@createTextBox = (config, svg) ->
  g = svg.group({ id: config.id + 'box', opacity: 0.0 })
  pathString = 'M-100,0 L60,0 L60,20 L-100,20 L-100,0'
  svg.path(g, pathString, { fill: '#000', stroke: '#000', strokeWidth: 1, transform: 'translate(5,5)', opacity: 0.5 })
  svg.path(g, pathString, { fill: '#000', stroke: '#000', strokeWidth: 1 })
  svg.text(g, -20, 15, '', { id: config.id + 'txtBox', fill: 'white', fontFamily: 'Verdana',  textAnchor: 'middle' })

@hideCountryBox = (config, svg) ->
  box = $('#' + config.id + 'box', svg.root())
  $(box).stop()
  $(box).animate({'opacity': 0 }, 500)
  countryBoxFadeOut = true

@showCountryBox = (config, svg) ->
  box = $('#' + config.id + 'box')
  $(box).stop()
  $(box).show().css('opacity', 1)
  countryBoxFadeOut = false
  
@drawCountries = (svg, config, countries, translate) ->
  for country in countries
    translate = [0, 0] if (!translate)

    if (country.translate)
      g = svg.group 
        id: country.id
        fill: config.inactiveCountryFill
        stroke: config.inactiveCountryStroke
        strokeWidth: config.inactiveCountryStrokeWidth
        transform: 'translate(' + (country.translate[0] + translate[0]) * config.scale + ',' + (country.translate[1] + translate[1]) * config.scale + ') scale(' + config.scale + ',' + config.scale + ')'
    else
      g = svg.group
        id: country.id
        fill: config.inactiveCountryFill
        stroke: config.inactiveCountryStroke
        strokeWidth: config.inactiveCountryStrokeWidth
        transform: 'translate(' + (translate[0]) * config.scale + ',' + (translate[1]) * config.scale + ') scale(' + config.scale + ',' + config.scale + ')'

    defs = svg.defs(g)
    for cpath in country.pathCollection 
      splitted = cpath.split(' ')
      path = svg.createPath()
      index = 0
      while (index < splitted.length)
        command = splitted[index]
        switch (command)
          when 'M'
            moveconfig1 = splitted[index + 1].split(',')
            path.move(moveconfig1[0], moveconfig1[1])
            index += 2
            
          when 'C'
            curveCconfig1 = splitted[index + 1].split(',')
            curveCconfig2 = splitted[index + 2].split(',')
            curveCconfig3 = splitted[index + 3].split(',')
            path.curveC(curveCconfig1[0], curveCconfig1[1], curveCconfig2[0], curveCconfig2[1], curveCconfig3[0], curveCconfig3[1])
            index += 4
          when 'L'
            lineconfig1 = splitted[index + 1].split(',')
            path.line(lineconfig1[0], lineconfig1[1])
            index += 2

      svg.path(g, path, { id: country.id, countryId: country.id })
      
    $('#' + country.id).bind 'mouseover', (e) ->
      $('#' + config.id + 'box').attr('transform', 'translate(' + e.pageX + ' ' + e.pageY + ')')
      g = e.target.parentNode
      $(g).attr('opacity', config.activeCountryOpacity)
      $(g).attr('fill', config.activeCountryFill)
      $(g).attr('stroke', config.activeCountryStroke)
      $(g).attr('strokeWidth', config.activeCountryStrokeWidth)
      config.countryId = e.target.id
      config.pos = [e.pageX, e.pageY]
      lastCountryId = currentCountryId
      currentCountryId = config.countryId
      
      showCountryBox(config, svg)
      box = $('#' + config.id + 'box', svg.root())
      $(box).stop()
      $(box).animate({ svgOpacity: 1.0 }, 100)
      txt = $('#' + config.id + 'txtBox', svg.root())
      config.countryId = 'do' if config.countryId is 'dom'
      name = countriesArray[config.countryId]["name"]
      txt[0].textContent = name.toUpperCase()


    $('#' + country.id).bind 'mouseout', (e) ->
      g = e.target.parentNode
      $(g).attr('fill', config.inactiveCountryFill)
      $(g).attr('opacity', config.inactiveCountryOpacity)
      $(g).attr('stroke', config.inactiveCountryStroke)
      $(g).attr('strokeWidth', config.inactiveCountryStrokeWidth)
      $('#' + config.id + 'box').stop()
      hideCountryBox(config, svg)


    $('#' + country.id).bind 'click', (path) ->
      g = path.target.parentNode
      document.location.href = "/#{countriesArray[config.countryId]['slug']}"