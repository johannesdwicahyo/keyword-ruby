# frozen_string_literal: true

require_relative "keyword_ruby/version"
require_relative "keyword_ruby/configuration"
require_relative "keyword_ruby/keyword"
require_relative "keyword_ruby/text_processing/stop_words"
require_relative "keyword_ruby/text_processing/tokenizer"
require_relative "keyword_ruby/text_processing/sentence_splitter"
require_relative "keyword_ruby/extractors/base"
require_relative "keyword_ruby/extractors/rake"
require_relative "keyword_ruby/extractors/yake"
require_relative "keyword_ruby/extractors/tfidf"

module KeywordRuby
  class Error < StandardError; end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end

    def extract(text, algorithm: nil, language: nil, top_n: nil, normalize: true)
      algo = algorithm || configuration.default_algorithm

      extractor = case algo
                  when :rake then Extractors::Rake.new(language: language, top_n: top_n, normalize: normalize)
                  when :yake then Extractors::Yake.new(language: language, top_n: top_n, normalize: normalize)
                  when :tfidf then Extractors::Tfidf.new(language: language, top_n: top_n, normalize: normalize)
                  else raise ArgumentError, "Unknown algorithm: #{algo}. Supported: :rake, :yake, :tfidf"
                  end

      extractor.extract(text)
    end

    def extract_batch(documents, **opts)
      documents.map { |doc| extract(doc, **opts) }
    end
  end
end
