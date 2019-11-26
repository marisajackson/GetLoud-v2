class CreateEmailHistory < ActiveRecord::Migration[5.2]
  def change
    create_table :email_history do |t|
      t.belongs_to :user, index: true
      t.jsonb :details, null: false, default: '{}'
      t.datetime :sent_at, null: false
    end
  end
end
