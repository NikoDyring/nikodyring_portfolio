class FetchBlogPostsJob < ApplicationJob
  queue_as :default

  # Retry with exponential backoff for network issues
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(*args)
    Rails.logger.info "Starting blog posts import from Dev.to"

    result = ArticleImportService.new.import_articles

    if result[:success]
      Rails.logger.info "Blog import completed successfully: #{result[:message]}"
    else
      Rails.logger.error "Blog import failed: #{result[:message]}"
      # Optionally notify admins or trigger alerts
    end

    result
  end
end
