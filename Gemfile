source "https://rubygems.org"

# Jekyll itself. This version matches what the GitHub Actions build uses.
gem "jekyll", "~> 4.3"

# Pin the sassc-based converter (compiles from C source) instead of Jekyll 4's
# default dart-sass converter, whose precompiled binary won't run on NixOS.
gem "jekyll-sass-converter", "~> 2.0"

# Small quality-of-life plugins (all allowed on GitHub Pages / Actions builds).
group :jekyll_plugins do
  gem "jekyll-sitemap"     # generates sitemap.xml for search engines
  gem "jekyll-seo-tag"     # adds title/description meta tags to each page
end

# Needed on newer Ruby versions (3.0+) where these were unbundled from core.
gem "webrick", "~> 1.8"
