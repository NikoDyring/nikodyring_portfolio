class AddExternalFieldsToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :external_id, :integer
    add_column :articles, :external_url, :string
    add_column :articles, :content, :text

    add_index :articles, :external_id, unique: true
  end
end
