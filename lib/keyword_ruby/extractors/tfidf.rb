# frozen_string_literal: true

module KeywordRuby
  module Extractors
    class Tfidf < Base
      def initialize(**opts)
        super
        @idf = nil
        @doc_count = 0
      end

      def fit(documents)
        @doc_count = documents.size
        doc_freq = Hash.new(0)

        documents.each do |doc|
          words = TextProcessing::Tokenizer.tokenize(doc)
          words.uniq.each { |w| doc_freq[w] += 1 }
        end

        @idf = {}
        doc_freq.each do |word, df|
          @idf[word] = Math.log(@doc_count.to_f / (1 + df))
        end

        self
      end

      def extract(text)
        validate_text!(text)
        return [] if text.nil? || text.strip.empty?

        words = TextProcessing::Tokenizer.tokenize(text)
        return [] if words.empty?

        tf = Hash.new(0)
        words.each { |w| tf[w] += 1 }

        total = words.size.to_f

        # When no corpus has been fitted, use TF-only (IDF=1 for all terms)
        scored = tf.map do |word, count|
          next if stop_word?(word) || word.length < @min_word_length

          tf_score = count / total
          idf_score = if @idf
                        @idf[word] || Math.log((@doc_count + 1).to_f / 1)
                      else
                        1.0
                      end
          score = tf_score * idf_score

          Keyword.new(phrase: word, score: score)
        end.compact

        results = scored.sort.first(@top_n)
        normalize_scores(results)
      end
    end
  end
end
