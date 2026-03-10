# frozen_string_literal: true

module KeywordRuby
  module TextProcessing
    class StopWords
      STOP_WORDS_DIR = File.join(__dir__, "..", "stop_words")

      def initialize(language: :en)
        @language = language
        @words = load_stop_words
      end

      def stop_word?(word)
        @words.include?(word.downcase)
      end

      def filter(words)
        words.reject { |w| stop_word?(w) }
      end

      private

      def load_stop_words
        path = File.join(STOP_WORDS_DIR, "#{@language}.txt")
        return Set.new unless File.exist?(path)

        Set.new(File.readlines(path, chomp: true).map(&:downcase).reject(&:empty?))
      end
    end
  end
end
