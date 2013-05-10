$(document).ready(function() {
  $("#search").submit(function(event) {
    event.preventDefault();
    var type = $("#type").val()
    $("#preview").attr('src', iframeUrl(type, true));
  });
  $("#type").change(function() {
    var type = $(this).val();
    $("#query").val($("#query").attr('data-' + type));
    $("#repo,#gist").hide();
    $("#" + type).show();
    $("#search").submit();
  }).change();
  var heights = {repo: 200, gist: 400};
  $("#add").click(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var type = $("#type").val()
    lti.resourceSelected({
      embed_type: 'iframe',
      url: iframeUrl($("#type").val()),
      width: 550,
      height: heights[type],
      title: "GitHub " + type
    });
  });
  function iframeUrl(type, rand) {
    var url = location.protocol + "//" + location.host + "/tools/github/github_summary_" + type + ".html";
    if(rand) {
      var key = Math.random();
      url = url + "?key=" + key;
      "github_summary_" + type + ".html?key=" + key + "#" + $("#query").val()
    }
    url = url + "#" + $("#query").val();
    return url;
  }
  $("#search").submit();
});