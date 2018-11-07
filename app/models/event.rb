class Event < ApplicationRecord
  has_many :event_artists
  has_many :artists, through: :event_artists
end
