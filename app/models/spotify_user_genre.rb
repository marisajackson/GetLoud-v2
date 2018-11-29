class SpotifyUserGenre < ApplicationRecord
  belongs_to :spotify_user
  belongs_to :genre
end
