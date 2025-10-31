namespace :blog do
  desc "Manually fetch blog posts from Dev.to"
  task fetch_posts: :environment do
    puts "Manually triggering blog posts import..."
    result = FetchBlogPostsJob.perform_now

    if result[:success]
      puts "✅ Blog import completed successfully: #{result[:message]}"
    else
      puts "❌ Blog import failed: #{result[:message]}"
    end
  end

  desc "Test scheduled job configuration"
  task test_schedule: :environment do
    puts "Checking recurring job configuration..."

    # Load the recurring configuration
    config_file = Rails.root.join("config", "recurring.yml")
    if File.exist?(config_file)
      config = YAML.load_file(config_file)

      puts "📋 All scheduled jobs configuration:"
      config.each do |env, jobs|
        next if env.start_with?("#") # Skip comments

        puts "  #{env}:"
        if jobs.is_a?(Hash)
          jobs.each do |job_name, job_config|
            schedule = job_config["schedule"] if job_config.is_a?(Hash)
            puts "    - #{job_name}: #{schedule}"
          end
        end
      end

      current_env_config = config[Rails.env]
      if current_env_config && current_env_config.any?
        puts "\n✅ Current environment (#{Rails.env}) has scheduled jobs"
      else
        puts "\n⚠️  No scheduled jobs configured for current environment (#{Rails.env})"
      end
    else
      puts "❌ recurring.yml file not found"
    end
  end
end
