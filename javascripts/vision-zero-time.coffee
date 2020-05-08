---
---
timeParser = d3.timeParse("%Y-%m-%d %H:%M:%S")
hourFormat = d3.timeFormat('%I %p')
dowHFormat = d3.timeFormat("%w")
dowFormat = d3.timeFormat("%A")

killed = (d) ->
  parseInt(d.killed)

injured = (d) ->
  parseInt(d.injured)

accidents = (d) ->
  parseInt(d.accidents)

killedInjured = (d) ->
  parseInt(d.killed)+parseInt(d.injured)

killedInjuredPerAccident = (d) ->
  (parseInt(d.killed)+parseInt(d.injured))/parseInt(d.accidents)

injuredAccidentsPercentage = (d) ->
  (parseInt(d.accidents_injured)/parseInt(d.accidents))


sumKilled = (data) ->
  d3.sum(data, killed)

sumInjured = (data) ->
  d3.sum(data, injured)

sumKilledInjured = (data) ->
  d3.sum(data, killedInjured)

nestDate = (dow, data, valueKey) ->
  startDate = new Date(2015,4,3)
  newDate = d3.timeDay.offset(startDate,dow)
  dowHFormat = d3.timeFormat("%w")
  entry = _.filter(data, (d) -> dowHFormat(d.date) == dowHFormat(newDate))
  value = d3.sum(entry, (d) -> d[valueKey]) if entry
  {
    "key": newDate
    "value": value
  }

mapDateData = (data, valueyKey) ->
  startDate = new Date(2015,4,3)
  [ {
    "key": startDate,
    "values": (nestDate(dow, data, valueyKey) for dow in [0..6])
  }]

createDoWData = (data, rollup = sumKilledInjured) ->
  d3.nest()
    .key( (d) -> d.date)
    .rollup(rollup)
    .entries(data)
createDowChart = (startDate,data, extent) ->
	dayofWeekChart().valueKey("value").startDate(startDate).colorDomain(extent)
dayData = (data, rollup) ->
  dateData = d3.nest()
    .key( (d) -> d.day)
    .rollup(rollup)
    .object(data)

dataForDateRange = (data, startDate, endDate, type = killedInjured) ->
  d3.sum(data, (d) ->
    currentDate = timeParser(d.date_hour)
    if(currentDate <= endDate && currentDate >= startDate)
      return type(d)
    0
  )

changeNeighborhoodData = (data, beatId) ->
  beatData = _.filter(data, (d) -> d.police_beat == beatId)
  beatData2016 = _.find(beatData, (d) -> d.year == "2016")
  beatData2015 = _.find(beatData, (d) -> d.year == "2015")
  beatData2017 = _.find(beatData, (d) -> d.year == "2017")

  d3.selectAll('.neighborhood').text(beatData[0].Neighborhood)
  d3.selectAll('.neighborhood-accidents').text(beatData2017.accidents)
  d3.selectAll('.neighborhood-injured').text(beatData2017.injured)
  d3.selectAll('.neighborhood-killed').text(beatData2017.killed)
  if beatData2016.accidents > beatData2015.accidents
    d3.select('.neighborhood-more-less-years').text("more (#{beatData2016.accidents-beatData2015.accidents})")
  else if beatData2016.accidents == beatData2015.accidents
    d3.select('.neighborhood-more-less-years').text("equal (#{beatData2016.accidents-beatData2015.accidents})")
  else
    d3.select('.neighborhood-more-less-years').text("less (#{beatData2016.accidents-beatData2015.accidents})")
  if beatData2016.killed > beatData2015.killed
    d3.select('.neighborhood-more-less-years-killed').text("more (#{beatData2016.killed-beatData2015.killed})")
  else if beatData2016.killed == beatData2015.killed
    d3.select('.neighborhood-more-less-years-killed').text("equal (#{beatData2016.killed-beatData2015.killed})")
  else
    d3.select('.neighborhood-more-less-years-killed').text("less (#{beatData2016.killed-beatData2015.killed})")

  accidentsNeighborhoodSpec = { "$schema": "https://vega.github.io/schema/vega-lite/v2.json", "description": "A simple bar chart with embedded data.", "data": { "values": beatData }, "mark": "bar", "encoding": { "y": {"field": "year", "type": "ordinal", "axis": { "title": ""}}, "x": {"field": "accidents", "type": "quantitative", "axis": { "title": "# accidents"}} } }
  killedNeighborhoodSpec = { "$schema": "https://vega.github.io/schema/vega-lite/v2.json", "description": "A simple bar chart with embedded data.", "data": { "values": beatData }, "mark": "bar", "encoding": { "y": {"field": "year", "type": "ordinal", "axis": { "title": ""}}, "x": {"field": "killed", "type": "quantitative", "axis": { "title": "# people killed"}} } }
  opt = { "mode": "vega-lite", actions: false }
  vega.embed("#killed-neighborhood-graph", killedNeighborhoodSpec, opt)
  vega.embed("#accidents-neighborhood-graph", accidentsNeighborhoodSpec, opt)

thisYear = (new Date()).getFullYear()

@showTimeRelatedData = () =>
  ready = (error, results) ->
    killedInjuredByYear = results[0]
    killedInjuredByYearAndPoliceBeat = results[1]
    fullHourAccidents = results[2]
    accidentsData = results[3]
    killedData2017 = _.find(killedInjuredByYear, (d) -> d.year == "#{thisYear}")
    killed2017 = parseInt(killedData2017.killed)

    totalAccidents = parseInt(killedData2017.accidents)
    killsPerAccicents = d3.format(".2")(killed2017/totalAccidents)
    lastDate = d3.max(fullHourAccidents, (d) -> timeParser(d.date_hour))
    lastDateLastYear = d3.timeYear.offset(lastDate,-1)
    killed2015CurrentDate = dataForDateRange(fullHourAccidents, new Date(2015,0,1),d3.timeYear.offset(lastDate,-2), killed)
    killed2016CurrentDate = dataForDateRange(fullHourAccidents, new Date(2016,0,1), lastDateLastYear, killed)
    killed2016 = dataForDateRange(fullHourAccidents, new Date(2016,0,1), new Date(2016,12,31), killed)
    currentNumberOfDays = d3.timeDay.count(d3.timeYear(lastDate), lastDate)
    yearKilled2017 = killed2017/currentNumberOfDays*365

    dayFormat = d3.timeFormat('%Y-%m-%d')
    yearFormat = d3.timeFormat('%Y')
    d3.map(accidentsData, (d) ->
      d.date = new Date(2016,0,1,d.hour)
      d.day = dayFormat(d.date)
      d.year = yearFormat(d.date)
    )

    maxInjured = d3.max(accidentsData, (d) -> parseInt(d.injured))
    maxAccidents = d3.max(accidentsData, (d) -> parseInt(d.accidents))
    maxKilled = d3.max(accidentsData, (d) -> parseInt(d.killed))
    maxWeighted = d3.max(accidentsData, (d) -> parseInt(d.weighted))

    nestHour = (h, newDate, data, valueKey, valueFn) ->
      if not valueFn
        valueFn = (d) -> d[valueKey]
      hourDate = d3.timeHour.offset(newDate, h)
      entry = _.find(data, (d) -> parseInt(d.hour) == h)
      {
        "key": hourDate
        "value": if entry then valueFn(entry) else 0
        "name": valueKey
      }
    newDate = new Date(2016,0,1,0)
    accidentsPerHour = (data) ->
      {
        "key": newDate
        "name": "Collissions"
        "values": (nestHour(h, newDate, data, "accidents", accidents) for h in [0..23])
      }
    injuredPerHour = (data) ->
      {
        "key": newDate
        "name": "Injured"
        "values": (nestHour(h, newDate, data, "injured", injured) for h in [0..23])
      }
    killedPerHour = (data) ->
      {
        "key": newDate
        "name": "Killed"
        "values": (nestHour(h, newDate, data, "killed", killed) for h in [0..23])
      }
    killedInjuredPerAccidentPerHour = (data) ->
      {
        "key": newDate
        "name": ""
        "values": (nestHour(h, newDate, data, "accidents_injured", injuredAccidentsPercentage) for h in [0..23])
      }
    mapAccidentsData = (data) ->
      [accidentsPerHour(data)]
    mapInjuredData = (data) ->
      [injuredPerHour(data)]
    mapKilledData = (data) ->
      [killedPerHour(data)]
    mapKilledInjuredPerAccidentData = (data) ->
      [killedInjuredPerAccidentPerHour(data)]
    mapData = (data) ->
      [accidentsPerHour(data), injuredPerHour(data), killedPerHour(data),
        {
          "key": newDate
          "name": "Weighted"
          "values": (nestHour(h, newDate, data, "weighted") for h in [0..23])
        }
      ]

    yValue = (d) -> d.name
    color = d3.scaleQuantize().domain([0,maxAccidents]).range(d3.range(9).map((d) -> 'q' + d + '-9'))
    classValue = (d) ->
      c = switch d.name
        when "injured"
          color.domain([0,maxInjured])
        when "killed"
          color.domain([0,maxKilled])
        when "weighted"
          color.domain([0,maxWeighted])
        else
          color.domain([0,maxAccidents])
      "hour #{color(parseInt(d.value || emptyValue))}"

    tooltipTemplate = (d) ->
      explanation = d.name
      if d.name is "injured"
        explanation = "injuries"
      if d.name is "accidents"
        explanation = "collisions"
      if d.name is "killed"
        explanation = "fatalities"
      "<h2>#{hourFormat(d.key)}</h2><p>#{parseInt(d.value) || 0} #{explanation}</p>"

    tooltipTemplatePerAccident = (d) ->
      percentFormat = d3.format('.2%')
      "<h2>#{hourFormat(d.key)}</h2><p>#{percentFormat(d.value) || "0%"} of collisions resulted in an injury</p>"

    dowTooltipTemplate = (d) ->
      weekdayFormat = d3.timeFormat('%A')
      "<h2>#{weekdayFormat(d.key)}</h2><p>#{parseInt(d.value) || 0}</p>"


    accidentsChart = () =>
      data = mapAccidentsData(accidentsData)
      mapData = (data) -> data
      maxEntry = _.find(data[0].values, {value: maxAccidents})
      timeEdges = findTimeEdges(data[0].values)
      d3.selectAll('.most-collisions-start-hour').text(hourFormat(timeEdges.min))
      d3.selectAll('.most-collisions-end-hour').text(hourFormat(timeEdges.max))
      d3.selectAll('.number-of-collisions').text(d3.sum(data[0].values.map((d) -> d.value)))

      #d3.select('.most-collisions-hour').text(hourFormat(maxEntry.key))
      dowChartAccidents = dayofWeekChart().valueKey("accidents").startDate(new Date(2016,0,1)).colorDomain([0,maxAccidents]).mapData(mapData).yValue(yValue).tooltipTemplate(tooltipTemplate)
      d3.select('#dow-chart-accidents').data([data]).call(dowChartAccidents)

    injuredChart = () =>
      data = mapInjuredData(accidentsData)
      mapData = (data) -> data
      timeEdges = findTimeEdges(data[0].values)
      d3.selectAll('.most-injuries-start-hour').text(hourFormat(timeEdges.min))
      d3.selectAll('.most-injuries-end-hour').text(hourFormat(timeEdges.max))
      dowChartInjuries = dayofWeekChart().valueKey("injured").startDate(new Date(2016,0,1)).colorDomain([0,maxInjured]).mapData(mapInjuredData).yValue(yValue).tooltipTemplate(tooltipTemplate)
      d3.select('#dow-chart-injuries').data([accidentsData]).call(dowChartInjuries)
    killedChart = () =>
      data = mapKilledData(accidentsData)
      timeEdges = findTimeEdges(data[0].values)
      d3.selectAll('.most-fatalities-start-hour').text(hourFormat(timeEdges.min))
      d3.selectAll('.most-fatalities-end-hour').text(hourFormat(timeEdges.max))
      dowChartKilled = dayofWeekChart().valueKey("killed").startDate(new Date(2016,0,1)).colorDomain([0,maxKilled]).mapData(mapKilledData).yValue(yValue).tooltipTemplate(tooltipTemplate)
      d3.select('#dow-chart-killed').data([accidentsData]).call(dowChartKilled)
    killedInjuredChart = () =>
      #get max and update most-per-accident
      data = mapKilledInjuredPerAccidentData(accidentsData)
      timeEdges = findTimeEdges(data[0].values, 0.2, 1)
      max = d3.max(data[0].values, (d) -> d.value)
      maxEntry = _.find(data[0].values, { value: max})
      d3.selectAll('.most-dangerous-start-hour').text(hourFormat(timeEdges.min))
      d3.selectAll('.most-dangerous-end-hour').text(hourFormat(timeEdges.max))
      d3.selectAll('.most-per-accident').text(hourFormat(maxEntry.key))
      d3.selectAll('.most-per-accident-percent').text(d3.format(".0%")(maxEntry.value))
      dowChartKilledInjuredPerAccident = dayofWeekChart().valueKey("killed").startDate(new Date(2016,0,1)).colorDomain([0,0.6]).mapData(mapKilledInjuredPerAccidentData).yValue(yValue).tooltipTemplate(tooltipTemplatePerAccident)
      d3.select('#dow-chart-killed-injured-per-accident').data([accidentsData]).call(dowChartKilledInjuredPerAccident)

    singleInjuredChart = () =>
      d3.map(fullHourAccidents, (d) ->
        d.date = timeParser(d.date_hour)
      )
      hourAccidentsData = mapDateData(fullHourAccidents, 'injured')
      injuredMax = d3.max(hourAccidentsData[0].values, (d) -> d.value)
      injuredMin = d3.min(hourAccidentsData[0].values, (d) -> d.value)
      maxEntry = _.find(hourAccidentsData[0].values, { value: injuredMax})
      d3.selectAll('.most-injuries-weekday').text(dowFormat(maxEntry.key))
      d3.selectAll('.most-injuries-weekday-amount').text(maxEntry.value)

      dowTInjured = dayofWeekSingleChart().valueKey("injured").colorDomain([injuredMin,injuredMax]).tooltipTemplate(dowTooltipTemplate).yValue((d) -> 'Injured')
      d3.select('#dow-chart-single-injured').data([fullHourAccidents]).call(dowTInjured)
    singleAccidentsChart = () =>
      hourAccidentsData = mapDateData(fullHourAccidents, 'accidents')
      accidentsMax = d3.max(hourAccidentsData[0].values, (d) -> d.value)
      accidentsMin = d3.min(hourAccidentsData[0].values, (d) -> d.value)
      maxEntry = _.find(hourAccidentsData[0].values, { value: accidentsMax})
      d3.selectAll('.most-collisions-weekday').text(dowFormat(maxEntry.key))
      d3.selectAll('.most-collisions-weekday-amount').text(maxEntry.value)

      dowT = dayofWeekSingleChart().valueKey("accidents").colorDomain([accidentsMin,accidentsMax]).tooltipTemplate(dowTooltipTemplate).yValue((d) -> 'Collisions')
      d3.select('#dow-chart-single').data([fullHourAccidents]).call(dowT)

    hodChart = () =>
      dowHofD = dayofWeekChart().valueKey("accidents").colorDomain([0,400])
      d3.select('#dow-hod-chart').data([fullHourAccidents]).call(dowHofD)

    hodInjuredChart = () =>
      dowHofDInjured = dayofWeekChart().valueKey("injured").colorDomain([0,220])
      d3.select('#dow-hod-chart-injured').data([fullHourAccidents]).call(dowHofDInjured)

    setTimeout(injuredChart, 500)
    setTimeout(accidentsChart, 500)
    setTimeout(killedChart, 600)
    setTimeout(killedInjuredChart, 700)
    setTimeout(singleInjuredChart, 700)
    setTimeout(singleAccidentsChart, 800)
    #setTimeout(hodChart, 2400)
    #setTimeout(hodInjuredChart, 2600)

  d3.queue(2)
    .defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_injured_b_year.csv")
    .defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_injured_b_year_police_beat.csv")
    .defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/full_hour_accidents.csv")
    .defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/per_hour_accidents.csv")
    .awaitAll(ready)
