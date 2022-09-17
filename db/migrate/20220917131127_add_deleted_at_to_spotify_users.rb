class AddDeletedAtToSpotifyUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :spotify_users, :deleted_at, :datetime, null: true
  end
end
