# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://bigtreeservices.ca"

SitemapGenerator::Sitemap.create do
  add '/main/home'
  add '/main/services'
  add '/main/commercial'
  add '/main/contact_us'
  add '/main/removal'
  add '/main/stumping'
  add '/main/careers'

  add '/requests/new'
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end
end
