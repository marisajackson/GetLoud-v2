class SpotifyUserSetUpJob < ApplicationJob
  queue_as :default

  def perform(spotify_user)
    logger.info "Starting Job: Set Up Spotify User: #{spotify_user.spotify_id}"
    spotify_service = SpotifyService.new(spotify_user)
    spotify_service.sync_user_artists
    spotify_service.sync_user_related_artists
    spotify_service.update_playlist
    logger.info "Finishing Job: Set Up Spotify User: #{spotify_user.spotify_id}"
  end
end
