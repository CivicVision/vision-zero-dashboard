---
---
@findWithin = (data, target, std, n) ->
  minTarget = target - (n*std)
  maxTarget = target + (n*std)
  results = []
  data.forEach((d) ->
    if (d >= target && d <= maxTarget)
      results.push(d)
    if (d <= target && d >= minTarget)
      results.push(d)
  )
  results

@findTargets = (data, targets, target, key) ->
  filteredResuts = data.filter((d) ->
    targets.indexOf(d[key]) != -1
  )

@findTimeEdges = (data, numberOfDeviations = 1, treshold = 2) ->
  accidentsNumbers = data.map((d) -> d.value)
  accidentsSum = d3.sum(accidentsNumbers)
  maxAccidents = d3.max(accidentsNumbers)
  accidentsMean = d3.mean(accidentsNumbers)
  sdt = d3.deviation(accidentsNumbers)
  targets = findWithin(accidentsNumbers, maxAccidents,  sdt, numberOfDeviations)
  acctargets = findTargets(data, targets, maxAccidents, 'value')
  simplehourFormat = d3.timeFormat('%H')
  acctargetsHours = acctargets.map((d) -> parseInt(simplehourFormat(d.key)))
  #filteredTargets = acctargetsHours.filter(outliers())
  filteredTargets = stats.filterOutliers(acctargetsHours,stats.outlierMethod.MAD,treshold)
  min = d3.min(filteredTargets)
  max = d3.max(filteredTargets)
  minDate = new Date()
  minDate.setHours(min)
  maxDate = new Date()
  maxDate.setHours(max)
  {min: minDate, max: maxDate}
