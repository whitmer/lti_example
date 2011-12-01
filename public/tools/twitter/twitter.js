var url = location.href;
var args = (url.split(/#/)[1] || '').split(/\&/);
var params = {}
for(var idx in args) {
  var arg = args[idx].split(/\=/);
  var key = arg[0];
  var value = arg[1];
  if(key && value) {
    params[key] = decodeURIComponent(value);
  }
}
var height = $(window).height();
var widgetArgs = {
  version: 2,
  type: 'profile',
  rpp: 30,
  interval: 30000,
  width: 'auto',
  height: height - 110,
  theme: {
    shell: {
      background: '#8ec1da',
      color: '#ffffff'
    },
    tweets: {
      background: '#ffffff',
      color: '#444444',
      links: '#1985b5'
    }
  },
  features: {
    scrollbar: true,
    loop: true,
    live: true,
    behavior: 'all'
  }
}
var skipValidation = false;
if(params.type) {
  skipValidation = true;
  if(params.type == 'single') {
    $.getJSON("/tweet_embed?id=" + params.query, function(data) {
      $("#header").after(data.html);
    });
  } else {
    widgetArgs.type = params.type;
    widgetArgs.search = params.query;
    widgetArgs.title = (params.type == 'search') ? 'search results' : null;
    widgetArgs.subject = params.query;
    
    var widget = new TWTR.Widget(widgetArgs).render();
    if(params.type == 'profile') {
      widget = widget.setUser(params.query);
    }
    widget.start();
  }
} else {
  $("#header").show();
}
$("#add").click(function(event) {
  event.preventDefault();
  event.stopPropagation();
  var obj = parseEmbedCode();
  if(obj.type == 'unknown') {
    alert("Invalid embed code");
  } else {
    lti.resourceSelected({
      embed_type: 'iframe',
      url: obj.iframe_url,
      width: 500,
      height: 300,
      title: "Twitter list"
    });
  }
});
function parseEmbedCode() {
  var code = $("#embed_code").val();
  var $a = $("<div/>").html(code).find("a:last");

  var iframe_url = location.protocol + "//" + location.host + "/tools/twitter/twitter_embed.html?";

  if($a.hasClass('twitter-timeline') && $a.attr('data-widget-id')) {
    return {
      type: 'feed',
      widget_id: $a.attr('data-widget-id'),
      url: $a.attr('href'),
      iframe_url: iframe_url + "widget_id=" + $a.attr('data-widget-id') + "&url=" + encodeURIComponent($a.attr('href'))
    };
  } else if($a.length) {
    var matches = $a.attr('href').match(/^https:\/\/twitter.com\/([A-Za-z0-9_]+)\/status\/(\d+)$/);
    if(matches[1] && matches[2]) {
      return {
        type: 'single',
        tweet_id: matches[2],
        author: matches[1],
        iframe_url: iframe_url + "tweet_id=" + matches[2] + "&author=" + matches[1]
      };
    } else {
      return {
        type: 'unknown'
      };
    }
  } else {
      return {
        type: 'unknown'
      };
  }
}
$("#search").submit(function(event) {
  event.preventDefault();
  $("#preview").empty();
  var obj = parseEmbedCode();
  if(obj.type == "single") {
    var $iframe = $("<iframe/>", {
      src: obj.iframe_url,
      style: "width: 500px; height: 300px; border: 0; overflow: auto;",
      frameborder: 0
    });
  } else if(obj.type == 'feed') {
    var $iframe = $("<iframe/>", {
      src: obj.iframe_url,
      style: "width: 500px; height: 300px; border: 0; overflow: auto;",
      frameborder: 0
    });
  } else {
    alert("Invalid embed code");
  }
  $("#preview").append($iframe);
});
$("#host").text(location.host);