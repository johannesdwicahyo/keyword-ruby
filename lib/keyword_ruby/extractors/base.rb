# frozen_string_literal: true

module KeywordRuby
  module Extractors
    class Base
      SUPPORTED_LANGUAGES = %i[en id ms nl fr de es pt ar ja].freeze

      def initialize(language: nil, top_n: nil, max_length: nil, min_word_length: nil, normalize: true)
        config = KeywordRuby.configuration
        @language = language || config.default_language
        @top_n = top_n || config.default_top_n
        @max_length = max_length || config.max_phrase_length
        @min_word_length = min_word_length || config.min_word_length
        @normalize = normalize

        validate_params!

        @stop_words = TextProcessing::StopWords.new(language: @language)
      end

      def extract(text)
        raise NotImplementedError, "#{self.class}#extract not implemented"
      end

      private

      def validate_params!
        unless SUPPORTED_LANGUAGES.include?(@language)
          raise ArgumentError, "Unsupported language: #{@language.inspect}. Supported: #{SUPPORTED_LANGUAGES.join(', ')}"
        end

        unless @top_n.is_a?(Integer) && @top_n > 0
          raise ArgumentError, "top_n must be a positive integer, got: #{@top_n.inspect}"
        end
      end

      def validate_text!(text)
        raise ArgumentError, "text must be a String, got #{text.class}" unless text.is_a?(String) || text.nil?
      end

      def normalize_scores(keywords)
        return keywords if keywords.empty? || !@normalize

        scores = keywords.map(&:score)
        min = scores.min
        max = scores.max
        range = max - min

        if range.zero?
          # All scores are equal -- normalize to 1.0
          keywords.map { |kw| Keyword.new(phrase: kw.phrase, score: 1.0, position: kw.position) }
        else
          keywords.map do |kw|
            normalized = (kw.score - min) / range
            Keyword.new(phrase: kw.phrase, score: normalized, position: kw.position)
          end
        end
      end

      def stop_word?(word)
        @stop_words.stop_word?(word)
      end
    end
  end
end
