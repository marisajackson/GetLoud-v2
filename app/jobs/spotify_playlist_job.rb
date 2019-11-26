class SpotifyPlaylistJob < ApplicationJob
  queue_as :default

  def perform(spotify_user)
    logger.info "Starting Job: Spotify Playlist: #{spotify_user.spotify_id}"
    spotify_service = SpotifyService.new(spotify_user)
    spotify_service.update_playlist
    WeeklyEmailJob.perform_later(spotify_user)
    logger.info "Finishing Job: Spotify Playlist: #{spotify_user.spotify_id}"
  end
end
