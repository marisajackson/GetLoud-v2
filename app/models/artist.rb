class Artist < ApplicationRecord
  has_many :event_artists
  has_many :events, through: :event_artists

  has_many :artist_genres
  has_many :genres, through: :artist_genres
end
