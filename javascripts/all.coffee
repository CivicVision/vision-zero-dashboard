---
---
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
	street_name = "#{d.street_name} #{d.street_type}"
	if d.cross_st_name
		return "#{street_name} / #{d.cross_st_name} #{d.cross_st_type}"
	else
		if d.street_dir
			return "#{d.street_no} #{d.street_dir} #{street_name}"
		else
			return "#{d.street_no} #{street_name}"

ready = (error, results) ->
	summaryByYear = results[0]
	accidentsKilled2017 = results[1]
	summary2017 = _.find(summaryByYear, (d) -> d.year == "2017")
	lastAccidentKilled = accidentsKilled2017[accidentsKilled2017.length-1]
	lastAccidentAddress = construct_street_name(lastAccidentKilled)
	dateFormat = d3.timeFormat('%B, %d')
	timeFormat = d3.timeFormat('%I %p')
	d3.selectAll('.lifes-lost').text(summary2017.killed)
	d3.selectAll('.last-life-lost-date').text(dateFormat(new Date(lastAccidentKilled.date_time)))
	d3.selectAll('.last-life-lost-time').text(timeFormat(new Date(lastAccidentKilled.date_hour)))
	d3.selectAll('.last-life-lost-location').text(lastAccidentAddress)

	dayFormat = d3.timeFormat('%Y-%m-%d')
	yearFormat = d3.timeFormat('%Y')
	timeParser = d3.timeParse("%Y-%m-%d %H:%M:%S")
	d3.map(accidentsKilled2017, (d) ->
		d.date = timeParser(d.date_hour)
		d.day = dayFormat(d.date)
		d.year = yearFormat(d.date)
	)
	dateDataKilled2017 = d3.nest()
	.key( (d) -> d.day)
	.rollup(sumKilled)
	.object(accidentsKilled2017)
	calendar2017 = calendarChart().colorRange(['#662506']).yearRange(d3.range(2017,2018))
	d3.select('#calendar-2017-killed').data([dateDataKilled2017]).call(calendar2017)

if d3.selectAll("#vision-zero-dashboard").size() > 0
	d3.queue(2)
	.defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_injured_b_year.csv")
	.defer(d3.csv, "https://s3.amazonaws.com/traffic-sd/accidents_killed_2017.csv")
	.awaitAll(ready)
