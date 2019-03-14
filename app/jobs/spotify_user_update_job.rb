class SpotifyUserUpdateJob < ApplicationJob
  queue_as :default

  def perform(spotify_user)
    logger.info "Starting Job: Update Spotify User: #{spotify_user.spotify_id}"
    spotify_service = SpotifyService.new(spotify_user)
    spotify_service.sync_user_artists
    spotify_service.sync_user_related_artists

    SpotifyPlaylistJob.perform_later spotify_user

    logger.info "Finishing Job: Update Spotify User: #{spotify_user.spotify_id}"
  end
end
