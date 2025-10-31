class AddExternalImageUrlToArticles < ActiveRecord::Migration[8.1]
  def change
    add_column :articles, :external_image_url, :string
  end
end
