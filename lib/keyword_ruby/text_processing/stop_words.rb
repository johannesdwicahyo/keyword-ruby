# frozen_string_literal: true

module KeywordRuby
  module TextProcessing
    class StopWords
      STOP_WORDS_DIR = File.join(__dir__, "..", "stop_words")

      def initialize(language: :en, strict: false)
        @language = language
        @strict = strict
        @words = load_stop_words
        add_custom_stop_words
      end

      def stop_word?(word)
        @words.include?(word.downcase)
      end

      def filter(words)
        words.reject { |w| stop_word?(w) }
      end

      def add(words)
        words.each { |w| @words.add(w.downcase) }
      end

      private

      def load_stop_words
        path = File.join(STOP_WORDS_DIR, "#{@language}.txt")
        if !File.exist?(path) && @strict
          raise KeywordRuby::Error, "Stop word file not found for language: #{@language}"
        end
        return Set.new unless File.exist?(path)

        Set.new(File.readlines(path, chomp: true).map(&:downcase).reject(&:empty?))
      end

      def add_custom_stop_words
        custom = KeywordRuby.configuration.custom_stop_words
        custom.each { |w| @words.add(w.downcase) } if custom
      end
    end
  end
end
