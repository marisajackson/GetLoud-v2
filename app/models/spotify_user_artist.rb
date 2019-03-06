class SpotifyUserArtist < ApplicationRecord
  enum relation_type: [:direct, :related]

  belongs_to :spotify_user
  belongs_to :artist
end
