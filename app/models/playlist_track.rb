class PlaylistTrack < ApplicationRecord
  belongs_to :playlist
  belongs_to :artist
  has_many :events, through: :artist

  def self.dedupe(*columns)
    # find all models and group them on keys which should be common
    self.group_by{|x| columns.map{|col| x.send(col)}}.each do |duplicates|
      duplicates.shift # or pop to keep last one instead

      # if there are any more left, they are duplicates then delete all of them
      duplicates.each{|x| x.destroy}
    end
  end
end
