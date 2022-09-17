# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_09_17_131127) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artist_genres", force: :cascade do |t|
    t.bigint "genre_id"
    t.bigint "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_artist_genres_on_artist_id"
    t.index ["genre_id"], name: "index_artist_genres_on_genre_id"
  end

  create_table "artists", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "spotify_id"
    t.datetime "next_event_at"
  end

  create_table "email_history", force: :cascade do |t|
    t.bigint "user_id"
    t.jsonb "details", default: "{}", null: false
    t.datetime "sent_at", null: false
    t.index ["user_id"], name: "index_email_history_on_user_id"
  end

  create_table "event_artists", force: :cascade do |t|
    t.bigint "event_id"
    t.bigint "artist_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_event_artists_on_artist_id"
    t.index ["event_id"], name: "index_event_artists_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "name"
    t.datetime "date"
    t.string "venue"
    t.string "metro_area"
    t.string "ticket_url"
    t.string "event_api"
    t.string "event_api_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_url"
  end

  create_table "genres", force: :cascade do |t|
    t.string "name", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlist_tracks", force: :cascade do |t|
    t.bigint "playlist_id"
    t.bigint "artist_id"
    t.string "spotify_track_id"
    t.datetime "last_updated_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_playlist_tracks_on_artist_id"
    t.index ["playlist_id"], name: "index_playlist_tracks_on_playlist_id"
  end

  create_table "playlists", force: :cascade do |t|
    t.bigint "spotify_user_id"
    t.string "spotify_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_updated_at"
    t.index ["spotify_user_id"], name: "index_playlists_on_spotify_user_id"
  end

  create_table "spotify_user_artists", force: :cascade do |t|
    t.bigint "spotify_user_id"
    t.bigint "artist_id"
    t.integer "relation_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["artist_id"], name: "index_spotify_user_artists_on_artist_id"
    t.index ["spotify_user_id"], name: "index_spotify_user_artists_on_spotify_user_id"
  end

  create_table "spotify_user_genres", force: :cascade do |t|
    t.bigint "spotify_user_id"
    t.bigint "genre_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "index_spotify_user_genres_on_genre_id"
    t.index ["spotify_user_id"], name: "index_spotify_user_genres_on_spotify_user_id"
  end

  create_table "spotify_users", force: :cascade do |t|
    t.string "spotify_id", default: "", null: false
    t.string "email", default: "", null: false
    t.string "display_name", default: "", null: false
    t.string "access_token", default: "", null: false
    t.string "refresh_token", default: "", null: false
    t.datetime "expires_at"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["user_id"], name: "index_spotify_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "metro_area"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "send_emails", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "spotify_users", "users"
end
