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
	var geocoder = new google.maps.Geocoder();
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
