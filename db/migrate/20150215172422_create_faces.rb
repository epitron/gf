class CreateFaces < ActiveRecord::Migration
  def change
    create_table :faces do |t|
      t.integer :photo_id, index: true

      t.timestamps null: false
    end
  end
end
