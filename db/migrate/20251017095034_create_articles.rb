class AddArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :headline
      t.string :subtitle
      t.string :text
      t.integer :category, default: 0
      t.integer :status, default: 0
      t.datetime :published_at

      t.timestamps
    end
  end
end
