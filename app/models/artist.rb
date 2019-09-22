class Artist < ApplicationRecord
  has_many :event_artists
  has_many :events, -> { where("date > ?", Time.now) }, through: :event_artists

  has_many :playlist_tracks

  has_many :artist_genres
  has_many :genres, through: :artist_genres

  has_many :spotify_user_artists
  has_many :spotify_users, through: :spotify_user_artists
end
