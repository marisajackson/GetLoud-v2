class PlaylistTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :artist
  has_many :events, through: :artist
end
