---
---
@dayofWeekChart = ->
  width = 700
  height = 20
  cellSize = 17
  xTicks = 3
  defaultEmpty = 0
  paddingDays = 5
  weekDayPadding = 70
  weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
  tooltipElement = 'body'
  hour = d3.timeFormat('%H')
  weekday = d3.timeFormat('%w')
  weekdayText = d3.timeFormat('%A')
  time = d3.timeFormat("%I %p")
  valueKey = "count"
  dateKey = "date"
  emptyValue = 0
  yValue = (d) ->
    weekDays[weekday(d.key)]

  xValue = (date) ->
    dowHFormat = d3.timeFormat("%w %H")
    entry = _.filter(this, (d) -> dowHFormat(d[dateKey]) == dowHFormat(date))
    d3.sum(entry, (d) -> d[valueKey]) if entry

  tooltipTemplate = (d) ->
    "<h2>#{d.key}</h2><p>#{d.value || emptyValue}</p>"

  dayOfWeekScale = d3.scaleOrdinal().domain([0...6]).range(weekDays)
  startDate = new Date(2015,4,3)
  cDomain = [-.05, .05]
  color = d3.scaleQuantize().domain(cDomain).range(d3.range(9).map((d) -> 'q' + d + '-9'))

  timeScaleDomain = d3.timeHours(startDate, d3.timeDay.offset(startDate,1))

  timescale = d3.scaleTime()
  .nice(d3.timeDay)
  .domain(timeScaleDomain)
  .range([0, cellSize*24])

  classValue = (d) ->
    "hour #{color(parseFloat(d.value || emptyValue))}"

  nestHour = (h, newDate, data) ->
    hourDate = d3.timeHour.offset(newDate, h)
    {
      "key": hourDate
      "value": xValue.call(data, hourDate)
    }
  nestDate = (dow, data) ->
    newDate = d3.timeDay.offset(startDate,dow)
    {
      "key": newDate
      "values": (nestHour(h, newDate, data) for h in [0..23])
    }

  mapData = (data) ->
    nData = (nestDate(dow, data) for dow in [0..6])
    nData

  chart = (selection) ->
    selection.each (data,i) ->
      data = mapData(data)

      color.domain(cDomain)
      timeScaleDomain = d3.timeHours(startDate, d3.timeDay.offset(startDate,1))
      timescale
        .domain([startDate, d3.timeDay.offset(startDate,1)])
        .range([0, cellSize*24])
      svg = d3.select(this).selectAll('svg').data(data)

      gEnter = svg.enter().append('svg').merge(svg).attr('width', width).attr('height', height).append('g')
        .attr('transform', "translate(#{weekDayPadding}, #{paddingDays})")
        .attr('class', 'YlOrRd')

      g = svg.merge(gEnter)
      labelText = g.selectAll('text.day-of-week').data((d) -> [d])
      labelText.enter().append('text').attr('class', 'day-of-week')
        .attr('transform', "translate(-#{weekDayPadding}, #{paddingDays*2})")
        .text(yValue)
      rect = g.selectAll('.hour').data((d) ->
        d.values
      )
      rect.enter().append('rect').attr('width', cellSize).attr('height', cellSize).attr('x', (d) ->
        hour(d.key)*cellSize
      ).attr('y', 0)
      .on("mouseout", (d) ->
        d3.select(this).classed("active", false)
        d3.select('#tooltip').style("opacity", 0)
      ).on("mousemove", (d) ->
        d3.select("#tooltip").style("left", (d3.event.pageX + 14) + "px")
        .style("top", (d3.event.pageY - 32) + "px")
      )
      .merge(rect).attr('class', classValue)
      .on("mouseover", (d) ->
        d3.select('#tooltip').html(tooltipTemplate.call(this, d)).style("opacity", 1)
        d3.select(this).classed("active", true)
      )
      hoursAxis = d3.axisTop(timescale)
      .ticks(d3.timeHour.every(xTicks))
      .tickFormat(time)
      hoursg = g.append('g')
      .classed('axis', true)
      .classed('hours', true)
      .classed('labeled', true)
      .attr("transform", "translate(0,-10.5)")
      .call(hoursAxis)
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
  chart.color = (value) ->
    unless arguments.length
      return color
    color = value
    chart
  chart.weekDays = (value) ->
    unless arguments.length
      return weekDays
    weekDays = value
    chart
  chart.xTicks = (value) ->
    unless arguments.length
      return xTicks
    xTicks = value
    chart
  chart.weekDayPadding = (value) ->
    unless arguments.length
      return weekDayPadding
    weekDayPadding = value
    chart
  chart.xValue = (value) ->
    unless arguments.length
      return xValue
    xValue = value
    chart
  chart.startDate = (value) ->
    unless arguments.length
      return startDate
    startDate = value
    chart
  chart.dateKey = (value) ->
    unless arguments.length
      return dateKey
    dateKey = value
    chart
  chart.valueKey = (value) ->
    unless arguments.length
      return valueKey
    valueKey = value
    chart
  chart.colorDomain = (value) ->
    unless arguments.length
      return colorDomain
    cDomain = value
    chart
  chart.mapData = (value) ->
    unless arguments.length
      return mapData
    mapData = value
    chart
  chart.classValue = (value) ->
    unless arguments.length
      return classValue
    classValue = value
    chart
  chart.yValue  = (value) ->
    unless arguments.length
      return yValue
    yValue = value
    chart
  chart.tooltipTemplate = (value) ->
    unless arguments.length
      return tooltipTemplate
    tooltipTemplate = value
    chart
  chart
