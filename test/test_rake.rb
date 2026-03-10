# frozen_string_literal: true

require_relative "test_helper"

class TestRake < Minitest::Test
  def setup
    KeywordRuby.reset_configuration!
  end

  def test_extract_english
    text = "Artificial intelligence and machine learning are transforming the technology industry. Deep learning algorithms have achieved remarkable results in natural language processing and computer vision."
    keywords = KeywordRuby.extract(text, algorithm: :rake, language: :en)

    assert keywords.is_a?(Array)
    assert keywords.all? { |k| k.is_a?(KeywordRuby::Keyword) }
    assert keywords.first.score >= keywords.last.score

    phrases = keywords.map(&:phrase)
    assert phrases.any? { |p| p.include?("learning") || p.include?("intelligence") }
  end

  def test_extract_indonesian
    text = "Indonesia adalah negara kepulauan terbesar di dunia. Negara ini memiliki keberagaman budaya yang sangat kaya."
    keywords = KeywordRuby.extract(text, algorithm: :rake, language: :id)

    assert keywords.is_a?(Array)
    assert keywords.any?
  end

  def test_extract_with_top_n
    text = "Natural language processing enables computers to understand human language. Machine learning models are trained on large datasets."
    keywords = KeywordRuby.extract(text, algorithm: :rake, top_n: 3)
    assert keywords.size <= 3
  end

  def test_extract_empty_string
    keywords = KeywordRuby.extract("", algorithm: :rake)
    assert_equal [], keywords
  end

  def test_extract_nil
    keywords = KeywordRuby.extract(nil, algorithm: :rake)
    assert_equal [], keywords
  end

  def test_keyword_to_h
    kw = KeywordRuby::Keyword.new(phrase: "machine learning", score: 4.5)
    hash = kw.to_h
    assert_equal "machine learning", hash[:phrase]
    assert_equal 4.5, hash[:score]
  end

  def test_keyword_to_s
    kw = KeywordRuby::Keyword.new(phrase: "deep learning", score: 9.0)
    assert_equal "deep learning (9.0)", kw.to_s
  end

  def test_degree_calculation_correctness
    # Test the RAKE co-occurrence degree calculation directly.
    # Given phrases: ["word1 word2", "word1 word2 word3"]
    # Co-occurrence matrix (each phrase contributes all pairs including self):
    #   Phrase "word1 word2": word1-word1 +1, word1-word2 +1, word2-word1 +1, word2-word2 +1
    #   Phrase "word1 word2 word3": word1-word1 +1, word1-word2 +1, word1-word3 +1,
    #                                word2-word1 +1, word2-word2 +1, word2-word3 +1,
    #                                word3-word1 +1, word3-word2 +1, word3-word3 +1
    # deg(word1) = cooc[word1][word1]=2 + cooc[word1][word2]=2 + cooc[word1][word3]=1 = 5
    # freq(word1) = 2
    # score(word1) = 5/2 = 2.5
    #
    # deg(word2) = cooc[word2][word1]=2 + cooc[word2][word2]=2 + cooc[word2][word3]=1 = 5
    # freq(word2) = 2
    # score(word2) = 5/2 = 2.5
    #
    # deg(word3) = cooc[word3][word1]=1 + cooc[word3][word2]=1 + cooc[word3][word3]=1 = 3
    # freq(word3) = 1
    # score(word3) = 3/1 = 3.0

    extractor = KeywordRuby::Extractors::Rake.new(language: :en, normalize: false)
    word_scores = extractor.send(:calculate_word_scores, ["word1 word2", "word1 word2 word3"])

    assert_in_delta 2.5, word_scores["word1"], 0.001
    assert_in_delta 2.5, word_scores["word2"], 0.001
    assert_in_delta 3.0, word_scores["word3"], 0.001
  end

  def test_scores_normalized_to_0_1
    text = "Artificial intelligence and machine learning are transforming the technology industry. Deep learning algorithms have achieved remarkable results."
    keywords = KeywordRuby.extract(text, algorithm: :rake, language: :en, normalize: true)

    refute_empty keywords
    keywords.each do |kw|
      assert kw.score >= 0.0, "Score #{kw.score} is below 0.0"
      assert kw.score <= 1.0, "Score #{kw.score} is above 1.0"
    end
  end

  def test_scores_unnormalized
    text = "Artificial intelligence and machine learning are transforming the technology industry. Deep learning algorithms have achieved remarkable results."
    keywords = KeywordRuby.extract(text, algorithm: :rake, language: :en, normalize: false)

    refute_empty keywords
    # Unnormalized RAKE scores can exceed 1.0 for multi-word phrases
    has_above_one = keywords.any? { |kw| kw.score > 1.0 }
    assert has_above_one, "Expected at least one unnormalized RAKE score above 1.0"
  end

  def test_invalid_language_raises
    assert_raises(ArgumentError) do
      KeywordRuby.extract("test", algorithm: :rake, language: :zz)
    end
  end

  def test_invalid_top_n_raises
    assert_raises(ArgumentError) do
      KeywordRuby.extract("test", algorithm: :rake, top_n: -1)
    end
  end

  def test_invalid_algorithm_raises
    assert_raises(ArgumentError) do
      KeywordRuby.extract("test", algorithm: :unknown)
    end
  end

  def test_non_string_input_raises
    assert_raises(ArgumentError) do
      KeywordRuby.extract(123, algorithm: :rake)
    end
  end
end
