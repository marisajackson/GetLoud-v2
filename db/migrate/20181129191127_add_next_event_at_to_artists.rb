class AddNextEventAtToArtists < ActiveRecord::Migration[5.2]
  def change
    add_column :artists, :next_event_at, :datetime
  end
end
