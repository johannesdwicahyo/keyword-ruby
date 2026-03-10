# frozen_string_literal: true

module KeywordRuby
  module TextProcessing
    class SentenceSplitter
      def self.split(text)
        sentences = text.split(/(?<=[.!?])\s+/)
        sentences.map(&:strip).reject(&:empty?)
      end
    end
  end
end
