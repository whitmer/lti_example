$(document).ready(function() {
  $("#form").on('change', "#form input", function() {
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
    data['name'] = data['name'] || "No Name";
    var types = ['editor_button', 'resource_selection', 'homework_submission', 'course_navigation', 'account_navigation', 'user_navigation'];
    for(var idx in types) {
      var type = types[idx];
      data[type + "_launch_url"] = data[type + "_launch_url"] || data["launch_url"];
      data[type + "_icon_url"] = data[type + "_icon_url"] || data["icon_url"];
      data[type + "_link_text"] = data[type + "_link_text"] || data["name"];
      data[type + "_width"] = data[type + "_width"] || 400;
      data[type + "_height"] = data[type + "_height"] || 300;
    }
    data.custom_fields = [];
    $(".fields .field:visible").each(function() {
      data.custom_fields.push({
        key: $(this).find(".key").val(),
        val: $(this).find(".value").val()
      });
    });
    var lines = Handlebars.templates['lti_xml'](data).split(/\n/);
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
  $(".add_field").click(function() {
    var $field = $(".fields .field:first").clone();
    $(".fields").append($field.show());
  });
  $(document).on('click', '.delete_field', function() {
    $(this).closest(".field").remove();
    $("#form").submit();
  });
});