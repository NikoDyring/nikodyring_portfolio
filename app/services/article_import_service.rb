class ArticleImportService
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

    # Store external image URL instead of downloading
    if article_data['social_image'].present?
      article.update!(external_image_url: article_data['social_image'])
    end

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


end