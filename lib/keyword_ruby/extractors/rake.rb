# frozen_string_literal: true

module KeywordRuby
  module Extractors
    class Rake < Base
      def extract(text)
        validate_text!(text)
        return [] if text.nil? || text.strip.empty?

        sentences = TextProcessing::Tokenizer.sentences(text)
        candidates = extract_candidates(sentences)
        return [] if candidates.empty?

        word_scores = calculate_word_scores(candidates)

        keyword_scores = candidates.uniq.map do |phrase|
          words = phrase.split(/\s+/)
          score = words.sum { |w| word_scores[w] || 0.0 }
          Keyword.new(phrase: phrase, score: score)
        end

        results = keyword_scores.sort.first(@top_n)
        normalize_scores(results)
      end

      private

      def extract_candidates(sentences)
        candidates = []

        sentences.each do |sentence|
          words = TextProcessing::Tokenizer.tokenize(sentence)
          current_phrase = []

          words.each do |word|
            if stop_word?(word) || word.length < @min_word_length
              if current_phrase.any?
                phrase = current_phrase.join(" ")
                candidates << phrase if current_phrase.length <= @max_length
                current_phrase = []
              end
            else
              current_phrase << word
            end
          end

          if current_phrase.any? && current_phrase.length <= @max_length
            candidates << current_phrase.join(" ")
          end
        end

        candidates
      end

      def calculate_word_scores(candidates)
        word_frequency = Hash.new(0)
        cooccurrence = Hash.new { |h, k| h[k] = Hash.new(0) }

        candidates.each do |phrase|
          words = phrase.split(/\s+/)
          words.each do |w1|
            word_frequency[w1] += 1
            words.each do |w2|
              cooccurrence[w1][w2] += 1
            end
          end
        end

        word_scores = {}
        word_frequency.each do |word, freq|
          deg = cooccurrence[word].values.sum
          word_scores[word] = deg.to_f / freq
        end

        word_scores
      end
    end
  end
end
