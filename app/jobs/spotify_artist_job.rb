class SpotifyArtistJob < ApplicationJob
  queue_as :default

  def perform(artist)
    logger.info "Starting Job: Spotify Artist Job: #{artist.name}"

    spotify_service = SpotifyService.new(SpotifyUser.first)
    spotify_service.update_artist(artist)

    logger.info "Finishing Job: Spotify Artist Job: #{artist.name}"
  end
end
