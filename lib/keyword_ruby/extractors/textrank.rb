# frozen_string_literal: true

module KeywordRuby
  module Extractors
    class TextRank < Base
      DEFAULT_DAMPING = 0.85
      DEFAULT_ITERATIONS = 30
      DEFAULT_CONVERGENCE = 0.0001

      def initialize(damping: DEFAULT_DAMPING, iterations: DEFAULT_ITERATIONS, **opts)
        super(**opts)
        @damping = damping
        @iterations = iterations
      end

      def extract(text)
        validate_text!(text)
        return [] if text.nil? || text.strip.empty?

        words = TextProcessing::Tokenizer.tokenize(text)
          .reject { |w| stop_word?(w) || w.length < @min_word_length }
        return [] if words.empty?

        # Build co-occurrence graph (window size = 4)
        graph = build_graph(words, window: 4)
        return [] if graph.empty?

        # Run PageRank
        scores = pagerank(graph)

        # Generate multi-word candidates
        all_words = TextProcessing::Tokenizer.tokenize(text)
        candidates = generate_phrases(all_words, scores)

        results = candidates.sort.first(@top_n)
        normalize_scores(results)
      end

      private

      def build_graph(words, window: 4)
        graph = Hash.new { |h, k| h[k] = Hash.new(0.0) }

        words.each_cons(window) do |group|
          group.uniq.combination(2) do |a, b|
            graph[a][b] += 1.0
            graph[b][a] += 1.0
          end
        end

        graph
      end

      def pagerank(graph)
        nodes = graph.keys
        n = nodes.size.to_f
        scores = nodes.map { |node| [node, 1.0 / n] }.to_h

        @iterations.times do
          new_scores = {}
          max_diff = 0.0

          nodes.each do |node|
            rank = (1.0 - @damping) / n
            neighbors = graph[node]

            neighbors.each do |neighbor, weight|
              out_weight = graph[neighbor].values.sum
              rank += @damping * (scores[neighbor] || 0.0) * weight / out_weight if out_weight > 0
            end

            new_scores[node] = rank
            max_diff = [max_diff, (rank - (scores[node] || 0.0)).abs].max
          end

          scores = new_scores
          break if max_diff < DEFAULT_CONVERGENCE
        end

        scores
      end

      def generate_phrases(words, word_scores)
        phrases = {}

        # Single words
        word_scores.each do |word, score|
          phrases[word] = score
        end

        # Multi-word phrases (2-4 words)
        (2..@max_length).each do |n|
          words.each_cons(n) do |gram|
            next if stop_word?(gram.first) || stop_word?(gram.last)
            next if gram.first.length < @min_word_length || gram.last.length < @min_word_length

            phrase = gram.join(" ")
            score = gram.sum { |w| word_scores[w] || 0.0 }
            phrases[phrase] = [phrases[phrase] || 0.0, score].max
          end
        end

        phrases.map { |phrase, score| Keyword.new(phrase: phrase, score: score) }
      end
    end
  end
end
