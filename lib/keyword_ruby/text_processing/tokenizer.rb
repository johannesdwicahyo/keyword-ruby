# frozen_string_literal: true

module KeywordRuby
  module TextProcessing
    class Tokenizer
      # Common English contractions mapped to their expanded forms
      CONTRACTIONS = {
        "n't"  => " not",
        "'re"  => " are",
        "'ve"  => " have",
        "'ll"  => " will",
        "'d"   => " would",
        "'m"   => " am",
        "'s"   => "",        # possessive or "is" -- just remove
      }.freeze

      def self.tokenize(text)
        normalized = text.downcase
        # Normalize curly/smart apostrophes to straight
        normalized = normalized.gsub(/[\u2018\u2019\u2032]/, "'")
        # Expand contractions before stripping punctuation
        CONTRACTIONS.each do |suffix, expansion|
          normalized = normalized.gsub(suffix, expansion)
        end
        normalized
          .gsub(/[^\p{L}\p{N}\s-]/, " ")
          .split(/\s+/)
          .reject(&:empty?)
      end

      def self.sentences(text)
        text.split(/[.!?\n]+/)
            .map(&:strip)
            .reject(&:empty?)
      end
    end
  end
end
