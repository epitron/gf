class AddNamesToFaces < ActiveRecord::Migration
  def change
    add_column :faces, :name, :string
    add_column :faces, :description, :text
  end
end
