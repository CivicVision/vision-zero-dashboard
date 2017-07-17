var geocoder;
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
  geocoder = new google.maps.Geocoder();
  var sv = new google.maps.StreetViewService();
  panorama = new google.maps.StreetViewPanorama(
    document.getElementById('map-pano'),
    {
      linksControl: false,
      panControl: false,
      enableCloseButton: false
    });
  address = formatAddress(lastAccident);
	geocoder.geocode({'address': address}, function(results, status) {
		if (status === 'OK') {
			map.setCenter(results[0].geometry.location);
			map.setZoom(16);
			var marker = new google.maps.Marker({
				map: map,
				position: results[0].geometry.location,
        color: 'green',
        label: lastAccident.killed
			});
      panorama.setPosition(results[0].geometry.location);
      panorama.setPov({
        heading: 270,
        pitch: 0
      });
      panorama.setVisible(true);
		} else {
      document.getElementById('map-error').innerHTML = 'Unable to find the address to show on a map';
		}
	});
}
function addAccidentToMap(map, accident) {
  var address = formatAddress(accident);
  var infowindow = new google.maps.InfoWindow({
  });
  function addToMap(results, status) {
    var dateFormat = d3.timeFormat('%B, %d');
    var timeFormat = d3.timeFormat('%I %p');
    var date = dateFormat(new Date(this.date_time))+' '+timeFormat(new Date(this.date_hour));
    var address = formatAddress(this);
    var contentString = '<h5>'+address+'</h5><p><b>Date:</b> '+date+'</p><p><b># fatalities:</b> '+this.killed+'<br/><b># injuries:</b> '+this.injured+'</p>';
    if (status === 'OK') {
      var marker = new google.maps.Marker({
        map: map,
        position: results[0].geometry.location,
        title: contentString,
        label: this.killed
      });
      google.maps.event.addListener(marker,'click', function() {
        infowindow.open(map, this);
        infowindow.setContent(this.title);
      });
    } else { }
  }
  geocoder.geocode({'address': address}, addToMap.bind(accident));
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
