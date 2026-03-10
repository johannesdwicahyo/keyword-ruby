# frozen_string_literal: true

require_relative "test_helper"

class TestTfidf < Minitest::Test
  def test_extract_with_corpus
    corpus = [
      "The cat sat on the mat",
      "The dog chased the cat",
      "Birds fly in the sky"
    ]

    extractor = KeywordRuby::Extractors::Tfidf.new(language: :en)
    extractor.fit(corpus)

    keywords = extractor.extract("The cat sat on the mat and played")
    assert keywords.is_a?(Array)
    assert keywords.any?
  end

  def test_extract_without_corpus_has_nonzero_scores
    extractor = KeywordRuby::Extractors::Tfidf.new(language: :en, normalize: false)
    keywords = extractor.extract("Machine learning is a field of artificial intelligence")
    assert keywords.is_a?(Array)
    refute_empty keywords
    keywords.each do |kw|
      assert kw.score > 0, "Expected non-zero score for '#{kw.phrase}', got #{kw.score}"
    end
  end

  def test_extract_without_corpus_tf_only
    # Without corpus, all IDF=1.0 so scores equal TF values
    extractor = KeywordRuby::Extractors::Tfidf.new(language: :en, normalize: false)
    keywords = extractor.extract("ruby ruby python java")

    # "ruby" appears 2/4 times = 0.5, others 1/4 = 0.25
    ruby_kw = keywords.find { |k| k.phrase == "ruby" }
    refute_nil ruby_kw
    assert_in_delta 0.5, ruby_kw.score, 0.001
  end

  def test_extract_empty
    extractor = KeywordRuby::Extractors::Tfidf.new
    keywords = extractor.extract("")
    assert_equal [], keywords
  end

  def test_extract_nil
    extractor = KeywordRuby::Extractors::Tfidf.new
    keywords = extractor.extract(nil)
    assert_equal [], keywords
  end

  def test_scores_normalized_to_0_1
    corpus = [
      "The cat sat on the mat",
      "The dog chased the cat",
      "Birds fly in the sky"
    ]

    extractor = KeywordRuby::Extractors::Tfidf.new(language: :en, normalize: true)
    extractor.fit(corpus)

    keywords = extractor.extract("The cat sat on the mat and the dog played with birds")
    refute_empty keywords
    keywords.each do |kw|
      assert kw.score >= 0.0, "Score #{kw.score} is below 0.0"
      assert kw.score <= 1.0, "Score #{kw.score} is above 1.0"
    end
  end

  def test_non_string_input_raises
    extractor = KeywordRuby::Extractors::Tfidf.new
    assert_raises(ArgumentError) do
      extractor.extract(42)
    end
  end
end
