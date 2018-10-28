class CreateSpotifyUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :spotify_users do |t|
      t.string :spotify_id,         null: false, default: ""
      t.string :email,              null: false, default: ""
      t.string :display_name,       null: false, default: ""

      t.string :access_token,       null: false, default: ""
      t.string :refresh_token,      null: false, default: ""

      t.references :user, foreign_key: true

      t.timestamps null: false
    end
  end
end
