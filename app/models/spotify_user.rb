class SpotifyUser < ApplicationRecord
  belongs_to :user

  has_many :spotify_user_genres
  has_many :genres, through: :spotify_user_genres

  # has_many :artists, through: :genres
  has_many :spotify_user_artists
  has_many :artists, through: :spotify_user_artists
  has_many :event_artists, -> { where("next_event_at > ?", Time.now) }, class_name: 'Artist', through: :spotify_user_artists, source: :artist

  has_many :direct_artist_links, -> { where("relation_type = ?", 0) }, class_name: 'SpotifyUserArtist'
  has_many :direct_artists, class_name: 'Artist', through: :direct_artist_links, source: :artist

  has_many :related_artist_links, -> { where("relation_type = ?", 1) }, class_name: 'SpotifyUserArtist'
  has_many :related_artists, class_name: 'Artist', through: :related_artist_links, source: :artist
end
