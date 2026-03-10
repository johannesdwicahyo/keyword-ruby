# frozen_string_literal: true

module KeywordRuby
  class Configuration
    attr_accessor :default_algorithm, :default_language, :default_top_n,
                  :max_phrase_length, :min_word_length

    def initialize
      @default_algorithm = :rake
      @default_language = :en
      @default_top_n = 10
      @max_phrase_length = 4
      @min_word_length = 2
    end
  end
end
