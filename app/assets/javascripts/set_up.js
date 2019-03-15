$(document).ready(function() {
  console.log('SET UP');
  $('#create-playlist-button').click(function(){
    $('#create-playlist-button').attr('disabled', true);
    $('#create-playlist-button').text('Saving...');
    let metroArea = $('#metro-area').val();
    $.ajax({
      url: '/users/metro-area',
      type: 'PUT',
      dataType: 'json',
      data: {metroArea: metroArea}
    })
    .done(function() {
      window.location.replace("http://concertwire.live");
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
