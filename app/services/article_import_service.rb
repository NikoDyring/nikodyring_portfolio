class ArticleImportService
  require 'net/http'
  require 'uri'
  require 'stringio'
  
  def initialize(api_service = nil)
    @api_service = api_service || DevToApiService.new('nikodyring')
  end

  def import_articles
    articles_data = @api_service.fetch_articles
    return { success: false, message: 'No articles fetched' } if articles_data.empty?

    imported_count = 0
    errors = []

    articles_data.each do |article_data|
      begin
        import_single_article(article_data)
        imported_count += 1
      rescue StandardError => e
        Rails.logger.error "Failed to import article #{article_data['id']}: #{e.message}"
        errors << { id: article_data['id'], error: e.message }
      end
    end

    {
      success: errors.empty?,
      imported_count: imported_count,
      errors: errors,
      message: "Imported #{imported_count} articles#{errors.any? ? " with #{errors.count} errors" : ''}"
    }
  end

  private

  def import_single_article(article_data)
    # Validate required fields
    return unless article_data['id'] && article_data['title']

    is_new_article = false
    article = Article.find_or_create_by!(external_id: article_data['id']) do |a|
      is_new_article = true
      a.headline = article_data['title']
      a.subtitle = article_data['description']
      a.category = parse_category(article_data['tag_list'])
      a.status = article_data['published_timestamp'] ? 'published' : 'draft'
      a.published_at = parse_date(article_data['published_timestamp'])
      a.content = article_data['body_markdown'] if article_data['body_markdown']
      a.external_url = article_data['url']
      a.text = article_data['description']
    end

    # Update existing articles with latest data (skip if it's a new article)
    unless is_new_article
      article.update!(
        headline: article_data['title'],
        subtitle: article_data['description'],
        category: parse_category(article_data['tag_list']),
        published_at: parse_date(article_data['published_timestamp'])
      )
    end

    # Attach thumbnail from social_image URL if present and not already attached
    attach_thumbnail_from_url(article, article_data['social_image']) if article_data['social_image'].present?

    article
  end

  def parse_category(tag_list)
    return 'general' if tag_list.blank?

    tags = tag_list.is_a?(Array) ? tag_list.map(&:downcase) : [tag_list.to_s.downcase]

    if tags.include?('webdev')
      'coding'
    elsif tags.include?('gamedev')
      'game_development'
    else
      'lifestyle'
    end
  end

  def parse_date(date_string)
    return nil if date_string.blank?
    
    Time.parse(date_string)
  rescue ArgumentError => e
    Rails.logger.warn "Invalid date format: #{date_string}"
    nil
  end

  def attach_thumbnail_from_url(article, image_url)
    return if image_url.blank? || article.thumbnail.attached?

    uri = URI.parse(image_url)
    
    # Download the image
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      # Extract filename from URL or use a default
      filename = extract_filename_from_url(image_url) || "thumbnail_#{article.external_id}.jpg"
      
      # Attach the downloaded image
      article.thumbnail.attach(
        io: StringIO.new(response.body),
        filename: filename,
        content_type: response.content_type || 'image/jpeg'
      )
      
      Rails.logger.info "Attached thumbnail for article #{article.external_id}: #{filename}"
    else
      Rails.logger.warn "Failed to download thumbnail for article #{article.external_id}: #{response.code} #{response.message}"
    end
  rescue StandardError => e
    Rails.logger.error "Error attaching thumbnail for article #{article.external_id}: #{e.message}"
  end

  def extract_filename_from_url(url)
    return nil if url.blank?
    
    uri = URI.parse(url)
    filename = File.basename(uri.path)
    
    # Return filename if it has an extension, otherwise nil
    filename.include?('.') ? filename : nil
  rescue StandardError
    nil
  end
end