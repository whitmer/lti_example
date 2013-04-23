window.addEventListener('message', function(event) {
  if(event.origin != 'https://www.edu-apps.org') {
    return;
  } else if(!event.data || event.data.action != 'InstallEduApp') {
    return;
  }
  var app = event.data;
  // fill in the form using the info from the app object
  // hide the dialog
  alert("App received!");
  console.log(app);
}, false);

// if the page is an LTI config page, add link to the DOM

// when said link is clicked, load up the app installer in an iframe dialog