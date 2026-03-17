# frozen_string_literal: true

require_relative "keyword_ruby/version"
require_relative "keyword_ruby/configuration"
require_relative "keyword_ruby/keyword"
require_relative "keyword_ruby/text_processing/stop_words"
require_relative "keyword_ruby/text_processing/tokenizer"
require_relative "keyword_ruby/extractors/base"
require_relative "keyword_ruby/extractors/rake"
require_relative "keyword_ruby/extractors/yake"
require_relative "keyword_ruby/extractors/tfidf"
require_relative "keyword_ruby/extractors/textrank"

module KeywordRuby
  class Error < StandardError; end

  ALGORITHMS = %i[rake yake tfidf textrank].freeze

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
      build_extractor(algo, language: language, top_n: top_n, normalize: normalize).extract(text)
    end

    def extract_batch(documents, algorithm: nil, language: nil, top_n: nil, normalize: true)
      algo = algorithm || configuration.default_algorithm

      if algo == :tfidf
        # TF-IDF benefits from shared corpus state
        extractor = build_extractor(algo, language: language, top_n: top_n, normalize: normalize)
        extractor.fit(documents)
        documents.map { |doc| extractor.extract(doc) }
      else
        extractor = build_extractor(algo, language: language, top_n: top_n, normalize: normalize)
        documents.map { |doc| extractor.extract(doc) }
      end
    end

    private

    def build_extractor(algo, **opts)
      case algo
      when :rake then Extractors::Rake.new(**opts)
      when :yake then Extractors::Yake.new(**opts)
      when :tfidf then Extractors::Tfidf.new(**opts)
      when :textrank then Extractors::TextRank.new(**opts)
      else raise ArgumentError, "Unknown algorithm: #{algo}. Supported: #{ALGORITHMS.join(', ')}"
      end
    end
  end
end
