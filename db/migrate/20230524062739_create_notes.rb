class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :notes do |t|
      t.text :body
      t.integer :user_id
      t.integer :bookmark_id

      t.timestamps
    end
  end
end
