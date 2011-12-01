$(document).ready(function() {
  $("#form").on('change', "#form input,#form textarea", function() {
    $("#form").submit();
  });
  $("#form").submit(function(event) {
    event.preventDefault();
    var args = $("#form").serializeArray();
    var data = {};
    for(var idx in args) {
      var arg = args[idx];
      data[arg['name']] = arg['value'];
    }
    data.score = Math.round(parseFloat(data.score) * 100) / 100;
    if(isNaN(data.score)) {
      data.score = null;
    }
    data.resultData = {
      url: data.url,
      text: data.text
    };
    if(!data.url && !data.text) {
      data.resultData = null;
    }
    var lines = Handlebars.templates['lti_outcome'](data).split(/\n/);
    var final_lines = [];
    for(var idx in lines) {
      if(lines[idx].match(/[^\s]/)) {
        final_lines.push(lines[idx]);
      }
    }
    $("#xml").val(final_lines.join("\n"));
  });
  $(document).on('change', '.extension_option', function() {
    $(".control-group." + $(this).attr('name')).toggle($(this).attr('checked'));
  });
  $(".extension_option").each(function() {
    $(this).change();
  });
});