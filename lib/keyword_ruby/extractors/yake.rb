# frozen_string_literal: true

module KeywordRuby
  module Extractors
    class Yake < Base
      def extract(text)
        validate_text!(text)
        return [] if text.nil? || text.strip.empty?

        words = TextProcessing::Tokenizer.tokenize(text)
        sentences = TextProcessing::Tokenizer.sentences(text)
        return [] if words.empty?

        word_stats = calculate_features(words, sentences)
        candidates = generate_candidates(words)
        return [] if candidates.empty?

        scored = candidates.map do |phrase|
          score = score_candidate(phrase, word_stats)
          Keyword.new(phrase: phrase, score: score)
        end

        max_score = scored.map(&:score).max
        inverted = scored.map do |kw|
          Keyword.new(phrase: kw.phrase, score: max_score - kw.score + 0.001)
        end

        results = inverted.sort.first(@top_n)
        normalize_scores(results)
      end

      private

      def calculate_features(words, sentences)
        total = words.size.to_f
        stats = {}

        word_freq = Hash.new(0)
        words.each { |w| word_freq[w] += 1 }

        first_positions = {}
        words.each_with_index do |w, i|
          first_positions[w] ||= i
        end

        word_freq.each do |word, freq|
          next if stop_word?(word) || word.length < @min_word_length

          tf = freq / total
          pos = (first_positions[word] || 0) / total
          len_norm = word.length > 3 ? 1.0 : 0.5

          stats[word] = {
            tf: tf,
            position: pos,
            frequency: freq,
            score: tf * (1.0 + pos) / len_norm
          }
        end

        stats
      end

      def generate_candidates(words)
        candidates = Set.new

        (1..@max_length).each do |n|
          words.each_cons(n) do |gram|
            phrase = gram.join(" ")
            # First and last words must not be stop words
            next if stop_word?(gram.first) || stop_word?(gram.last)
            # First and last words must meet minimum length
            next if gram.first.length < @min_word_length || gram.last.length < @min_word_length

            candidates << phrase
          end
        end

        candidates.to_a
      end

      def score_candidate(phrase, word_stats)
        words = phrase.split(/\s+/)
        # Only score non-stop words; stop words in the middle are neutral (score 1.0 in product)
        scores = words.map do |w|
          if stop_word?(w) || w.length < @min_word_length
            1.0
          else
            word_stats.dig(w, :score) || 1.0
          end
        end

        if scores.length == 1
          scores.first
        else
          scores.reduce(:*)
        end
      end
    end
  end
end
