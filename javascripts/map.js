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
  var dateFormat = d3.timeFormat('%B, %d');
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
	var map2017 = new google.maps.Map(document.getElementById('map-2017'), {
		zoom: 10,
		center: {lat: 32.824, lng: -117.235}
	});
  var accidentsLength = accidents.length;
  for(var i=0;i<accidentsLength;i++) {
    addAccidentToMap(map2017, accidents[i]);
  }
}
