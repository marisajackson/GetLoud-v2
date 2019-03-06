class Playlist < ApplicationRecord
  belongs_to :spotify_user
  has_many :playlist_tracks
  has_many :events, through: :playlist_tracks
end
