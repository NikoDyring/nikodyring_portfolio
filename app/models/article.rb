class Article < ApplicationRecord
  has_one_attached :featured_image
  has_one_attached :thumbnail

  enum :category, { uncategorized: 0, coding: 1, game_development: 2, gaming: 3, lifestyle: 4 }
  enum :status, { draft: 0, published: 1 }

  validates :headline, presence: true
  validates :subtitle, presence: true
  validates :text, presence: true
  validates :category, presence: true
  validates :status, presence: true

  after_commit :set_published_at, on: [ :create, :update ], if: :article_published?

  # Get the image URL, preferring external URL over Active Storage
  def image_url
    return external_image_url if external_image_url.present?
    return Rails.application.routes.url_helpers.rails_blob_url(thumbnail, only_path: false) if thumbnail.attached?
    nil
  end

  # Get just the image path (for internal use)
  def image_path
    return external_image_url if external_image_url.present?
    return Rails.application.routes.url_helpers.rails_blob_path(thumbnail) if thumbnail.attached?
    nil
  end

  private

  def article_published?
    saved_change_to_status? && published?
  end

  def set_published_at
    update_column(:published_at, Time.now)
  end
end
