---
---

STREET_NAME = 'address_road_primary';
STREET_TYPE = 'address_sfx_primary';
STREET_NO = 'address_no_primary';
STREET_DIR = 'address_pd_primary';
CROSS_STREET = 'address_name_intersecting';
CROSS_TYPE = 'address_sfx_intersecting';

killed = (d) ->
  parseInt(d.killed)

injured = (d) ->
  parseInt(d.injured)

killedInjured = (d) ->
  parseInt(d.killed)+parseInt(d.injured)

sumKilled = (data) ->
  d3.sum(data, killed)

sumInjured = (data) ->
  d3.sum(data, injured)

sumKilledInjured = (data) ->
  d3.sum(data, killedInjured)

construct_street_name = (d) ->
  street_name = "#{d[STREET_NAME]} #{d[STREET_TYPE]}"
  if d[CROSS_STREET]
    return "#{street_name} / #{d[CROSS_STREET]} #{d[CROSS_TYPE]}"
  else
    if d[STREET_DIR]
      return "#{d[STREET_NO]} #{d[STREET_DIR]} #{street_name}"
    else
      return "#{d[STREET_NO]} #{street_name}"

thisYear = (new Date()).getFullYear()

ready = (error, results) ->
  summaryByYear = results.shift()
  summary = _.find(summaryByYear, (d) -> d.year == "#{thisYear}")
  lastYearKilled = results[ results.length-1 ]
  lastAccidentKilled = lastYearKilled[ lastYearKilled.length-1]
  lastAccidentAddress = construct_street_name(lastAccidentKilled)
  dateFormat = d3.timeFormat('%B, %d')
  timeFormat = d3.timeFormat('%I %p')
  d3.selectAll('.current-year').text(thisYear)
  d3.selectAll('.lifes-lost').text(summary.killed)
  d3.selectAll('.last-life-lost-date').text(dateFormat(new Date(lastAccidentKilled.date_time)))
  d3.selectAll('.last-life-lost-time').text(timeFormat(new Date(lastAccidentKilled.date_hour)))
  d3.selectAll('.last-life-lost-location').text(lastAccidentAddress)


  dayFormat = d3.timeFormat('%Y-%m-%d')
  yearFormat = d3.timeFormat('%Y')
  timeParser = d3.timeParse("%Y-%m-%d %H:%M:%S")
  d3.map(lastYearKilled, (d) ->
    d.date = timeParser(d.date_hour)
    d.day = dayFormat(d.date)
    d.year = yearFormat(d.date)
  )
  dateDataKilled2018 = d3.nest()
  .key( (d) -> d.day)
  .rollup(sumKilled)
  .object(lastYearKilled)
  width = parseInt(d3.select('#calendar-2018-killed').style('width'), 10)
  calendar2017 = calendarChart().colorRange(['#662506']).yearRange(d3.range(thisYear,thisYear+1)).width(width)
  d3.select('#calendar-2018-killed').data([dateDataKilled2018]).call(calendar2017)
  initMap(lastAccidentKilled)
  show2017Map(_.flatten(results))
  setTimeout(showTimeRelatedData, 3000)

if d3.selectAll("#vision-zero-dashboard").size() > 0
  queue = d3.queue(2)
  queue.defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_injured_b_year.csv")
  d3.range(2016,thisYear+1).forEach((year) -> 
    queue.defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_#{year}_geocoded.csv")
  )
  queue.awaitAll(ready)
