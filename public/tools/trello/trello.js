$(document).ready(function() {
  $("#search").submit(function(event) {
    event.preventDefault();
    $("#preview").attr('src', iframeUrl(true));
  });
  $("#add").click(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var url = 
    lti.resourceSelected({
      embed_type: 'iframe',
      url: iframeUrl(),
      width: 500,
      height: 300,
      title: "Trello board"
    });
  });
  function iframeUrl(rand) {
    var url = location.protocol + "//" + location.host + "/tools/trello/trello_summary.html";
    if(rand) {
      var key = Math.random();
      url = url + "?key=" + key;
    }
    url = url + "#" + $("#query").val();
    return url;
  }
  $("#search").submit();
});