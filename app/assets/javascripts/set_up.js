$(document).ready(function() {
  console.log('SET UP');
  $('#create-playlist-button').click(function(){
    let metroArea = $('#metro-area').val();
    $.ajax({
      url: '/users/metro-area',
      type: 'PUT',
      dataType: 'json',
      data: {metroArea: metroArea}
    })
    .done(function() {
      console.log("success");
    })
    .fail(function() {
      console.log("error");
    })
    .always(function() {
      console.log("complete");
    });

  });
});
