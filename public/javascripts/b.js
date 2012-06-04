var llSanDiego = [32.710719, -117.167945];
var llSanFrancisco = [37.789828, -122.402072];
var latCenter = (llSanDiego[0] + llSanFrancisco[0]) / 2;
var lonCenter = (llSanDiego[1] + llSanFrancisco[1]) / 2;
var paths = [];
$(function($) {
  var map = new GMaps({
    div: '#map',
    lat: latCenter,
    lng: lonCenter,
    zoom: 6
  });
  var step = function(e) {
    paths.unshift([e.path[0].lat(), e.path[0].lng()]);
    var first = e.path[0];
    var last = e.path[e.path.length - 1];
    var path = [first, last];
    if (e.path.length > 5) {
      var mid = e.path[Math.floor(e.path.length / 3)];
      paths.unshift([mid.lat(), mid.lng()]);
      var mid2 = e.path[Math.floor(2 * e.path.length / 3)];
      paths.unshift([mid2.lat(), mid2.lng()]);
      path = [first, mid, mid2, last];
    } else if (e.path.length > 2) {
      var mid = e.path[Math.floor(e.path.length / 2)];
      paths.unshift([mid.lat(), mid.lng()]);
      path = [first, mid, last];
    }
    map.drawPolyline({
      path: path,
      strokeColor: '#131540',
      strokeOpacity: 0.6,
      strokeWeight: 6
    });
  };
  var postResults = function(result) {
    var html = '<ul>'
    var cities = JSON.parse(result);
    $.each(cities, function(i, city){
      var link = 'https://www.google.com/search?q=site:wikipedia.org+' + city.name + '+California&btnI=745&pws=0';
      var linkedName = '<a href="' + link + '" target="_blank">' + city.name + '</a>';
      var content = '<h2>' + linkedName + '</h2>' +
        '<p><b>Population:</b> ' + city.population + '</p>' +
        '<p><b>Progress:</b> ' + city.progress.toFixed(2) + '%</p>';
      map.addMarker({
        lat: city.latlon[0],
        lng: city.latlon[1],
        title: city.name,
        infoWindow: { content: content }
      });
      html += '<li>' + linkedName + '</li>'
    });
    $('#instructions').html(html + '</ul>');
  };
  var success = function() {
    var dist = $('#dist').val().replace(/[^\d\.]/g, '');
    var pop  = $('#pop').val().replace(/[^\d\.]/g, '');
    $('#dist').val(dist);
    $('#pop').val(pop);

    // TODO: Make this less awkward
    var prog = Number($('input[name=progress]:checked').val());
    if (prog != 25 && prog != 75) {
      prog = 50;
    }

    var params = {
      paths: paths,
      dist: dist,
      pop: pop,
      start: (prog - 15) / 100.0,
      end: (prog + 15) / 100.0
    };
    $.post('/bisect', params, postResults);
  };
  $('#submit').click(function(){
    var origin = $('#origin').val().split(',');
    var destin = $('#destin').val().split(',');
    // TODO: geocoding
    // http://maps.googleapis.com/maps/api/geocode/json?address=blah&sensor=false
    paths = [origin];
    map.travelRoute({
      origin: origin,
      destination: destin,
      travelMode: 'driving',
      step: step,
      success: success,
    });
  });
});

