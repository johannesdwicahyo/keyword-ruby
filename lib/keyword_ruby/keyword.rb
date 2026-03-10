# frozen_string_literal: true

module KeywordRuby
  class Keyword
    attr_reader :phrase, :score, :position

    def initialize(phrase:, score:, position: nil)
      @phrase = phrase
      @score = score
      @position = position
    end

    def to_h
      { phrase: @phrase, score: @score, position: @position }.compact
    end

    def to_s
      "#{@phrase} (#{@score.round(2)})"
    end

    def <=>(other)
      other.score <=> @score
    end
  end
end
