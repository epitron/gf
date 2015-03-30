class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :user_id
      t.integer :width
      t.integer :height
      
      t.string :filename

      t.boolean :public, default: false

      t.timestamps null: false
    end
  end
end
