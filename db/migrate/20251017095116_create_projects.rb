class AddProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title
      t.string :description
      t.string :url
      t.integer :status, default: 0
      t.integer :category, default: 0
      t.integer :programming_language, default: 0

      t.timestamps
    end
  end
end
