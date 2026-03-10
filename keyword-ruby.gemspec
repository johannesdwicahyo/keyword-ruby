# frozen_string_literal: true

require_relative "lib/keyword_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "keyword-ruby"
  spec.version = KeywordRuby::VERSION
  spec.authors = ["Johannes Dwi Cahyo"]
  spec.email = ["johannes@example.com"]
  spec.summary = "Keyword extraction for Ruby using RAKE, YAKE, and TF-IDF"
  spec.description = "Pure Ruby keyword and keyphrase extraction library. Implements RAKE, YAKE, and TF-IDF algorithms for extracting keywords from text."
  spec.homepage = "https://github.com/johannesdwicahyo/keyword-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir[
    "lib/**/*.rb",
    "lib/**/*.txt",
    "README.md",
    "LICENSE",
    "CHANGELOG.md",
    "Rakefile",
    "keyword-ruby.gemspec"
  ]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rake", "~> 13.0"
end
