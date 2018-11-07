class Artist < ApplicationRecord
  has_many :event_artists
  has_many :events, through: :event_artists
end