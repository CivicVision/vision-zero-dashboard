function latLngFromAccident(accident) {
  var locationArr = accident.location.split(" ");
  return {lat: parseFloat(locationArr[0]), lng: parseFloat(locationArr[1])};
}
function formatAddress(d) {
	street_name = d.street_name+' '+d.street_type;
	if(d.cross_st_name) {
		return street_name+' and '+d.cross_st_name+' '+d.cross_st_type;
	} else {
		if(d.street_dir) {
			return d.street_no+' '+d.street_dir+' '+street_name;
		} else {
			return d.street_no+' '+street_name;
    }
  }
}
function initMap(lastAccident) {
	var map = new google.maps.Map(document.getElementById('map'), {
		zoom: 11,
		center: {lat: 32.824, lng: -117.235},
    disableDefaultUI: true
	});
  var sv = new google.maps.StreetViewService();
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById('map-pano'),
    {
      linksControl: false,
      panControl: false,
      enableCloseButton: false
    });
  var address = formatAddress(lastAccident);
  var accidentLocation = latLngFromAccident(lastAccident);
  map.setCenter(accidentLocation);
  map.setZoom(16);
  var marker = new google.maps.Marker({
    map: map,
    position: accidentLocation,
    color: 'green',
    label: lastAccident.killed
  });
  panorama.setPosition(accidentLocation);
  panorama.setPov({
    heading: 270,
    pitch: 0
  });
  panorama.setVisible(true);
}
function addAccidentToMap(map, accident) {
  var address = formatAddress(accident);
  var infowindow = new google.maps.InfoWindow({
  });
  var dateFormat = d3.timeFormat('%B, %d %Y');
  var timeFormat = d3.timeFormat('%I %p');
  var date = dateFormat(new Date(accident.date_time))+' '+timeFormat(new Date(accident.date_hour));
  var contentString = '<h5>'+address+'</h5><p><b>Date:</b> '+date+'</p><p><b># fatalities:</b> '+accident.killed+'<br/><b># injuries:</b> '+accident.injured+'</p>';
  var accidentLocation = latLngFromAccident(accident);
  var marker = new google.maps.Marker({
    map: map,
    position: accidentLocation,
    title: contentString,
    label: accident.killed
  });
  google.maps.event.addListener(marker,'click', function() {
    infowindow.open(map, this);
    infowindow.setContent(this.title);
  });
}
function show2017Map(accidents) {
  var silverStyle = [ { elementType: 'geometry', stylers: [{color: '#f5f5f5'}] },
            { elementType: 'labels.icon', stylers: [{visibility: 'off'}] },
            { elementType: 'labels.text.fill', stylers: [{color: '#616161'}] },
            { elementType: 'labels.text.stroke', stylers: [{color: '#f5f5f5'}] },
            { featureType: 'administrative.land_parcel', elementType: 'labels.text.fill', stylers: [{color: '#bdbdbd'}] },
            { featureType: 'poi', elementType: 'geometry', stylers: [{color: '#eeeeee'}] },
            { featureType: 'poi', elementType: 'labels.text.fill', stylers: [{color: '#757575'}] },
            { featureType: 'poi.park', elementType: 'geometry', stylers: [{color: '#e5e5e5'}] },
            { featureType: 'poi.park', elementType: 'labels.text.fill', stylers: [{color: '#9e9e9e'}] },
            { featureType: 'road', elementType: 'geometry', stylers: [{color: '#ffffff'}] },
            { featureType: 'road.arterial', elementType: 'labels.text.fill', stylers: [{color: '#757575'}] },
            { featureType: 'road.highway', elementType: 'geometry', stylers: [{color: '#dadada'}] },
            { featureType: 'road.highway', elementType: 'labels.text.fill', stylers: [{color: '#616161'}] },
            { featureType: 'road.local', elementType: 'labels.text.fill', stylers: [{color: '#9e9e9e'}] },
            { featureType: 'transit.line', elementType: 'geometry', stylers: [{color: '#e5e5e5'}] },
            { featureType: 'transit.station', elementType: 'geometry', stylers: [{color: '#eeeeee'}] },
            { featureType: 'water', elementType: 'geometry', stylers: [{color: '#c9c9c9'}] },
            { featureType: 'water', elementType: 'labels.text.fill', stylers: [{color: '#9e9e9e'}] }
          ];
  var styledMapType = new google.maps.StyledMapType(silverStyle,{name: 'Styled Map'});
	var map2017 = new google.maps.Map(document.getElementById('map-2018'), {
		zoom: 10,
		center: {lat: 32.824, lng: -117.235}
	});
  map2017.mapTypes.set('styled_map', styledMapType);
  map2017.setMapTypeId('styled_map');
  var accidentsLength = accidents.length;
  var heatmapData = [];
  for (var i = 0; i < accidentsLength; i++) {
    var accidentLocation = latLngFromAccident(accidents[i]);
    if (!isNaN(accidentLocation.lat) && !isNaN(accidentLocation.lng)) {
      var latLng = new google.maps.LatLng(accidentLocation);
      heatmapData.push(latLng);
    }
  }
  var heatmap = new google.maps.visualization.HeatmapLayer({
    data: heatmapData,
    map: map2017
  });
}
