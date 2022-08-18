$(document).ready(function () {
  $('#create-playlist-button').click(function () {
    $('#sign-up-form').addClass('submitted')
    let isValid =
      $('#metro-area').is(':valid') && $('#agree-check').is(':valid')

    if (!$('#agree-check').is(':valid')) {
      $('.form-check-label').addClass('invalid')
    }

    if (!isValid) return

    $('#create-playlist-button').attr('disabled', true)
    $('#create-playlist-button').text('Saving...')
    let metroArea = $('#metro-area').val()
    $.ajax({
      url: '/users/metro-area',
      type: 'PUT',
      dataType: 'json',
      data: { metroArea: metroArea },
    })
      .done(function (data) {
        window.location.replace(data.spotify_auth_url)
        console.log('success')
      })
      .fail(function (err) {
        console.log(err)
        console.log('error')
      })
      .always(function () {
        // window.location.replace('http://www.concertwire.live')
        console.log('complete')
      })
  })
})
