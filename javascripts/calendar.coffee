---
---
@calendarChart = ->
  width = 960
  height = 136
  cellSize = 17
  formatPercent = d3.format('.1%')
  cRange = ['#ffffe5','#fff7bc','#fee391','#fec44f','#fe9929','#ec7014','#cc4c02','#993404','#662506']
  color = d3.scaleQuantize().domain([
    6
    0
  ]).range(cRange)
  years = d3.range(2015,2018)
  pathMonth = (t0) ->
    t1 = new Date(t0.getFullYear(), t0.getMonth() + 1, 0)
    d0 = t0.getDay()
    w0 = d3.timeWeek.count(d3.timeYear(t0), t0)
    d1 = t1.getDay()
    w1 = d3.timeWeek.count(d3.timeYear(t1), t1)
    'M' + (w0 + 1) * cellSize + ',' + d0 * cellSize + 'H' + w0 * cellSize + 'V' + 7 * cellSize + 'H' + w1 * cellSize + 'V' + (d1 + 1) * cellSize + 'H' + (w1 + 1) * cellSize + 'V' + 0 + 'H' + (w0 + 1) * cellSize + 'Z'
  chart = (selection) ->
    selection.each (data,i) ->
      #color.domain([0,d3.max(d3.values(data))])
      color.range(cRange)
      color.domain([0,100])
      svg = d3.select(this).selectAll('svg').data(years)
      gEnter = svg.enter().append('svg').merge(svg).attr('width', width).attr('height', height).append('g')
      .attr("transform", "translate(" + ((width - cellSize * 53) / 2) + "," + (height - cellSize * 7 - 1) + ")")
      gEnter.merge(gEnter).append('text').attr('transform', 'translate(-6,' + cellSize * 3.5 + ')rotate(-90)').attr('font-family', 'sans-serif').attr('font-size', 10).attr('text-anchor', 'middle').text (d) ->
        d

      rect = gEnter.merge(gEnter).append('g').attr('fill', 'none').attr('stroke', '#ccc').selectAll('rect').data((d) ->
        d3.timeDays new Date(d, 0, 1), new Date(d + 1, 0, 1)
      ).enter().append('rect').attr('width', cellSize).attr('height', cellSize).attr('x', (d) ->
        d3.timeWeek.count(d3.timeYear(d), d) * cellSize
      ).attr('y', (d) ->
        d.getDay() * cellSize
      ).datum(d3.timeFormat('%Y-%m-%d'))
      gEnter.merge(gEnter).append('g').attr('fill', 'none').attr('stroke', '#000').selectAll('path').data((d) ->
        d3.timeMonths new Date(d, 0, 1), new Date(d + 1, 0, 1)
      ).enter().append('path').attr 'd', pathMonth
      rect.merge(rect).filter((d) ->
        d of data
      ).attr('fill', (d) ->
        color data[d]
      ).append('title').text (d) ->
        d + ': ' + data[d]
  chart.cellSize = (value) ->
    unless arguments.length
      return cellSize
    cellSize = value
    chart
  chart.height = (value) ->
    unless arguments.length
      return height
    height = value
    chart
  chart.width = (value) ->
    unless arguments.length
      return width
    width = value
    chart
  chart.yearRange = (value) ->
    unless arguments.length
      return years
    years = value
    chart
  chart.color = (value) ->
    unless arguments.length
      return color
    color = value
    chart
  chart.colorDomain = (value) ->
    unless arguments.length
      return colorDomain
    cDomain = value
    chart
  chart.colorRange = (value) ->
    unless arguments.length
      return cRange
    cRange = value
    chart
  chart
