class CreateFaces < ActiveRecord::Migration
  def change
    create_table :faces do |t|
      t.integer :photo_id, index: true
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height

      t.timestamps null: false
    end
  end
end
